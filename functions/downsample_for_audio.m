function y = downsample_for_audio(x, Fs_from, Fs_to)
% DOWNSAMPLE_FOR_AUDIO  Resample a signal from a high simulation rate
% down to a standard playback rate before calling sound().
%
%   y = downsample_for_audio(x, Fs_from, Fs_to)
%
%   INPUTS
%       x       - signal at the high simulation rate (e.g. Fs_mod = 5*Fc)
%       Fs_from - the signal's current sampling rate (Hz)
%       Fs_to   - target playback rate (Hz), typically the original audio Fs
%
%   OUTPUT
%       y - x resampled to Fs_to, safe to pass to sound(y, Fs_to)
%
%   Extracted from main_exp2_ssb.m so Experiments 1 and 3 can reuse it --
%   sound() doesn't support playback at Fs = 5*Fc (~500 kHz), so every
%   sound() call anywhere in the project should go through this first.

    [P, Q] = rat(Fs_to / Fs_from);
    y = resample(x, P, Q);
end
