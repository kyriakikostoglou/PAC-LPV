function [s, fs] = createsim1(L, snr, c)
%CREATESIM1 Create a monophasic PAC signal:
%   Low-freq process y1 modulates the amplitude of a high-freq sinusoid.
%
% Inputs
%   L   : length in seconds
%   snr : target SNR in dB (signal power / noise power)
%   c   : coupling gain used in logistic amplitude modulator
%
% Outputs
%   s   : 1 x N trimmed noisy signal (transients removed)
%   fs  : sampling rate (Hz)

fl = 4;           % Low frequency (Hz) targeted in y1
fh = 60;          % High frequency (Hz) carrier
tc = 0;           % Threshold/offset for logistic
fs = 240;         % Sampling rate (Hz)
k  = 1;           % Modulation scale
N  = L * fs;

% Low-frequency driver y1 as narrowband noise centered at fl
y1  = randn(1, N);
y1  = eegfilt(y1, fs, fl-0.5, fl+0.5);
y1  = zscore(y1);

% Logistic amplitude modulator (bounded, smooth nonlinearity)
ag  = k ./ (1 + exp(-c*y1 - tc));

% High-frequency carrier with amplitude modulated by ag
yg  = ag .* sin(2*pi*fh*(0:N-1)/fs);

% Clean mixture
yall = y1 + yg;

% Additive white Gaussian noise to reach target SNR
% Compute noise variance from SNR (in dB) and signal power
va = 10^( log10(yall*yall') - (snr/10) );
n  = sqrt(va) * randn(1, length(yall));

s  = yall + n;

% Trim edges to reduce filter/Hilbert transients
s  = s(400:end-400);
end