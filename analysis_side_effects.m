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
dfw_c.z_UAW_perc_post=nanzscore(dfw_c.sumUAW_post)
dfw_c.treat_reordered=reordercats(dfw_c.treat,{'3','2','1','0'});

UAW_lm1=fitlm(dfw_c,'z_UAW_perc_post~treat_reordered+male+study','DummyVarCoding','effects')
anova(UAW_lm1)
anova(UAW_lm1,'summary')
