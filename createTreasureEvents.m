function [events,score] = createTreasureEvents(subject,sessionDir,sessNum,saveDir)
% function events = createTreasureEvents(parfile)
%
% Create events struture for the treasure game.
%
% Input: 
%        subject: subject code (eg, 'R1124J')
%     sessionDir: path to session direction (eg., /data10/RAM/subjects/R1124J/behavioral/TH1/session_0)
%     sessionNum: session number (eg, 0)
%        saveDir: directory to save events.mat and score.mat

if ~exist('subject','var') || isempty(subject)
    fprintf('ERROR. PLEASE INPUT subject\n')
    return
end

if ~exist('sessNum','var') || isempty(sessNum)
    fprintf('ERROR. PLEASE INPUT sessionNum\n')
    return
end

if ~exist('sessionDir','var') || isempty(sessionDir)
    fprintf('ERROR. PLEASE INPUT sessionDir\n')
    return
end

if ~exist('saveDir','var') || isempty(saveDir)
    fprintf('ERROR. PLEASE INPUT saveDir\n')
    return
end

if ~exist(saveDir,'dir')
    mkdir(saveDir);
end

% create parfile if needed
cwd = pwd;
parfile = fullfile(sessionDir,'treasure.par');
if ~exist(parfile,'file')
  fprintf('%s does not exist. Creating.',parfile)
  par_python_func = which('treasureLogParser.py');   
  cd(sessionDir);
  [s,r] = system(['python ',par_python_func,' ',subject,'Log.txt']);
  if ~exist(parfile,'file')
    fprintf('%s could not be created.',parfile)
    return
  else
    fprintf(' Done.\n')
  end
end
cd(cwd);

% create timing parfile if needed
cwd = pwd;
parfileTiming = fullfile(sessionDir,'treasureTime.par');
if ~exist(parfileTiming,'file')
  fprintf('%s does not exist. Creating.',parfileTiming)
  par_python_func = which('treasureLogParser_timingInfo.py');   
  cd(sessionDir);
  [s,r] = system(['python ',par_python_func,' ',subject,'Log.txt']);
  if ~exist(parfileTiming,'file')
    fprintf('%s could not be created.',parfileTiming)    
    return
  else
    fprintf(' Done.\n')
  end
end
[timingInfo,timePerObj] = treasureTimingAnalysis(parfileTiming);
cd(cwd);

% create eeg.eeglog.up if needed
beh_syncfile = fullfile(sessionDir,'eeg.eeglog.up');
if ~exist(beh_syncfile,'file')
  unitySyncs = fullfile(sessionDir,[subject,'EEGLog.txt']);
  if exist(unitySyncs,'file')
    fprintf('Creating eeg.eeglog.up from %s.\n',unitySyncs)
    cd(sessionDir);
    [s,r] = system(sprintf('grep "ON" %s > eeg.eeglog.up',unitySyncs)); 
  elseif ~exist(unitySyncs,'file')
      fprintf('WARNING: behavioral sync pulse files does not exist\n')
  %else
  %  error(sprintf('neither %s or %s exist\n',beh_syncfile, unitySyncs))
  end
end
cd(cwd);

% open parfile
fid = fopen(parfile,'r');

% head has the field names
header = textscan(fid,'%s',21);

% next two lines have session start
startMS = textscan(fid,'%s',2); 
if ~strcmp(startMS{1}(1),'SESSION_START')
    fprintf('ERROR. LOGFILE FORMAT NOT EXPECTED\n')
    return
else
    startMS = str2double(startMS{1}(2));
end


% and selector radius size
selector_radius = textscan(fid,'%s',2); 
if ~strcmp(selector_radius{1}(1),'RADIUS')
    fprintf('ERROR. LOGFILE FORMAT NOT EXPECTED\n')
    return
else
    selector_radius = str2double(selector_radius{1}(2));
end


% read in the rest and close
c = textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s','delimiter','\t');
fclose(fid);

% create empty structure
header = {vertcat(header{:},'session')};
header = {vertcat(header{:},'radius_size')};
events = cell2struct(cell(length(header{1}),1),header{:});
events(length(c{1})).mstime = [];
header = header{1};

% fill it in
for e = 1:length(c{1})
    for f = 1:length(header)
        if any(strcmp(header{f},{'mstime','trial','block','chestNum','locationX','locationY','chosenLocationX','chosenLocationY','navStartLocationX','navStartLocationY','recStartLocationX','recStartLocationY','isRecFromNearSide','isRecFromStartSide','isSerial','reactionTime','rememberBool','isHighConf'}));
            events(e).(header{f}) = str2double(c{f}{e});
        elseif strcmp(header{f},'session')
            events(e).(header{f}) = sessNum;            
        elseif strcmp(header{f},'radius_size')   
            events(e).(header{f}) = selector_radius;     
        elseif strcmp(c{f}{e},'None')            
            events(e).(header{f}) = '';
        else            
            events(e).(header{f}) = c{f}{e};
        end        
    end
end


% once we have the events struture, add some convenience info like number
% of items per trial (listLength) and distance error (distErr)
trials     = [events.trial];
chests     = strcmp({events.type},'CHEST');
recs       = strcmp({events.type},'REC');
uniqTrials = unique(trials);

% add fields
[events.listLength] = deal('');
[events.distErr]    = deal(NaN);
[events.recalled]    = deal(NaN);

for t = uniqTrials
   trialInds     = trials==t;
   trialPresInds = trialInds & chests;
   trialRecInds  = trialInds & recs;
   
   % number of items presented on this trial
   numItems      = sum(~cellfun('isempty',{events(trialPresInds).item}));
   
   % add num items
   [events(trialInds).listLength] = deal(numItems);
   
   % calc distance error for each rec item   
   recEvents = events(trialRecInds);
   for r = 1:length(recEvents)
       recItem  = recEvents(r).item;
       recPos   = [recEvents(r).chosenLocationX recEvents(r).chosenLocationY];
       corrPos  = [recEvents(r).locationX recEvents(r).locationY];
       distErr  = sqrt(sum((corrPos - recPos).^2));       
       recalled = distErr < selector_radius;
       itemInds = trialInds & strcmp({events.item},recItem);
       [events(itemInds).distErr] = deal(distErr);
       [events(itemInds).recalled] = deal(recalled);
   end
end

% add initial event with session start time
f = fieldnames(events);
c = NaN(length(f),1);
eStart = cell2struct(num2cell(c),f);
eStart.mstime = startMS;
eStart.type = 'SESS_START';
eStart.subj = events(1).subj;
eStart.session = events(1).session;
eStart.radius_size = events(1).radius_size;
events = [eStart events];
[events.subj] = deal(subject);

% save to file
fname = fullfile(saveDir,'events.mat');
save(fname,'events');

% create scores.mat to hold the score for the session
fid = fopen(fullfile(sessionDir,'totalScore.txt'));
c = textscan(fid,'%s');
fclose(fid);
sessionScore = str2num(c{1}{1});
score = [];
score.sessionScore = sessionScore;
score.subj = subject;
score.session = sessNum;
fname = fullfile(saveDir,'score.mat');
save(fname,'score');

% create timing.mat to hold the timing info for the session
timing = [];
timing.trialInfo = timingInfo;
timing.timePerObj = timePerObj;
timing.subj = subject;
timing.session = sessNum;
fname = fullfile(saveDir,'timing.mat');
save(fname,'timing');















