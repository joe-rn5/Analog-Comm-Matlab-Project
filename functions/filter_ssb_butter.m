function ssb_lsb = filter_ssb_butter(dsb_signal, Fs, Fc, Bm, order)
% FILTER_SSB_BUTTER Extract LSB using practical Butterworth filter
%
%   ssb_lsb = filter_ssb_butter(dsb_signal, Fs, Fc, Bm)
%   ssb_lsb = filter_ssb_butter(dsb_signal, Fs, Fc, Bm, order)
%
%   Uses filter() not filtfilt() — shows real phase distortion
%   NOTE: butter(4, ... 'bandpass') produces an 8th-order filter

    if nargin < 5 || isempty(order)
        order = 4;
    end

    % LSB band: [Fc-Bm, Fc]
    Wn = [Fc - Bm, Fc] / (Fs/2);

    % Design Butterworth bandpass filter
    [b, a] = butter(order, Wn, 'bandpass');

    % Apply filter (causal, shows phase distortion)
    ssb_lsb = filter(b, a, dsb_signal);
end