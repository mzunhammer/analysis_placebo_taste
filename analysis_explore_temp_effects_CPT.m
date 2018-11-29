function analysis_explore_temp_effects_CPT(dfw_c)
%% Exploring potential temperature effects in the data
[r,p]=corr(dfw_c.study=='1',dfw_c.aucrating_perc_post,'Type','Kendall')
[r,p]=corr(dfw_c.TT_TU,dfw_c.aucrating_perc_post,'Type','Kendall')

% Plotting potential temperature & time effects in the data
dfw_c_sorted=sortrows(dfw_c,'datetime_CPT_end_pre');
dfw_c_sorted.aucrating_perc_mean=nanmean([dfw_c_sorted.aucrating_perc_pre,dfw_c_sorted.aucrating_perc_post]')';
dfw_c_sorted.aucrating_perc_7d_mean=movmean(dfw_c_sorted.aucrating_perc_mean,days(7),...
                                            'SamplePoints',dfw_c_sorted.datetime_CPT_end_pre);
dfw_c_sorted.maxtime_mean=nanmean([dfw_c_sorted.maxtime_pre,dfw_c_sorted.maxtime_post]')';
dfw_c_sorted.maxtime_7d_mean_neg=movmean(dfw_c_sorted.maxtime_mean,days(7),...
                                            'SamplePoints',dfw_c_sorted.datetime_CPT_end_pre)*-1;                                        
                                     
fig=figure;
left_color = [0 0 0];
right_color = [0 0 .5];

gap=0.08; %gap between subplots in percent figure width
width_s1=sum(dfw_c_sorted.study=="1")/length(dfw_c_sorted.study)*(1-gap*4); %width of subplots
width_s2=sum(dfw_c_sorted.study=="2")/length(dfw_c_sorted.study)*(1-gap*4);
width_s3=sum(dfw_c_sorted.study=="3")/length(dfw_c_sorted.study)*(1-gap*4);


set(fig,'defaultAxesColorOrder',[left_color; right_color]);

subplot(1,3,1)
x=dfw_c_sorted.datetime_CPT_end_pre(dfw_c_sorted.study=="1");
y1=dfw_c_sorted.aucrating_perc_7d_mean(dfw_c_sorted.study=="1");
y2=dfw_c_sorted.TT_TU_7d(dfw_c_sorted.study=="1");
yyaxis left,plot(x,y1,'.-')
ylim([35,85])
ylabel('% area under the pain curve, 7-day moving average')
yyaxis right,plot(x,y2,'.-')
ylim([-3,30])
set(gca,'YTickLabel',[]);
title('Study 1')
xticks(min(x):14:max(x))
xtickangle(45)
xtickformat('dd-MMM-yy')
%pbaspect([1 3 1])
set(gca,'Position',[gap gap*1.5 width_s1 1-2*gap]) %left, bottom, width, height

% Figure 1b: plot %AUCP change: post-pre
subplot(1,3,2)
x=dfw_c_sorted.datetime_CPT_end_pre(dfw_c_sorted.study=="2");
y1=dfw_c_sorted.aucrating_perc_7d_mean(dfw_c_sorted.study=="2");
y2=dfw_c_sorted.TT_TU_7d(dfw_c_sorted.study=="2");
yyaxis left,plot(x,y1,'.-')
ylim([35,85])
set(gca,'YTickLabel',[]);
yyaxis right,plot(x,y2,'.-')
ylim([-3,30])
set(gca,'YTickLabel',[]);
title('Study 2')
xticks(min(x):14:max(x))
xtickangle(45)
xtickformat('dd-MMM-yy')
set(gca,'Position',[2*gap+width_s1 gap*1.5 width_s2 1-2*gap]) %left, bottom, width, height
 
subplot(1,3,3)
x=dfw_c_sorted.datetime_CPT_end_pre(dfw_c_sorted.study=="3");
y1=dfw_c_sorted.aucrating_perc_7d_mean(dfw_c_sorted.study=="3");
y2=dfw_c_sorted.TT_TU_7d(dfw_c_sorted.study=="3");
yyaxis left,plot(x,y1,'.-')
set(gca,'YTickLabel',[]);
ylim([35,85])
yyaxis right,plot(x,y2,'.-')
ylim([-3,30])
ylabel('Outside temperature in °C, 7-day moving average')

title('Study 3')
xticks(min(x):14:max(x))
xtickangle(45)
xtickformat('dd-MMM-yy')
set(gca,'Position',[3*gap+width_s1+width_s2 gap*1.5 width_s3 1-2*gap]) %left, bottom, width, height

%annotation('textbox',...
%           [0.3, 0.7, .4, .1],... % x y width heigth
%           'String',['7-day moving average'],...
%           'Units','Normalized',...
%           'FontWeight','bold',...
%           'HorizontalAlignment','center',...
%           'LineStyle','none');

hgexport(gcf, '../paper_placebo_taste/figure2Sa.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure2Sa.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure2Sa.png');




fig=figure;
left_color = [0 0 0];
right_color = [0 0 .5];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

subplot(1,3,1)
x=dfw_c_sorted.datetime_CPT_end_pre(dfw_c_sorted.study=="1");
y1=dfw_c_sorted.maxtime_7d_mean_neg(dfw_c_sorted.study=="1");
y2=dfw_c_sorted.TT_TU_7d(dfw_c_sorted.study=="1");
yyaxis left,plot(x,y1,'.-')
ylim([-180,-60])
ylabel('CPT tolerance time, 7-day moving average');
yyaxis right,plot(x,y2,'.-')
ylim([-3,30])
set(gca,'YTickLabel',[]);
title('Study 1')
xticks(min(x):14:max(x))
xtickangle(45)
xtickformat('dd-MMM-yy')
%pbaspect([1 3 1])
set(gca,'Position',[gap gap*1.5 width_s1 1-2*gap]) %left, bottom, width, height

% Figure 1b: plot %AUCP change: post-pre
subplot(1,3,2)
x=dfw_c_sorted.datetime_CPT_end_pre(dfw_c_sorted.study=="2");
y1=dfw_c_sorted.maxtime_7d_mean_neg(dfw_c_sorted.study=="2");
y2=dfw_c_sorted.TT_TU_7d(dfw_c_sorted.study=="2");
yyaxis left,plot(x,y1,'.-')
ylim([-180,-60])
set(gca,'YTickLabel',[]);
yyaxis right,plot(x,y2,'.-')
ylim([-3,30])
set(gca,'YTickLabel',[]);
title('Study 2')
xticks(min(x):14:max(x))
xtickangle(45)
xtickformat('dd-MMM-yy')
set(gca,'Position',[2*gap+width_s1 gap*1.5 width_s2 1-2*gap]) %left, bottom, width, height
 
subplot(1,3,3)
x=dfw_c_sorted.datetime_CPT_end_pre(dfw_c_sorted.study=="3");
y1=dfw_c_sorted.maxtime_7d_mean_neg(dfw_c_sorted.study=="3");
y2=dfw_c_sorted.TT_TU_7d(dfw_c_sorted.study=="3");
yyaxis left,plot(x,y1,'.-')
set(gca,'YTickLabel',[]);
ylim([-180,-60])
yyaxis right,plot(x,y2,'.-')
ylim([-3,30])
ylabel('Outside temperature in °C, 7-day moving average')

title('Study 3')
xticks(min(x):14:max(x))
xtickangle(45)
xtickformat('dd-MMM-yy')
set(gca,'Position',[3*gap+width_s1+width_s2 gap*1.5 width_s3 1-2*gap]) %left, bottom, width, height

%annotation('textbox',...
%           [0.3, 0.7, .4, .1],... % x y width heigth
%           'String',['7-day moving average'],...
%           'Units','Normalized',...
%           'FontWeight','bold',...
%           'HorizontalAlignment','center',...
%           'LineStyle','none');

hgexport(gcf, '../paper_placebo_taste/figure2Sb.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure2Sb.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure2Sb.png');
end