function coef=lm_wrap(df,varargin)
%Wrapper for funelling fitlm-coefficients to bootci
mdl=fitlm(df,varargin{:});
coef=mdl.Coefficients.Estimate;