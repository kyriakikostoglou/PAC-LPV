function out = SIM_LPVpol(X, y, pv, Cmat)
%SIM_LPVpol Evaluate residual energy using fixed coefficients Cmat.
%
% Used for phase-shuffled baseline: rebuild design with permuted pv and
% compute the residual energy without refitting Cmat.
%
% Inputs
%   X    : [py, ncy]
%   y    : N x 1 vector
%   pv   : N x 2 scheduling variables (possibly permuted)
%   Cmat : coefficient vector from LPVpol_reg
%
% Output
%   out.R     : residual energy (e' * e)
%   out.e     : residual vector
%   out.nmse  : alias for residual energy (kept for compatibility)

N    = size(y,1);
py   = X(1);
ncy  = X(2);

ignore = py + 1;

% 2D polynomial basis in pv
temp1 = repmat(pv(:,1), 1, ncy+1) .^ (repmat(ncy:-1:0, size(pv,1), 1));
temp2 = repmat(pv(:,2), 1, ncy+1) .^ (repmat(0:1:ncy,  size(pv,1), 1));
tempp = temp1 .* temp2;

V = [ones(N, py) repmat(tempp, 1, py)];

% Lagged outputs for AR part
temp = flipud(buffer(y, py, py-1, 'nodelay'))';
F    = [zeros(py, size(V,2)); temp kron(temp, ones(1, size(tempp,2)))];
F(end,:) = [];

% Final design with intercept
V = [ones(N,1) V .* F];

% Residual using fixed coefficients
ypred = V(ignore:end,:) * Cmat;
e     = y(ignore:end,:) - ypred;

out.R    = e' * e;
out.e    = e;
out.nmse = out.R;
end
