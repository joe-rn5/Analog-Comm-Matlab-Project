%% SSB Experiment - Simplified
clear; clc; close all;

% Parameters
Fc = 100e3;
Bm = 4000;
audio_file = 'eric.wav';

% Step 1: Load and preprocess
fprintf('Loading audio...\n');
[filtered, ~, Fs_audio, ~] = load_and_filter_audio(audio_file, Bm);
[message, Fs] = resample_for_carrier(filtered, Fs_audio, Fc, 5);
message = message / max(abs(message));

% Step 2: Generate DSB-SC
fprintf('Generating DSB-SC...\n');
[dsb_sc, t, ~] = generate_dsb_sc(message, Fs, Fc);

% Plot DSB-SC
figure;
subplot(2,1,1);
plot(t(1:200), dsb_sc(1:200));
title('DSB-SC Time Domain');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
N = length(dsb_sc);
X = fftshift(fft(dsb_sc));
f = (-N/2:N/2-1)*(Fs/N);
plot(f, abs(X));
xlim([-1.2*Fc, 1.2*Fc]);
title('DSB-SC Spectrum');
xlabel('Frequency (Hz)'); ylabel('|X(f)|');
grid on;

% Step 3: SSB Filtering (Ideal)
fprintf('Filtering SSB...\n');
ssb = filter_ssb_ideal(dsb_sc, Fs, Fc, Bm);

% Plot SSB
figure;
subplot(2,1,1);
plot(t(1:200), ssb(1:200));
title('SSB-LSB Time Domain');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
X = fftshift(fft(ssb));
f = (-N/2:N/2-1)*(Fs/N);
plot(f, abs(X));
xlim([-1.2*Fc, 1.2*Fc]);
title('SSB-LSB Spectrum');
xlabel('Frequency (Hz)'); ylabel('|X(f)|');
grid on;

% Step 4: Coherent Detection (No Noise)
fprintf('Demodulating...\n');
demod = coherent_detector(ssb, Fc, Fs);

% Plot demodulated
figure;
subplot(2,1,1);
plot((0:length(demod)-1)/Fs, demod);
title('Demodulated Signal (No Noise)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
X = fftshift(fft(demod));
f = (-length(demod)/2:length(demod)/2-1)*(Fs/length(demod));
plot(f, abs(X));
xlim([-2*Bm, 2*Bm]);
title('Demodulated Spectrum');
xlabel('Frequency (Hz)'); ylabel('|X(f)|');
grid on;

% Play audio
demod_audio = downsample_for_audio(demod, Fs, Fs_audio);
sound(demod_audio, Fs_audio);
pause(3);

% Step 5: SNR Testing (0, 10, 30 dB)
fprintf('Testing SNR...\n');
for snr = [0, 10, 30]
    % Add noise manually
    signal_power = mean(ssb.^2);
    noise_power = signal_power / (10^(snr/10));
    noise = sqrt(noise_power) * randn(size(ssb));
    noisy = ssb + noise;

    % Demodulate
    demod_noisy = coherent_detector(noisy, Fc, Fs);

    % Plot
    figure;
    subplot(2,1,1);
    plot((0:length(demod_noisy)-1)/Fs, demod_noisy);
    title(sprintf('Demodulated (SNR = %d dB)', snr));
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;

    subplot(2,1,2);
    X = fftshift(fft(demod_noisy));
    f = (-length(demod_noisy)/2:length(demod_noisy)/2-1)*(Fs/length(demod_noisy));
    plot(f, abs(X));
    xlim([-2*Bm, 2*Bm]);
    title(sprintf('Spectrum (SNR = %d dB)', snr));
    xlabel('Frequency (Hz)'); ylabel('|X(f)|');
    grid on;

    % Play
    audio = downsample_for_audio(demod_noisy, Fs, Fs_audio);
    sound(audio, Fs_audio);
    pause(3);
end

% Step 6: SSB-TC with Envelope Detection
fprintf('SSB-TC...\n');
[dsb_tc, ~, ~] = generate_dsb_tc(message, Fs, Fc);
ssb_tc = filter_ssb_ideal(dsb_tc, Fs, Fc, Bm);
demod_tc = envelope_detector(ssb_tc);

% Plot SSB-TC
figure;
subplot(2,1,1);
plot((0:length(demod_tc)-1)/Fs, demod_tc);
title('SSB-TC Envelope Detection');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
X = fftshift(fft(demod_tc));
f = (-length(demod_tc)/2:length(demod_tc)/2-1)*(Fs/length(demod_tc));
plot(f, abs(X));
xlim([-2*Bm, 2*Bm]);
title('SSB-TC Spectrum');
xlabel('Frequency (Hz)'); ylabel('|X(f)|');
grid on;

% Play
tc_audio = downsample_for_audio(demod_tc, Fs, Fs_audio);
sound(tc_audio, Fs_audio);

fprintf('Done!\n');