 function [data, M, m] =scale_func(data,M,m)
[Nb_s , ~]=size(data);
if nargin==1
    M = max(data,[],1);
    m = min(data,[],1);
end

data = 2*(data-repmat(m,Nb_s,1))./(repmat(M-m,Nb_s,1)) - 1;