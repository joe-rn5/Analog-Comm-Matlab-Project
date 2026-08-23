function ssb_lsb = filter_ssb_butter(dsb_signal, Fs, Fc, Bm, order)
% FILTER_SSB_BUTTER Extract LSB using practical Butterworth filter
%
%   ssb_lsb = filter_ssb_butter(dsb_signal, Fs, Fc, Bm)
%   ssb_lsb = filter_ssb_butter(dsb_signal, Fs, Fc, Bm, order)

    if nargin < 5 || isempty(order)
        order = 4;   % assignment spec: 4th order
    end

    % LSB band: [Fc-Bm, Fc] (positive frequencies)
    Wn = [Fc - Bm, Fc] / (Fs/2);

    % Design Butterworth bandpass filter
    [b, a] = butter(order, Wn, 'bandpass');

    % Apply filter with zero-phase filtering to avoid phase distortion
    ssb_lsb = filtfilt(b, a, dsb_signal);

    % Plot comparison with ideal filter if desired
    % ssb_ideal = filter_ssb_ideal(dsb_signal, Fs, Fc, Bm);
    % figure;
    % subplot(2,1,1); plot(ssb_ideal); title('Ideal Filter Output');
    % subplot(2,1,2); plot(ssb_lsb); title('Butterworth Filter Output');
end