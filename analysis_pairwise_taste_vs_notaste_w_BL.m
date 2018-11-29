function analysis_pairwise_taste_vs_notaste_w_BL(dfw_c_pla)
%% Pairwise t-Tests for Taste VS No-Taste measures with baseline differences
testvars={'AUC_diff','maxtime_diff','CPT_HR_mean_diff'};
forSD1={'aucrating_perc_pre','maxtime_pre','CPT_HR_mean_pre'};
forSD2={'aucrating_perc_post','maxtime_post','CPT_HR_mean_post'};
% Note: for valid Cohen's d, SD's have to be calcualted from SD of original
% measurements, not SD of difference between pre- and post- treatment.
for i=1:length(testvars)
    disp(['##### Ttest and permuted ttest for: ',testvars{i},'#####']);
    x=dfw_c_pla{dfw_c_pla.treat=='1',testvars(i)};
    y=dfw_c_pla{dfw_c_pla.treat=='2',testvars(i)};
    x=x(~isnan(x));
    y=y(~isnan(y));

    x_SD=dfw_c_pla{dfw_c_pla.treat=='1',forSD1(i)};
    y_SD=dfw_c_pla{dfw_c_pla.treat=='2',forSD2(i)};
    %[h,p,ci,stats] = ttest2(x,y) %classic t-test
    x_CI=bootci(10000,{@nanmean,x},'type','cper');
    y_CI=bootci(10000,{@nanmean,y},'type','cper');

    %Cohen's d_s, according to Lakens 2013 (Formula 1)
    n1=length(x);
    n2=length(y);
    df1=n1-1;
    df2=n2-1;
    sd_pooled=(nanstd(x_SD)+nanstd(y_SD))./2;
    effect=mean(x)-mean(y);
    se_effect=sqrt((std(x)^2)./n1+(std(y)^2)./n2);
    d=(effect)/sd_pooled;
    var_d=(n1+n2)./(n1.*n2)+(d.^2)./(2.*(df1+df2));
    se_d= sqrt(var_d);

    sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(x),x_CI)
    sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(y),y_CI)
    sprintf([testvars{i},': Cohen''s d: %f, SD-pooled: %f'],d,sd_pooled)

    [pval, t_orig, crit_t, est_alpha, ~]=mult_comp_perm_t2(x,y,10000)
    bayes_factor(abs(d),se_d,0,[0,0.5,2])
end

    bayes_factor(abs(0.205694),0.2134,1,[0,0.2691])
end