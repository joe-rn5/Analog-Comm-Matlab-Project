function msg_out = coherent_detector(mod_signal, Fs, Fc, varargin)
% COHERENT_DETECTOR  Coherent demodulation with noise, freq/phase errors
%
%   msg_out = coherent_detector(mod_signal, Fs, Fc)
%   msg_out = coherent_detector(mod_signal, Fs, Fc, 'SNR_dB', snr)
%   msg_out = coherent_detector(mod_signal, Fs, Fc, 'FreqOffset', df)
%   msg_out = coherent_detector(mod_signal, Fs, Fc, 'PhaseOffset', dphi_deg)
%
%   SIGNATURE: (mod_signal, Fs, Fc, ...) - Fs BEFORE Fc

    p = inputParser;
    addParameter(p, 'SNR_dB', []);
    addParameter(p, 'FreqOffset', 0);
    addParameter(p, 'PhaseOffset', 0);
    parse(p, varargin{:});

    snr_db       = p.Results.SNR_dB;
    freq_offset  = p.Results.FreqOffset;
    phase_offset = p.Results.PhaseOffset;

    % Add noise manually (no toolbox needed)
    if ~isempty(snr_db)
        signal_power = mean(mod_signal.^2);
        snr_linear = 10^(snr_db/10);
        noise_power = signal_power / snr_linear;
        noise = sqrt(noise_power) * randn(size(mod_signal));
        mod_signal = mod_signal + noise;
    end

    N = length(mod_signal);
    t = (0:N-1) / Fs;
    t = reshape(t, size(mod_signal));

    % Local oscillator
    local_carrier = cos(2*pi*(Fc + freq_offset)*t + deg2rad(phase_offset));

    % Mix
    mixed = mod_signal .* local_carrier;

    % Low-pass filter (4 kHz cutoff)
    cutoff = 4000;
    Msig = fftshift(fft(mixed));
    f = (-N/2:N/2-1) * (Fs/N);
    Msig(abs(f) > cutoff) = 0;
    msg_out = real(ifft(ifftshift(Msig)));

end