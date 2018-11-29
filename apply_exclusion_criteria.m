function df_c=apply_exclusion_criteria(df)
    try
    excluded_low_baseline_pain=df.aucrating_perc<5;
    catch
    excluded_low_baseline_pain=df.aucrating_perc_pre<5;
    end
    excluded=df.subject_no(df.exclusion==1|excluded_low_baseline_pain);
    df_c=df;
    df_c(ismember(df.subject_no,excluded),:)=[];
end