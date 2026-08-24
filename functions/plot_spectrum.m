function [f, X] = plot_spectrum(signal, Fs, title_str, freq_range, use_db)
    if nargin < 3 || isempty(title_str), title_str = 'Magnitude Spectrum'; end
    if nargin < 5 || isempty(use_db), use_db = false; end

    signal = signal(:);
    N = length(signal);
    X = fftshift(fft(signal));
    f = (-N/2 : N/2 - 1).' * (Fs / N);

    figure;
    if use_db
        mag_db = 20*log10(abs(X) / max(abs(X)) + eps);
        plot(f, mag_db);
        ylabel('|X(f)| (dB, normalized)');
        ylim([-100 5]);
    else
        plot(f, abs(X));
        ylabel('|X(f)|');
    end
    grid on;
    xlabel('Frequency (Hz)');
    title(title_str);
    if nargin >= 4 && ~isempty(freq_range)
        xlim(freq_range);
    end
end