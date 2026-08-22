function [dsb_tc, t, Fs] = generate_dsb_tc(message, Fs, Fc)
% GENERATE_DSB_TC Generate a double-sideband transmitted-carrier signal.
%
% Inputs:
%   message - filtered and resampled message signal
%   Fs      - sampling frequency in Hz
%   Fc      - carrier frequency in Hz
%
% Outputs:
%   dsb_tc  - DSB-TC modulated signal
%   t       - time vector
%   Fs      - sampling frequency (returned for convenient project handoff)

    message = message(:);
    N = length(message);

    % Time vector corresponding to the resampled message
    t = (0:N-1).' / Fs;

    % Carrier used for modulation
    carrier = cos(2*pi*Fc*t);

    % The assignment requires the DC bias to be twice the message peak.
    % Therefore the modulation index is Am/(2*Am) = 0.5.
    message_peak = max(abs(message));
    dc_bias = 2 * message_peak;

    % DSB-TC: add the DC bias before multiplying by the carrier.
    dsb_tc = (dc_bias + message) .* carrier;
end
