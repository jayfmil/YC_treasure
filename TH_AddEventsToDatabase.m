function [] = TH_AddEventsToDatabase(subject,exp,expDir,session)
% function [] = TH_AddEventsToDatabase(subject,expDir,session)
%
% FUNCTION:
%   TH_AddEventsToDatabase
%
% DESCRIPTION:
%   Add events in a TH folder to the events database. performs
%   all the checks to make sure that you do not screw up the events
%   database. 
%
% INPUT:
%   subject........ 'R1124'
%   expDir......... path to the events that you want to add.  Examples:
%                   '/data10/RAM/subjects/R1124J/behavioral/TH1/session_0'
%   session........ the session number that should be in the events dir
%
% OUTPUT:
%   saves the train events into the events database
%
% LAST UPDATED:
%   1/15/16 JFM     
%

% get the location of the events database
if isdir('/Volumes/rhino/data/events/')
    baseDir = '/Volumes/rhino';
elseif isdir('/data/events/')
    baseDir = '';
else
    error('can''t identify connection to rhino');
end

% get directories. 
eventsDir = fullfile(baseDir,'/data/events/',exp);
if ~exist(eventsDir,'dir');
  fprintf('EXITING....Events directory does not exist\n\n')  
  return
end

% check tp see if subject names match
fprintf('\n')
if isempty(regexp(expDir,subject))
  fprintf('  WARNNG: %s not found in %s\n',upper(subject),upper(expDir))
  fprintf('          you might be making an error.\n')
  fprintf('          please check this before making events. EXITING\n\n')
  fprintf('               !!! NO EVENTS SAVED !!! \n\n')
  return
end

% get the directories
evFile         = fullfile(expDir,'events.mat');
scoreFile      = fullfile(expDir,'score.mat');
timingFile     = fullfile(expDir,'timing.mat');

% load the events
ev        = loadEvents_local(evFile,session,'events'); 
score     = loadEvents_local(scoreFile,session,'score');
timing    = loadEvents_local(timingFile,session,'timing');

% load the events in the events database
[ev_db,doCat_ev] = loadEventsDB_local(eventsDir,subject,session,'events'); 
[score_db,doCat_score_db] = loadEventsDB_local(eventsDir,subject,session,'score');
[timing_db,doCat_timing_db] = loadEventsDB_local(eventsDir,subject,session,'timing');

% save the concatenated events
fprintf('\n\n')
fprintf('  events: ')
if ~isempty(ev)&&~isempty(ev_db)  
  fprintf('adding new session\n')
  ev_new = [ev_db ev];
  saveEventsDB_local(eventsDir,subject,'events',ev_new);
elseif ~isempty(ev)&&isempty(ev_db)&&doCat_ev % THIS DOESN'T REALLY MAKE SENSE. WON'T IT OVERWRITE HERE WHEN YOU DON'T WANT?
    fprintf('no database events found for this subject...\ncreating new events struct in database from the current session\n');
    ev_new = ev;
    saveEventsDB_local(eventsDir,subject,'events',ev_new);
else
  fprintf('not adding session\n')
end


fprintf('score events: ')
if ~isempty(score)&&~isempty(score_db)
  fprintf('adding new session\n')
  score_ev_new = [score_db score];
  saveEventsDB_local(eventsDir,subject,'score',score_ev_new);
elseif ~isempty(score)&&isempty(score_db)&&doCat_score_db
  fprintf('no database events found for this subject...\ncreating new events struct in database from the current session\n');
  score_ev_new = score;
  saveEventsDB_local(eventsDir,subject,'score',score_ev_new);
else
  fprintf('not adding session\n')
end

fprintf('timing events: ')
if ~isempty(timing)&&~isempty(timing_db)
  fprintf('adding new session\n')
  timing_ev_new = [timing_db timing];
  saveEventsDB_local(eventsDir,subject,'timing',timing_ev_new);
elseif ~isempty(timing)&&isempty(timing_db)&&doCat_timing_db
  fprintf('no database events found for this subject...\ncreating new events struct in database from the current session\n');
  timing_ev_new = timing;
  saveEventsDB_local(eventsDir,subject,'timing',timing_ev_new);
else
  fprintf('not adding session\n')
end

fprintf('\n\n')

%----------------------------------------------------
function saveEventsDB_local(eDir,subj,evStr,events);
  thisFileName = sprintf('%s_%s.mat',subj,evStr);
  thisFile     = fullfile(eDir,thisFileName);
  save(thisFile,'events')
  
%----------------------------------------------------
function [ev,doCat] = loadEventsDB_local(eDir,subj,sess,evStr); 
  thisFileName = sprintf('%s_%s.mat',subj,evStr);
  thisFile     = fullfile(eDir,thisFileName);
  
  doCat = 1;
  if ~exist(thisFile,'file')
    ev=[];    
    fprintf('%s does not exist in %s\n',thisFileName,eDir)
    return
  end
  
  % load the events
  ev_tmp = load(thisFile);
  ev     = ev_tmp.events;
  
  % check to make sure that the session doed not already exist in
  % the events on the database
  unSess  = unique([ev.session]);
  if sum(ismember(sess,unSess))>0    
    fprintf('%s session is already loaded in the events database\n',thisFile);
    ev = [];
    doCat = 0;
    return
  end
    
%-----------------------------------------------
function ev = loadEvents_local(evFil,sessNum,field)
  [~,thisFile] = fileparts(evFil);
  if ~exist(evFil,'file')
    fprintf('%s does not exist\n',thisFile)
    ev = [];
    return
  end  
  
  % load the events
  ev_tmp = load(evFil);
  ev     = ev_tmp.(field);
  
  % check to make sure that the events have the session that you
  % think that thet have
  unSess  = unique([ev.session]);
  numSess = length(unSess);
  if numSess~=1
    error(sprintf('I found more than one session in %s'),thisFile)
  end
  if unSess~=sessNum
    error(sprintf('%s: expecting session %d, found session %d'),...
	  sessNum,unSess)
  end
 
