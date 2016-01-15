function [res,figs] = treasureAnalyses(events,saveDir)
% function treasureAnalyses(events,saveDir)
%
% Inputs:  events - treasure game events structure for a single session
%         saveDir - directory to save results
%
% This function saves a file <sessionname>_res.mat in saveDir. This
% function also creates a report <sessionname>_treasureReport.pdf


% location to save average data
if ~exist(saveDir,'dir')
    mkdir(saveDir);
end

% location to save figures
figDir = fullfile(saveDir,'figs');
if ~exist(figDir,'dir')
    mkdir(figDir);
end

% structure to hold average data
subj = events(1).subj;
res  = [];
figs = [];

%--------------------------------------------------------------------------

% get important behavioral variables from events
% recall events, used for most analyses
itemRecEvents = strcmp({events.type},'REC');

% list length: number of chests with items per list
listLengths = [events(itemRecEvents).listLength];

% trial number
trialNum = [events(itemRecEvents).trial];
blockNum = [events(itemRecEvents).block];

% add study test lag to events
events = addStudyTestLag(events);
studyTestLag = [events(itemRecEvents).studyTestLag];

% add "correctItem" field to indicate if the response location corresponds
% the location of the correct item (1), a different item on the list (2),
% or no item 0)
events = addCorrectField(events);
isCorrectItem     = [events(itemRecEvents).correctItem];
isCorrectItemNo   = [events(itemRecEvents).correctItemNoConf];
isCorrectItemLow  = [events(itemRecEvents).correctItemLowConf];
isCorrectItemHigh = [events(itemRecEvents).correctItemHighConf];

% euclidean distance error for each recall
distErrs    = [events(itemRecEvents).distErr];

% reaction time for each recall
reactTimes  = [events(itemRecEvents).reactionTime]/1000;

% correct/incorrect bool
correct = [events(itemRecEvents).recalled];

% whether the object location is near or far from test location
nearFar = ~[events(itemRecEvents).isRecFromNearSide];

% whether the orientation is flipped from nav to test
sameDiff = ~[events(itemRecEvents).isRecFromStartSide];

% also calculate normalized distance error
xs          = [events(itemRecEvents).chosenLocationX];
ys          = [events(itemRecEvents).chosenLocationY];
xsCorrect   = [events(itemRecEvents).locationX];
ysCorrect   = [events(itemRecEvents).locationY];
normErrs    = NaN(size(distErrs));
for i = 1:length(normErrs)
   normErrs(i) = calcNormError([xs(i) ys(i)],[xsCorrect(i) ysCorrect(i)]);
end

% confidence of each response (0 = not remembered, 1 = low, 2 = high)
confs = [events(itemRecEvents).isHighConf];
confs = confs + 1;
confs([events(itemRecEvents).rememberBool]==0) = 0;

% presenation events are used for serial position analyses
itemPresEvents = strcmp({events.type},'CHEST') & ~isnan([events.rememberBool]);

% number of chests for the trial
presListLength = [events(itemPresEvents).listLength];

% serial position of the object and associated measures
presSerPos     = [events(itemPresEvents).chestNum];
distErrsPres   = [events(itemPresEvents).distErr];
rememberBool   = [events(itemPresEvents).rememberBool];
uniqListLen    = unique(presListLength);
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% PERFORMANCE BY LIST LENGTH BAR

metrics     = {distErrs,normErrs,reactTimes,correct};
fields      = {'errMeanListLength','normErrMeanListLength','reactMeanListLength','correctMeanListLength'};
ylabels     = {'Distance Error (VR Units)','Normalized Distance Error','Reaction Time (s)','Prob. Correct'};
for m = 1:length(metrics)
    
    % calculate mean, std, and counts of errors and reaction time
    [errMeanListLength,errStdListLength,nMeanListLength] = grpstats(metrics{m}',listLengths',{'mean','std','numel'});    
    
    % plot it
    figure(1)
    clf    
    bar(errMeanListLength,'w','linewidth',2)
    ylabel(ylabels{m},'fontsize',16)
    xlabel('List Length','fontsize',16)
    set(gca,'fontsize',16)
    set(gca,'xticklabel',unique(listLengths))
    grid on
    hold on
    errorbar(1:length(errMeanListLength),errMeanListLength,errStdListLength./sqrt(nMeanListLength-1),'k','linewidth',2,'linestyle','none')
            
    % save to res structure and print figure
    res.(fields{m}) = errMeanListLength';
    fname = fullfile(figDir,[subj '_' fields{m}]);
    figs.(fields{m}) = fname;    
    print('-depsc2','-loose',[fname '.eps'])
end

% save un binned data to res structure
res.distErrs   = distErrs';
res.normErrs   = normErrs';
res.reactTimes = reactTimes';
res.correct    = correct';

%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% PERFORMANCE BY TRIAL NUMBER BAR

metrics     = {distErrs,normErrs,reactTimes,correct};
fields      = {'errMeanTrial','normErrMeanTrial','reactMeanTrial','correctMeanTrial'};
ylabels     = {'Distance Error (VR Units)','Normalized Distance Error','Reaction Time (s)','Prob. Correct'};
for m = 1:length(metrics)
    
    % calculate mean, std, and counts of errors and reaction time
    [errMeanTrial,errStdTrial,nMeanTrial] = grpstats(metrics{m}',trialNum',{'mean','std','numel'});    
    
    % plot it
    figure(1)
    clf    
    bar(errMeanTrial,'w','linewidth',2)
    ylabel(ylabels{m},'fontsize',16)
    xlabel('Trial Number','fontsize',16)
    set(gca,'fontsize',16)
    set(gca,'xtick',1:2:length(unique(trialNum)));
    t = unique(trialNum);
    set(gca,'xticklabel',t(1:2:end)+1);
    grid on
    hold on
    errorbar(1:length(errMeanTrial),errMeanTrial,errStdTrial./sqrt(nMeanTrial-1),'k','linewidth',2,'linestyle','none')
            
    % save to res structure and print figure
    res.(fields{m}) = errMeanTrial';
    fname = fullfile(figDir,[subj '_' fields{m}]);
    figs.(fields{m}) = fname;    
    print('-depsc2','-loose',[fname '.eps'])    
end

%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% PERFORMANCE BY BLOCK NUMBER BAR

metrics     = {distErrs,normErrs,reactTimes,correct};
fields      = {'errMeanBlock','normErrMeanBlock','reactMeanBlock','correctMeanBlock'};
ylabels     = {'Distance Error (VR Units)','Normalized Distance Error','Reaction Time (s)','Prob. Correct'};
for m = 1:length(metrics)
    
    % calculate mean, std, and counts of errors and reaction time
    [errMeanBlock,errStdBlock,nMeanBlock] = grpstats(metrics{m}',blockNum',{'mean','std','numel'});    
    
    % plot it
    figure(1)
    clf    
    bar(errMeanBlock,'w','linewidth',2)
    ylabel(ylabels{m},'fontsize',16)
    xlabel('Block Number','fontsize',16)
    set(gca,'fontsize',16)
    set(gca,'xtick',1:2:length(unique(blockNum)));
    t = unique(blockNum);
    set(gca,'xticklabel',t);
    grid on
    hold on
    errorbar(1:length(errMeanBlock),errMeanBlock,errStdBlock./sqrt(nMeanBlock-1),'k','linewidth',2,'linestyle','none')
            
    % save to res structure and print figure
    res.(fields{m}) = errMeanBlock';
    fname = fullfile(figDir,[subj '_' fields{m}]);
    figs.(fields{m}) = fname;    
    print('-depsc2','-loose',[fname '.eps'])    
end

%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% PERFORMANCE BY STUDY TEST LAG BAR

metrics     = {distErrs,normErrs,reactTimes,correct};
fields      = {'errMeanLag','normErrMeanLag','reactMeanLag','correctMeanLag'};
ylabels     = {'Distance Error (VR Units)','Normalized Distance Error','Reaction Time (s)','Prob. Correct'};
for m = 1:length(metrics)
    
    % calculate mean, std, and counts of errors and reaction time
    [errMeanLag,errStdLag,nMeanLag] = grpstats(metrics{m}',studyTestLag',{'mean','std','numel'});    
    
    % catch instances where not all confidence levels are used and add in NaNs
    missing = ~ismember(1:6,studyTestLag);
    if ~all(missing)
        [errMeanLagTmp,errStdLagTmp,nMeanLagTmp]      = deal(NaN(6,1));        
        errMeanLagTmp(~missing)   = errMeanLag;errMeanLag=errMeanLagTmp;
        errStdLagTmp(~missing)    = errStdLag;errStdLag=errStdLagTmp;
        nMeanLagTmp(~missing)     = nMeanLag;nMeanLag=nMeanLagTmp;
    end        
    
    % plot it
    figure(1)
    clf    
    bar(errMeanLag,'w','linewidth',2)
    ylabel(ylabels{m},'fontsize',16)
    xlabel('Lag','fontsize',16)
    set(gca,'fontsize',16)
    set(gca,'xtick',1:length(unique(studyTestLag)));
    t = unique(studyTestLag);
    set(gca,'xticklabel',t);
    grid on
    hold on
    errorbar(1:length(errMeanLag),errMeanLag,errStdLag./sqrt(nMeanLag-1),'k','linewidth',2,'linestyle','none')
            
    % save to res structure and print figure
    res.(fields{m}) = errMeanLag';
    fname = fullfile(figDir,[subj '_' fields{m}]);
    figs.(fields{m}) = fname;    
    print('-depsc2','-loose',[fname '.eps'])    
end


%--------------------------------------------------------------------------
% PERFORMANCE BY CONFIDENCE BAR

fields = {'errMeanConf','normErrMeanConf','reactMeanConf','correctMeanConf'};
for m = 1:length(metrics)
    
    % calculate mean, std, and counts of errors and reaction time
    [errMeanConf,errStdConf,nMeanConf] = grpstats(metrics{m}',confs',{'mean','std','numel'});    
    
    % catch instances where not all confidence levels are used and add in NaNs
    missing = ~ismember(0:2,confs);
    if ~all(missing)
        [errMeanConfTmp,errStdConfTmp,nMeanConfTmp]      = deal(NaN(3,1));        
        errMeanConfTmp(~missing)   = errMeanConf;errMeanConf=errMeanConfTmp;
        errStdConfTmp(~missing)    = errStdConf;errStdConf=errStdConfTmp;
        nMeanConfTmp(~missing)     = nMeanConf;nMeanConf=nMeanConfTmp;
    end
    
    % plot it
    figure(2)
    clf
    bar(errMeanConf,'w','linewidth',2)
    ylabel(ylabels{m},'fontsize',16)
    xlabel('Confidence','fontsize',16)
    set(gca,'fontsize',16)
    set(gca,'xticklabel',unique(listLengths))
    grid on
    hold on
    errorbar(1:length(errMeanConf),errMeanConf,errStdConf./sqrt(nMeanConf-1),'k','linewidth',2,'linestyle','none')
        
    % save to res structure and print figure
    res.(fields{m}) = errMeanConf';
    if m == 1        
        res.probConf = (nMeanConf/nansum(nMeanConf))';
    end
    fname = fullfile(figDir,[subj '_' fields{m}]);
    figs.(fields{m}) = fname;
    print('-depsc2','-loose',[fname '.eps'])
end
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% PERFORMANCE BY TARGET LOCATION (NEAR/FAR)

fields = {'errTargetLoc','normErrTargetLoc','reactTargetLoc','correctTargetLoc'};
for m = 1:length(metrics)
    
    % calculate means, std, and counts
    [errMeanTargLoc,errStdDistLoc,nMeanDistTargLoc] = grpstats(metrics{m}',nearFar',{'mean','std','numel'});
    
    % plot it
    figure(3)
    clf
    bar(errMeanTargLoc,'w','linewidth',2)
    ylabel(ylabels{m},'fontsize',16)
    xlabel('Target Location','fontsize',16)
    set(gca,'fontsize',16)
    set(gca,'xticklabel',{'Near','Far'})
    grid on
    hold on
    errorbar(1:length(errMeanTargLoc),errMeanTargLoc,errStdDistLoc./sqrt(nMeanDistTargLoc-1),'k','linewidth',2,'linestyle','none')
    
    % save to res structure and print figure
    res.(fields{m}) = errMeanTargLoc';
    fname = fullfile(figDir,[subj '_' fields{m}]);
    figs.(fields{m}) = fname;
    print('-depsc2','-loose',[fname '.eps'])
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% PERFORMANCE BY ORIENTATION FLIPPED (SAME/DIRR)

fields = {'errFieldOrient','normFieldOrient','reactFieldOrient','correctFieldOrient'};
for m = 1:length(metrics)
    
    % calculate means, std, and counts
    [errMeanFieldOrient,errStdFieldOrient,nMeanFieldOrient] = grpstats(metrics{m}',sameDiff',{'mean','std','numel'});
    
    % plot it
    figure(3)
    clf
    bar(errMeanFieldOrient,'w','linewidth',2)
    ylabel(ylabels{m},'fontsize',16)
    xlabel('Field Orientation','fontsize',16)
    set(gca,'fontsize',16)
    set(gca,'xticklabel',{'Same','Different'})
    grid on
    hold on
    errorbar(1:length(errMeanFieldOrient),errMeanFieldOrient,errStdFieldOrient./sqrt(nMeanFieldOrient-1),'k','linewidth',2,'linestyle','none')
    
    % save to res structure and print figure
    res.(fields{m}) = errMeanFieldOrient';
    fname = fullfile(figDir,[subj '_' fields{m}]);
    figs.(fields{m}) = fname;
    print('-depsc2','-loose',[fname '.eps'])
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% SERIAL POSITION CURVE BY LISTLENGTH

% compute error for each serial position
errMat    = NaN(length(uniqListLen),max([events.chestNum]));
errStdMat = NaN(length(uniqListLen),max([events.chestNum]));
for i = 1:length(uniqListLen)
    trials = presListLength == uniqListLen(i);
    [err,errStd,n] = grpstats(distErrsPres(trials)',presSerPos(trials)',{'mean','std','numel'});
    errMat(i,unique(presSerPos(trials))) = err;
    errStdMat(i,unique(presSerPos(trials))) = errStd./sqrt(n-1);
end
res.errMat = errMat;

figure(4)
clf
errorbar(repmat(1:size(errStdMat,2),size(errStdMat,1),1)',errMat',errStdMat','linewidth',3)
h=legend(strcat(cellfun(@num2str,num2cell(uniqListLen),'uniformoutput',false),' item list'));
set(h,'fontsize',20)
xlabel('','fontsize',16);
ylabel('Distance Error','fontsize',16);
grid on
set(gca,'gridlinestyle',':');
set(gca,'fontsize',16)
set(gca,'xtick',1:size(errMat,2))

fname = fullfile(figDir,[subj '_spc']);
figs.spc = fname;
print('-depsc2','-loose',[fname '.eps'])
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% DISTANCE ERROR HISTOGRAM
figure(5)
clf
[n,x] = hist(distErrs);
bar(x,n,1,'w','linewidth',2);
xlabel('Distance Error','fontsize',16);
ylabel('Count','fontsize',16);
set(gca,'fontsize',16)
grid on
set(gca,'gridlinestyle',':');
set(gca,'fontsize',16)
fname = fullfile(figDir,[subj '_distErrHist']);
figs.distErrHist = fname;
print('-depsc2','-loose',[fname '.eps'])


% DISTANCE ERROR BY HISTOGRAM CONFIDENCE
edges = 0:5:100;
binMean = mean([edges(1:end-1)' edges(2:end)'],2);
distByConf = NaN(3,20);
figure(6)
clf
for i = 1:3
    n =  histc(distErrs(confs==i-1),edges);
    n = n/sum(n);
    hold on
    plot(binMean,n(1:20),'linewidth',3)
    distByConf(i,:) = n(1:20);
end
ylabel('Probability','fontsize',16);
xlabel('Distance Error','fontsize',16);
grid on
set(gca,'gridlinestyle',':');
set(gca,'fontsize',16)
fname = fullfile(figDir,[subj '_distErrConfHist']);
res.distByConfHist = distByConf;
print('-depsc2','-loose',[fname '.eps'])

% NORMALIZED DISTANCE ERROR BY HISTOGRAM CONFIDENCE
edges = 0:.05:1;
binMean = mean([edges(1:end-1)' edges(2:end)'],2);
normErrByConf = NaN(3,20);
figure(7)
clf
for i = 1:3
    n =  histc(normErrs(confs==i-1),edges);
    n = n/sum(n);
    hold on
    plot(binMean,n(1:20),'linewidth',3)
    normErrByConf(i,:) = n(1:20);
end
ylabel('Probability','fontsize',16);
xlabel('Normalized Distance Error','fontsize',16);
grid on
set(gca,'gridlinestyle',':');
set(gca,'fontsize',16)
fname = fullfile(figDir,[subj '_normDistErrConfHist']);
res.normDistByConfHist = normErrByConf;
print('-depsc2','-loose',[fname '.eps'])
%--------------------------------------------------------------------------

confusionPerc = NaN(1,3);
for i = 1:3
    confusionPerc(i) = mean(isCorrectItem==i-1);
end
confusionPerc = confusionPerc([2 1 3]);
res.confusionPerc = confusionPerc;

confusionPercNo = NaN(1,3);
for i = 1:3
    confusionPercNo(i) = sum(isCorrectItemNo==i-1)/sum(isCorrectItemNo ~= 1 & ~isnan(isCorrectItemNo));%sum(~isnan(isCorrectItemNo));
end
confusionPercNo = confusionPercNo([2 1 3]);
res.confusionPercNo = confusionPercNo;

confusionPercLow = NaN(1,3);
for i = 1:3
    confusionPercLow(i) = sum(isCorrectItemLow==i-1)/sum(isCorrectItemLow ~= 1 & ~isnan(isCorrectItemLow));%sum(~isnan(isCorrectItemLow));
end
confusionPercLow = confusionPercLow([2 1 3]);
res.confusionPercLow = confusionPercLow;

confusionPercHigh = NaN(1,3);
for i = 1:3
    confusionPercHigh(i) = sum(isCorrectItemHigh==i-1)/sum(isCorrectItemHigh ~= 1 & ~isnan(isCorrectItemHigh));%sum(~isnan(isCorrectItemHigh));
end
confusionPercHigh = confusionPercHigh([2 1 3]);
res.confusionPercHigh = confusionPercHigh;


%--------------------------------------------------------------------------
% PERCENT CORRECT AS A FUNCTION OF DISTANCE THRESHOLD
figure(8)
clf
possDists = linspace(0,100,250);
pCorr = NaN(1,length(possDists));
for i = 1:length(possDists)
    pCorr(i) = mean(distErrs < possDists(i));
end
pCorr = pCorr*100;
plot(possDists,pCorr,'linewidth',3)
grid on
set(gca,'gridlinestyle',':');

hold on
x1 = possDists(sum(possDists < 10));
y1 = pCorr(sum(possDists < 10));
plot([x1 x1],[0 y1],'-k','linewidth',3);
plot([0 x1],[y1 y1],'-k','linewidth',3);

half = sum(pCorr <= 50);
x2 = possDists(half);
y2 = pCorr(half);
plot([x2 x2],[0 y2],':k','linewidth',3);
plot([0 x2],[y2 y2],':k','linewidth',3);

xlabel('Correct threshold','fontsize',24)
ylabel('Percent within circle','fontsize',24)

titleStr = sprintf('%.2f%% at 10, 50%% at %.2f',y1,x2);
title(titleStr);
set(gca,'TitleFontWeight','normal')
set(gca,'fontsize',24)

fname = fullfile(figDir,[subj '_pCorr']);
figs.pCorr = fname;
print('-depsc2','-loose',[fname '.eps'])

fname = fullfile(saveDir,[events(1).subj '_res.mat']);
save(fname,'res')


function events = addStudyTestLag(events)

% add empty field to fill in
[events.studyTestLag] = deal(NaN);

% loop over each recall event
recInds = find(strcmp({events.type},'REC'));
for e = 1:length(recInds)
    
    % find corresponding presentation events
    pres = find(strcmp({events(1:recInds(e)-1).item},events(recInds(e)).item));
    
    % compute and add lag to presentation and recall events
    lag   = recInds(e) - pres;
    events(pres).studyTestLag = lag;
    events(recInds(e)).studyTestLag = lag;        
end




function events = addCorrectField(events)

% add empty field to fill in
[events.correctItem] = deal(0);
[events.correctItemNoConf] = deal(NaN);
[events.correctItemLowConf] = deal(NaN);
[events.correctItemHighConf] = deal(NaN);


% loop over each trial
trials = unique([events.trial]);
recInds = strcmp({events.type},'REC');
for t = 1:length(trials)
    
    trialInds = [events.trial] == trials(t);
    trialRec  = find(trialInds & recInds);
        
    objectLocs  = [[events(trialRec).locationX]' [events(trialRec).locationY]'];
    chanceDists = calcChanceForTrial(objectLocs);
    respLocs = [[events(trialRec).chosenLocationX]' [events(trialRec).chosenLocationY]'];
    for r = 1:length(trialRec)
       
        objLoc = [events(trialRec(r)).locationX events(trialRec(r)).locationY];
        dists  = pdist([objLoc; respLocs]);
        
        confField = 'correctItemHighConf';
        if ~events(trialRec(r)).rememberBool
            confField = 'correctItemNoConf';
        elseif ~events(trialRec(r)).isHighConf
            confField = 'correctItemLowConf';
        end
        
        thresh = min(chanceDists(setdiff(1:length(trialRec),r)));
        
        correctItem = 0;
        if dists(r) < 10;
            correctItem = 1;                           
        elseif any(dists(setdiff(1:length(trialRec),r)) < thresh);
%             dists(setdiff(1:length(trialRec),r)) < chanceDists(setdiff(1:length(trialRec),r))
            correctItem = 2;
        end
        events(trialRec(r)).correctItem = correctItem;
        events(trialRec(r)).(confField) = correctItem;
        
        % find corresponding presentation events
        pres = find(strcmp({events(1:trialRec(r)-1).item},events(trialRec(r)).item));        
        events(pres).correctItem = correctItem;
        events(pres).(confField) = correctItem;
        
    end
    
end
























