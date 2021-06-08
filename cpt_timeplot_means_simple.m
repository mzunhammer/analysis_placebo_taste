function [h,h_means]=cpt_timeplot_means_simple(x1,x2,y,y_vline,min_max,ref,varargin)

figure
% Styles
meanlinesize=5;
bootsamples=10000;

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
                    line(1:180',curr_y_mean',...
                            'LineStyle','--',...
                            'Color',meancolor);
                else
                    line(1:180',curr_y_mean',...
                            'Color',meancolor);
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
                subaxis(1,k1,i,'Spacing',0.03,'MarginLeft',0.15,'MarginRight',0.01)
                if mod(j,2)>0
                    line(1:180',curr_y_mean',...
                            'LineStyle','--',...
                            'Color',meancolor);
                    hold on;
                    if any(ismember(varargin(cellfun(@ischar,varargin)),'highlight_maxima'))
                      % plot(find(curr_y_mean==max(curr_y_mean)),max(curr_y_mean),'+',...
                       %    'MarkerSize',10,'LineWidth',2,'color',meancolor*(1-(j/k2)))
                       allcurr_y=[curr_y{:}]';
                       curr_y_CI= bootci(bootsamples,{@nanmean,allcurr_y(:,find(curr_y_mean==max(curr_y_mean)))},'type','cper'); 
                       errorbar(find(curr_y_mean==max(curr_y_mean)),... %X
                         max(curr_y_mean),... %Y
                         curr_y_CI(1)-max(curr_y_mean),...%curr_y_sd(i),...%Error
                         curr_y_CI(2)-max(curr_y_mean),...
                        '.','color',meancolor,...
                        'Marker','x')
                    end
                else
                    line(1:180',curr_y_mean',...
                            'Color',meancolor);
                hold on;
                %plot(curr_y_mean,'color',meancolor*0.5); %,'LineWidth',meanlinesize
                if any(ismember(varargin(cellfun(@ischar,varargin)),'highlight_maxima'))
                      % plot(find(curr_y_mean==max(curr_y_mean)),max(curr_y_mean),'+',...
                       %    'MarkerSize',10,'LineWidth',2,'color',meancolor*(1-(j/k2)))
                       allcurr_y=[curr_y{:}]';
                       curr_y_CI= bootci(bootsamples,{@nanmean,allcurr_y(:,find(curr_y_mean==max(curr_y_mean)))},'type','cper'); 
                       errorbar(find(curr_y_mean==max(curr_y_mean)),... %X
                         max(curr_y_mean),... %Y
                         curr_y_CI(1)-max(curr_y_mean),...%curr_y_sd(i),...%Error
                         curr_y_CI(2)-max(curr_y_mean),...
                        '.','color',meancolor)
                end
                axis([0,...
                      180,...
                      min_max]); %
                if any(ismember(varargin(cellfun(@ischar,varargin)),'refline'))
                hline(ref,'color',[.5 .5 .5])
                end
                % Highlight maxima.

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