function analysis_intervention_checks(dfw_c, dfw_c_pla, treatlabels)
    treatcolors={[0,0,0],[0.6,0.6,0.6],[0,0.3,0.7],[0.7,0,0.3]};
    %% GLMs Treatment related beliefs
    dfw_c_pla.z_maxtime_pre=nanzscore(dfw_c_pla.maxtime_pre); %no
    dfw_c_pla.z_maxtime_post=nanzscore(dfw_c_pla.maxtime_post); %no
    dfw_c_pla.z_treat_expect_post=nanzscore(dfw_c_pla.treat_expect_post); %no
    dfw_c_pla.z_taste_intensity_post=nanzscore(dfw_c_pla.taste_intensity_post); %no
    dfw_c_pla.z_taste_valence_post=nanzscore(dfw_c_pla.taste_valence_post); %a little little
    dfw_c_pla.z_treat_efficacy_post=nanzscore(dfw_c_pla.treat_efficacy_post); %yes, indeed
    dfw_c_pla.z_sumUAW_post=nanzscore(dfw_c_pla.sumUAW_post); %pretty sure

    treatvars={'treat',...
               'treat_expect_post','treat_efficacy_post','taste_intensity_post','taste_valence_post','sumUAW_post'};
    ztreatvars={'treat',...
              'treat_expect_post','z_treat_efficacy_post','z_taste_intensity_post','z_taste_valence_post','z_sumUAW_post'};

    dfw_c_pla.treat_reordered=reordercats(dfw_c_pla.treat,{'1','2','3'});
    lm=cell(size(treatvars));
    for i=2:length(treatvars)
    disp(treatvars{i})
    dfw_c_pla.y=dfw_c_pla.(treatvars{i});
    dfw_c_pla.zy=dfw_c_pla.(ztreatvars{i});
    lm{i}=fitlm(dfw_c_pla,'y~study+treat_reordered','RobustOpts','on');
    zlm{i}=fitlm(dfw_c_pla,'zy~study+treat_reordered','RobustOpts','on');
    lm_anova=anova(lm{i})
    lm{i}
    zlm{i}
    (lm_anova.SumSq)/(lm_anova.SumSq+lm_anova.SumSq('Error')) % partial eta squared
    %anova(lm{i},'summary');
    %figure
    %title(treatvars{i})
    %plot(dfw_c_pla.y,lm{i}.Residuals.Studentized,'.')
    end

    %% Extra contrast for taste intensity
    dfw_c_pla.treat_reordered=reordercats(dfw_c_pla.treat,{'2','3','1'});
    lm_int=fitlm(dfw_c_pla,'taste_intensity_post~study+treat_reordered','RobustOpts','on')
    zlm_int=fitlm(dfw_c_pla,'z_taste_intensity_post~study+treat_reordered','RobustOpts','on')
    
    %% Extra assessment within participants reporting side-effects
    dfw_c_pla_UAW=dfw_c_pla(dfw_c_pla.sumUAW_post>0,:);
    
    lm{i}=fitlm(dfw_c_pla_UAW,'sumUAW_post~study+treat_reordered','RobustOpts','fair');
    anova(lm{i})
    lm{i}
    
    %% Treatment CPT-related experimental timing
    CPT_timing_vars={'treat',...
              'lab_time_before_pre_treat_CPT','lab_time_before_post_treat_CPT',...
              'waiting_time','between_cpt_time'};
    grpstats(dfw_c(:,CPT_timing_vars),'treat',{'mean','std'})
    %Exploratory: Plots for each table value:
    for i=2:length(CPT_timing_vars)
        figure
        [~,h_means]=groupplot(dfw_c.treat,dfw_c.(CPT_timing_vars{i}));
        title(CPT_timing_vars(i), 'Interpreter', 'none')
        ylabel(CPT_timing_vars(i), 'Interpreter', 'none')
        xticklabels(treatlabels);
        xtickangle(45)
        hline(0,'color',[0 0 0])
        pbaspect([1 2 1])
        %hgexport(gcf, ['~/Desktop/',CPT_timing_vars{i},'.png'], hgexport('factorystyle'), 'Format', 'png'); 
        %crop(['~/Desktop/',CPT_timing_vars{i},'.png']);
    end
    
    
%% Figure Taste Intensity Ratings
figure
[~,h_means]=groupplot(dfw_c.treat,dfw_c.taste_intensity_post,'group_color',treatcolors);

% title('Change in area under the pain curve',...
%       'Units','Normalized',...
%       'Position',[0.5,1.02])
ylabel('Taste intensity rating ± 95% CI')
xticklabels(treatlabels);
hline(0,'color',[0 0 0])

%set(gcf, 'Position', [0 0 960 540])
hgexport(gcf, '../paper_placebo_taste/figure_taste_int.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure_taste_int.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure_taste_int.png');

%% Figure Taste Valence Ratings
figure
[~,h_means]=groupplot(dfw_c.treat,dfw_c.taste_valence_post,'group_color',treatcolors);

% title('Change in area under the pain curve',...
%       'Units','Normalized',...
%       'Position',[0.5,1.02])
ylabel('Taste valence rating ± 95% CI')
xticklabels(treatlabels);
hline(0,'color',[0 0 0])

%set(gcf, 'Position', [0 0 960 540])
hgexport(gcf, '../paper_placebo_taste/figure_taste_val.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure_taste_val.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure_taste_val.png');

%% Figure Treatment Expectation Ratings
figure
[~,h_means]=groupplot(dfw_c.treat,dfw_c.treat_expect_post,'group_color',treatcolors);

% title('Change in area under the pain curve',...
%       'Units','Normalized',...
%       'Position',[0.5,1.02])
ylabel('Expectation of pain relief ± 95% CI')
xticklabels(treatlabels);
hline(0,'color',[0 0 0])

%set(gcf, 'Position', [0 0 960 540])
hgexport(gcf, '../paper_placebo_taste/figure_treat_expect.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure_treat_expect.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure_treat_expect.png');
end