function [res] = f_ValueAndTranspose(x)

res = value(x)';

res(isnan(res)) = 0;

res = res.*(res>1e-3);

end