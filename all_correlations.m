function CorrelationResults=all_correlations(X_table,correlation_type,bootsamples)

X_names=X_table.Properties.VariableNames;
X=X_table{:,:};
[R,P]=corr(X,...
    'rows','pairwise','type',correlation_type);

ci=NaN(2,numel(R));
% Bootstrapped Confidence intervals for the correlations above
% WARNING1 Bootstrapping can take a when computing 1000+ correlations.
% WARNING2 Bootstrapping will fail if a variable with many NaN's is entered.
% Only 'x' is the input since we fix v1 and v2 (same name as vars)
f  = @(X) correlator(X,'Pearson');
ci = bootci(bootsamples,{f,X});

%Permuted p-Values
permR=NaN([size(X,2),size(X,2),bootsamples]);
permB=NaN([size(X,2),size(X,2),bootsamples]);

h=waitbar(0,'Permuting');% Waitbar to monitor progress
for i=1:bootsamples 
% Computes r ps times for randomly shuffled (i.e. "shake") rows.
permR(:,:,i)=corr(shake(X),...
    'rows','pairwise','type',correlation_type); 
% Counts the number of times where the original r was more extreme than the r obtained from permuted data.
permB(:,:,i)=abs(permR(:,:,i))>abs(R); % Computes
waitbar(i/bootsamples,h) % Waitbar to monitor progress
end
b=sum(permB,3);% n of values more extreme than original r
close(h)
% Exact p-Value assuming permutations "ohne Zur�cklegen", only valid for
% large ps (>1000) and sufficient sample size
permuted_p_wo_rep=(b+1)./(bootsamples+1);%see: (Smyth and Fipson 2010)

%% Arrange correlation results in table with names
% Puts the correlation matrix into a list
R_diag = R(tril(true(size(R)),-1));
P_diag = P(tril(true(size(P)),-1));
P_permuted_diag = permuted_p_wo_rep(tril(true(size(permuted_p_wo_rep)),-1));

namatrix=repmat(X_names,size(R,1),1);
for i=1:size(namatrix,1)
  for j=1:size(namatrix,2)  
      namatrix(i,j)={[namatrix{i,j},' / ',X_names{i}]};
  end
end

namatrix_diag=namatrix(find(tril(ones(size(namatrix)),-1)));
sigi_index_diag=P_permuted_diag<=1;

CI_lo=ci(1,:)';
CI_hi=ci(2,:)';
CorrelationResults=table(namatrix_diag(sigi_index_diag),R_diag(sigi_index_diag),CI_lo(sigi_index_diag),CI_hi(sigi_index_diag), P_diag(sigi_index_diag),P_permuted_diag(sigi_index_diag),'VariableNames', {'Variables' 'r' 'CI95lo' 'CI95hi' 'p' 'p_permuted'});
CorrelationResults=sortrows(CorrelationResults,{'p','r'},{'ascend','descend'});

%% Function definition for boot
function R_diag=correlator(X,correlation_type)
    [r]=corr(X,...
        'rows','pairwise','type',correlation_type);
    R_diag = r(tril(true(size(r)),-1));
end
end