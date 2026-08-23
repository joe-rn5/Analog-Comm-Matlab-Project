function msg_out = coherent_detector(mod_signal, Fc, Fs, varargin)
% COHERENT_DETECTOR  Coherent (synchronous) demodulation with optional
% noise, local-oscillator frequency offset, and phase offset.
%
%   msg_out = coherent_detector(mod_signal, Fc, Fs)
%   msg_out = coherent_detector(mod_signal, Fc, Fs, 'SNR_dB', snr)
%   msg_out = coherent_detector(mod_signal, Fc, Fs, 'FreqOffset', df)
%   msg_out = coherent_detector(mod_signal, Fc, Fs, 'PhaseOffset', dphi_deg)

    p = inputParser;
    addParameter(p, 'SNR_dB', []);
    addParameter(p, 'FreqOffset', 0);
    addParameter(p, 'PhaseOffset', 0);
    parse(p, varargin{:});

    snr_db       = p.Results.SNR_dB;
    freq_offset  = p.Results.FreqOffset;
    phase_offset = p.Results.PhaseOffset;

    % --- Add noise (manual implementation) ---
    if ~isempty(snr_db)
        % Calculate signal power
        signal_power = mean(mod_signal.^2);

        % Convert SNR from dB to linear scale
        snr_linear = 10^(snr_db/10);

        % Calculate required noise power
        noise_power = signal_power / snr_linear;

        % Generate Gaussian noise with zero mean
        noise = sqrt(noise_power) * randn(size(mod_signal));

        % Add noise to signal
        mod_signal = mod_signal + noise;

        fprintf('Added noise with SNR = %d dB (noise power = %.6f)\n', ...
                snr_db, noise_power);
    end

    % --- Coherent detection ---
    N = length(mod_signal);
    t = (0:N-1) / Fs;
    t = reshape(t, size(mod_signal));

    % Local oscillator with optional frequency and phase errors
    local_carrier = cos(2*pi*(Fc + freq_offset)*t + deg2rad(phase_offset));

    % Mix signal with local carrier
    mixed = mod_signal .* local_carrier;

    % Low-pass filter to recover baseband
    cutoff = 4e3;  % 4 kHz cutoff for voice signal
    Msig = fftshift(fft(mixed));
    f = (-N/2:N/2-1) * (Fs/N);
    Msig(abs(f) > cutoff) = 0;
    msg_out = real(ifft(ifftshift(Msig)));

end