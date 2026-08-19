function [f, X] = plot_spectrum(signal, Fs, title_str, freq_range)
% PLOT_SPECTRUM  Compute and plot the (two-sided) magnitude spectrum of a
% time-domain signal. Shared utility used across all three experiments
% so every plot in the report looks consistent.
%
%   plot_spectrum(signal, Fs)
%   plot_spectrum(signal, Fs, title_str)
%   plot_spectrum(signal, Fs, title_str, freq_range)
%   [f, X] = plot_spectrum(...)
%
%   INPUTS
%       signal     - time-domain signal (vector)
%       Fs         - sampling frequency (Hz)
%       title_str  - optional plot title (default: 'Magnitude Spectrum')
%       freq_range - optional [fmin fmax] in Hz to zoom the x-axis
%                    (default: full Nyquist range, i.e. no zoom)
%
%   OUTPUTS (optional, useful if a caller wants the raw data too)
%       f - frequency axis (Hz)
%       X - fftshifted spectrum (complex)

    if nargin < 3 || isempty(title_str)
        title_str = 'Magnitude Spectrum';
    end

    signal = signal(:);
    N = length(signal);

    X = fftshift(fft(signal));
    f = (-N/2 : N/2 - 1).' * (Fs / N);

    figure;
    plot(f, abs(X));
    grid on;
    xlabel('Frequency (Hz)');
    ylabel('|X(f)|');
    title(title_str);

    if nargin >= 4 && ~isempty(freq_range)
        xlim(freq_range);
    end
end
