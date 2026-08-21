function msg_out = envelope_detector(mod_signal)


    msg_out = abs(hilbert(mod_signal));

end
