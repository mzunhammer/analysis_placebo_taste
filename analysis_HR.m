function analysis_HR(dfl_c,dfw_c, treatlabels, varargin)
% Flags for varargin:
% 'singlecurves': Will create a plot of all CPT rating curves
% 'averagecurves': Will create a plot of averaged CPT rating curves

%% SUPPLEMENT 2a v A: plot FULL, raw HR curves
if any(strcmp(varargin,'singlecurves'))
    h_means=cpt_timeplot2(dfl_c.prepost,dfl_c.treat,dfl_c.CPT_HR,80);
    hs = findall(gcf,'Type','axes');
    xticklabels(hs(5:8),[])
    yticklabels(hs([1,2]),[])

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

    %hgexport(gcf, '../paper_placebo_taste/figure2Sa.svg', hgexport('factorystyle'), 'Format', 'svg'); 
    %hgexport(gcf, '../paper_placebo_taste/figure2Sa.png', hgexport('factorystyle'), 'Format', 'png'); 
    %crop('../paper_placebo_taste/figure2Sa.png');

% SUPPLEMENT 2a v B: plot FULL, HR curves in % of baseline
    h_means=cpt_timeplot2(dfl_c.prepost,dfl_c.treat,dfl_c.CPT_HR_perc_BL,80);
    hs = findall(gcf,'Type','axes');
    xticklabels(hs(5:8),[])
    yticklabels(hs([1,2]),[])

    title(hs(8),treatlabels(1));
    title(hs(7),treatlabels(2));
    title(hs(6),treatlabels(3));
    title(hs(5),treatlabels(4));

    ylabel(hs(4),'Heart rate (%baseline)');
    ylabel(hs(8),'Heart rate (%baseline)');
    xlabel(hs(1),'Time (s)');
    xlabel(hs(2),'Time (s)');
    xlabel(hs(3),'Time (s)');
    xlabel(hs(4),'Time (s)');

    text(hs(4),-0.6, 0.5, 'post','Units','normalized','FontWeight','bold','FontSize',11)
    text(hs(8),-0.6, 0.5, 'pre','Units','normalized','FontWeight','bold','FontSize',11)

    %hgexport(gcf, '../paper_placebo_taste/figure2Sa.svg', hgexport('factorystyle'), 'Format', 'svg'); 
    %hgexport(gcf, '../paper_placebo_taste/figure2Sa.png', hgexport('factorystyle'), 'Format', 'png'); 
    %crop('../paper_placebo_taste/figure2Sa.png');
end
%% SUPPLEMENT 2a v A: plot MEAN HR curves
if any(strcmp(varargin,'averagecurves'))
    h_means=cpt_timeplot_means(dfl_c.treat,dfl_c.prepost,dfl_c.CPT_HR,dfl_c.maxtime,[60,100],80);
    hs = findall(gcf,'Type','axes');
    title(hs(4),treatlabels(1));
    title(hs(3),treatlabels(2));
    title(hs(2),treatlabels(3));
    title(hs(1),treatlabels(4));
    yticklabels(hs([1,2]),[])
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
    %hgexport(gcf, '../paper_placebo_taste/figure2Sb.svg', hgexport('factorystyle'), 'Format', 'svg'); 
    %hgexport(gcf, '../paper_placebo_taste/figure2Sb.png', hgexport('factorystyle'), 'Format', 'png'); 
    %crop('../paper_placebo_taste/figure2Sb.png');

    %% SUPPLEMENT 2a v B: plot MEAN HR curves, in % baseline
    h_means=cpt_timeplot_means(dfl_c.treat,dfl_c.prepost,dfl_c.CPT_HR_perc_BL,dfl_c.maxtime,[80,120],80);
    hs = findall(gcf,'Type','axes');
    title(hs(4),treatlabels(1));
    title(hs(3),treatlabels(2));
    title(hs(2),treatlabels(3));
    title(hs(1),treatlabels(4));
    yticklabels(hs([1,2]),[])
    ylabel(hs(4),'Mean heart rate (%baseline) ± 95% CI');
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
    %hgexport(gcf, '../paper_placebo_taste/figure2Sb.svg', hgexport('factorystyle'), 'Format', 'svg'); 
    %hgexport(gcf, '../paper_placebo_taste/figure2Sb.png', hgexport('factorystyle'), 'Format', 'png'); 
    %crop('../paper_placebo_taste/figure2Sb.png');
end

%% GLM correct HR mean
dfw_c.z_CPT_HR_mean_pre=nanzscore(dfw_c.CPT_HR_mean_pre);
dfw_c.z_CPT_HR_mean_post=nanzscore(dfw_c.CPT_HR_mean_post);
dfw_c.z_CPT_HR_mean_diff=nanzscore(dfw_c.CPT_HR_mean_diff);
dfw_c.z_TT_TU=nanzscore(dfw_c.TT_TU);
dfl_c.z_TT_TU=nanzscore(dfl_c.TT_TU);

HR_mean_temp=fitlm(dfl_c,'CPT_HR_mean~z_TT_TU','RobustOpts','fair')

HR_mean_pre_temp=fitlm(dfw_c,'CPT_HR_mean_pre~z_TT_TU','RobustOpts','fair')
HR_mean_post_temp=fitlm(dfw_c,'CPT_HR_mean_post~z_TT_TU','RobustOpts','fair')
HR_mean_diff_temp=fitlm(dfw_c,'CPT_HR_mean_diff~z_TT_TU','RobustOpts','fair')

dfl_c.HR_mean_temp_correct=HR_mean_temp.Residuals.Raw+HR_mean_temp.Coefficients.Estimate(1);

dfw_c.HR_mean_pre_temp_correct=HR_mean_pre_temp.Residuals.Raw+HR_mean_pre_temp.Coefficients.Estimate(1);
dfw_c.HR_mean_post_temp_correct=HR_mean_post_temp.Residuals.Raw+HR_mean_post_temp.Coefficients.Estimate(1);
dfw_c.HR_mean_diff_temp_correct=HR_mean_diff_temp.Residuals.Raw+HR_mean_diff_temp.Coefficients.Estimate(1);

%% GLM correct HR mean perc BL
dfw_c.z_CPT_HR_mean_perc_BL_pre=nanzscore(dfw_c.CPT_HR_mean_perc_BL_pre);
dfw_c.z_CPT_HR_mean_perc_BL_post=nanzscore(dfw_c.CPT_HR_mean_perc_BL_post);
dfw_c.z_CPT_HR_mean_perc_BL_diff=nanzscore(dfw_c.CPT_HR_mean_perc_BL_diff);
dfw_c.z_TT_TU=nanzscore(dfw_c.TT_TU);
dfl_c.z_TT_TU=nanzscore(dfl_c.TT_TU);

HR_mean_perc_BL_temp=fitlm(dfl_c,'CPT_HR_mean_perc_BL~z_TT_TU','RobustOpts','fair')

HR_mean_perc_BL_pre_temp=fitlm(dfw_c,'CPT_HR_mean_perc_BL_pre~z_TT_TU','RobustOpts','fair')
HR_mean_perc_BL_post_temp=fitlm(dfw_c,'CPT_HR_mean_perc_BL_post~z_TT_TU','RobustOpts','fair')
HR_mean_perc_BL_diff_temp=fitlm(dfw_c,'CPT_HR_mean_perc_BL_diff~z_TT_TU','RobustOpts','fair')

dfl_c.HR_mean_perc_BL_temp_correct=HR_mean_perc_BL_temp.Residuals.Raw+HR_mean_perc_BL_temp.Coefficients.Estimate(1);

dfw_c.HR_mean_perc_BL_pre_temp_correct=HR_mean_perc_BL_pre_temp.Residuals.Raw+HR_mean_perc_BL_pre_temp.Coefficients.Estimate(1);
dfw_c.HR_mean_perc_BL_post_temp_correct=HR_mean_perc_BL_post_temp.Residuals.Raw+HR_mean_perc_BL_post_temp.Coefficients.Estimate(1);
dfw_c.HR_mean_perc_BL_diff_temp_correct=HR_mean_perc_BL_diff_temp.Residuals.Raw+HR_mean_perc_BL_diff_temp.Coefficients.Estimate(1);



%% GLM correct HR max
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



%% Figure 2a v A: plot HR pre versus post (HR_mean)
figure
subplot(1,2,1)
[~,h_means]=groupplot2(dfl_c.treat,dfl_c.prepost,dfl_c.HR_mean_temp_correct);
title('Mean heart rate',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
h=gca;
ylabel('Mean heart rate (bpm) ± 95% CI')
xticklabels(treatlabels);
xtickangle(45)
pbaspect([1 2 1])

% Figure 2b: plot HR change: post-pre
subplot(1,2,2)
pbaspect([2 1 1])
unicodeminus = sprintf(strrep('\u2212', '\u', '\x'));

[~,h_means]=groupplot(dfw_c.treat,dfw_c.HR_mean_diff_temp_correct); %dfw_c.CPT_HR_max_perc_BL_diff 
title('Change in mean heart rate',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
ylabel('Mean heart rate (bpm) ± 95% CI')
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

%% Figure 2a v B: plot HR pre versus post (HR_max)
figure
subplot(1,2,1)
[~,h_means]=groupplot2(dfl_c.treat,dfl_c.prepost,dfl_c.HR_max_temp_correct);
title('Max heart rate',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
h=gca;
ylabel('Max heart rate (BPM) ± 95% CI')
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
ylabel('Max heart rate (BPM) ± 95% CI')
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

%% Figure 2a v C: plot HR pre versus post (HR_mean_perc_BL)
figure
subplot(1,2,1)
[~,h_means]=groupplot2(dfl_c.treat,dfl_c.prepost,dfl_c.HR_mean_perc_BL_temp_correct);
title('Mean heart rate during CPT in % BL',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
h=gca;
ylabel('Mean heart rate (%BL) ± 95% CI')
xticklabels(treatlabels);
xtickangle(45)
pbaspect([1 2 1])

% Figure 2b: plot HR change: post-pre
subplot(1,2,2)
pbaspect([2 1 1])
unicodeminus = sprintf(strrep('\u2212', '\u', '\x'));

[~,h_means]=groupplot(dfw_c.treat,dfw_c.HR_mean_perc_BL_diff_temp_correct); %dfw_c.CPT_HR_max_perc_BL_diff 
title('Change in mean heart rate during CPT in % BL',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
ylabel('Mean heart rate (%BL) ± 95% CI')
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
dfw_c.z_CPT_HR_mean_perc_BL_pre=nanzscore(dfw_c.CPT_HR_mean_perc_BL_pre);
dfw_c.z_CPT_HR_mean_perc_BL_post=nanzscore(dfw_c.CPT_HR_mean_perc_BL_post);
dfw_c.z_CPT_HR_max_pre=nanzscore(dfw_c.CPT_HR_max_pre);
dfw_c.z_CPT_HR_max_post=nanzscore(dfw_c.CPT_HR_max_post);
dfw_c.z_maxtime_pre=nanzscore(dfw_c.maxtime_pre);
dfw_c.z_maxtime_post=nanzscore(dfw_c.maxtime_post);

dfw_c.z_lab_time_before_pre_treat_CPT=nanzscore(dfw_c.lab_time_before_pre_treat_CPT);
dfw_c.z_TT_TU=nanzscore(dfw_c.TT_TU);
dfw_c.treat_reordered=reordercats(dfw_c.treat,{'0','1','2','3'});

HRlm1=fitlm(dfw_c,'z_CPT_HR_mean_post~z_CPT_HR_mean_pre+treat_reordered+bmi+male',...
            'RobustOpts','fair')

HRlm1=fitlm(dfw_c,'CPT_HR_mean_post~z_CPT_HR_mean_pre+z_TT_TU+treat_reordered',...
            'RobustOpts','fair')
                
HRlm1=fitlm(dfw_c,'z_CPT_HR_max_post~z_CPT_HR_max_pre+z_maxtime_post+z_TT_TU+treat_reordered',...
            'RobustOpts','fair')        
%HRlm1=fitlm(dfw_c,'z_CPT_HR_max_post~z_CPT_HR_max_pre+z_TT_TU+treat',...
%            'DummyVarCoding','effects','RobustOpts','fair')
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