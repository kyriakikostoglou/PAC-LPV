% -------------------------------------------------------------------------
% Cross-Frequency Coupling (CFC) Simulation and Analysis (LPV-AR approach)
% -------------------------------------------------------------------------
% This script:
%   1) Simulates signals with phase–amplitude coupling (PAC)
%   2) Runs the LPV-based PAC estimator across a grid of (phase, amplitude)
%      frequencies
%   3) Aggregates results across multiple realizations
%   4) Visualizes the mean Modulation Index (MI)
% -------------------------------------------------------------------------

close all; clear all

maxiters = 1;              % Num ber of simulation realizations
c        = 3;               % Coupling strength parameter used in simulation
snr      = 40;              % SNR (dB) for additive Gaussian noise
L        = 10;              % Signal length in seconds (before trimming)
fl       = 2:1:10;          % Candidate phase (low) frequencies (Hz)
fh       = 20:2:80;         % Candidate amplitude (high) frequencies (Hz)
niters   = 10;              % niters : scalar, number of shuffling iterations used to build the
                            % null distribution (i.e., how many times to permute phase and
                            % recompute residuals). Higher = more stable null estimate.
                            % Default = 10 if not provided.

% Samples to discard at the beginning and end due to Hilbert edge effects.
% Make sure this is smaller than final signal length/2.
ignore   = 200;

% Preallocate MI: [nLowFreqs x nHighFreqs x nRealizations]
MI = zeros(length(fl), length(fh), maxiters);

% --------------------------- Monte Carlo loop -----------------------------
for iters = 1:maxiters
    % Create a monophasic coupled signal (y1 drives amplitude of high-freq carrier)
    % Returns:
    %   s  : 1 x N vector (trimmed to avoid filter transients)
    %   Fs : sampling rate (Hz)
    [s(iters,:), Fs] = createsim1(L, snr, c);

    % If you wish biphasic couplings instead, use createsim2 and comment the above
    % [s(iters,:), Fs] = createsim2(L, snr, c);

    % Run PAC analysis for this realization
    % MI iters: [nLowFreqs x nHighFreqs]
    MI(:,:,iters) = runall(s(iters,:), Fs, iters, fl, fh, ignore, niters);
end

% --------------------------- Aggregate & plot -----------------------------
MImean = squeeze(mean(MI, 3));  % Mean MI across realizations

figure; imagesc(fl, fh, MImean'); axis xy
xlabel('Phase Frequency (Hz)')
ylabel('Amplitude Frequency (Hz)')
title('Mean PAC (LPV-AR Modulation Index) across realizations')
colorbar
