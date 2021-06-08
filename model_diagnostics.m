function model_diagnostics(linModel)

f=figure
subplot(2,3,1)
plotResiduals(linModel); %Histogram (normality assumption)
subplot(2,3,2)
boxplot(table2array(linModel.Residuals(:,3:end))); %Boxplot (spotting outliers,normality assumption)
title('Studentized|Standardized Residuals')
subplot(2,3,3)
plotResiduals(linModel,'probability'); %Quantile plot (normality assumption)
subplot(2,3,4)
plotResiduals(linModel,'lagged'); %Lag plot for  serial correlation (independent errror assumption)
%subplot(2,3,5)
%plotResiduals(linModel,'symmetry'); %Symmetry plot (normality assumption)
subplot(2,3,5)
plotResiduals(linModel,'fitted'); %Residuals vs fitted values plot (overview, homoscedasticity)
subplot(2,3,6)
hold on
preds=predict(linModel);
for i=1:length(preds)
    if ~isempty(linModel.Robust)
        currweight=min([1-linModel.Robust.Weights(i),0.99]);
    else
        currweight=0;
    end
plot(linModel.Fitted(i)+table2array(linModel.Residuals(i,1)),preds(i),'.',...
    'MarkerSize',10,...
    'MarkerEdgeColor',[currweight,currweight,currweight],...
     'MarkerFaceColor',[currweight,currweight,currweight])
end
xlabel('Observed')
ylabel('Predicted')
ax_min=min([linModel.Fitted+table2array(linModel.Residuals(:,1));predict(linModel)])-1;
ax_max=max([linModel.Fitted+table2array(linModel.Residuals(:,1));predict(linModel)])+1;
xlim([ax_min,ax_max]);
ylim([ax_min,ax_max]);
refline(1,0);
hold off
annotation(f,'textbox',[0.1, 0.9, 0.1, 0.1],'String',...
    ['Skewness: ' num2str(skewness(linModel.Residuals.Raw)), '  ',...
    'Kurtosis: ' num2str(kurtosis(linModel.Residuals.Raw))],...
    'EdgeColor','none');

[dw_p,dw_d]=dwtest(linModel);   
annotation(f,'textbox',[0.1, 0.1, 0.1, 0.1],'String',...
    ['Durbin-Watson: ' num2str(dw_d), ', ',...
    'p: ' num2str(dw_p)],...
    'EdgeColor','none');