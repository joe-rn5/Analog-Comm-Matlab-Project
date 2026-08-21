function msg_out = coherent_detector(mod_signal, Fc, Fs, varargin)

    p = inputParser;
    addParameter(p, 'SNR_dB', []);
    addParameter(p, 'FreqOffset', 0);
    addParameter(p, 'PhaseOffset', 0);
    parse(p, varargin{:});

    snr_db       = p.Results.SNR_dB;
    freq_offset  = p.Results.FreqOffset;
    phase_offset = p.Results.PhaseOffset;

    
    if ~isempty(snr_db)
        mod_signal = awgn(mod_signal, snr_db, 'measured');
    end

  
    N = length(mod_signal);
    t = (0:N-1) / Fs;
    t = reshape(t, size(mod_signal));

   
    local_carrier = cos(2*pi*(Fc + freq_offset)*t + deg2rad(phase_offset));

    
    mixed = mod_signal .* local_carrier;

  
    cutoff = 4e3;
    Msig = fftshift(fft(mixed));
    f = (-N/2:N/2-1) * (Fs/N);
    Msig(abs(f) > cutoff) = 0;
    msg_out = real(ifft(ifftshift(Msig)));

end
