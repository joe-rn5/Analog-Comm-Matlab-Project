function ssb_lsb = filter_ssb_butter(dsb_signal, Fs, Fc, Bm, order)
% FILTER_SSB_BUTTER  Extract the lower sideband (LSB) from a DSB-SC
% signal using a PRACTICAL Butterworth bandpass filter, instead of the
% ideal brick-wall filter used in filter_ssb_ideal.m.
%
%   ssb_lsb = filter_ssb_butter(dsb_signal, Fs, Fc, Bm)
%   ssb_lsb = filter_ssb_butter(dsb_signal, Fs, Fc, Bm, order)
%
%   Assignment reference: Experiment 2, step 7 -- "Repeat steps 5 and 6,
%   only this time use a practical 4th order Butterworth filter."
%   [butter, filter]
%
%   INPUTS
%       dsb_signal - DSB-SC signal (output of generate_dsb_sc)
%       Fs         - sampling frequency (Hz)
%       Fc         - carrier frequency (Hz)
%       Bm         - message bandwidth (Hz), e.g. 4000
%       order      - Butterworth filter order (optional, default 4 per spec)
%
%   OUTPUT
%       ssb_lsb - dsb_signal filtered down to the LSB only
%
%   Owner: Person 5
%
%   APPROACH
%   The LSB occupies [Fc-Bm, Fc] (plus its mirror [-Fc, -(Fc-Bm)]).
%   Design a bandpass Butterworth filter over that band with butter(),
%   normalized to the Nyquist frequency (Fs/2), then apply it with
%   filter(). Compare the result against filter_ssb_ideal.m's output at
%   the same Fc/Bm -- a real filter has a nonzero transition band, so
%   expect (and discuss in the report) residual USB leakage and passband
%   ripple that the ideal version doesn't have.

    if nargin < 5 || isempty(order)
        order = 4;   % assignment spec: 4th order
    end

    % TODO: Wn = [Fc-Bm, Fc] / (Fs/2);
    % TODO: [b, a] = butter(order, Wn, 'bandpass');
    % TODO: ssb_lsb = filter(b, a, dsb_signal);
    % TODO: plot_spectrum(ssb_lsb, Fs, ...) next to filter_ssb_ideal's
    %       output for the report comparison

    error('filter_ssb_butter:notImplemented', ...
        'TODO: implement per Experiment 2, step 7 (practical Butterworth filter).');
end
