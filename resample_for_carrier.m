function [resampled_signal, Fs_new] = resample_for_carrier(signal, Fs_old, Fc, oversample_factor)
% RESAMPLE_FOR_CARRIER  Resample a baseband signal so it can be modulated
% onto a carrier of frequency Fc without violating the sampling theorem.
%
%   [resampled_signal, Fs_new] = resample_for_carrier(signal, Fs_old, Fc)
%   [resampled_signal, Fs_new] = resample_for_carrier(signal, Fs_old, Fc, oversample_factor)
%
%   INPUTS
%       signal            - band-limited time-domain signal (e.g. output
%                            of load_and_filter_audio)
%       Fs_old             - original sampling frequency of "signal" (Hz)
%       Fc                 - carrier frequency to be used later (Hz)
%       oversample_factor  - optional, default = 5 (assignment spec: Fs = 5*Fc)
%
%   OUTPUTS
%       resampled_signal - signal resampled to Fs_new
%       Fs_new           - new sampling frequency actually achieved (Hz)
%
%   METHOD
%       MATLAB's resample() needs an integer P/Q ratio, so we compute the
%       closest rational approximation of Fs_new/Fs_old using rat().

    if nargin < 4 || isempty(oversample_factor)
        oversample_factor = 5;   % assignment default: Fs = 5*Fc
    end

    Fs_target = oversample_factor * Fc;

    if Fs_target < 2 * Fc
        error('resample_for_carrier:nyquist', ...
              'Target sampling frequency must be at least 2*Fc.');
    end

    % Find integer upsample/downsample factors P/Q ~= Fs_target/Fs_old
    [P, Q] = rat(Fs_target / Fs_old);

    resampled_signal = resample(signal, P, Q);
    Fs_new = Fs_old * P / Q;

    fprintf(['resample_for_carrier: Fs_old = %d Hz -> Fs_new = %g Hz ' ...
             '(target %g Hz, P=%d, Q=%d)\n'], Fs_old, Fs_new, Fs_target, P, Q);
end
