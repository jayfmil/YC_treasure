function events = createTreasureEvents(parfile,saveDir)
% function events = createTreasureEvents(parfile)
%
% Create events struture for the treasure game.
%
% Input: path to parfile created with parser.py
%        path to directory to save events file

if ~exist(saveDir,'dir')
    mkdir(saveDir);
end

% open parfile
fid = fopen(parfile,'r');

% head has the field names
header = textscan(fid,'%s',17);

% read in the rest and close
c = textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s','delimiter','\t');
fclose(fid);

% create empty structure
events = cell2struct(cell(17,1),header{:});
events(length(c{1})).mstime = [];
header = header{1};

% fill it in
for e = 1:length(c{1})
    for f = 1:length(header)
        if any(strcmp(header{f},{'mstime','trial','chestNum','locationX','locationY','chosenLocationX','chosenLocationY','recStartLocationX','recStartLocationY','isRecFromNearSide','isSerial','reactionTime','rememberBool','isHighConf'}));
            events(e).(header{f}) = str2double(c{f}{e});
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
       recItem = recEvents(r).item;
       recPos  = [recEvents(r).chosenLocationX recEvents(r).chosenLocationY];
       corrPos = [recEvents(r).locationX recEvents(r).locationY];
       distErr = sqrt(sum((corrPos - recPos).^2));       
       itemInds = trialInds & strcmp({events.item},recItem);
       [events(itemInds).distErr] = deal(distErr);
   end
end

% save to file
fname = fullfile(saveDir,[events(1).subj '_events.mat']);
save(fname,'events');















