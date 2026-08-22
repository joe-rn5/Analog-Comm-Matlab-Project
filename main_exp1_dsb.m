

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

sound(env_tc, Fs_mod);
pause(length(env_tc)/Fs_mod + 1);
sound(env_sc, Fs_mod);
pause(length(env_sc)/Fs_mod + 1);
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

sound(rx_snr0, Fs_mod);
pause(length(rx_snr0)/Fs_mod + 1);
sound(rx_snr10, Fs_mod);
pause(length(rx_snr10)/Fs_mod + 1);
sound(rx_snr30, Fs_mod);
pause(length(rx_snr30)/Fs_mod + 1);

%% ---- Step 5: Coherent detection with frequency error (100.1 kHz) -----
rx_freqerr = coherent_detector(dsb_sc, Fc, Fs_mod, 'FreqOffset', 100);
% NOTE: local oscillator runs at Fc + 100 = 100.1 kHz, matching the
% assignment's required error case.

figure;
plot(rx_freqerr);
title('Coherent Detection - Frequency Error (100.1 kHz LO)');
xlabel('Sample'); ylabel('Amplitude');

%% ---- Step 6: Coherent detection with phase error (20 deg) ------------
rx_phaseerr = coherent_detector(dsb_sc, Fc, Fs_mod, 'PhaseOffset', 20);

figure;
plot(rx_phaseerr);
title('Coherent Detection - Phase Error (20 deg)');
xlabel('Sample'); ylabel('Amplitude');

disp('main_exp1_dsb.m complete.');
