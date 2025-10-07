function [res]=LPVpol_reg(X,y,pv,lambda)
N=size(y,1);
py=X(1);
ncy=X(2); 
ignore=py+1;



temp1=[repmat(pv(:,1),1,ncy+1).^(repmat(ncy:-1:0,size(pv,1),1))];
temp2=[repmat(pv(:,2),1,ncy+1).^(repmat(0:1:ncy,size(pv,1),1))];
tempp=temp1.*temp2;

V=[ones(N,py) repmat(tempp,1,py)];

temp=flipud(buffer(y,py,py-1,'nodelay'))';
F=[zeros(py,size(V,2));temp kron(temp,ones(1,size(tempp,2)))];F(end,:)=[];

V=[ones(N,1)  V.*F];
LAM=lambda*eye(size(V,2));
LAM(1,1)=0; 

Cmat=((V(ignore:end,:)'*V(ignore:end,:)+LAM)\V(ignore:end,:)')*y(ignore:end,:);
ypred = V(ignore:end,:)*Cmat;
e = y(ignore:end,:)-ypred; 
R=e'*e;
res.nmse=R;
res.e=e;
res.Cmat=Cmat;



