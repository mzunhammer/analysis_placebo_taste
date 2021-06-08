function analysis_HR_vs_pain_ratings(dfl_c,dfw_c, treatlabels, varargin)
% Flags for varargin:
% Cave, confusing nomenclature:
% mean_CPT_HR_mean_pre[*CPT*]_post[*treatment*] --> "average heart rate before CPT, after treatment"
treatcolors={[0,0,0],[0.6,0.6,0.6],[0,0.3,0.7],[0.7,0,0.3]};

dfw_c.maxtimers =(dfw_c.maxtime_pre>179) & (dfw_c.maxtime_post>179);
dfw_c.CPT_HR_max_change_from_BL_pre= dfw_c.CPT_HR_max_pre-dfw_c.CPT_HR_mean_pre_pre;
dfw_c.CPT_HR_max_change_from_BL_post= dfw_c.CPT_HR_max_post-dfw_c.CPT_HR_mean_pre_post;
dfw_c.CPT_HR_mean_change_from_BL_pre= dfw_c.CPT_HR_mean_pre-dfw_c.CPT_HR_mean_pre_pre;
dfw_c.CPT_HR_mean_change_from_BL_post= dfw_c.CPT_HR_mean_post-dfw_c.CPT_HR_mean_pre_post;

dfw_c.CPT_HR_mean_change_from_BL_diff= dfw_c.CPT_HR_mean_change_from_BL_post-dfw_c.CPT_HR_mean_change_from_BL_pre;
dfw_c.CPT_HR_max_change_from_BL_diff= dfw_c.CPT_HR_max_change_from_BL_post-dfw_c.CPT_HR_max_change_from_BL_pre;

dfw_c.valid_HR = ~isnan(dfw_c.CPT_HR_mean_diff);
dfw_c.valid_HR_complete_CPT = dfw_c.maxtimers & ~isnan(dfw_c.CPT_HR_mean_diff);
 

demovars={'study','treat',...
          'valid_HR'};
grpstats(dfw_c(:,demovars),{'study','treat'},{'sum'})
% LIMIT ANALYSIS TO valid HR recordings
dfw_c=dfw_c(dfw_c.valid_HR,:);

CPT_vars={'treat',...
        'maxtimers',...
        'healthy',...
        'CPT_HR_mean_pre_pre','CPT_HR_mean_pre_post',...
        'CPT_HR_mean_pre','CPT_HR_mean_post',...
        'CPT_HR_max_pre','CPT_HR_max_post',...
        'CPT_HR_max_perc_BL_pre','CPT_HR_max_perc_BL_post',...
        'CPT_HR_max_change_from_BL_pre','CPT_HR_max_change_from_BL_post'};
% GENERAL MEANS: ("HEALTHY" is used as a dummy, as all included participants have that tag)   
grpstats(dfw_c(:,CPT_vars(3:end)),'healthy',{'mean','std'})
% QUALITY CHECK 1: ARE EARLY-ABORTERS, MAXTIMERS FUNDAMENTALLY DIFFERENT?
grpstats(dfw_c(:,CPT_vars([2,4:end])),'maxtimers',{'mean','std'})
% GROUP MEANS: TREATMENT EFFECTS (ignoring sub study!!!)
grpstats(dfw_c(:,CPT_vars([1,4:end])),'treat',{'mean','std'})


% Test pre-CPT baseline differences between before and after treatment
[H,P,CI,STATS] =ttest(dfw_c.CPT_HR_mean_pre_pre,...
                       dfw_c.CPT_HR_mean_pre_post)
%% GLM analysis HR
dfw_c.z_CPT_HR_mean_pre_pre=nanzscore(dfw_c.CPT_HR_mean_pre_pre);
dfw_c.z_CPT_HR_mean_pre_post=nanzscore(dfw_c.CPT_HR_mean_pre_post);
dfw_c.z_CPT_HR_mean_pre=nanzscore(dfw_c.CPT_HR_mean_pre);
dfw_c.z_CPT_HR_mean_post=nanzscore(dfw_c.CPT_HR_mean_post);
dfw_c.z_CPT_HR_mean_perc_BL_pre=nanzscore(dfw_c.CPT_HR_mean_perc_BL_pre);
dfw_c.z_CPT_HR_mean_perc_BL_post=nanzscore(dfw_c.CPT_HR_mean_perc_BL_post);

dfw_c.z_CPT_HR_max_change_from_BL_pre =nanzscore(dfw_c.CPT_HR_max_change_from_BL_pre);
dfw_c.z_CPT_HR_max_change_from_BL_post =nanzscore(dfw_c.CPT_HR_max_change_from_BL_post);

dfw_c.z_CPT_HR_max_pre=nanzscore(dfw_c.CPT_HR_max_pre);
dfw_c.z_CPT_HR_max_post=nanzscore(dfw_c.CPT_HR_max_post);
dfw_c.z_maxtime_pre=nanzscore(dfw_c.maxtime_pre);
dfw_c.z_maxtime_post=nanzscore(dfw_c.maxtime_post);

% dfw_c.z_lab_time_before_pre_treat_CPT=nanzscore(dfw_c.lab_time_before_pre_treat_CPT);
% dfw_c.z_TT_TU=nanzscore(dfw_c.TT_TU);


% Correlation Analysis Ia: Is HR-baseline associated with %AUPC (before
% treatment)

[R,P,RLO,RUP]=corrcoef(dfw_c.CPT_HR_mean_pre_pre,dfw_c.aucrating_perc_pre)
[Rho,Ppart] = partialcorr(dfw_c.CPT_HR_mean_pre_pre,dfw_c.aucrating_perc_pre,dummyvar(dfw_c.study)) 
lm_hrBL_vs_AUPCpre=fitlm(dfw_c,'aucrating_perc_pre~study+CPT_HR_mean_pre_pre',...
                    'RobustOpts','on')

hold on
plot(dfw_c.CPT_HR_mean_pre_pre,dfw_c.aucrating_perc_pre,'.')
l1=lsline;l1.LineStyle='--';
xlabel('HR Baseline pre-CPT pre-treatment')
ylabel('%AUPC pre-treatment CPT')
refline(lm_hrBL_vs_AUPCpre.Coefficients{'CPT_HR_mean_pre_pre','Estimate'},...
        lm_hrBL_vs_AUPCpre.Coefficients{'(Intercept)','Estimate'})
hold off
annotation('textbox',[.6 .7 .2 .2],...
            'String', strcat('Uncorrected correlation: r = ',sprintf('%0.2f',R(2)), ' p = ',sprintf('%0.2f',P(2))),...
            'FitBoxToText','on')
        
annotation('textbox',[.6 .2 .2 .2],...
            'String', strcat('Study-corrected: r = ',sprintf('%0.2f',Rho), ' p = ',sprintf('%0.2f',Ppart)),...
            'FitBoxToText','on')
% Result: No, not really.

% Correlation Analysis Ib: Is HR-baseline associated with %AUPC (after
% treatment)

[R,P,RLO,RUP]=corrcoef(dfw_c.CPT_HR_mean_pre_post,dfw_c.aucrating_perc_post)
[Rho,Ppart] = partialcorr(dfw_c.CPT_HR_mean_pre_post,dfw_c.aucrating_perc_post,dummyvar(dfw_c.study)) 
lm_hrBL_vs_AUPCpost=fitlm(dfw_c,'aucrating_perc_post~study+CPT_HR_mean_pre_post',...
                    'RobustOpts','on')

hold on
plot(dfw_c.CPT_HR_mean_pre_post,dfw_c.aucrating_perc_post,'.')
l1=lsline;l1.LineStyle='--';
xlabel('HR Baseline pre-CPT post-treatment')
ylabel('%AUPC post-treatment CPT')
refline(lm_hrBL_vs_AUPCpost.Coefficients{'CPT_HR_mean_pre_post','Estimate'},...
        lm_hrBL_vs_AUPCpost.Coefficients{'(Intercept)','Estimate'})
hold off
annotation('textbox',[.6 .7 .2 .2],...
            'String', strcat('Uncorrected correlation: r = ',sprintf('%0.2f',R(2)), ' p = ',sprintf('%0.2f',P(2))),...
            'FitBoxToText','on')
        
annotation('textbox',[.6 .2 .2 .2],...
            'String', strcat('Study-corrected: r = ',sprintf('%0.2f',Rho), ' p = ',sprintf('%0.2f',Ppart)),...
            'FitBoxToText','on')
% Result: No, not really.



%%%% Correlation Analysis IIa:
%%%% Is maxHR during CPT (CPT-HR-response) associated with %AUPC (before
% treatment)
figure
plot(dfw_c.CPT_HR_max_change_from_BL_pre,dfw_c.aucrating_perc_pre,'.')
xlabel('HR-peak response pre-treatment CPT (abs increase from BL in bpm)')
ylabel('%AUPC pre-treatment CPT')
l1=lsline;l1.LineStyle='--';
[R,P,RLO,RUP]=corrcoef(dfw_c.CPT_HR_max_change_from_BL_pre,dfw_c.aucrating_perc_pre)
[Rho,Ppart] = partialcorr(dfw_c.CPT_HR_max_change_from_BL_pre,dfw_c.aucrating_perc_pre,dummyvar(dfw_c.study)) 
lm_hrmax_vs_AUPCpre=fitlm(dfw_c,'aucrating_perc_pre~study+CPT_HR_max_change_from_BL_pre',...
                    'RobustOpts','on')
refline(lm_hrmax_vs_AUPCpre.Coefficients{'CPT_HR_max_change_from_BL_pre','Estimate'},...
        lm_hrmax_vs_AUPCpre.Coefficients{'(Intercept)','Estimate'})
annotation('textbox',[.6 .7 .2 .2],...
            'String', strcat('Uncorrected correlation: r = ',sprintf('%0.2f',R(2)), ' p = ',sprintf('%0.2f',P(2))),...
            'FitBoxToText','on')
        
annotation('textbox',[.6 .2 .2 .2],...
            'String', strcat('Study-corrected: r = ',sprintf('%0.2f',Rho), ' p = ',sprintf('%0.2f',Ppart)),...
            'FitBoxToText','on')  
box off     
currsvg=strcat('../paper_placebo_taste/figure_HR_vs_AUPC_pre.svg');
currpng=strcat('../paper_placebo_taste/figure_HR_vs_AUPC_pre.png');
hgexport(gcf, currsvg, hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, currpng, hgexport('factorystyle'), 'Format', 'png'); 
crop(currpng);        

% >> No real association
   
%%%% Correlation Analysis IIb:
%%%% Is maxHR during CPT (CPT-HR-response) associated with %AUPC (after
% treatment)
figure
plot(dfw_c.CPT_HR_max_change_from_BL_post,dfw_c.aucrating_perc_post,'.')
xlabel('HR-peak response post-treatment CPT (abs increase from BL in bpm)')
ylabel('%AUPC post-treatment CPT')
l1=lsline;l1.LineStyle='--';
[R,P,RLO,RUP]=corrcoef(dfw_c.CPT_HR_max_change_from_BL_post,dfw_c.aucrating_perc_post)
[Rho,Ppart] = partialcorr(dfw_c.CPT_HR_max_change_from_BL_post,dfw_c.aucrating_perc_post,dummyvar(dfw_c.study)) 
lm_hrmax_vs_AUPCpost=fitlm(dfw_c,'aucrating_perc_post~study+CPT_HR_max_change_from_BL_post',...
                    'RobustOpts','on')
refline(lm_hrmax_vs_AUPCpost.Coefficients{'CPT_HR_max_change_from_BL_post','Estimate'},...
        lm_hrmax_vs_AUPCpost.Coefficients{'(Intercept)','Estimate'})
annotation('textbox',[.6 .7 .2 .2],...
            'String', strcat('Uncorrected correlation: r = ',sprintf('%0.2f',R(2)), ' p = ',sprintf('%0.2f',P(2))),...
            'FitBoxToText','on')
        
annotation('textbox',[.6 .2 .2 .2],...
            'String', strcat('Study-corrected: r = ',sprintf('%0.2f',Rho), ' p = ',sprintf('%0.2f',Ppart)),...
            'FitBoxToText','on')
box off     
currsvg=strcat('../paper_placebo_taste/figure_HR_vs_AUPC_post.svg');
currpng=strcat('../paper_placebo_taste/figure_HR_vs_AUPC_post.png');
hgexport(gcf, currsvg, hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, currpng, hgexport('factorystyle'), 'Format', 'png'); 
crop(currpng);   
% >> No real association

% %%%% Correlation Analysis IIc:
% !!!! CAVE: FLAWED ANALYSIS: SINCE HR-mean is averaged across a longer
% time-frame for maxtimers, the seeming association between HR-mean and
% AUPC is mainly driven by whether participants aborted, or not.
% Since many participants showed an rebound below BL levels after prolonged CPT, mean CPT ist not a good measure!!!!!
% 
% %%%% Is maxHR during CPT (CPT-HR-response) associated with %AUPC (before
% % treatment)
% plot(dfw_c.CPT_HR_mean_change_from_BL_pre,dfw_c.aucrating_perc_pre,'.')
% xlabel('mean HR response pre-treatment CPT (mean increase from BL in bpm)')
% ylabel('%AUPC pre-treatment CPT')
% l1=lsline;l1.LineStyle='--';
% [R,P,RLO,RUP]=corrcoef(dfw_c.CPT_HR_mean_change_from_BL_pre,dfw_c.aucrating_perc_pre)
% [Rho,Ppart] = partialcorr(dfw_c.CPT_HR_mean_change_from_BL_pre,dfw_c.aucrating_perc_pre,dummyvar(dfw_c.study)) 
% lm_hrmean_vs_AUPCpre=fitlm(dfw_c,'aucrating_perc_pre~study+CPT_HR_mean_change_from_BL_pre',...
%                     'RobustOpts','on')
% refline(lm_hrmean_vs_AUPCpre.Coefficients{'CPT_HR_mean_change_from_BL_pre','Estimate'},...
%         lm_hrmean_vs_AUPCpre.Coefficients{'(Intercept)','Estimate'})
% annotation('textbox',[.6 .7 .2 .2],...
%             'String', strcat('Uncorrected correlation: r = ',sprintf('%0.2f',R(2)), ' p = ',sprintf('%0.2f',P(2))),...
%             'FitBoxToText','on')
%         
% annotation('textbox',[.6 .2 .2 .2],...
%             'String', strcat('Study-corrected: r = ',sprintf('%0.2f',Rho), ' p = ',sprintf('%0.2f',Ppart)),...
%             'FitBoxToText','on')               
% % >> No real association
%    
% %%%% Correlation Analysis IId:
% %%%% Is maxHR during CPT (CPT-HR-response) associated with %AUPC (after
% % treatment)
% plot(dfw_c.CPT_HR_mean_change_from_BL_post,dfw_c.aucrating_perc_post,'.')
% xlabel('HR-peak response post-treatment CPT (abs increase from BL in bpm)')
% ylabel('%AUPC post-treatment CPT')
% l1=lsline;l1.LineStyle='--';
% [R,P,RLO,RUP]=corrcoef(dfw_c.CPT_HR_mean_change_from_BL_post,dfw_c.aucrating_perc_post)
% [Rho,Ppart] = partialcorr(dfw_c.CPT_HR_mean_change_from_BL_post,dfw_c.aucrating_perc_post,dummyvar(dfw_c.study)) 
% lm_hrmean_vs_AUPCpost=fitlm(dfw_c,'aucrating_perc_post~study+CPT_HR_mean_change_from_BL_post',...
%                     'RobustOpts','on')
% refline(lm_hrmean_vs_AUPCpost.Coefficients{'CPT_HR_mean_change_from_BL_post','Estimate'},...
%         lm_hrmean_vs_AUPCpost.Coefficients{'(Intercept)','Estimate'})
% annotation('textbox',[.6 .7 .2 .2],...
%             'String', strcat('Uncorrected correlation: r = ',sprintf('%0.2f',R(2)), ' p = ',sprintf('%0.2f',P(2))),...
%             'FitBoxToText','on')
%         
% annotation('textbox',[.6 .2 .2 .2],...
%             'String', strcat('Study-corrected: r = ',sprintf('%0.2f',Rho), ' p = ',sprintf('%0.2f',Ppart)),...
%             'FitBoxToText','on')               
% % >> No real association


% Correlation Analysis III: Is placebo treatment induced change in HRmax associated
% with treatment induced change in %AUPC

treats=unique(dfw_c.treat);

for i=1:length(treats)
    figure

    dfw_temp=dfw_c(dfw_c.treat==treats(i),:);
    plot(dfw_temp.CPT_HR_max_change_from_BL_diff,...
         dfw_temp.AUC_diff,'.','Color',treatcolors{i},'MarkerEdgeColor',treatcolors{i})

    l1=lsline;l1.LineStyle='--';l1.Color=treatcolors{i};
    [R,P]=corr(dfw_temp.CPT_HR_max_diff,dfw_temp.AUC_diff,'Type','Kendall')
    [Rho,Ppart] = partialcorr(dfw_temp.CPT_HR_max_diff,dfw_temp.AUC_diff,dummyvar(dfw_temp.study)) 
    lm_hrmax_vs_AUPCpost=fitlm(dfw_temp,'AUC_diff~study+CPT_HR_max_diff',...
                        'RobustOpts','on')
    l2=refline(lm_hrmax_vs_AUPCpost.Coefficients{'CPT_HR_max_diff','Estimate'},...
            lm_hrmax_vs_AUPCpost.Coefficients{'(Intercept)','Estimate'});
    l2.Color=treatcolors{i};
    annotation('textbox',[.5 .70 .2 .2],...
                'String', strcat('Uncorrected correlation: tau = ',sprintf('%0.2f',R), ' p = ',sprintf('%0.2f',P)),...
                'FitBoxToText','on')
    annotation('textbox',[.5 .1 .2 .2],...
                'String', strcat('Study-corrected: r = ',sprintf('%0.2f',Rho), ' p = ',sprintf('%0.2f',Ppart)),...
                'FitBoxToText','on')  
    xlabel('Treatment related CPT HR-peak response change (post-pre)')
    ylabel('Treatment related CPT %AUPC change (post-pre)')
    xlim([min(dfw_c.CPT_HR_max_change_from_BL_diff) max(dfw_c.CPT_HR_max_change_from_BL_diff)]);
    ylim([min(dfw_c.AUC_diff) max(dfw_c.AUC_diff)]);
    
    currsvg=strcat(['../paper_placebo_taste/figure_HR_vs_AUPC_treat_', char(treats(i)),'.svg']);
    currpng=strcat(['../paper_placebo_taste/figure_HR_vs_AUPC_treat_', char(treats(i)),'.png']);
    hgexport(gcf, currsvg, hgexport('factorystyle'), 'Format', 'svg'); 
    hgexport(gcf, currpng, hgexport('factorystyle'), 'Format', 'png'); 
    crop(currpng);
end


lm_HR_vs_AUPC=fitlm(dfw_c,'aucrating_perc_post~study+aucrating_perc_pre+CPT_HR_max_diff*treat','RobustOpts','on');
lm_HR_vs_AUPC_F_test=anova(lm_HR_vs_AUPC);

tic
f = waitbar(0,'%','Name','Permuting...');
i=0;
warningcount=0;
perms=5000; %repetitions for permutation testing
while i<perms
    waitbar(i/perms,f)

    lastwarn('', ''); %In some cases robustfit will not converge on iterations and throw a warning message. This occurs especially when using Matlab's Standard Bisquare Robust Weighting option
    dfw_c.treat_reordered_rand=shuffle(dfw_c.treat);
    dfw_c.CPT_HR_max_diff_reordered_rand=shuffle(dfw_c.CPT_HR_max_diff);
    curr_mdl_treat=fitlm(dfw_c,'aucrating_perc_post~study+aucrating_perc_pre+CPT_HR_max_diff_reordered_rand*treat_reordered_rand');
    [warnMsg, warnId] = lastwarn();
    if~isempty(warnId) %repeat loop in case of warning msg >> non-converging permutations excluded
        warnMsg
        warningcount=warningcount+1
                continue;
    else
        i=i+1;
    end
    t_perm_treat(:,i)=curr_mdl_treat.Coefficients.Estimate;
    curr_anova=anova(curr_mdl_treat);
    F_perm(:,i)=curr_anova.F(1:end-1);
end
toc
warningcount
p_ANOVA_perm=(sum(F_perm>repmat(lm_HR_vs_AUPC_F_test.F(1:end-1),[1,length(F_perm)]),2)+1)...
                    /(length(F_perm)+1)
%Add Permutation p-Value to ANOVA Results
lm_HR_vs_AUPC_F_test.pPerm=NaN(size(lm_HR_vs_AUPC_F_test,1),1); lm_HR_vs_AUPC_F_test.pPerm(1)=p_ANOVA_perm(1);lm_HR_vs_AUPC_F_test.pPerm(3)=p_ANOVA_perm(3);lm_HR_vs_AUPC_F_test.pPerm(4)=p_ANOVA_perm(4);


end