%% MAIN_EXP3_FM -- Experiment 3: Narrowband FM
% Reuses Person 1's preprocessing exactly as Experiments 1 and 2 do.
% generate_nbfm.m and nbfm_demodulator.m are Person 5's functions --
% this script will error with 'notImplemented' until those are filled in.

clear; clc; close all;

%% ---- Parameters ------------------------------------------------------
audio_file  = 'eric.wav';
cutoff_freq = 4000;     % Hz, ideal LPF cutoff (assignment spec)
Fc          = 100e3;    % Hz, carrier frequency (assignment spec)
oversample  = 5;        % Fs = 5*Fc per assignment
kf          = 1000;     % TODO (Person 5): tune so the narrowband
                         % condition holds -- see generate_nbfm.m

%% ---- Step 1: Preprocessing (Person 1's functions) ---------------------
[filtered_signal, ~, Fs_audio, ~] = load_and_filter_audio(audio_file, cutoff_freq);
[message, Fs_mod] = resample_for_carrier(filtered_signal, Fs_audio, Fc, oversample);

%% ---- Step 2: Generate NBFM (Person 5) ---------------------------------
[nbfm_signal, t_mod, ~] = generate_nbfm(message, Fs_mod, Fc, kf);
plot_spectrum(nbfm_signal, Fs_mod, 'NBFM Spectrum');

%% ---- Step 3: Demodulate (Person 5) ------------------------------------
rx = nbfm_demodulator(nbfm_signal, Fs_mod);

figure;
plot(t_mod(1:length(rx)), rx);
title('NBFM Demodulated Signal'); xlabel('t (s)'); ylabel('Amplitude');

rx_audio = downsample_for_audio(rx, Fs_mod, Fs_audio);
sound(rx_audio, Fs_audio);
pause(length(rx_audio)/Fs_audio + 1);

disp('main_exp3_fm.m complete.');
