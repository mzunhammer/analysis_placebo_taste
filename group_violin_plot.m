function [h,h_means]=groupplot(x1,x2,y)

figure

% Styles
pointsize=15;
meanpointsize=30;
color_pre=[0.6,0.6,0.6];
color_post=[0.3,0.3,0.6];

groups1=unique(x1);
groups2=unique(x2);

k1=numel(groups1);
k2=numel(groups2);

min_gap=0.5; %minimum gap between columns
nudge=(1-min_gap)./numel(groups2);
gap_err=nudge/4;

% Data
for i=1:k1
    xpos1=i; % Xposition
    for j=1:k2
        % Xposition nudged
        xpos2(j)=xpos1+(j-1-0.5.*(k2-1)).*nudge;
        % y-data
        curr_y=y((x1 == groups1(i)) & (x2 == groups2(j)));
        curr_y_mean(j) = nanmean(curr_y);
        curr_y_sd(j) = std(curr_y);
        curr_y_CI= bootci(1000,{@nanmean,curr_y},'type','cper')-curr_y_mean(j);
        % Appearance
        curr_color=[0.8 0.8 0.8]*(1-((j-1)/k2));
        
        % Plots
        violinplot(curr_y,'x',xpos2(j),'nopoints',...
            'color',curr_color);
        hold on

        h_means(j)=errorbar(xpos2(j)-gap_err,... %X
                 curr_y_mean(j),... %Y
                 curr_y_CI(1),...%curr_y_sd(j),...%Error
                 curr_y_CI(2),...
                '.',...
                'MarkerSize',meanpointsize,...
                'LineWidth',2,...
                'color',curr_color)
    end
    l=line(xpos2-gap_err,...
         curr_y_mean,...
         'LineWidth',2,...
         'color',[0.5,0.5,0.5]);
    uistack(l);
    uistack(l,'bottom');
end
axis([1-min_gap %xmin
     k1+min_gap %xmax
     floor(min(y)/10)*10 %ymin
     ceil(max(y)/10)*10]); %ymax
 
box off;
h=gcf;
end