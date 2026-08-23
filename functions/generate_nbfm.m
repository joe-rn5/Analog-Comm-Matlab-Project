function [nbfm_signal, t, Fs] = generate_nbfm(message, Fs, Fc, kf)
% GENERATE_NBFM - Generate NBFM signal

    message = message(:);
    N = length(message);
    t = (0:N-1).' / Fs;

    % Integrate message (phase modulation)
    phase_integral = cumsum(message) / Fs;

    % Calculate phase deviation
    phase_dev = 2*pi * kf * phase_integral;

    % Check NBFM condition
    peak_phase = max(abs(phase_dev));
    fprintf('Peak phase deviation: %.4f rad\n', peak_phase);
    if peak_phase > 0.5
        fprintf('WARNING: Not narrowband! Should be << 1 rad\n');
    end

    % Generate NBFM
    nbfm_signal = cos(2*pi*Fc*t + phase_dev);
end