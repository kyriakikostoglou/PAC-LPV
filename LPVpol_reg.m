function res = LPVpol_reg(X, y, pv, lambda)
%LPVpol_reg  Ridge-regularized LPV polynomial AR regression (single lambda).
%
% Models the output y as an AR process whose coefficients vary with
% scheduling variables pv via a 2D polynomial basis.
%
% Inputs
%   X       : [p, ncy] where
%               p   = AR order (number of past y samples)
%               ncy = polynomial degree in pv = [pv1 pv2]
%   y       : N x 1 output (amplitude/envelope) vector
%   pv      : N x 2 scheduling vars (columns: typically [cos(phi) sin(phi)])
%   lambda  : scalar ridge parameter (no penalty on intercept)
%
% Output (struct)
%   res.nmse : residual energy (e' * e) over fitted portion (N - p samples)
%   res.e    : residual vector
%   res.Cmat : estimated coefficient vector

% -------------------- unpack & bookkeeping -------------------------------
N   = size(y,1);
py  = X(1);          % AR order
ncy = X(2);          % polynomial degree in pv
ignore = py + 1;     % first valid index (need py lags of y)

% -------------------- 2D polynomial basis in pv --------------------------
% Build all monomials pv1^(ncy:-1:0) .* pv2^(0:1:ncy) for each row (time)
% Result 'tempp' has size N x (ncy+1), representing degree-ncy curve on pv
temp1 = repmat(pv(:,1), 1, ncy+1) .^ repmat(ncy:-1:0, size(pv,1), 1);
temp2 = repmat(pv(:,2), 1, ncy+1) .^ repmat(0:1:ncy,  size(pv,1), 1);
tempp = temp1 .* temp2;

% Repeat the basis block for each AR lag; prepend ones for bookkeeping
V = [ones(N, py) , repmat(tempp, 1, py)];   % N x [py + py*(ncy+1)]

% -------------------- build AR regressors (lags of y) --------------------
% temp is N x py where each column k is y(t-k)
temp = flipud(buffer(y, py, py-1, 'nodelay'))';  % standard lag matrix

% For each lag and each polynomial term, multiply the corresponding lagged y.
% F aligns zeros for the first 'py' rows, then fills with lagged values.
F = [zeros(py, size(V,2)); ...
     temp , kron(temp, ones(1, size(tempp,2)))];
F(end,:) = [];   % drop last row to match dimensions with V

% Final design matrix: intercept + (polynomial basis × lagged outputs)
V = [ones(N,1) , V .* F];

% -------------------- ridge regression (no penalty on intercept) ---------
LAM = lambda * eye(size(V,2));
LAM(1,1) = 0;   % do not penalize intercept

% Solve (V'V + λI)C = V'y on the valid rows (after 'ignore')
Cmat  = ((V(ignore:end,:)'*V(ignore:end,:) + LAM) \ V(ignore:end,:)') * y(ignore:end,:);
ypred = V(ignore:end,:) * Cmat;

% -------------------- residuals & outputs --------------------------------
e = y(ignore:end,:) - ypred;     % residuals on fitted portion
R = e' * e;                      % residual energy (not normalized variance)

res.nmse = R;
res.e    = e;
res.Cmat = Cmat;
end
