%% DEMO_PERSON1_PREPROCESSING
% Quick sanity-check / handoff script for the common preprocessing block.
% Run this once your audio file is in place to confirm everything works
% before Persons 2-5 build their modulation/detection code on top of it.
%
% Replace 'message.wav' below with the actual filename provided for the
% assignment.

clear; clc; close all;

%% ---- Parameters ----------------------------------------------------
project_folder = 'C:\Users\eidsa\Downloads\Analog Project';  % project folder
audio_filename = 'eric.wav';   % <-- update to match the uploaded file's real name
audio_file = audio_filename;      % no Windows path needed in MATLAB Online
cutoff_freq = 4000;            % Hz, ideal LPF cutoff (assignment spec)
Fc          = 100e3;           % Hz, carrier frequency (assignment spec)

% Not sure of the exact filename? Uncomment the lines below to list all
% audio files in the project folder, then update audio_filename above.
% disp(dir(fullfile(project_folder, '*.wav')));
% disp(dir(fullfile(project_folder, '*.mp3')));

%% ---- Step 1: Load + ideal lowpass filter ----------------------------
[filtered_signal, original_signal, Fs, t] = ...
    load_and_filter_audio(audio_file, cutoff_freq);

% Spectrum before filtering
plot_spectrum(original_signal, Fs, 'Original Signal Spectrum');

% Spectrum after filtering (zoomed near baseband to see the cutoff)
plot_spectrum(filtered_signal, Fs, 'Filtered Signal Spectrum (BW = 4 kHz)', ...
              [-10000 10000]);

% Time-domain look at the filtered signal
figure;
plot(t, filtered_signal);
grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('Filtered Signal - Time Domain');

% Listen to confirm only small distortion was introduced
sound(filtered_signal, Fs);
pause(length(filtered_signal)/Fs + 1);  % let playback finish before continuing

%% ---- Step 2: Resample so Fs = 5*Fc for modulation -------------------
[resampled_signal, Fs_new] = resample_for_carrier(filtered_signal, Fs, Fc, 5);

plot_spectrum(resampled_signal, Fs_new, ...
    sprintf('Resampled Signal Spectrum (Fs = %g Hz)', Fs_new));