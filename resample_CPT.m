function [rating_in_s,rating_in_s_full_CPT]=resample_CPT(x,t,t_max,new_sampling_rate)
    % before resampling time-series have to be de-trended otherwise matlab
    % will introduce end-point effects...
    % see: https://de.mathworks.com/help/signal/examples/resampling-nonuniformly-sampled-signals.html
    i_notnan=intersect(find(~isnan(x)),find(~isnan(t))); %to get last non-nan entry in both HR and time-series
    b(1) = (x(i_notnan(end))-x(1)) / (t(i_notnan(end))-t(1));
    b(2) = x(1);
    % detrend the signal
    xdetrend = x - polyval(b,t);
    rating_in_s=NaN(1,t_max);
    rating_in_s_full_CPT=ones(1,t_max).*100;
    [ydetrend,ty]=resample(xdetrend,t,new_sampling_rate,'pchip');
    rating_in_s(1:length(ydetrend))=ydetrend+ polyval(b,ty);
    rating_in_s_full_CPT(1:length(ydetrend))=ydetrend+ polyval(b,ty);
end