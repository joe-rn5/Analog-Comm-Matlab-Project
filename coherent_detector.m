function msg_out = coherent_detector(mod_signal, Fc, Fs, varargin)
% COHERENT_DETECTOR  Coherent (synchronous) demodulation with optional
% noise, local-oscillator frequency offset, and phase offset.
%
%   ** ARGUMENT ORDER WARNING **
%   This function takes (mod_signal, Fc, Fs, ...). Every other function
%   in this project takes (signal, Fs, Fc, ...) -- Fs before Fc. Double
%   check argument order at every call site; Fc and Fs are both
%   plausible-looking numbers (100e3 vs 500e3), so swapping them will
%   NOT throw an error -- it will silently run the carrier at the wrong
%   frequency. Confirm all call sites in main_exp1_dsb.m / main_exp2_ssb.m
%   / main_exp3_fm.m match this order before final submission.
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
