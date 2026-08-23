function [nbfm_signal, t, Fs] = generate_nbfm(message, Fs, Fc, kf)
% GENERATE_NBFM Generate narrowband FM signal
%
%   [nbfm_signal, t, Fs] = generate_nbfm(message, Fs, Fc, kf)
%
%   Narrowband condition: peak phase deviation << 1 rad
%   peak_phase_dev = 2*pi*kf*max(abs(message))/Fs

    message = message(:);
    N = length(message);
    t = (0:N-1).' / Fs;

    % Integrate message using cumsum (discrete-time integration)
    % The integral approximation: ∫message dt ≈ cumsum(message)/Fs
    phase_dev = 2*pi * kf * cumsum(message) / Fs;

    % Check narrowband condition
    peak_phase_dev = max(abs(phase_dev));
    if peak_phase_dev >= 0.5  % warn if not narrowband
        warning('generate_nbfm:wideband', ...
            'Peak phase deviation = %.3f rad (NBFM requires << 1 rad)', ...
            peak_phase_dev);
    end

    % Generate FM signal
    nbfm_signal = cos(2*pi*Fc*t + phase_dev);

    % For the report: note that NBFM spectrum resembles AM spectrum
    % because for small phase deviation, cos(ωc t + θ(t)) ≈ cos(ωc t) - θ(t)sin(ωc t)
    % The spectrum shows carrier + sidebands similar to DSB-TC but with
    % quadrature relationship between carrier and sidebands
end