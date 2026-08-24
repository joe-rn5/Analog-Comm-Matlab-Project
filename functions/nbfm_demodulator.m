function rx = nbfm_demodulator(nbfm_signal, Fs)
% NBFM_DEMODULATOR - With volume boosting

    % Differentiate
    dsig = gradient(nbfm_signal) * Fs;

    % Envelope detection
    env = abs(hilbert(dsig));

    % Remove DC
    rx = env - mean(env);

    % Low-pass filter
    [b, a] = butter(6, 4000/(Fs/2), 'low');
    rx = filtfilt(b, a, rx);

    % VOLUME FIX: Amplify
    rx = rx * 2.5;  % Boost volume

    % Normalize without making it too quiet
    max_val = max(abs(rx));
    if max_val > 0.8
        rx = rx / max_val * 0.9;  % Prevent clipping
    end

    % Remove DC again (might have crept in)
    rx = rx - mean(rx);
end