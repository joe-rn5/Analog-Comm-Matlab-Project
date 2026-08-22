%% Preprocessing
clear; clc; close all;

Fc = 100e3;    % carrier frequency
Bm = 4000;     % message bandwidth
% Fs = 5*Fc is required so the carrier can be simulated without aliasing

audio_file = 'eric.wav';

[filtered_signal, ~, Fs_audio, ~] = load_and_filter_audio(audio_file, Bm);
[message, Fs] = resample_for_carrier(filtered_signal, Fs_audio, Fc, 5);

%% DSB-SC
[dsb_sc, ~, Fs] = generate_dsb_sc(message, Fs, Fc);
plot_spectrum(dsb_sc, Fs, 'DSB-SC Spectrum', [-1.2*Fc, 1.2*Fc]);

%% Ideal SSB Filtering
% Keep the LSB only as required
ssb_lsb = filter_ssb_ideal(dsb_sc, Fs, Fc, Bm);
plot_spectrum(ssb_lsb, Fs, 'SSB-LSB Spectrum', [-1.2*Fc, 1.2*Fc]);

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

%% Coherent Detection — SNR = 0, 10, 30 dB
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

%% SSB-TC
[dsb_tc, ~, Fs] = generate_dsb_tc(message, Fs, Fc);
ssb_tc_lsb = filter_ssb_ideal(dsb_tc, Fs, Fc, Bm);

% SSB-TC carries the transmitted carrier through the LSB filter, so the
% message can be recovered with an envelope detector instead of coherent
% detection
demod_tc = envelope_detector(ssb_tc_lsb);

figure;
plot((0:length(demod_tc)-1)/Fs, demod_tc); grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('SSB-TC Envelope Detection');

demod_tc_audio = downsample_for_audio(demod_tc, Fs, Fs_audio);
sound(demod_tc_audio, Fs_audio);
pause(length(demod_tc_audio)/Fs_audio + 1);


function y = downsample_for_audio(x, Fs_from, Fs_to)
    [P, Q] = rat(Fs_to / Fs_from);
    y = resample(x, P, Q);
end
