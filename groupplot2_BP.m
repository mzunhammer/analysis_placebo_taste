function [h,h_means]=groupplot2_BP(x1,x2,y)
%figure
bootsamples=10000;
% Styles
xscale=0.75;
pointsize=15;
meanpointsize=30;

groups1=unique(x1);
groups2=unique(x2);

k1=numel(groups1);
k2=numel(groups2);

min_gap=0.5*xscale; %minimum gap between columns
nudge=(1-min_gap)./numel(groups2);
gap_err=nudge/4*0*xscale;

% Data
for i=1:k1
    xpos1=i*xscale; % Xposition
    curr_y=[];
    curr_color=[0.6 0.6 0.6]*(1-((i-1)/k1));
    for j=1:k2
        % Xposition nudged
        xpos2(j)=xpos1+(j-1-0.5.*(k2-1)).*nudge;
        % y-data
        curr_y(:,j)=y((x1 == groups1(i)) & (x2 == groups2(j)));
        curr_y_mean(j) = nanmean(curr_y(:,j));
        curr_y_sd(j) = std(curr_y(:,j));
        curr_y_CI= bootci(bootsamples,{@nanmean,curr_y(:,j)},'type','bca')-curr_y_mean(j);
        % Appearance        
        % Plots
        %plot(xpos2(j),curr_y(:,j),...
        %    '.','MarkerSize',pointsize,...
        %    'color',curr_color);
        hold on

        h_means(j)=errorbar(xpos2(j)-gap_err,... %X
                 curr_y_mean(j),... %Y
                 curr_y_CI(1),...%curr_y_sd(j),...%Error
                 curr_y_CI(2),...
                '.',...
                'MarkerSize',meanpointsize,...
                'LineWidth',2,...
                'color',curr_color);
    end
    %Mean connection lines
    l=line(xpos2-gap_err,...
         curr_y_mean,...
         'LineWidth',2,...
         'color',curr_color);
    uistack(l);
    uistack(l,'bottom');
    
    %Single-sub connection lines
%     ls=line(xpos2,...
%      curr_y,...
%      'LineWidth',2,...
%      'color',[0.85 0.85 0.85]);
%     uistack(ls);
%     uistack(ls,'bottom');
end
% axis([1*xscale-min_gap %xmin
%      k1*xscale+min_gap %xmax
%      floor(min(y)/10)*10 %ymin
%      ceil(max(y)/10)*10]); %ymax
% xticks(1*xscale:xscale:k1*xscale) 
box off;
h=gcf;
end