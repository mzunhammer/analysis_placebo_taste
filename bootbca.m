function [ci,bstat] = bootbca(stat,nboot,bootfun,alpha,weights,bootstrpOptions,varargin)
% convenience copy from bootci.m, since bootci does not accept tables
% corrected and accelerated percentile bootstrap CI
% T.J. DiCiccio and B. Efron (1996), "Bootstrap Confidence Intervals",
% statistical science, 11(3)
 
bstat = bootstrp(nboot,bootfun,varargin{:},'weights',weights,'Options',bootstrpOptions);

% same as bootcper, this is the bias correction
z_0 = fz0(bstat,stat);

% apply jackknife
try
    jstat = jackknife(bootfun,varargin{:},'Options',bootstrpOptions);
catch ME
    m = message('stats:bootci:JackknifeFailed',func2str(bootfun));
    throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
end
N = size(jstat,1);
if isempty(weights)
    weights = repmat(1/N,N,1);
else
    weights = weights(:);
    weights = weights/sum(weights);
end

% acceleration finding, see DiCiccio and Efron (1996)
mjstat = sum(bsxfun(@times,jstat,weights),1); % mean along 1st dim.
score = bsxfun(@minus,mjstat,jstat); % score function at stat; ignore (N-1) factor because it cancels out in the skew
iszer = all(score==0,1);
skew = sum(bsxfun(@times,score.^3,weights),1) ./ ...
    (sum(bsxfun(@times,score.^2,weights),1).^1.5) /sqrt(N); % skewness of the score function
skew(iszer) = 0;
acc = skew/6;  % acceleration

% transform back with bias corrected and acceleration
z_alpha1 = norminv(alpha/2);
z_alpha2 = -z_alpha1;
pct1 = 100*normcdf(z_0 +(z_0+z_alpha1)./(1-acc.*(z_0+z_alpha1)));
pct1(z_0==Inf) = 100;
pct1(z_0==-Inf) = 0;
pct2 = 100*normcdf(z_0 +(z_0+z_alpha2)./(1-acc.*(z_0+z_alpha2)));
pct2(z_0==Inf) = 100;
pct2(z_0==-Inf) = 0;

% inverse of ECDF
m = numel(stat);
lower = zeros(1,m);
upper = zeros(1,m);
for i=1:m
    lower(i) = prctile(bstat(:,i),pct2(i),1);
    upper(i) = prctile(bstat(:,i),pct1(i),1);
end

% return
ci = sort([lower;upper],1);
end % bootbca()