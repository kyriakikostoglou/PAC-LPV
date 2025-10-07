function [MI] = pac_LPV(phas, ampl)
%PAC_LPV Estimate modulation index (MI) via LPV polynomial AR modeling.
%
% The method:
%   - Uses scheduling variables a = [cos(phase), sin(phase)]
%   - Searches over small grids of AR order (p) and polynomial degree (pl)
%     to find a good model (via residual energy)
%   - Then selects a ridge parameter by balancing fit vs. coefficient norm
%   - Computes MI by comparing residual energy to a phase-shuffled baseline
%
% Inputs
%   phas : 1 x N phase time series (radians)
%   ampl : 1 x N amplitude/envelope time series (nonnegative)
%
% Output
%   MI   : scalar modulation index

AA = ampl(:);                            % ensure column
a  = [cos(phas(:)) sin(phas(:))];        % scheduling variables

% Coarse search over model orders:
%   p  in {1..10} (AR order)
%   pl in {1..4}  (2D polynomial degree)
tempp = zeros(10*4, 3);                  % [p, pl, objective]
cc    = 0;

for p = 1:10
    for pl = 1:4
        cc = cc + 1;
        res = LPVpol_reg([p pl], AA, a, 1);   % temporary lambda=1
        tempp(cc,:) = [p, pl, res.nmse];
    end
end

% Candidate ridge values to evaluate with rn/sn tradeoff
lreg = [0.001 0.01 0.1 1 10 100];

% Pick best (p,pl) from coarse search (minimum residual energy)
[~, ii] = min(tempp(:,3));
plop    = tempp(ii,2);
pop     = tempp(ii,1);

% Compute rn (fit) and sn (coef norm) across lambdas for chosen (p,pl)
[rn, sn] = LPVpol_reg_all([pop plop], AA, a, lreg);

% Choose lambda that balances fit and regularization (heuristic)
[~, ii] = min(log((1 ./ rn) + (1 ./ sn)));
reg_c   = lreg(ii);

% Final fit with selected hyperparameters
res = LPVpol_reg([pop plop], AA, a, reg_c);

% Build a null distribution by shuffling the scheduling variables (phase)
% and recomputing the residual for the same coefficients (SIM only).
for iter = 1:10
    anew = a(randperm(size(a,1)), :);        % permute time order (break PAC)
    res2(iter) = SIM_LPVpol([pop plop], AA, anew, res.Cmat); %#ok<AGROW>
end

% MI as distance between fit error and shuffled baseline (log ratio)
MI = abs(log((res.nmse) / mean([res2.nmse])));  % use field below from SIM
end
