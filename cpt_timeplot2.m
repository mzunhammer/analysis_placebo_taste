function [h,h_means]=cpt_timeplot2(x1,x2,y,ref)

figure
% Styles
meanlinesize=5;
spaghetticolor=[0.8,0.8,0.8];
meancolor=[0,0,0];

groups1=unique(x1);
groups2=unique(x2);

k1=numel(groups1);
k2=numel(groups2);

% Data
iplot=1;
y_min = round(min(nanmin(vertcat(y{:}))/10))*10;
y_max = round(max(nanmax(vertcat(y{:}))/10))*10;

for i=1:k1
    curr_y={}; 
    for j=1:k2
        % y-data
        curr_y=y((x1 == groups1(i)) & (x2 == groups2(j)));
        curr_y_mean = nanmean([curr_y{:}]');
        curr_y_sd = nanstd([curr_y{:}]');
        %curr_y_CI= bootci(1000,{@nanmean,curr_y(:,j)},'type','cper')-curr_y_mean(j);

        subaxis(k1,k2,iplot,'Spacing',0.03,'MarginLeft',0.15,'MarginRight',0.01)
        % Plots
        for n=1:length(curr_y)
        plot(curr_y{n},'color',spaghetticolor);
        hold on
        end
        plot(curr_y_mean,'color',meancolor); %,'LineWidth',meanlinesize
        
        axis([0,...
              180,...
              y_min,... %
              y_max]); %
        hline(ref,'color',[.5 .5 .5])
        box off;

        iplot=iplot+1;
    end
end

h=gcf;
end