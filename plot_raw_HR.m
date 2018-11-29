function plot_raw_HR(dfl,index,varargin)
 % Additional arguments:
 % 'Corrected_Time': Can be used after HR datetime was corrected for
 % monitor time-drift
 % 'Trigger_Focus': Can be used to focus the plot around the first trigger.
 
 for i = index
    if isempty(dfl.dfraw{i})
        fprintf('Error: No HR data at i=%d, no plot\n',i)
        continue
    end
        
    if any(ismember(varargin,'Corrected_Time'))
        t=dfl.dfraw{i}.datetime_corr;
    else
        t=dfl.dfraw{i}.datetime;
    end

    if any(ismember(varargin,'Trigger_Focus'))
        % Plot HR recording, limited to a time-frame around
        % trigger1 +3 min & trigger1 -1 min
        curr_t=t;
        currtrigs=find(dfl.dfraw{i}.triggers);
        currtrigtimes=curr_t(currtrigs);
        start_t=currtrigtimes(1)-minutes(1);
        end_t=currtrigtimes(1)+minutes(3);
        jstart=find(curr_t<start_t,1,'last');
        if isempty(jstart)
            jstart=1;
        end
        jend=find(curr_t<end_t,1,'last');

        figure
        plot(t(jstart:jend),...
            [dfl.dfraw{i}.HR(jstart:jend),...
             dfl.dfraw{i}.triggers(jstart:jend)*100]);
        title(sprintf('i=%d, subID=%d, sess=%d, CPT-maxtime=%3.1f',...
                       i,dfl.subject_no_numeric(i),dfl.prepost(i),dfl.maxtime(i)))

        hold on
        plot(xlim,[dfl.CPT_HR_max(i) dfl.CPT_HR_max(i)])
        plot(t(jstart:jend),...
            dfl.dfraw{i}.NBPS(jstart:jend),'LineWidth',30);
        line([dfl.datetime_CPT_end(i)-seconds(dfl.maxtime(i)),...
              dfl.datetime_CPT_end(i)],[100,100],'LineWidth',10);
        hold off    
     else
        % Plot full HR recording
        figure
        plot(t,...
            [dfl.dfraw{i}.HR,...
             dfl.dfraw{i}.triggers*100]);
        title(sprintf('i=%d, subID=%d, sess=%d, CPT-maxtime=%3.1f',...
                       i,dfl.subject_no_numeric(i),dfl.prepost(i),dfl.maxtime(i)))
        hold on
        plot(t,...
            dfl.dfraw{i}.NBPS,'LineWidth',30);
        line([dfl.datetime_CPT_end(i)-seconds(dfl.maxtime(i)),...
              dfl.datetime_CPT_end(i)],[100,100],'LineWidth',10);
        hold off
     end
 end