function rx = nbfm_demodulator(nbfm_signal, Fs)
% NBFM_DEMODULATOR Demodulate NBFM using differentiator + envelope detector
%
%   rx = nbfm_demodulator(nbfm_signal, Fs)
%
%   Method: differentiating FM converts freq variation to amplitude variation
%   d/dt[cos(ωc t + φ(t))] = -(ωc + dφ/dt)sin(ωc t + φ(t))
%   Envelope of derivative = |ωc + dφ/dt| ≈ ωc + dφ/dt (for NBFM)
%   After removing DC: rx ∝ dφ/dt ∝ message

    % Differentiate FM signal
    dsig = diff(nbfm_signal) * Fs;

    % Pad to maintain same length (or use gradient for better accuracy)
    dsig = [dsig; dsig(end)];

    % Envelope detection using Hilbert transform
    env = abs(hilbert(dsig));

    % Remove DC component (proportional to Fc)
    rx = env - mean(env);

    % Optional: low-pass filter to remove any residual high-frequency noise
    % Design a lowpass filter with cutoff at 4kHz
    % [b, a] = butter(4, 4000/(Fs/2), 'low');
    % rx = filtfilt(b, a, rx);
end