%% Experiment 3: NBFM
clear; clc; close all;

%% Parameters
audio_file = 'eric.wav';
cutoff_freq = 4000;
Fc = 100e3;
oversample = 5;
kf = 8000;  % Good for voice

%% Step 1: Preprocessing
fprintf('=== Loading Audio ===\n');
[filtered_signal, ~, Fs_audio, ~] = load_and_filter_audio(audio_file, cutoff_freq);
[message, Fs_mod] = resample_for_carrier(filtered_signal, Fs_audio, Fc, oversample);
message = message / max(abs(message));
t = (0:length(message)-1)' / Fs_mod;

%% Step 2: Generate NBFM
fprintf('=== Generating NBFM (kf = %d) ===\n', kf);
[nbfm_signal, ~, ~] = generate_nbfm(message, Fs_mod, Fc, kf);

% Plot NBFM
figure('Name', 'NBFM Signal');
subplot(2,1,1);
plot(t(1:500), nbfm_signal(1:500));
title('NBFM Time Domain');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
N = length(nbfm_signal);
X = fftshift(fft(nbfm_signal));
f = (-floor(N/2):ceil(N/2)-1)' * (Fs_mod/N);
plot(f, abs(X));
xlim([-1.2*Fc, 1.2*Fc]);
title('NBFM Spectrum');
xlabel('Frequency (Hz)'); ylabel('|X(f)|');
grid on;

%% Step 3: Demodulate
fprintf('=== Demodulating ===\n');
rx = nbfm_demodulator(nbfm_signal, Fs_mod);
rx = rx * 4;  % 4x volume boost

% Clip to prevent distortion
rx = max(min(rx, 1), -1);

% Plot
figure('Name', 'Demodulated Signal');
subplot(2,1,1);
plot(t, rx);
title('NBFM Demodulated Signal (4x Boost)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;
ylim([-1.2, 1.2]);

subplot(2,1,2);
X = fftshift(fft(rx));
f = (-floor(length(rx)/2):ceil(length(rx)/2)-1)' * (Fs_mod/length(rx));
plot(f, abs(X));
xlim([-5000, 5000]);
title('Demodulated Spectrum');
xlabel('Frequency (Hz)'); ylabel('|X(f)|');
grid on;

% Play
rx_audio = downsample_for_audio(rx, Fs_mod, Fs_audio);
fprintf('Playing demodulated audio (4x boosted)...\n');
sound(rx_audio, Fs_audio);
pause(length(rx_audio)/Fs_audio + 1);

%% Step 4: SNR Testing
fprintf('\n=== SNR Testing ===\n');
for snr_db = [0, 10, 30, 40]
    fprintf('SNR = %d dB...\n', snr_db);

    signal_power = mean(nbfm_signal.^2);
    noise_power = signal_power / (10^(snr_db/10));
    noise = sqrt(noise_power) * randn(size(nbfm_signal));
    noisy_nbfm = nbfm_signal + noise;

    rx_noisy = nbfm_demodulator(noisy_nbfm, Fs_mod);
    rx_noisy = rx_noisy * 4;  % 4x boost
    rx_noisy = max(min(rx_noisy, 1), -1);

    figure('Name', sprintf('SNR = %d dB', snr_db));
    subplot(2,1,1);
    plot(t, rx_noisy);
    title(sprintf('NBFM Demodulated - SNR = %d dB (4x Boost)', snr_db));
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;
    ylim([-1.2, 1.2]);

    subplot(2,1,2);
    X = fftshift(fft(rx_noisy));
    f = (-floor(length(rx_noisy)/2):ceil(length(rx_noisy)/2)-1)' * (Fs_mod/length(rx_noisy));
    plot(f, abs(X));
    xlim([-5000, 5000]);
    title(sprintf('Spectrum - SNR = %d dB', snr_db));
    xlabel('Frequency (Hz)'); ylabel('|X(f)|');
    grid on;

    rx_audio = downsample_for_audio(rx_noisy, Fs_mod, Fs_audio);
    sound(rx_audio, Fs_audio);
    pause(length(rx_audio)/Fs_audio + 1);
end

disp('main_exp3_fm.m complete!');