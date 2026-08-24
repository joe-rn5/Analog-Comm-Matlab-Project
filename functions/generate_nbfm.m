function [nbfm_signal, t, Fs] = generate_nbfm(message, Fs, Fc, kf)
% GENERATE_NBFM Generate narrowband FM signal
%
%   [nbfm_signal, t, Fs] = generate_nbfm(message, Fs, Fc, kf)

    message = message(:);
    N = length(message);
    t = (0:N-1).' / Fs;

    % Remove DC before integration to prevent phase drift
    message_ac = message - mean(message);

    % Integrate message using cumsum
    phase_dev = 2*pi * kf * cumsum(message_ac) / Fs;

    % Check narrowband condition
    peak_phase_dev = max(abs(phase_dev));
    fprintf('Peak phase deviation: %.4f rad\n', peak_phase_dev);
    if peak_phase_dev > 0.5
        fprintf('WARNING: Not narrowband! Should be << 1 rad\n');
    end

    % Generate FM signal
    nbfm_signal = cos(2*pi*Fc*t + phase_dev);
end