%% Experiment 3: Narrowband FM (NBFM)
clear; clc; close all;

%% Parameters
audio_file = 'eric.wav';
cutoff_freq = 4000;
Fc = 100e3;
oversample = 5;
kf = 5000;  % Good value for voice

%% Step 1: Preprocessing
fprintf('=== Loading and Preprocessing ===\n');
[filtered_signal, ~, Fs_audio, ~] = load_and_filter_audio(audio_file, cutoff_freq);
[message, Fs_mod] = resample_for_carrier(filtered_signal, Fs_audio, Fc, oversample);
message = message / max(abs(message));
fprintf('Message max: %.4f\n', max(abs(message)));

t = (0:length(message)-1)' / Fs_mod;

%% Step 2: Generate NBFM
fprintf('=== Generating NBFM (kf = %d) ===\n', kf);
[nbfm_signal, ~, ~] = generate_nbfm(message, Fs_mod, Fc, kf);

% Plot NBFM
figure('Name', 'NBFM Generation');
subplot(2,1,1);
plot(t(1:500), nbfm_signal(1:500));
title('NBFM Time Domain');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
N = length(nbfm_signal);
X = fftshift(fft(nbfm_signal));
f = (-N/2:N/2-1)*(Fs_mod/N);
plot(f, abs(X));
xlim([-1.2*Fc, 1.2*Fc]);
title('NBFM Spectrum');
xlabel('Frequency (Hz)'); ylabel('|X(f)|');
grid on;

%% Step 3: Demodulate (No Noise)
fprintf('=== Demodulating NBFM ===\n');
rx = nbfm_demodulator(nbfm_signal, Fs_mod);

% Plot demodulated
figure('Name', 'NBFM Demodulated (No Noise)');
subplot(2,1,1);
plot(t(1:min(500,length(rx))), rx(1:min(500,length(rx))));
title('NBFM Demodulated Signal (No Noise)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
X = fftshift(fft(rx));
f = (-length(rx)/2:length(rx)/2-1)*(Fs_mod/length(rx));
plot(f, abs(X));
xlim([-5000, 5000]);
title('Demodulated Spectrum');
xlabel('Frequency (Hz)'); ylabel('|X(f)|');
grid on;

% Play audio
rx_audio = downsample_for_audio(rx, Fs_mod, Fs_audio);
fprintf('Playing demodulated audio (no noise)...\n');
sound(rx_audio, Fs_audio);
pause(3);

%% Step 4: SNR Testing
fprintf('\n=== SNR Testing ===\n');
for snr_db = [0, 10, 30]
    fprintf('SNR = %d dB...\n', snr_db);

    % Add noise manually
    signal_power = mean(nbfm_signal.^2);
    noise_power = signal_power / (10^(snr_db/10));
    noise = sqrt(noise_power) * randn(size(nbfm_signal));
    noisy_nbfm = nbfm_signal + noise;

    % Demodulate
    rx_noisy = nbfm_demodulator(noisy_nbfm, Fs_mod);

    % Plot
    figure('Name', sprintf('NBFM SNR = %d dB', snr_db));
    subplot(2,1,1);
    plot(t(1:min(500,length(rx_noisy))), rx_noisy(1:min(500,length(rx_noisy))));
    title(sprintf('NBFM Demodulated - SNR = %d dB', snr_db));
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;

    subplot(2,1,2);
    X = fftshift(fft(rx_noisy));
    f = (-length(rx_noisy)/2:length(rx_noisy)/2-1)*(Fs_mod/length(rx_noisy));
    plot(f, abs(X));
    xlim([-5000, 5000]);
    title(sprintf('Spectrum - SNR = %d dB', snr_db));
    xlabel('Frequency (Hz)'); ylabel('|X(f)|');
    grid on;

    % Play
    rx_audio = downsample_for_audio(rx_noisy, Fs_mod, Fs_audio);
    sound(rx_audio, Fs_audio);
    pause(3);
end

%% Step 5: Compare Different kf Values
fprintf('\n=== Comparing kf Values ===\n');
kf_values = [1000, 3000, 5000, 8000];

for i = 1:length(kf_values)
    kf_test = kf_values(i);
    fprintf('Testing kf = %d...\n', kf_test);

    [nbfm_test, ~, ~] = generate_nbfm(message, Fs_mod, Fc, kf_test);
    rx_test = nbfm_demodulator(nbfm_test, Fs_mod);

    audio_test = downsample_for_audio(rx_test, Fs_mod, Fs_audio);
    fprintf('Playing kf = %d...\n', kf_test);
    sound(audio_test, Fs_audio);
    pause(2);
end

disp('main_exp3_fm.m complete!');