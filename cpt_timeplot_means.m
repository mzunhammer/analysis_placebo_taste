function [h,h_means]=cpt_timeplot_means(x1,x2,y,y_vline,min_max,ref)

figure
bootsamples=10000;
% Styles
meanlinesize=5;
spaghetticolor=[0.8,0.8,0.8];
meancolor=[0.9,0.9,0.9];

groups1=unique(x1);
groups2=unique(x2);

k1=numel(groups1);
k2=numel(groups2);

% Data
iplot=1;
%y_min = round(min(nanmin(vertcat(y{:}))/10))*10;
%y_max = round(max(nanmax(vertcat(y{:}))/10))*10;

for i=1:k1
    curr_y={}; 
    for j=1:k2
        % y-data        
        curr_y=y((x1 == groups1(i)) & (x2 == groups2(j)));
        curr_y_maxtime=y_vline((x1 == groups1(i)) & (x2 == groups2(j)));
        curr_mean_maxtime=mean(curr_y_maxtime);
        curr_y_mean = nanmean([curr_y{:}]');
        %curr_y_sd = nanstd([curr_y{:}]');
        curr_y_CI= bootci(bootsamples,{@nanmean,[curr_y{:}]'},'type','cper')-curr_y_mean;
        subaxis(1,k1,i,'Spacing',0.03,'MarginLeft',0.15,'MarginRight',0.01)
        if mod(j,2)>0
            boundedline(1:180',curr_y_mean',abs(curr_y_CI)','--b',...
                    'alpha',...
                    'transparency',0.1,...
                    'cmap',meancolor*(1-(j/k2)));
        else
            boundedline(1:180',curr_y_mean',abs(curr_y_CI)','b',...
                    'alpha',...
                    'transparency',0.1,...
                    'cmap',meancolor*(1-(j/k2)));
        end
        %plot(curr_y_mean,'color',meancolor*0.5); %,'LineWidth',meanlinesize
        hold on
        axis([0,...
              180,...
              min_max]); %
        hline(ref,'color',[.5 .5 .5])
        % Plot average maxtime. Too much info on graph.
        %line([curr_mean_maxtime,curr_mean_maxtime],...
        %     [0,curr_y_mean(round(curr_mean_maxtime))],...
        %      'color',meancolor*(1-(j/k2)),'LineStyle',':')
        box off;

    end
    hold off
end

h=gcf;
end