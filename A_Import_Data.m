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
dfraw.datetime=cellfun(@(x) datetime(x{1}{4},'InputFormat','ddMMyy_HHmm'),fnameprts,'UniformOutput',0);
dfraw.datetime=[dfraw.datetime{:}]';

% Get data from files
for i=1:length(fnames)
    % To load all
    %dfraw.matdata{i,1}=load(fullfile(protfolder,fnames{i}));
    a=load(fullfile(protfolder,fnames{i}));
    dfraw.rating{i,1}=a.Results.Rating;
    dfraw.time{i,1}=a.Results.Time;
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


save dfraw.mat dfraw crf