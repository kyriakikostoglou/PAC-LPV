function [MI] = runall(s, Fs, iters, fl, fh, ignore, niters)
%RUNALL Compute LPV-based PAC across a grid of (phase, amplitude) frequencies.
%
% This function computes the Modulation Index (MI) between phase and amplitude
% components of a signal using Linear Parameter-Varying (LPV) autoregressive modeling.
% It iterates across low (phase) and high (amplitude) frequency combinations,
% filters the signal in the corresponding bands, and estimates PAC using
% the LPV polynomial regression method described in:
%
%   Kostoglou, K. et al. (2022). *Frontiers in Human Neuroscience*, 16:915815.
%   https://doi.org/10.3389/fnhum.2022.915815
%
% Inputs
%   s       : 1 x N signal
%   Fs      : sampling rate (Hz)
%   iters   : realization index (used for progress display)
%   fl      : vector of low (phase) frequencies to test [Hz]
%   fh      : vector of high (amplitude) frequencies to test [Hz]
%   ignore  : samples to discard at both ends after Hilbert (edge effects)
%   niters  : number of shuffling iterations used to build the null
%             distribution in the PAC estimation (controls how many
%             surrogate permutations are used for baseline comparison)
%
% Output
%   MI      : [length(fl) x length(fh)] Modulation Index matrix

    MI = nan(length(fl), length(fh));

    % Loop over candidate phase (low) frequencies
    for il = 1:length(fl)
        % Bandpass around low frequency (narrow band) to extract phase
        % eegfilt returns zero-phase filtered signal (filtfilt)
        [eegl, ~] = eegfilt(detrend(s,'constant'), Fs, fl(il), fl(il)+0.5);

        % Loop over candidate amplitude (high) frequencies
        for ih = 1:length(fh)
            % Progress display: show which frequencies are being processed
            fprintf('Estimating PAC... realization %d | low-freq %.1f Hz | high-freq %.1f Hz\n', ...
                    iters, fl(il), fh(ih));

            % Bandpass around high frequency (wider band) to extract envelope
            [eegh, ~] = eegfilt(detrend(s,'constant'), Fs, fh(ih), fh(ih)+2);

            % Extract instantaneous phase and amplitude (via Hilbert transform)
            phas = angle(hilbert(eegl));    % instantaneous phase
            ampl = abs(hilbert(eegh));      % instantaneous amplitude (envelope)

            % Discard edge samples (Hilbert + filtering transients)
            phas = phas(ignore:end-ignore);
            ampl = ampl(ignore:end-ignore);

            % Normalize amplitude to ensure consistent scaling
            for kk = 1:size(ampl,1)
                ampl(kk,:) = ampl(kk,:) / norm(ampl(kk,:));
            end

            % Compute LPV-based PAC (with surrogate testing)
            MI(il, ih) = pac_LPV(phas(:)', ampl(:)', niters);
        end
    end
end
