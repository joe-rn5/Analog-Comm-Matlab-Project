clear; clc; close all;

%% ---- Parameters ------------------------------------------------------
audio_file  = 'eric.wav';
cutoff_freq = 4000;
Fc          = 100e3;
oversample  = 5;
kf          = 2000;  % Tuned for NBFM condition

%% ---- Step 1: Preprocessing -------------------------------------------
[filtered_signal, ~, Fs_audio, ~] = load_and_filter_audio(audio_file, cutoff_freq);
[message, Fs_mod] = resample_for_carrier(filtered_signal, Fs_audio, Fc, oversample);

% FIX: Normalize message
message = message / max(abs(message));

%% ---- Step 2: Generate NBFM -------------------------------------------
[nbfm_signal, t_mod, ~] = generate_nbfm(message, Fs_mod, Fc, kf);
plot_spectrum(nbfm_signal, Fs_mod, 'NBFM Spectrum', [-1.2*Fc, 1.2*Fc]);

%% ---- Step 3: Demodulate ----------------------------------------------
rx = nbfm_demodulator(nbfm_signal, Fs_mod);

figure;
plot(t_mod(1:length(rx)), rx);
title('NBFM Demodulated Signal'); xlabel('t (s)'); ylabel('Amplitude');

rx_audio = downsample_for_audio(rx, Fs_mod, Fs_audio);
sound(rx_audio, Fs_audio);
pause(length(rx_audio)/Fs_audio + 1);

%% ---- Step 4: Test with Different SNR Values --------------------------
for snr_db = [0, 10, 30]
    noisy_nbfm = awgn(nbfm_signal, snr_db, 'measured');
    rx_noisy = nbfm_demodulator(noisy_nbfm, Fs_mod);
    
    figure;
    plot(t_mod(1:length(rx_noisy)), rx_noisy);
    title(sprintf('NBFM Demodulated - SNR = %d dB', snr_db));
    xlabel('t (s)'); ylabel('Amplitude');
    
    rx_audio = downsample_for_audio(rx_noisy, Fs_mod, Fs_audio);
    sound(rx_audio, Fs_audio);
    pause(length(rx_audio)/Fs_audio + 1);
end

disp('main_exp3_fm.m complete.');