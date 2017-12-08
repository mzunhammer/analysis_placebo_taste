function [h,h_means]=groupplot2(x1,y)
%figure
% Styles
xscale=0.5;
pointsize=15;
meanpointsize=30;

groups1=unique(x1);

k1=numel(groups1);

min_gap=0.5*xscale; %minimum gap between columns
nudge=(1-min_gap)./numel(groups1);
gap_err=nudge/2*xscale;

% Data
for i=1:k1
    xpos1=i*xscale; % Xposition
    % y-data
    curr_y=y(x1 == groups1(i));
    curr_y_mean(i) = nanmean(curr_y);
    curr_y_sd(i) = std(curr_y);
    curr_y_CI= bootci(1000,{@nanmean,curr_y},'type','cper')-curr_y_mean(i);
    % Appearance
    curr_color=[0.6 0.6 0.6]*(1-((i-1)/k1));
    % Plots
    plot(xpos1,curr_y,...
        '.','MarkerSize',pointsize,...
        'color',curr_color);
    hold on

    h_means(i)=errorbar(xpos1-gap_err,... %X
             curr_y_mean(i),... %Y
             curr_y_CI(1),...%curr_y_sd(i),...%Error
             curr_y_CI(2),...
            '.',...
            'MarkerSize',meanpointsize,...
            'LineWidth',2,...
            'color',curr_color);
end
axis([1*xscale-min_gap %xmin
     k1*xscale+min_gap %xmax
     floor(min(y)/10)*10 %ymin
     ceil(max(y)/10)*10]); %ymax
xticks(1*xscale:xscale:k1*xscale) 
box off;
h=gcf;
end