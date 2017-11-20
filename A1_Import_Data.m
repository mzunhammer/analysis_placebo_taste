clear

%% Read cold_pressor rating files
protfolder='../data_placebo_taste/cold_pressor/';
dir_protfolder=dir(protfolder);
fnames={dir_protfolder.name};
fnames=regexp(fnames,'^\d\d\d_\w_\w_\d_\d\d\d\d\d\d_\d\d\d\d.mat','match');
fnames=[fnames{:}]';

% Get info from filename
fnameprts=regexp(fnames,'^(\d\d\d)_(\w)_\w_(\d)_(\d\d\d\d\d\d_\d\d\d\d).mat','tokens');
dfraw.subIDs=cellfun(@(x) x{1}{1},fnameprts,'UniformOutput',0);
dfraw.sex=cellfun(@(x) x{1}{2},fnameprts,'UniformOutput',0);
dfraw.prepost=cellfun(@(x) str2num(x{1}{3}),fnameprts,'UniformOutput',0);
dfraw.prepost=[dfraw.prepost{:}]';
dfraw.datetime_CPT_end=cellfun(@(x) datetime(x{1}{4},'InputFormat','ddMMyy_HHmm'),fnameprts,'UniformOutput',0);
dfraw.datetime_CPT_end=[dfraw.datetime_CPT_end{:}]';
%Unfortunately no exact daytime was saved in rating-results.
%As a proxy, file-creation time was extracted and is used
load /Users/matthiaszunhammer/Dropbox/Gerrit/data_placebo_taste/exact_rating_end_times.mat
dfraw.datetime_CPT_filetime=exacttimes;
% Get data from files
for i=1:length(fnames)
    % To load all
    %dfraw.matdata{i,1}=load(fullfile(protfolder,fnames{i}));
    a=load(fullfile(protfolder,fnames{i}));
    dfraw.rating{i,1}=a.Results.Rating;
    dfraw.time{i,1}=a.Results.Time;
    
    if ~isempty(a.Results.ratingTreatExpect)
        dfraw.treat_expect(i,1)=a.Results.ratingTreatExpect;
        dfraw.cursorini_treat_expect(i,1)=a.Results.IniCursorPosTreatExpect;
        dfraw.ratingdur_treat_expect(i,1)=a.Results.ratingDurTreatExpect;
    else
        dfraw.treat_expect(i,1)=NaN;
        dfraw.cursorini_treat_expect(i,1)=NaN;
        dfraw.ratingdur_treat_expect(i,1)=NaN;
    end


end

% Get maximum matrix size for ratings
max_len_rating=max(cellfun(@length, dfraw.rating));
max_len_time=max(cellfun(@length, dfraw.time));

assert(max_len_rating==max_len_time,...
       'ERROR: Longest rating array is not equal to longest time array.' )
    
% Define maximum length of data, fill rest with NaNs
dfraw.ratingfull=NaN(length(dfraw.rating),max_len_rating);
dfraw.timefull=NaN(length(dfraw.time),max_len_rating);
% Fill all rating and time data into maximum length array
for i=1:length(dfraw.rating)
    dfraw.ratingfull(i,1:length(dfraw.rating{i}))=dfraw.rating{i};
    dfraw.timefull(i,1:length(dfraw.time{i}))=dfraw.time{i};
end

% Clip end of matrices by 4 epochs to account for minor inequalities in the number of
% sampling intervals/3 minutes
dfraw.ratingfull=dfraw.ratingfull(:,1:end-4);
dfraw.timefull=dfraw.timefull(:,1:end-4);

% Create a vector of full rating data where NaNs are filled with 100
dfraw.ratingfull100=dfraw.ratingfull;
dfraw.ratingfull100(isnan(dfraw.ratingfull))=100;

% Summarize time in s across measurement timepoints
dfraw.timemean=nanmean(dfraw.timefull)

%% Read post-treatment rating files
protfolder2='../data_placebo_taste/post_treatment_on_screen_questions/';
dir_protfolder2=dir(protfolder2);
fnames2={dir_protfolder2.name};
fnames2=regexp(fnames2,'^\d\d\d_\w_\w_\d\d\d\d\d\d_\d\d\d\d.mat','match');
fnames2=[fnames2{:}]';

% Get info from filename
fnameprts=regexp(fnames2,'^(\d\d\d)_(\w)_\w_(\d\d\d\d\d\d_\d\d\d\d).mat','tokens');
dfraw2.subIDs=cellfun(@(x) x{1}{1},fnameprts,'UniformOutput',0);
dfraw2.sex=cellfun(@(x) x{1}{2},fnameprts,'UniformOutput',0);
dfraw2.datetime_VAS_end=cellfun(@(x) datetime(x{1}{3},'InputFormat','ddMMyy_HHmm'),fnameprts,'UniformOutput',0);
dfraw2.datetime_VAS_end=[dfraw2.datetime_VAS_end{:}]';

% Get data from files
for i=1:length(fnames2)
    a=load(fullfile(protfolder2,fnames2{i}));
    dfraw2.treat_efficacy(i,1)=a.Results.ratingTreatEff;
    dfraw2.taste_intensity(i,1)=a.Results.ratingTasteInt;
    dfraw2.taste_valence(i,1)=a.Results.ratingTasteVal;
    
    dfraw2.cursorini_treat_efficacy(i,1)=a.Results.IniCursorPosTreatEff;
    dfraw2.cursorini_taste_intensity(i,1)=a.Results.IniCursorPosTasteInt;
    dfraw2.cursorini_taste_valence(i,1)=a.Results.IniCursorPosTasteVal;
    
    dfraw2.ratingdur_treat_efficacy(i,1)=a.Results.ratingDurTreatEff;
    dfraw2.ratingdur_taste_intensity(i,1)=a.Results.ratingDurTasteInt;
    dfraw2.ratingdur_taste_valence(i,1)=a.Results.ratingDurTasteVal;
end


%% Read treatment group allocation from randomization, add to raw df
randomlist_path='../data_placebo_taste/Randomisierung_Gerrit_Geschmacksstudie_Final.xlsx';
[ndata, ~, ~] = xlsread(randomlist_path);
xlsID=ndata(:,1);
treat=ndata(:,2);
treat(isnan(treat))=-1; % No treatment, no taste, taste
treat=treat+1;

for i=1:length(dfraw.subIDs)
    currID=str2num(dfraw.subIDs{i});
    dfraw.treat(i,1)=treat(xlsID==currID);
end

%% Read demografic/crf/questionnaire data
crfdata_path='../data_placebo_taste/case_report_forms.xlsx';
crf=readtable(crfdata_path,...
          'sheet',2,...
          'ReadVariableNames',true);

%% Create long df (dfl) from raw imports (pain ratings)
subject_no=categorical(cellfun(@str2num,dfraw.subIDs));

prepost=categorical(dfraw.prepost);
treat=categorical(dfraw.treat);
maxtime=cellfun(@max, dfraw.time);

%For AUC and Mean rating, the mean has to be taken across the maximum time interval(3
%min) with max rating (100) imputed instead of NaN for subjects that aborted testing.
%ACHTUNG: ratingfull fills with NaNs ratingfull100 with max-ratings!!
meanrating=cellfun(@nanmean,dfraw.rating);
aucrating=cellfun(@(x,y) trapz(x,y),dfraw.time,dfraw.rating);
aucrating100=trapz(dfraw.ratingfull100,2); % same as meanrating100=mean(dfraw.ratingfull100,2);
max_aucrating100=length(dfraw.ratingfull100)*100;
aucrating_perc=aucrating100/max_aucrating100*100;

meanratingbaseline=meanrating;
datetime_CPT_end=dfraw.datetime_CPT_end;
datetime_CPT_filetime=dfraw.datetime_CPT_filetime;

treat_expect=dfraw.treat_expect;
cursorini_treat_expect=dfraw.cursorini_treat_expect;
ratingdur_treat_expect=dfraw.ratingdur_treat_expect;

dfl=table(subject_no,...
    prepost,...
    treat,...
    maxtime,...
    meanrating,...
    aucrating_perc,...
    datetime_CPT_end,...
    datetime_CPT_filetime,...
    treat_expect,...
    cursorini_treat_expect,...
    ratingdur_treat_expect);

% Resample time-courses to 180 seconds and as cells
dfl.rating180=num2cell(resample(dfraw.ratingfull100',1,10)',2);
%% Create long df (dfl) from raw imports (post-treatment ratings)
subject_no=categorical(cellfun(@str2num,dfraw2.subIDs));

prepost=categorical(repmat(2,size(subject_no)));

treat_efficacy=dfraw2.treat_efficacy;
taste_intensity=dfraw2.taste_intensity;
taste_valence=dfraw2.taste_valence;

cursorini_treat_efficacy=dfraw2.cursorini_treat_efficacy;
cursorini_taste_intensity=dfraw2.cursorini_taste_intensity;
cursorini_taste_valence=dfraw2.cursorini_taste_valence;

ratingdur_treat_efficacy=dfraw2.ratingdur_treat_efficacy;
ratingdur_taste_intensity=dfraw2.ratingdur_taste_intensity;
ratingdur_taste_valence=dfraw2.ratingdur_taste_valence;

datetime_VAS_end=dfraw2.datetime_VAS_end;

dfl2=table(subject_no,...
    prepost,...
    treat_efficacy,...
    taste_intensity,...
    taste_valence,...
    cursorini_treat_efficacy,...
    cursorini_taste_intensity,...
    cursorini_taste_valence,...
    ratingdur_treat_efficacy,...
    ratingdur_taste_intensity,...
    ratingdur_taste_valence,...
    datetime_VAS_end);

dfl2.taste_valence=dfl2.taste_valence-50; % 101pt VAS with "neutral" at 50 >> to obtain intuitive positive and negative values

%% Join dfl with crf data
crf.subject_no=categorical(crf.subject_no);
crf.handedness=categorical(crf.handedness);
crf.bmi=crf.body_weight_in_kg./(crf.height_in_cm/100).^2;

dfl=join(dfl,crf);
dfl=outerjoin(dfl,dfl2);
dfl.Properties.VariableNames{'subject_no_dfl'} = 'subject_no';
dfl.Properties.VariableNames{'prepost_dfl'} = 'prepost';
dfl.subject_no_dfl2=[];
dfl.prepost_dfl2=[];

save df.mat dfl dfraw crf