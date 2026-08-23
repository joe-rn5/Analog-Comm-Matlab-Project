%% Preprocessing
clear; clc; close all;

Fc = 100e3;
Bm = 4000;
audio_file = 'eric.wav';

[filtered_signal, ~, Fs_audio, ~] = load_and_filter_audio(audio_file, Bm);
[message, Fs] = resample_for_carrier(filtered_signal, Fs_audio, Fc, 5);

% FIX: Normalize message
message = message / max(abs(message));

%% DSB-SC
[dsb_sc, ~, Fs] = generate_dsb_sc(message, Fs, Fc);
plot_spectrum(dsb_sc, Fs, 'DSB-SC Spectrum', [-1.2*Fc, 1.2*Fc]);

%% Ideal SSB Filtering
ssb_lsb = filter_ssb_ideal(dsb_sc, Fs, Fc, Bm);
plot_spectrum(ssb_lsb, Fs, 'SSB-LSB Spectrum (Ideal)', [-1.2*Fc, 1.2*Fc]);

%% Coherent Detection (no noise)
demod = coherent_detector(ssb_lsb, Fc, Fs);

figure;
plot((0:length(demod)-1)/Fs, demod); grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('Coherent Detection — No Noise');
plot_spectrum(demod, Fs, 'Coherent Detection Spectrum — No Noise', [-2*Bm, 2*Bm]);

demod_audio = downsample_for_audio(demod, Fs, Fs_audio);
sound(demod_audio, Fs_audio);
pause(length(demod_audio)/Fs_audio + 1);

%% Coherent Detection with SNR
for snr_db = [0, 10, 30]
    demod = coherent_detector(ssb_lsb, Fc, Fs, 'SNR_dB', snr_db);

    figure;
    plot((0:length(demod)-1)/Fs, demod); grid on;
    xlabel('Time (s)'); ylabel('Amplitude');
    title(sprintf('Coherent Detection — SNR = %d dB', snr_db));
    plot_spectrum(demod, Fs, sprintf('Coherent Detection Spectrum — SNR = %d dB', snr_db), [-2*Bm, 2*Bm]);

    demod_audio = downsample_for_audio(demod, Fs, Fs_audio);
    sound(demod_audio, Fs_audio);
    pause(length(demod_audio)/Fs_audio + 1);
end

%% Butterworth Filter (Practical)
ssb_lsb_butter = filter_ssb_butter(dsb_sc, Fs, Fc, Bm);
plot_spectrum(ssb_lsb_butter, Fs, 'SSB-LSB Spectrum (Butterworth)', [-1.2*Fc, 1.2*Fc]);

demod_butter = coherent_detector(ssb_lsb_butter, Fc, Fs);
demod_butter_audio = downsample_for_audio(demod_butter, Fs, Fs_audio);
sound(demod_butter_audio, Fs_audio);
pause(length(demod_butter_audio)/Fs_audio + 1);

%% SSB-TC
[dsb_tc, ~, Fs] = generate_dsb_tc(message, Fs, Fc);
ssb_tc_lsb = filter_ssb_ideal(dsb_tc, Fs, Fc, Bm);

demod_tc = envelope_detector(ssb_tc_lsb);

figure;
plot((0:length(demod_tc)-1)/Fs, demod_tc); grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('SSB-TC Envelope Detection');

demod_tc_audio = downsample_for_audio(demod_tc, Fs, Fs_audio);
sound(demod_tc_audio, Fs_audio);

disp('main_exp2_ssb.m complete.');