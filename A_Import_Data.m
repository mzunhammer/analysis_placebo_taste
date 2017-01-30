clear

%% Read all files
protfolder='./Cold_Pressor_Rating/Protocols/';
dir_protfolder=dir(protfolder);
fnames={dir_protfolder.name};
fnames=regexp(fnames,'^\d\d\d_\w_\w_\d_\d\d\d\d\d\d_\d\d\d\d.mat','match');
fnames=[fnames{:}]';

% Get info from filename
fnameprts=regexp(fnames,'^(\d\d\d)_(\w)_\w_(\d)_(\d\d\d\d\d\d_\d\d\d\d).mat','tokens');
dfraw.subIDs=cellfun(@(x) x{1}{1},fnameprts,'UniformOutput',0);
dfraw.sex=cellfun(@(x) x{1}{2},fnameprts,'UniformOutput',0);
dfraw.prepost=cellfun(@(x) str2num(x{1}{3}),fnameprts,'UniformOutput',0);
dfraw.datetime=cellfun(@(x) datetime(x{1}{4},'InputFormat','ddMMyy_HHmm'),fnameprts,'UniformOutput',0);
dfraw.datetime=[dfraw.datetime{:}]';

% Add treatment conditions
for i=1:length(fnames)
    % To load all
    %dfraw.matdata{i,1}=load(fullfile(protfolder,fnames{i}));
    a=load(fullfile(protfolder,fnames{i}));
    dfraw.rating{i,1}=a.Results.Rating;
    dfraw.time{i,1}=a.Results.Time;
end

% Add treatment conditions
randomlist_path='../Randomisierung_Gerrit_Geschmacksstudie_Final.xlsx';
[ndata, ~, ~] = xlsread(randomlist_path);
xlsID=ndata(:,1);
treat=ndata(:,2);
treat(isnan(treat))=-1; % No treatment, no taste, taste
treat=treat+1;

%Convert pre-post to num
dfraw.prepost=[dfraw.prepost{:}]';

for i=1:length(dfraw.subIDs)
    currID=str2num(dfraw.subIDs{i});
    dfraw.treat(i,1)=treat(xlsID==currID);
end

% Replace first two ratings by zero (can be NaN or Spikey at the start of the procedure)
for i=1:length(dfraw.rating)
    dfraw.rating{i}(1:2)=0;
end

% Create full length matrix filled up with NaNs
dfraw.ratingfull=NaN(length(dfraw.rating),1797);
dfraw.timefull=NaN(length(dfraw.time),1797);

for i=1:length(dfraw.rating)
    dfraw.ratingfull(i,1:length(dfraw.rating{i}))=dfraw.rating{i};
    dfraw.timefull(i,1:length(dfraw.time{i}))=dfraw.time{i};
end

dfraw.ratingfull=dfraw.ratingfull(:,1:end-1);
dfraw.timefull=dfraw.timefull(:,1:end-1);
save dfraw.mat dfraw