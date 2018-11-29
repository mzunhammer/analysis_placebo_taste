function analysis_BP(dfw_c,dfl_c)
%% Figure S4a: plot BP pre versus post
% Figure S4a: plot BP SYS pre and post
subplot(2,2,1)
[~,h_means]=groupplot2(dfl_c.treat,dfl_c.prepost,dfl_c.SYS_after_CPT);
title('Mean systolic BP, pre vs post')
ylabel('Mean systolic BP (bpm) ± 95% CI')
xticklabels(treatlabels);
xtickangle(45)
% Figure S4b: plot BP SYS difference: post-pre
subplot(2,2,2)
pbaspect([2 1 1])
[~,h_means]=groupplot(dfw_c.treat,dfw_c.SYS_after_CPT_post-dfw_c.SYS_after_CPT_pre);
title(['Mean systolic BP, post ' unicodeminus ' pre'])
ylabel('Change systolic BP (bpm) ± 95% CI (post-pre)')
xticklabels(treatlables);
xtickangle(45)
hline(0,'color',[0 0 0])
% Figure S4c: plot BP DIA pre and post
subplot(2,2,3)
[~,h_means]=groupplot2(dfl_c.treat,dfl_c.prepost,dfl_c.DIA_after_CPT);
title('Mean diastolic BP, pre vs post')
ylabel('Mean diastolic BP (bpm) ± 95% CI')
xticklabels(treatlabels);
xtickangle(45)
% Figure S4d: plot BP DIA difference: post-pre
subplot(2,2,4)
[~,h_means]=groupplot(dfw_c.treat,dfw_c.DIA_after_CPT_post-dfw_c.DIA_after_CPT_pre);
title(['Mean diastolic BP, post ' unicodeminus ' pre']);

ylabel('Change diastolic BP (bpm) ± 95% CI (post-pre)')
xticklabels(treatlabels);
xtickangle(45)
hline(0,'color',[0 0 0])
set(gcf, 'Position', [0 0 960 960])
hgexport(gcf, '../paper_placebo_taste/figureS4.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figureS4.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figureS4.png');

%% GLM analysis mean blood pressure
% No effect whatsoever
dfw_c.z_DIA_after_CPT_pre=nanzscore(dfw_c.DIA_after_CPT_pre);
dfw_c.z_DIA_after_CPT_post=nanzscore(dfw_c.DIA_after_CPT_post);
dfw_c.z_SYS_after_CPT_pre=nanzscore(dfw_c.SYS_after_CPT_pre);
dfw_c.z_SYS_after_CPT_post=nanzscore(dfw_c.SYS_after_CPT_post);

dfw_c.z_DIA_change_CPT_pre=nanzscore(dfw_c.DIA_after_CPT_pre-dfw_c.DIA_before_CPT_pre);
dfw_c.z_DIA_change_CPT_post=nanzscore(dfw_c.DIA_after_CPT_post-dfw_c.DIA_before_CPT_post);
dfw_c.z_SYS_change_CPT_pre=nanzscore(dfw_c.SYS_after_CPT_pre-dfw_c.SYS_before_CPT_pre);
dfw_c.z_SYS_change_CPT_post=nanzscore(dfw_c.SYS_after_CPT_post-dfw_c.SYS_before_CPT_post);


DIAlm1=fitlm(dfw_c,'z_DIA_after_CPT_post~z_DIA_after_CPT_pre+treat+z_TT_TU',...
            'RobustOpts','fair')
anova(DIAlm1)
anova(DIAlm1,'summary')
plot(predict(DIAlm1),DIAlm1.Residuals.Studentized,'.')

SYSlm1=fitlm(dfw_c,'z_SYS_after_CPT_post~z_SYS_after_CPT_pre+treat+z_TT_TU',...
            'RobustOpts','fair')
anova(SYSlm1)
anova(SYSlm1,'summary')
plot(predict(SYSlm1),SYSlm1.Residuals.Studentized,'.')
end