function analysis_HR(dfl_c,dfw_c)

%% SUPPLEMENT 2a: plot FULL HR curves
h_means=cpt_timeplot2(dfl_c.prepost,dfl_c.treat,dfl_c.CPT_HR,80);
hs = findall(gcf,'Type','axes');
xticks(hs(5:8),[])
yticks(hs([1,2]),[])

title(hs(8),treatlabels(1));
title(hs(7),treatlabels(2));
title(hs(6),treatlabels(3));
title(hs(5),treatlabels(4));

ylabel(hs(4),'Heart rate (bpm)');
ylabel(hs(8),'Heart rate (bpm)');
xlabel(hs(1),'Time (s)');
xlabel(hs(2),'Time (s)');
xlabel(hs(3),'Time (s)');
xlabel(hs(4),'Time (s)');

text(hs(4),-0.6, 0.5, 'post','Units','normalized','FontWeight','bold','FontSize',11)
text(hs(8),-0.6, 0.5, 'pre','Units','normalized','FontWeight','bold','FontSize',11)

hgexport(gcf, '../paper_placebo_taste/figure2Sa.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure2Sa.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure2Sa.png');

%% SUPPLEMENT 2b: plot MEAN HR curves
h_means=cpt_timeplot_means(dfl_c.treat,dfl_c.prepost,dfl_c.CPT_HR,dfl_c.maxtime,[60,100],80);
hs = findall(gcf,'Type','axes');
title(hs(4),treatlabels(1));
title(hs(3),treatlabels(2));
title(hs(2),treatlabels(3));
title(hs(1),treatlabels(4));
yticks(hs([1,2]),[])
ylabel(hs(4),'Mean heart rate (bpm) ± 95% CI');
xlabel(hs(1),'Time (s)');
xlabel(hs(2),'Time (s)');
xlabel(hs(3),'Time (s)');
xlabel(hs(4),'Time (s)');
text(hs(4),0.85, 0.45, 'pre','Units','normalized','FontSize',11)
text(hs(4),0.85, 0.15, 'post','Units','normalized','FontSize',11)
text(hs(3),0.85, 0.45, 'pre','Units','normalized','FontSize',11)
text(hs(3),0.85, 0.15, 'post','Units','normalized','FontSize',11)
text(hs(2),0.85, 0.45, 'pre','Units','normalized','FontSize',11)
text(hs(2),0.85, 0.15, 'post','Units','normalized','FontSize',11)
text(hs(1),0.85, 0.45, 'pre','Units','normalized','FontSize',11)
text(hs(1),0.85, 0.15, 'post','Units','normalized','FontSize',11)
hgexport(gcf, '../paper_placebo_taste/figure2Sb.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure2Sb.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure2Sb.png');


%% GLM correct HR
dfw_c.z_CPT_HR_max_pre=nanzscore(dfw_c.CPT_HR_max_pre);
dfw_c.z_CPT_HR_max_post=nanzscore(dfw_c.CPT_HR_max_post);
dfw_c.z_CPT_HR_max_diff=nanzscore(dfw_c.CPT_HR_max_diff);
dfw_c.z_TT_TU=nanzscore(dfw_c.TT_TU);
dfl_c.z_TT_TU=nanzscore(dfl_c.TT_TU);

HR_max_temp=fitlm(dfl_c,'CPT_HR_max~z_TT_TU','RobustOpts','fair')

HR_max_pre_temp=fitlm(dfw_c,'CPT_HR_max_pre~z_TT_TU','RobustOpts','fair')
HR_max_post_temp=fitlm(dfw_c,'CPT_HR_max_post~z_TT_TU','RobustOpts','fair')
HR_max_diff_temp=fitlm(dfw_c,'CPT_HR_max_diff~z_TT_TU','RobustOpts','fair')

dfl_c.HR_max_temp_correct=HR_max_temp.Residuals.Raw+HR_max_temp.Coefficients.Estimate(1);

dfw_c.HR_max_pre_temp_correct=HR_max_pre_temp.Residuals.Raw+HR_max_pre_temp.Coefficients.Estimate(1);
dfw_c.HR_max_post_temp_correct=HR_max_post_temp.Residuals.Raw+HR_max_post_temp.Coefficients.Estimate(1);
dfw_c.HR_max_diff_temp_correct=HR_max_diff_temp.Residuals.Raw+HR_max_diff_temp.Coefficients.Estimate(1);

%% Figure 2a: plot HR pre versus post
% Extreme HR-Differences:
% - Subject 98: extreme peak in 1st CPT, 2nd CPT recording looks artefactually
% flat.
% - Subject 277: extreme peaking in 1st and 2ndt CPT, but still in
% physiological range. Looks letigimate.

subplot(1,2,1)
[~,h_means]=groupplot2(dfl_c.treat,dfl_c.prepost,dfl_c.HR_max_temp_correct);
title('Max heart rate',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
h=gca;
text(h,0.3125, 120, 'pre','FontSize',9,'HorizontalAlignment','left')
text(h,0.6875, 120, 'post','FontSize',9,'HorizontalAlignment','right')
text(h,0.8125, 120, 'pre','FontSize',9,'HorizontalAlignment','left')
text(h,1.1875, 120, 'post','FontSize',9,'HorizontalAlignment','right')
text(h,1.3175, 120, 'pre','FontSize',9,'HorizontalAlignment','left')
text(h,1.6875, 120, 'post','FontSize',9,'HorizontalAlignment','right')
ylabel('Max heart rate (bpm) ± 95% CI')
xticklabels(treatlabels);
xtickangle(45)
pbaspect([1 2 1])

% Figure 2b: plot HR change: post-pre
subplot(1,2,2)
pbaspect([2 1 1])
unicodeminus = sprintf(strrep('\u2212', '\u', '\x'));

[~,h_means]=groupplot(dfw_c.treat,dfw_c.HR_max_diff_temp_correct); %dfw_c.CPT_HR_max_diff 
title('Change in max heart rate',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
ylabel('Max heart rate (bpm) ± 95% CI')
xticklabels(treatlabels);
xtickangle(45)
hline(0,'color',[0 0 0])
pbaspect([1 2 1])

annotation('arrow',...
           [0.48 0.52],[.5 .5],...
           'HeadStyle','plain',...
           'Units','Normalized');
annotation('textbox',...
           [0.48, 0.58, .04, .04],...
           'String',['post ' unicodeminus ' pre'],...
           'Units','Normalized',...
           'FontWeight','bold',...
           'HorizontalAlignment','center',...
           'LineStyle','none');
       
hgexport(gcf, '../paper_placebo_taste/figure2.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure2.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure2.png');

%% GLM analysis mean HR
% Mixed model version (too complicated to communicate, equivalent results):
% HRmm1=fitlme(dfl_c,'CPT_HR_mean~prepost*treat+(1|subject_no)',...
%                'CheckHessian',1,...
%                'DummyVarCoding','effects')
dfw_c.z_CPT_HR_mean_pre=nanzscore(dfw_c.CPT_HR_mean_pre);
dfw_c.z_CPT_HR_mean_post=nanzscore(dfw_c.CPT_HR_mean_post);
dfw_c.z_CPT_HR_max_pre=nanzscore(dfw_c.CPT_HR_max_pre);
dfw_c.z_CPT_HR_max_post=nanzscore(dfw_c.CPT_HR_max_post);
dfw_c.z_lab_time_before_pre_treat_CPT=nanzscore(dfw_c.lab_time_before_pre_treat_CPT);
dfw_c.z_TT_TU=nanzscore(dfw_c.TT_TU);

HRlm1=fitlm(dfw_c,'z_CPT_HR_mean_post~z_CPT_HR_mean_pre+z_TT_TU+treat',...
            'DummyVarCoding','effects','RobustOpts','fair')
        
HRlm1=fitlm(dfw_c,'z_CPT_HR_max_post~z_CPT_HR_max_pre+z_TT_TU+treat',...
            'DummyVarCoding','effects','RobustOpts','fair')
anova(HRlm1)
anova(HRlm1,'summary')
plot(predict(HRlm1),HRlm1.Residuals.Studentized,'.')
excluded_HR=abs(HRlm1.Residuals.Studentized>4);

HRlm2=fitlm(dfw_c,'z_CPT_HR_mean_post~z_CPT_HR_mean_pre+z_lab_time_before_pre_treat_CPT+treat',...
            'DummyVarCoding','effects')
anova(HRlm2)
anova(HRlm2,'summary')
plot(predict(HRlm2),HRlm1.Residuals.Studentized,'.')
end