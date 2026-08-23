%% MAIN -- top-level driver, runs all three experiments end to end
% Requires functions/ on the path, and eric.wav in the project's working
% directory (or update audio_file inside each main_exp*.m if renamed).
%
% Run order: DSB -> SSB -> NBFM. Each main_exp*.m is self-contained
% (does its own load/filter/resample) so they can also be run
% individually while developing/debugging a single experiment.

clear; clc; close all;
addpath('functions');

main_exp1_dsb
main_exp2_ssb
main_exp3_fm
