
clear; clc; close all;

%% ---- Parameters ------------------------------------------------------
audio_file  = 'eric.wav';   % update to match the real assignment file
cutoff_freq = 4000;         % Hz, ideal LPF cutoff (assignment spec)
Fc          = 100e3;        % Hz, carrier frequency (assignment spec)
oversample  = 5;            % Fs = 5*Fc per assignment

%% ---- Step 1: Person 1's preprocessing ---------------------------------
[filtered_signal, original_signal, Fs, t] = ...
    load_and_filter_audio(audio_file, cutoff_freq);

[message, Fs_mod] = resample_for_carrier(filtered_signal, Fs, Fc, oversample);
% message : filtered + resampled signal, ready to modulate
% Fs_mod  : sampling frequency to use for all modulation/detection below (~5*Fc)
% Fs      : original audio rate -- kept around so playback can be
%           downsampled back to it before every sound() call

%% ---- Step 2: Person 2's DSB generation --------------------------------
[dsb_tc, t_mod, ~] = generate_dsb_tc(message, Fs_mod, Fc);
[dsb_sc, ~, ~]      = generate_dsb_sc(message, Fs_mod, Fc);
% t_mod: time vector matching dsb_tc/dsb_sc (length of the resampled message)

plot_spectrum(dsb_tc, Fs_mod, 'DSB-TC Spectrum');
plot_spectrum(dsb_sc, Fs_mod, 'DSB-SC Spectrum');

%% ---- Step 3: Envelope detection (both DSB-TC and DSB-SC) -------------
env_tc = envelope_detector(dsb_tc);
env_sc = envelope_detector(dsb_sc);

figure;
subplot(2,1,1); plot(t_mod, env_tc);
title('Envelope Detector Output - DSB-TC'); xlabel('t (s)');
subplot(2,1,2); plot(t_mod, env_sc);
title('Envelope Detector Output - DSB-SC (expect distortion)'); xlabel('t (s)');

% FIX: sound() can't play at Fs_mod (~500 kHz) -- downsample back to the
% original audio rate first, same pattern main_exp2_ssb.m already uses.
env_tc_audio = downsample_for_audio(env_tc, Fs_mod, Fs);
sound(env_tc_audio, Fs);
pause(length(env_tc_audio)/Fs + 1);

env_sc_audio = downsample_for_audio(env_sc, Fs_mod, Fs);
sound(env_sc_audio, Fs);
pause(length(env_sc_audio)/Fs + 1);
% OBSERVATION (for report, step 7): envelope detection works cleanly for
% DSB-TC because the carrier is transmitted with a DC bias large enough
% to keep (dc_bias + message) always positive, so abs(hilbert(.)) tracks
% the message directly. DSB-SC has no DC bias, so the envelope detector
% cannot distinguish sign changes in the message and the recovered
% signal is distorted (rectified). Envelope detection is therefore only
% suitable for carrier-transmitted schemes (DSB-TC), not DSB-SC.

%% ---- Step 4: Coherent detection of DSB-SC, SNR = 0/10/30 dB ----------
rx_snr0  = coherent_detector(dsb_sc, Fc, Fs_mod, 'SNR_dB', 0);
rx_snr10 = coherent_detector(dsb_sc, Fc, Fs_mod, 'SNR_dB', 10);
rx_snr30 = coherent_detector(dsb_sc, Fc, Fs_mod, 'SNR_dB', 30);

figure;
subplot(3,1,1); plot(rx_snr0);  title('Coherent Detection - SNR = 0 dB');
subplot(3,1,2); plot(rx_snr10); title('Coherent Detection - SNR = 10 dB');
subplot(3,1,3); plot(rx_snr30); title('Coherent Detection - SNR = 30 dB');

plot_spectrum(rx_snr0,  Fs_mod, 'Received Spectrum - SNR = 0 dB');
plot_spectrum(rx_snr10, Fs_mod, 'Received Spectrum - SNR = 10 dB');
plot_spectrum(rx_snr30, Fs_mod, 'Received Spectrum - SNR = 30 dB');

% FIX: same downsample-before-sound pattern as Step 3.
rx_snr0_audio = downsample_for_audio(rx_snr0, Fs_mod, Fs);
sound(rx_snr0_audio, Fs);
pause(length(rx_snr0_audio)/Fs + 1);

rx_snr10_audio = downsample_for_audio(rx_snr10, Fs_mod, Fs);
sound(rx_snr10_audio, Fs);
pause(length(rx_snr10_audio)/Fs + 1);

rx_snr30_audio = downsample_for_audio(rx_snr30, Fs_mod, Fs);
sound(rx_snr30_audio, Fs);
pause(length(rx_snr30_audio)/Fs + 1);

%% ---- Step 5: Coherent detection with frequency error (100.1 kHz) -----
rx_freqerr = coherent_detector(dsb_sc, Fc, Fs_mod, 'FreqOffset', 100);
% NOTE: local oscillator runs at Fc + 100 = 100.1 kHz, matching the
% assignment's required error case.

figure;
plot(rx_freqerr);
title('Coherent Detection - Frequency Error (100.1 kHz LO)');
xlabel('Sample'); ylabel('Amplitude');

% ADDED: assignment step 9 explicitly asks to "find the error" -- compare
% against a clean (zero-offset, no-noise) coherent detection as reference.
rx_clean = coherent_detector(dsb_sc, Fc, Fs_mod);
err_signal = rx_clean - rx_freqerr;

figure;
plot(t_mod, err_signal);
title('Error Signal: Clean Detection vs. 100.1 kHz LO Mismatch');
xlabel('t (s)'); ylabel('Amplitude');

fprintf('RMS error from 100 Hz frequency offset: %.4f\n', rms(err_signal));
% Note for the report: with a frequency-mismatched LO, the recovered
% envelope is modulated by an additional cos(2*pi*FreqOffset*t) term --
% listen to/plot rx_freqerr and identify what this periodic amplitude
% variation is commonly called.

%% ---- Step 6: Coherent detection with phase error (20 deg) ------------
rx_phaseerr = coherent_detector(dsb_sc, Fc, Fs_mod, 'PhaseOffset', 20);

figure;
plot(rx_phaseerr);
title('Coherent Detection - Phase Error (20 deg)');
xlabel('Sample'); ylabel('Amplitude');

disp('main_exp1_dsb.m complete.');
