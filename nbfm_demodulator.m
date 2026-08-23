function rx = nbfm_demodulator(nbfm_signal, Fs)
% NBFM_DEMODULATOR  Demodulate an NBFM signal using a differentiator
% followed by an envelope detector.
%
%   rx = nbfm_demodulator(nbfm_signal, Fs)
%
%   Assignment reference: Experiment 3, step 4 -- "Demodulate the NBFM
%   signal using a differentiator and an ED." [diff, hilbert, abs]
%
%   INPUTS
%       nbfm_signal - NBFM modulated signal (output of generate_nbfm)
%       Fs          - sampling frequency (Hz)
%
%   OUTPUT
%       rx - recovered baseband message (assume no noise, per spec)
%
%   Owner: Person 5
%
%   APPROACH
%   Differentiating an FM signal converts frequency variation into
%   amplitude variation: the envelope of d/dt[cos(2*pi*Fc*t + phase(t))]
%   is proportional to (Fc + dphase/dt), i.e. proportional to Fc plus
%   the original message. Steps:
%     1) differentiate with diff() -- remember diff() shortens the
%        vector by one sample and needs scaling by Fs to approximate
%        a true derivative
%     2) envelope-detect the result with Person 3's envelope_detector.m
%     3) subtract the mean to remove the DC term contributed by Fc

    % TODO: dsig = diff(nbfm_signal) * Fs;
    % TODO: env  = envelope_detector(dsig);   % reuse Person 3's function
    % TODO: rx   = env - mean(env);           % strip the Fc-proportional DC term

    error('nbfm_demodulator:notImplemented', ...
        'TODO: implement per Experiment 3, step 4.');
end
