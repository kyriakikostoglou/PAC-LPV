function [s, fs] = createsim2(L, snr, c)
%CREATESIM2 Create a variant (biphasic-like) PAC signal by zero-centering
% the logistic modulator before applying it to the high-frequency carrier.
%
% Inputs/Outputs same as createsim1.

fl = 4;           % Low frequency (Hz)
fh = 60;          % High frequency (Hz)

tc = 0;
fs = 240;
k  = 1;
N  = L * fs;

% Low-frequency driver as narrowband noise around fl
y1  = randn(1, N);
y1  = eegfilt(y1, fs, fl-0.5, fl+0.5);
y1  = zscore(y1);

% Optionally: pure sinusoid driver
% y1 = a * sin(2*pi*fl*(0:N-1)/fs);

% Zero-mean logistic amplitude modulator
ag  = k ./ (1 + exp(-c*y1 - tc));
ag  = ag - mean(ag);

% Apply amplitude modulation to high-freq carrier
yg  = ag .* sin(2*pi*fh*(0:N-1)/fs);

% Add noise to reach target SNR
yall = y1 + yg;
va   = 10^( log10(yall*yall') - (snr/10) );
n    = sqrt(va)*randn(1, length(yall));

s    = yall + n;

% Trim edges to reduce transients
s    = s(400:end-400);
end