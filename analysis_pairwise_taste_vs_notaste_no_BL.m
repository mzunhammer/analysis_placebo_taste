function analysis_pairwise_taste_vs_notaste_no_BL(dfw_c_pla)

%% Pairwise t-Tests for TASTE measures without baseline
testvars={'treat_expect_post','taste_intensity_post','taste_valence_post','treat_efficacy_post','sumUAW_post'};
for i=1:length(testvars)
disp(['##### Ttest and permuted ttest for: ',testvars{i},'#####']);
x=dfw_c_pla{dfw_c_pla.treat=='1',testvars(i)};
y=dfw_c_pla{dfw_c_pla.treat=='2',testvars(i)};
x=x(~isnan(x));
y=y(~isnan(y));

%[h,p,ci,stats] = ttest2(x,y) %classic t-test
x_CI=bootci(10000,{@nanmean,x},'type','cper');
y_CI=bootci(10000,{@nanmean,y},'type','cper');

%Cohen's d_s, according to Lakens 2013 (Formula 1)
n1=length(x);
n2=length(y);
df1=n1-1;
df2=n2-1;
sd_pooled=sqrt(((df1.*std(x).^2)+(df2.*std(y).^2))./(df1+df2));
effect=mean(x)-mean(y);
d=(effect)/sd_pooled;
var_d=(n1+n2)./(n1.*n2)+(d.^2)./(2.*(df1+df2));
se_d= sqrt(var_d);

sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(x),x_CI)
sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(y),y_CI)
sprintf([testvars{i},': Cohen''s d: %f, SD-pooled: %f'],d,sd_pooled)

[pval, t_orig, crit_t, est_alpha, ~] = mult_comp_perm_t2(x,y,10000)
% A half-Normal prior is used for all of these Bayes Factors, as we
% expected that Tasty-Placebo a) increases expectations b) tastes more
% intense and c) tastes more negative d) is perceived as more efficient e)
% leads to more side-effects
bayes_factor(abs(d),se_d,0,[0,0.5,2])
end

