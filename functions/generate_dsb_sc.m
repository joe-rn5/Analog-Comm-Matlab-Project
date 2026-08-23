function [dsb_sc, t, Fs] = generate_dsb_sc(message, Fs, Fc)
% GENERATE_DSB_SC Generate a double-sideband suppressed-carrier signal.
%
% Inputs:
%   message - filtered and resampled message signal
%   Fs      - sampling frequency in Hz
%   Fc      - carrier frequency in Hz
%
% Outputs:
%   dsb_sc  - DSB-SC modulated signal
%   t       - time vector
%   Fs      - sampling frequency (returned for convenient project handoff)

    message = message(:);
    N = length(message);

    % Time vector corresponding to the resampled message
    t = (0:N-1).' / Fs;

    % Carrier used for modulation
    carrier = cos(2*pi*Fc*t);

    % DSB-SC: multiply the message directly by the carrier.
    % There is no separate transmitted carrier term.
    dsb_sc = message .* carrier;
end
