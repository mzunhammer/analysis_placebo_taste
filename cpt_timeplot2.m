function [h,h_means]=cpt_timeplot2(x1,x2,y,ref)

%Optional: re-sampling style error-regions
bootlines=1;
resamples=1000;

figure
% Styles
meanlinesize=5;
spaghetticolor=[0.5,0.5,0.5];
boot_spaghetticolor=[0.2,0.2,0.8];

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
        y_matrix=[curr_y{:}]';
        curr_y_mean = nanmean(y_matrix);
        curr_mean_maxtime = mean(cellfun(@(x) sum(~isnan(x)),curr_y));
        curr_y_sd = nanstd([curr_y{:}]');
        %curr_y_CI= bootci(10000,{@nanmean,curr_y(:,j)},'type','cper')-curr_y_mean(j);

        subaxis(k1,k2,iplot,'Spacing',0.03,'MarginLeft',0.15,'MarginRight',0.01)
        % Plots
        for n=1:length(curr_y)
            plot(curr_y{n},'color',[spaghetticolor,0.3]);
            hold on
        end
        if bootlines == 1 % add boot-strapped transparent lines
        for n=1:resamples
            sampled_y_matrix=datasample(y_matrix,length(y_matrix),1,'Replace',true); 
            curr_y_boot_mean=nanmean(sampled_y_matrix);
            plot(curr_y_boot_mean,'color',[boot_spaghetticolor,1/(resamples/10)]); %,'LineWidth',meanlinesize
            hold on
        end
        end
        plot(curr_y_mean,'color',meancolor); %,'LineWidth',meanlinesize
        vline(curr_mean_maxtime,'color',[.5 .5 .5],'LineStyle','--')
        
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