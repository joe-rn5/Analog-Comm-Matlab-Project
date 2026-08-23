function ssb_lsb = filter_ssb_ideal(dsb_signal, Fs, Fc, Bm)
% DSB-SC contains both sidebands around the carrier: USB in [Fc, Fc+Bm]
% and LSB in [Fc-Bm, Fc]. Removing the USB with an ideal filter leaves
% only the LSB, plus its negative-frequency mirror (needed since the
% time-domain signal must stay real)

    N = length(dsb_signal);
    X = fftshift(fft(dsb_signal));
    f = (-floor(N/2) : ceil(N/2)-1).' * (Fs/N);

    mask = (f >= Fc-Bm & f <= Fc) | (f <= -(Fc-Bm) & f >= -Fc);

    X_lsb = X .* mask;
    ssb_lsb = real(ifft(ifftshift(X_lsb)));
end
