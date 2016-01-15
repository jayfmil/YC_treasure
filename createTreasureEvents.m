function events = createTreasureEvents(parfile,sessNum,saveDir)
% function events = createTreasureEvents(parfile)
%
% Create events struture for the treasure game.
%
% Input: path to parfile created with parser.py
%        path to directory to save events file

if ~exist('sessNum','var') || isempty(sessNum)
    fprintf('ERROR. PLEASE INPUT SESSION NUMBER\n')
    return
end

if ~exist(saveDir,'dir')
    mkdir(saveDir);
end

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

% save to file
fname = fullfile(saveDir,[events(1).subj '_events.mat']);
save(fname,'events');















