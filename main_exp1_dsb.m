clear; clc; close all;

%% ---- Parameters ------------------------------------------------------
audio_file  = 'eric.wav';
cutoff_freq = 4000;
Fc          = 100e3;
oversample  = 5;

%% ---- Step 1: Preprocessing -------------------------------------------
[filtered_signal, original_signal, Fs, t] = ...
    load_and_filter_audio(audio_file, cutoff_freq);

[message, Fs_mod] = resample_for_carrier(filtered_signal, Fs, Fc, oversample);

% Normalize message
message = message / max(abs(message));

%% ---- Step 2: DSB Generation ------------------------------------------
[dsb_tc, t_mod, ~] = generate_dsb_tc(message, Fs_mod, Fc);
[dsb_sc, ~, ~] = generate_dsb_sc(message, Fs_mod, Fc);

plot_spectrum(dsb_tc, Fs_mod, 'DSB-TC Spectrum', [-2*Fc, 2*Fc]);
plot_spectrum(dsb_sc, Fs_mod, 'DSB-SC Spectrum', [-2*Fc, 2*Fc]);

%% ---- Step 3: Envelope Detection --------------------------------------
env_tc = envelope_detector(dsb_tc);
env_sc = envelope_detector(dsb_sc);

figure;
subplot(2,1,1);
plot(t_mod, env_tc);
title('Envelope Detector Output - DSB-TC');
xlabel('t (s)');
subplot(2,1,2);
plot(t_mod, env_sc);
title('Envelope Detector Output - DSB-SC (expect distortion)');
xlabel('t (s)');

% Play DSB-TC
env_tc_audio = downsample_for_audio(env_tc, Fs_mod, Fs);
sound(env_tc_audio, Fs);
pause(length(env_tc_audio)/Fs + 1);

% Play DSB-SC (should be distorted)
env_sc_audio = downsample_for_audio(env_sc, Fs_mod, Fs);
sound(env_sc_audio, Fs);
pause(length(env_sc_audio)/Fs + 1);

%% ---- Step 4: Coherent Detection with SNR (NEW SIGNATURE: Fs, Fc) ----
for snr = [0, 10, 30]
    rx = coherent_detector(dsb_sc, Fs_mod, Fc, 'SNR_dB', snr);

    figure;
    plot(rx);
    title(sprintf('Coherent Detection - SNR = %d dB', snr));
    xlabel('Sample'); ylabel('Amplitude');

    plot_spectrum(rx, Fs_mod, sprintf('Received Spectrum - SNR = %d dB', snr), [-5000, 5000]);

    rx_audio = downsample_for_audio(rx, Fs_mod, Fs);
    sound(rx_audio, Fs);
    pause(length(rx_audio)/Fs + 1);
end

%% ---- Step 5: Frequency Error (100.1 kHz) ----------------------------
rx_freqerr = coherent_detector(dsb_sc, Fs_mod, Fc, 'FreqOffset', 100);

figure;
plot(rx_freqerr);
title('Coherent Detection - Frequency Error (100.1 kHz LO)');
xlabel('Sample'); ylabel('Amplitude');

% Compare with clean detection
rx_clean = coherent_detector(dsb_sc, Fs_mod, Fc);
err_signal = rx_clean - rx_freqerr;

figure;
plot(t_mod, err_signal);
title('Error Signal: Clean Detection vs. 100.1 kHz LO Mismatch');
xlabel('t (s)'); ylabel('Amplitude');

fprintf('RMS error from 100 Hz frequency offset: %.4f\n', rms(err_signal));

%% ---- Step 6: Phase Error (20 degrees) --------------------------------
rx_phaseerr = coherent_detector(dsb_sc, Fs_mod, Fc, 'PhaseOffset', 20);

figure;
plot(rx_phaseerr);
title('Coherent Detection - Phase Error (20 deg)');
xlabel('Sample'); ylabel('Amplitude');

disp('main_exp1_dsb.m complete.');