function analysis_side_effects(dfw_c)

%% Figure X: plot sumUAW 
figure
pbaspect([1 1 1])
[~,h_means]=groupplot(dfw_c.treat,dfw_c.sumUAW_post);
title('Side effects score',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
ylabel('Side effects score ± 95% CI')
xticklabels(treatlabels);
xtickangle(45)
hline(0,'color',[0 0 0])
pbaspect([1 1 1])

%set(gcf, 'Position', [0 0 960 540])
hgexport(gcf, '../paper_placebo_taste/figureUAW.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figureUAW.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figureUAW.png');




% GLM analysis UAW
% Mixed model version (too complicated to communicate, equivalent results):
% AUPCmm1=fitlme(dfl_c,'aucrating_perc~prepost*treat+(1|subject_no)',...
%                'CheckHessian',1,...
%                'DummyVarCoding','effects')
'Participants with  Side Effects'
sum(dfw_c.sumUAW_post>0)
'Participants without  Side Effects'
length(dfw_c.sumUAW_post)-sum(dfw_c.sumUAW_post>0)
(length(dfw_c.sumUAW_post)-sum(dfw_c.sumUAW_post>0))/length(dfw_c.sumUAW_post)


%% Create sub-dfs limited to placebo-conditions
dfl_c_pla=dfl_c(dfl_c.treat~='0',:);
dfl_c_pla.treat = removecats(dfl_c_pla.treat);
dfw_c_pla=dfw_c(dfw_c.treat~='0',:);
dfw_c_pla.treat = removecats(dfw_c_pla.treat);

dfw_c_pla.z_UAW_perc_post=nanzscore(dfw_c_pla.sumUAW_post);
dfw_c_pla.treat_reordered=reordercats(dfw_c_pla.treat,{'1','2','3'});

UAW_lm1=fitlm(dfw_c_pla,'sumUAW_post~treat_reordered+study','RobustOpts','on')
UAW_lm1_anova=anova(UAW_lm1)
anova(UAW_lm1,'summary')
(UAW_lm1_anova.SumSq)/(UAW_lm1_anova.SumSq+UAW_lm1_anova.SumSq('Error')) % partial eta squared

UAW_lm2=fitlm(dfw_c_pla(dfw_c_pla.sumUAW_post>0,:),'sumUAW_post~treat_reordered+study','RobustOpts','on')
UAW_lm2_anova=anova(UAW_lm2)
anova(UAW_lm2,'summary')
(UAW_lm2_anova.SumSq)/(UAW_lm2_anova.SumSq+UAW_lm2_anova.SumSq('Error'))


