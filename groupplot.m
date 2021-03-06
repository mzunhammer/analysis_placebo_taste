function [h,h_means]=groupplot(x1,y,varargin)
%figure
% Styles
% varargin:
% For custom colors: 'group_color',{[0,0,0],[0.1,0.1,0.5],[...],...}
% For maximum column width, regardless of number of points per bin: 'max_point_spread'
bootsamples=10000;
xscale=0.5;
pointsize=12;
meanpointsize=30;

groups1=unique(x1);

k1=numel(groups1);

min_gap=0.5*xscale; %minimum gap between columns
nudge=(1-min_gap)./numel(groups1);

gap_err=nudge/2*xscale;
point_spread=gap_err*2.5; % central in case 'max_point_spread' is set
point_distance=point_spread/4; % not used in case 'max_point_spread' is set

% Data
for i=1:k1
    xpos1=i*xscale; % Xposition (middle position)
    % y-data
    curr_y=y(x1 == groups1(i));
    curr_y_mean(i) = nanmean(curr_y);
    curr_y_sd(i) = std(curr_y);
    if ~all(isnan(curr_y))
        curr_y_CI=bootci(bootsamples,{@nanmean,curr_y},'type','cper')-curr_y_mean(i);
    else
        curr_y_CI=[NaN,NaN];
    end
    % Appearance
    if any(strcmpi('group_color',varargin))
        curr_color=varargin{find(strcmpi(varargin,'group_color'))+1}{i};
    else
        curr_color=[0.6 0.6 0.6]*(1-((i-1)/k1));%
    end
    
    if i==1
        marker_symbol='o';
        curr_pointsize=pointsize/3;
    else
        marker_symbol='.';
        curr_pointsize=pointsize;
    end
    
    % Get bins for dotplot to spread out data-points on x (to avoid overlap)
    [C,~,ic] = unique(round(curr_y));
    % Plots
    for j=1:length(C)
        curr_iC = ic==j;
        if any(strcmpi('max_point_spread',varargin))
            curr_n_in_C = sum(curr_iC);
            x_points_raw = 1:curr_n_in_C;
            x_points = (x_points_raw-median(x_points_raw))...
                       /curr_n_in_C...
                       *point_spread;
        else
            curr_n_in_C = sum(curr_iC);
            x_points_raw = 1:curr_n_in_C;
            x_points = (x_points_raw-median(x_points_raw))...
                       *point_distance;
        end
        plot(xpos1+gap_err+x_points,...         %x
            curr_y(curr_iC),...%y
            marker_symbol,'MarkerSize',curr_pointsize,...
            'color',curr_color);
        hold on
    end
    
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