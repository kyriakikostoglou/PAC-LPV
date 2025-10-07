function [MI] = runall(s, Fs, iters, fl, fh, ignore)
%RUNALL Compute LPV-based PAC across a grid of (phase, amplitude) frequencies.
%
% Inputs
%   s       : 1 x N signal
%   Fs      : sampling rate (Hz)
%   iters   : realization index (used for progress display)
%   fl      : vector of low (phase) frequencies to test [Hz]
%   fh      : vector of high (amplitude) frequencies to test [Hz]
%   ignore  : samples to discard at both ends after Hilbert (edge effects)
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
            % Progress display: [iteration, low-freq index, high-freq index]
            % disp([iters il ih])
            fprintf('Estimating PAC... realization %d | low-freq %.1f Hz | high-freq %.1f Hz\n', ...
                    iters, fl(il), fh(ih));

            % Bandpass around high frequency (wider band) to extract envelope
            [eegh, ~] = eegfilt(detrend(s,'constant'), Fs, fh(ih), fh(ih)+2);

            % Phase of low-frequency component and amplitude of high-frequency
            phas = angle(hilbert(eegl));    % instantaneous phase
            ampl = abs(hilbert(eegh));      % instantaneous amplitude (envelope)

            % Discard edge samples (Hilbert + filtering transients)
            phas = phas(ignore:end-ignore);
            ampl = ampl(ignore:end-ignore);

            % Normalize amplitude vector(s) to avoid scale issues
            % (kept as loop to preserve original behavior)
            for kk = 1:size(ampl,1)
                ampl(kk,:) = ampl(kk,:) / norm(ampl(kk,:));
            end

            % LPV-AR PAC estimate (returns a scalar MI)
            MI(il, ih) = pac_LPV(phas(:)', ampl(:)');
        end
    end
end
