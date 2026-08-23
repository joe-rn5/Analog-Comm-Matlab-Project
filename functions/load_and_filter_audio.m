function [filtered_signal, original_signal, Fs, t] = load_and_filter_audio(filepath, cutoff_freq)
% LOAD_AND_FILTER_AUDIO  Read an audio file and remove all frequency
% content above cutoff_freq using an IDEAL (brick-wall) lowpass filter.
%
%   [filtered_signal, original_signal, Fs, t] = ...
%       load_and_filter_audio(filepath, cutoff_freq)
%
%   INPUTS
%       filepath    - path to the audio file (e.g. 'message.wav')
%       cutoff_freq - ideal LPF cutoff in Hz (Experiment spec: 4000)
%
%   OUTPUTS
%       filtered_signal - band-limited signal in the time domain (real)
%       original_signal - the raw signal exactly as read from the file
%       Fs              - sampling frequency of the audio file (Hz)
%       t               - time vector matching original_signal / filtered_signal
%
%   METHOD
%       1) audioread the file
%       2) fft + fftshift to view/operate on the two-sided spectrum
%       3) zero out every bin whose |frequency| > cutoff_freq (ideal filter)
%       4) ifftshift + ifft back to the time domain
%
%   NOTE: This is intentionally NOT done with a built-in filter design
%   function (e.g. designfilt/lowpass) because the assignment explicitly
%   asks for an IDEAL filter implemented via the FFT masking approach.

    % ---- 1) Read the audio file -------------------------------------
    [original_signal, Fs] = audioread(filepath);

    % If stereo, keep only one channel for simplicity (mono processing)
    if size(original_signal, 2) > 1
        original_signal = original_signal(:, 1);
    end
    original_signal = original_signal(:);          % force column vector

    N = length(original_signal);
    t = (0:N-1).' / Fs;

    % ---- 2) Spectrum of the original signal --------------------------
    X = fftshift(fft(original_signal));
    f = (-N/2 : N/2 - 1).' * (Fs / N);              % frequency axis (Hz)

    % ---- 3) Ideal brick-wall lowpass mask -----------------------------
    mask = abs(f) <= cutoff_freq;
    X_filtered = X .* mask;

    % ---- 4) Back to the time domain -----------------------------------
    filtered_signal = real(ifft(ifftshift(X_filtered)));

    fprintf('load_and_filter_audio: Fs = %d Hz, N = %d samples, cutoff = %d Hz\n', ...
            Fs, N, cutoff_freq);
end
