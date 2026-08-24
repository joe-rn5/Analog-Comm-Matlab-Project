%% SSB Experiment - Complete Working Version
clear; clc; close all;

Fc = 100e3;
Bm = 4000;
audio_file = 'eric.wav';

% ----- Step 1-3: Load, Filter, Resample -----
fprintf('=== Loading and Preprocessing ===\n');
[filtered_signal, original_signal, Fs_audio, t_audio] = load_and_filter_audio(audio_file, Bm);
[message, Fs] = resample_for_carrier(filtered_signal, Fs_audio, Fc, 5);

% Normalize
message = message / max(abs(message));
fprintf('Message: max=%.6f\n', max(abs(message)));

% ----- Step 4: DSB-SC Generation -----
fprintf('=== Generating DSB-SC ===\n');
[dsb_sc, t, Fs] = generate_dsb_sc(message, Fs, Fc);
fprintf('DSB-SC: max=%.6f\n', max(abs(dsb_sc)));

% PLOT DSB-SC
figure('Name', 'DSB-SC');
subplot(2,1,1);
plot(t(1:200), dsb_sc(1:200));
title('DSB-SC Time Domain (First 200 samples)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
N = length(dsb_sc);
X = fftshift(fft(dsb_sc));
f = (-floor(N/2):ceil(N/2)-1)' * (Fs/N);
plot(f, abs(X));
xlim([-1.2*Fc, 1.2*Fc]);
grid on;
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
title('DSB-SC Spectrum');

% ----- Step 5: Ideal SSB Filtering -----
fprintf('=== Extracting LSB (Ideal Filter) ===\n');
ssb_lsb = filter_ssb_ideal(dsb_sc, Fs, Fc, Bm);
fprintf('SSB-LSB (Ideal): max=%.6f\n', max(abs(ssb_lsb)));

% PLOT SSB-LSB (Ideal)
figure('Name', 'SSB-LSB (Ideal)');
subplot(2,1,1);
plot(t(1:200), ssb_lsb(1:200));
title('SSB-LSB Time Domain (Ideal Filter)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
X = fftshift(fft(ssb_lsb));
f = (-floor(N/2):ceil(N/2)-1)' * (Fs/N);
plot(f, abs(X));
xlim([-1.2*Fc, 1.2*Fc]);
grid on;
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
title('SSB-LSB Spectrum (Ideal)');

% ----- Step 6: Coherent Detection (No Noise) - NEW SIGNATURE -----
fprintf('=== Coherent Detection (No Noise) ===\n');
demod = coherent_detector(ssb_lsb, Fs, Fc);
fprintf('Demodulated: max=%.6f\n', max(abs(demod)));

% PLOT Demodulated
figure('Name', 'Coherent Detection - No Noise');
subplot(2,1,1);
plot((0:length(demod)-1)/Fs, demod);
title('Coherent Detection — No Noise');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
X = fftshift(fft(demod));
f = (-floor(length(demod)/2):ceil(length(demod)/2)-1)' * (Fs/length(demod));
plot(f, abs(X));
xlim([-2*Bm, 2*Bm]);
grid on;
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
title('Baseband Spectrum');

% Play audio - computed pause
demod_audio = downsample_for_audio(demod, Fs, Fs_audio);
fprintf('Playing demodulated audio (no noise)...\n');
sound(demod_audio, Fs_audio);
pause(length(demod_audio)/Fs_audio + 1);

% ----- Step 7: Butterworth Filter (PRACTICAL) -----
fprintf('=== Extracting LSB (Butterworth Filter) ===\n');
ssb_butter = filter_ssb_butter(dsb_sc, Fs, Fc, Bm);
fprintf('SSB-Butterworth: max=%.6f\n', max(abs(ssb_butter)));

% PLOT SSB-LSB (Butterworth)
figure('Name', 'SSB-LSB (Butterworth)');
subplot(2,1,1);
plot(t(1:200), ssb_butter(1:200));
title('SSB-LSB Time Domain (Butterworth - Practical)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
X = fftshift(fft(ssb_butter));
f = (-floor(N/2):ceil(N/2)-1)' * (Fs/N);
plot(f, abs(X));
xlim([-1.2*Fc, 1.2*Fc]);
grid on;
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
title('SSB-LSB Spectrum (Butterworth)');

% Demodulate Butterworth
demod_butter = coherent_detector(ssb_butter, Fs, Fc);
demod_butter_audio = downsample_for_audio(demod_butter, Fs, Fs_audio);
fprintf('Playing Butterworth demodulated audio...\n');
sound(demod_butter_audio, Fs_audio);
pause(length(demod_butter_audio)/Fs_audio + 1);

% ----- Step 8: SNR Testing (Manual Noise) -----
fprintf('=== SNR Testing ===\n');
for snr_db = [0, 10, 30]
    fprintf('Testing SNR = %d dB...\n', snr_db);

    % Manual noise addition
    signal_power = mean(ssb_lsb.^2);
    snr_linear = 10^(snr_db/10);
    noise_power = signal_power / snr_linear;
    noise = sqrt(noise_power) * randn(size(ssb_lsb));
    noisy_ssb = ssb_lsb + noise;

    demod_noisy = coherent_detector(noisy_ssb, Fs, Fc);

    figure('Name', sprintf('SNR = %d dB', snr_db));
    subplot(2,1,1);
    plot((0:length(demod_noisy)-1)/Fs, demod_noisy);
    title(sprintf('Coherent Detection — SNR = %d dB', snr_db));
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;

    subplot(2,1,2);
    X = fftshift(fft(demod_noisy));
    f = (-floor(length(demod_noisy)/2):ceil(length(demod_noisy)/2)-1)' * (Fs/length(demod_noisy));
    plot(f, abs(X));
    xlim([-2*Bm, 2*Bm]);
    grid on;
    xlabel('Frequency (Hz)');
    ylabel('|X(f)|');
    title(sprintf('Spectrum — SNR = %d dB', snr_db));

    demod_audio = downsample_for_audio(demod_noisy, Fs, Fs_audio);
    sound(demod_audio, Fs_audio);
    pause(length(demod_audio)/Fs_audio + 1);
end

% ----- Step 9: SSB-TC -----
fprintf('=== SSB-TC with Envelope Detection ===\n');
[dsb_tc, ~, ~] = generate_dsb_tc(message, Fs, Fc);
ssb_tc = filter_ssb_ideal(dsb_tc, Fs, Fc, Bm);
demod_tc = envelope_detector(ssb_tc);

figure('Name', 'SSB-TC Envelope Detection');
subplot(2,1,1);
plot((0:length(demod_tc)-1)/Fs, demod_tc);
title('SSB-TC Envelope Detection');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
X = fftshift(fft(demod_tc));
f = (-floor(length(demod_tc)/2):ceil(length(demod_tc)/2)-1)' * (Fs/length(demod_tc));
plot(f, abs(X));
xlim([-2*Bm, 2*Bm]);
grid on;
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
title('SSB-TC Demodulated Spectrum');

demod_tc_audio = downsample_for_audio(demod_tc, Fs, Fs_audio);
fprintf('Playing SSB-TC demodulated audio...\n');
sound(demod_tc_audio, Fs_audio);
pause(length(demod_tc_audio)/Fs_audio + 1);

disp('main_exp2_ssb.m complete!');