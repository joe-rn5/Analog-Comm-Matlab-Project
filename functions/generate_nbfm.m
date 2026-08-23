function [nbfm_signal, t, Fs] = generate_nbfm(message, Fs, Fc, kf)
% GENERATE_NBFM  Generate a narrowband FM (NBFM) signal.
%
%   [nbfm_signal, t, Fs] = generate_nbfm(message, Fs, Fc, kf)
%
%   Assignment reference: Experiment 3, step 2 -- generate the NBFM
%   signal at Fc = 100 kHz, Fs = 5*Fc.
%
%   INPUTS
%       message - filtered and resampled message signal
%       Fs      - sampling frequency (Hz)
%       Fc      - carrier frequency (Hz)
%       kf      - frequency sensitivity constant
%
%   OUTPUTS
%       nbfm_signal - NBFM modulated signal
%       t           - time vector
%       Fs          - sampling frequency (returned for handoff, matches
%                     the generate_dsb_sc / generate_dsb_tc pattern)
%
%   Owner: Person 5
%
%   BACKGROUND (relevant to assignment step 3 -- "what is the condition
%   we needed to achieve NBFM"): the narrowband approximation only holds
%   when the peak phase deviation is small (<< 1 rad). Choose kf with
%   that in mind and be ready to justify the choice in the report.
%
%   APPROACH
%   s(t) = cos(2*pi*Fc*t + 2*pi*kf*cumsum(message)/Fs)
%   (cumsum approximates discrete-time integration of the message.)

    message = message(:);
    N = length(message);
    t = (0:N-1).' / Fs;

    % TODO: phase_dev = 2*pi*kf*cumsum(message)/Fs;
    % TODO: nbfm_signal = cos(2*pi*Fc*t + phase_dev);
    % TODO: plot_spectrum(nbfm_signal, Fs, 'NBFM Spectrum') and compare
    %       its bandwidth against the DSB/SSB spectra for the report

    error('generate_nbfm:notImplemented', ...
        'TODO: implement per Experiment 3, step 2.');
end
