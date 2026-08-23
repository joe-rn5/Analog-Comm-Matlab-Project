function rx = nbfm_demodulator(nbfm_signal, Fs)
% NBFM_DEMODULATOR - Smooth demodulation using gradient

    % Use gradient instead of diff (smoother)
    dsig = gradient(nbfm_signal) * Fs;

    % Square the signal (simple envelope detection)
    env = sqrt(dsig.^2 + (imag(hilbert(dsig))).^2);
    % OR use Hilbert:
    % env = abs(hilbert(dsig));

    % Remove DC
    rx = env - mean(env);

    % Multi-stage filtering for clean audio
    [b, a] = butter(4, 4000/(Fs/2), 'low');
    rx = filtfilt(b, a, rx);

    % Another filter to remove residual noise
    [b2, a2] = butter(2, 3000/(Fs/2), 'low');
    rx = filtfilt(b2, a2, rx);

    % Normalize
    rx = rx / max(abs(rx));
end