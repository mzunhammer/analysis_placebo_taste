function analysis_BP(dfl_c,dfw_c, treatlabels, varargin)

dfw_c.SYS_CPT_effect_pre= dfw_c.SYS_after_CPT_pre-dfw_c.SYS_before_CPT_pre;
dfw_c.SYS_CPT_effect_post= dfw_c.SYS_after_CPT_post-dfw_c.SYS_before_CPT_post;
dfw_c.DIA_CPT_effect_pre= dfw_c.DIA_after_CPT_pre-dfw_c.DIA_before_CPT_pre;
dfw_c.DIA_CPT_effect_post= dfw_c.DIA_after_CPT_post-dfw_c.DIA_before_CPT_post;


bpvars = ...
{'SYS_before_CPT_pre'                         
 'SYS_after_CPT_pre'                          
 'DIA_before_CPT_pre'                         
 'DIA_after_CPT_pre' 
 'SYS_before_CPT_post'                         
 'SYS_after_CPT_post'                          
 'DIA_before_CPT_post'                         
 'DIA_after_CPT_post'
 'SYS_CPT_effect_pre'
 'SYS_CPT_effect_post'
 'DIA_CPT_effect_pre'
 'DIA_CPT_effect_post'};
grpstats(dfw_c(:,['treat',bpvars']),'treat',{'mean','std'})

grpstats(dfw_c(:,['healthy',bpvars']),'healthy',{'mean','std'})

treatcolors={[0,0,0],[0.6,0.6,0.6],[0,0.3,0.7],[0.7,0,0.3]};
y_label='BP Systolic';
figure
[~,h_means]=groupplot(dfw_c.treat,dfw_c.DIA_CPT_effect_post,'group_color',treatcolors);
ylabel(y_label)
xticklabels(treatlabels);
hline(0,'color',[0 0 0])


%% PLOT BP-Measurements over time:
dfl_c_beforeCPT=dfl_c(:,{'treat','prepost','SYS_before_CPT','DIA_before_CPT'});
dfl_c_beforeCPT.prepost(dfl_c_beforeCPT.prepost=='2')='3';
dfl_c_beforeCPT.Properties.VariableNames={'treat','prepost','SYS','DIA'};
dfl_c_afterCPT=dfl_c(:,{'treat','prepost','SYS_after_CPT','DIA_after_CPT'});
dfl_c_afterCPT.prepost(dfl_c_afterCPT.prepost=='2')='4';
dfl_c_afterCPT.prepost(dfl_c_afterCPT.prepost=='1')='2';
dfl_c_afterCPT.Properties.VariableNames={'treat','prepost','SYS','DIA'};
dfll_c=[dfl_c_beforeCPT;dfl_c_afterCPT];

close all
[~,h_means]=groupplot2_BP(dfll_c.treat,dfll_c.prepost,dfll_c.SYS);
hold on
[~,h_means]=groupplot2_BP(dfll_c.treat,dfll_c.prepost,dfll_c.DIA);
hold off

h=gca
treats=unique(dfll_c.treat)
for i=1:numel(treats)
j=(i-1)*0.75;
text(h,0.75+j, 100, treatlabels(i),'FontSize',9,'HorizontalAlignment','center')
text(h,0.500+j, 59, 'preCTP','FontSize',9,'HorizontalAlignment','right', 'Rotation',45)
text(h,0.625+j, 65, 'preTr','FontSize',9,'HorizontalAlignment','center')
text(h,0.666+j, 59, 'postCPT','FontSize',9,'HorizontalAlignment','right', 'Rotation',45)
text(h,0.833+j,  59, 'preCPT','FontSize',9,'HorizontalAlignment','right', 'Rotation',45)
text(h,0.875+j,  65, 'postTr','FontSize',9,'HorizontalAlignment','center')
text(h,1.000+j,  59, 'postCPT','FontSize',9,'HorizontalAlignment','right', 'Rotation',45)
end
axis([0.25,3.5,60,140])
text(h,3.4, 80, 'Diastolic BP','FontSize',9,'HorizontalAlignment','right', 'Rotation',90)
text(h,3.4, 130,'Systolic BP','FontSize',9,'HorizontalAlignment','right', 'Rotation',90)
set(gca,'xticklabel',{[]},'XTick',[])

hgexport(gcf, '../paper_placebo_taste/figureBP.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figureBP.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figureBP.png');
%% GLM1: Sanity check: Are there baseline (pre-CPT, pre-treatment differences
% between treatment groups)
dfw_c.treat_reordered=reordercats(dfw_c.treat,{'0','1','2','3'});
lm_SYS_before_CPT_pre=fitlm(dfw_c,...
                    'SYS_before_CPT_pre~study+treat_reordered',...
                    'RobustOpts','on')
anova_lm_SYS_before_CPT_pre=anova(lm_SYS_before_CPT_pre)
partial_eta_sq=anova_lm_SYS_before_CPT_pre.SumSq./(anova_lm_SYS_before_CPT_pre.SumSq+anova_lm_SYS_before_CPT_pre.SumSq('Error'));
model_diagnostics(lm_SYS_before_CPT_pre)

dfw_c.treat_reordered=reordercats(dfw_c.treat,{'0','1','2','3'});
lm_DIA_before_CPT_pre=fitlm(dfw_c,...
                    'DIA_before_CPT_pre~study+treat_reordered',...
                    'RobustOpts','on')
anova_lm_DIA_before_CPT_pre=anova(lm_DIA_before_CPT_pre)
partial_eta_sq=anova_lm_DIA_before_CPT_pre.SumSq./(anova_lm_DIA_before_CPT_pre.SumSq+anova_lm_DIA_before_CPT_pre.SumSq('Error'));
model_diagnostics(lm_DIA_before_CPT_pre)
% >>> No prominent group differences


% GLM2: Did treatment group affect post-treatment baseline, pre-CPT BP?
lm_SYS_before_CPT_post=fitlm(dfw_c,...
                    'SYS_before_CPT_post~SYS_before_CPT_pre+study+treat_reordered',...
                    'RobustOpts','on')
anova_SYS_before_CPT_post=anova(lm_SYS_before_CPT_post)
partial_eta_sq=anova_SYS_before_CPT_post.SumSq./(anova_SYS_before_CPT_post.SumSq+anova_SYS_before_CPT_post.SumSq('Error'));
model_diagnostics(lm_SYS_before_CPT_post)

lm_DIA_before_CPT_post=fitlm(dfw_c,...
                    'DIA_before_CPT_post~DIA_before_CPT_pre+study+treat_reordered',...
                    'RobustOpts','on')
anova_DIA_before_CPT_post=anova(lm_DIA_before_CPT_post)
partial_eta_sq=anova_DIA_before_CPT_post.SumSq./(anova_DIA_before_CPT_post.SumSq+anova_DIA_before_CPT_post.SumSq('Error'));
model_diagnostics(lm_DIA_before_CPT_post)
% >>> No clear group differences, but in the sweet group, post-treatment
% Diastolic BP tended to be elevated

% GLM3: Did treatment group affect pre-to-post-CPT increases in post-treatment BP?
lm_SYS_after_CPT_post=fitlm(dfw_c,...
                    'SYS_after_CPT_post~SYS_before_CPT_post+study+treat_reordered',...
                    'RobustOpts','on')
anova_SYS_after_CPT_post=anova(lm_SYS_after_CPT_post)
partial_eta_sq=anova_SYS_after_CPT_post.SumSq./(anova_SYS_after_CPT_post.SumSq+anova_SYS_after_CPT_post.SumSq('Error'));
model_diagnostics(lm_SYS_after_CPT_post)


lm_DIA_after_CPT_post=fitlm(dfw_c,...
                    'DIA_after_CPT_post~DIA_before_CPT_post+study+treat_reordered',...
                    'RobustOpts','on')
anova_DIA_after_CPT_post=anova(lm_DIA_after_CPT_post)
partial_eta_sq=anova_DIA_after_CPT_post.SumSq./(anova_DIA_after_CPT_post.SumSq+anova_DIA_after_CPT_post.SumSq('Error'));
model_diagnostics(lm_DIA_after_CPT_post)
% >>> No clear group differences, but in the sweet group, post-treatment
% Diastolic BP tended to be elevated

% GLM4: Did treatment group affect pre-to-post-CPT increases in BP differently than pre-to-post-CPT increases before treatment?
lm_SYS_after_CPT_post=fitlm(dfw_c,...
                    'SYS_CPT_effect_post~SYS_CPT_effect_pre+study+treat_reordered',...
                    'RobustOpts','on')
anova_SYS_after_CPT_post=anova(lm_SYS_after_CPT_post)
partial_eta_sq=anova_SYS_after_CPT_post.SumSq./(anova_SYS_after_CPT_post.SumSq+anova_SYS_after_CPT_post.SumSq('Error'));
model_diagnostics(lm_SYS_after_CPT_post)

lm_DIA_after_CPT_post=fitlm(dfw_c,...
                    'DIA_CPT_effect_post~DIA_CPT_effect_pre+study+treat_reordered',...
                    'RobustOpts','on')
anova_DIA_after_CPT_post=anova(lm_DIA_after_CPT_post)
partial_eta_sq=anova_DIA_after_CPT_post.SumSq./(anova_DIA_after_CPT_post.SumSq+anova_DIA_after_CPT_post.SumSq('Error'));
model_diagnostics(lm_DIA_after_CPT_post)



end