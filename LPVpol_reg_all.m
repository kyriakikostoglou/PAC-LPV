function [rn, sn] = LPVpol_reg_all(X, y, pv, lambda)
%LPVpol_reg_all Evaluate fit & coefficient norms for a set of regularizers.
%
% This constructs an LPV polynomial regression design matrix (with memory
% order py and 2D polynomial degree ncy), then for each lambda performs
% ridge regression and returns:
%   rn(i) : residual norm^2  for lambda(i)
%   sn(i) : parameter norm^2 (excluding intercept) for lambda(i)
%
% Inputs
%   X      : [py, ncy] where
%              py  = AR order (number of past outputs)
%              ncy = 2D polynomial degree on scheduling vars pv(:,1:2)
%   y      : N x 1 output vector
%   pv     : N x 2 scheduling variables (columns used as basis inputs)
%   lambda : vector of ridge parameters
%
% Outputs
%   rn, sn : vectors (same length as lambda)

N   = size(y,1);
py  = X(1);
ncy = X(2);
bb  = size(pv,2);        %#ok<NASGU>  % number of scheduling channels (expected 2)
ignore = py + 1;         % discard first samples (need py past outputs)

% Build 2D polynomial basis in pv up to degree ncy:
%   sum_{i+j<=ncy} pv1^i * pv2^j  (implemented via tensor of powers)
temp1 = repmat(pv(:,1), 1, ncy+1) .^ (repmat(ncy:-1:0, size(pv,1), 1));
temp2 = repmat(pv(:,2), 1, ncy+1) .^ (repmat(0:1:ncy,  size(pv,1), 1));
tempp = temp1 .* temp2;  % elementwise combinations

% Repeat basis blocks for each AR lag
V = [ones(N, py) repmat(tempp, 1, py)];

% Build regressor that multiplies each basis block by the lagged outputs
temp = flipud(buffer(y, py, py-1, 'nodelay'))';    % [N x py] past outputs
F    = [zeros(py, size(V,2)); ...
        temp kron(temp, ones(1, size(tempp,2)))];  % align lags with basis
F(end,:) = [];                                     % drop last row to match dims

% Final design matrix with intercept
V  = [ones(N,1) V .* F];
VV = V(ignore:end, :);       % drop first py rows (insufficient past)
yy = y(ignore:end, :);

tempVV = (VV' * VV);
rn = zeros(length(lambda),1);
sn = zeros(length(lambda),1);

for i = 1:length(lambda)
    % Ridge with no penalty on intercept
    LAM = lambda(i) * eye(size(V,2)); 
    LAM(1,1) = 0;

    Cmat = ((tempVV + LAM) \ VV') * yy;  % coefficients
    ypred = VV * Cmat;
    e     = yy - ypred;

    rn(i) = norm(e)^2;           % residual energy
    sn(i) = norm(Cmat(2:end))^2; % coefficient energy (exclude intercept)
end
end