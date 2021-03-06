function [h,h_means]=cpt_timeplot_means(x1,x2,y,y_vline,min_max,ref,varargin)

figure
bootsamples=10000;
% Styles
meanlinesize=5;
spaghetticolor=[0.8,0.8,0.8];

defaultcolor=[0.5,0.5,0.5];

groups1=unique(x1);
groups2=unique(x2);

k1=numel(groups1);
k2=numel(groups2);

% Data
iplot=1;
%y_min = round(min(nanmin(vertcat(y{:}))/10))*10;
%y_max = round(max(nanmax(vertcat(y{:}))/10))*10;

if any(ismember(varargin(cellfun(@ischar,varargin)),'highlight_difference'))
        for i=1:k1
            curr_y={}; 
            for j=1:k2
                if any(strcmpi('group_color',varargin))
                    meancolor=varargin{find(strcmpi(varargin,'group_color'))+1}{i};
                else
                    meancolor=defaultcolor;%
                end
                % y-data        
                curr_y=y((x1 == groups1(i)) & (x2 == groups2(j)));
                curr_y_maxtime=y_vline((x1 == groups1(i)) & (x2 == groups2(j)));
                curr_mean_maxtime=mean(curr_y_maxtime);
                curr_y_mean = nanmean([curr_y{:}]');
                %curr_y_sd = nanstd([curr_y{:}]');
                diff_area=zeros(2,size([curr_y{:}]',2));
                subaxis(1,k1,i,'Spacing',0.03,'MarginLeft',0.15,'MarginRight',0.01)
                if mod(j,2)>0
                    boundedline(1:180',curr_y_mean',abs(diff_area)','--b',...
                            'alpha',...
                            'transparency',0.1,...
                            'cmap',meancolor);
                else
                    boundedline(1:180',curr_y_mean',abs(diff_area)','b',...
                            'alpha',...
                            'transparency',1,...
                            'cmap',[1,1,1]);
                    line(1:180',curr_y_mean','Color',meancolor);
                end
                %plot(curr_y_mean,'color',meancolor*0.5); %,'LineWidth',meanlinesize
                hold on
                axis([0,...
                      180,...
                      min_max]); %
                if any(ismember(varargin(cellfun(@ischar,varargin)),'refline'))
                hline(ref,'color',[.5 .5 .5])
                end
                % Highlight maxima.
                if any(ismember(varargin(cellfun(@ischar,varargin)),'highlight_maxima'))
                   plot(find(curr_y_mean==max(curr_y_mean)),max(curr_y_mean),'+',...
                       'MarkerSize',10,'LineWidth',2,'color',meancolor)
                end
                % Plot average maxtime. Too much info on graph.
        %         line([curr_mean_maxtime,curr_mean_maxtime],...
        %             [0,curr_y_mean(round(curr_mean_maxtime))],...
        %              'color',meancolor,'LineStyle',':')
                box off;

            end
            hold off
            end
        
else        
        for i=1:k1
            curr_y={}; 
            for j=1:k2
                % y-data 
                if any(strcmpi('group_color',varargin))
                    meancolor=varargin{find(strcmpi(varargin,'group_color'))+1}{i};
                else
                    meancolor=defaultcolor;%
                end
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
                            'cmap',brighten(meancolor,0.75));
                else
                    boundedline(1:180',curr_y_mean',abs(curr_y_CI)','b',...
                            'alpha',...
                            'transparency',0.1,...
                            'cmap',brighten(meancolor,-0.25));
                end
                %plot(curr_y_mean,'color',meancolor*0.5); %,'LineWidth',meanlinesize
                hold on
                axis([0,...
                      180,...
                      min_max]); %
                if any(ismember(varargin(cellfun(@ischar,varargin)),'refline'))
                hline(ref,'color',[.5 .5 .5])
                end
                % Highlight maxima.
                if any(ismember(varargin(cellfun(@ischar,varargin)),'highlight_maxima'))
                   plot(find(curr_y_mean==max(curr_y_mean)),max(curr_y_mean),'+',...
                       'MarkerSize',10,'LineWidth',2,'color',meancolor*(1-(j/k2)))
                end
                % Plot average maxtime. Too much info on graph.
        %         line([curr_mean_maxtime,curr_mean_maxtime],...
        %             [0,curr_y_mean(round(curr_mean_maxtime))],...
        %              'color',meancolor*(1-(j/k2)),'LineStyle',':')
                box off;

            end
            hold off
            end
end
h=gcf;
end