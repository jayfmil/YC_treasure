function treasureTimingAnalysis(parfile)
% function treasureTimingAnalysis(parfile)
%
% input .par file that is created with treasureLogParser_timingInfo.py

% open parfile
fid = fopen(parfile,'r');

% read in the rest and close
c = textscan(fid,'%s%s%s','delimiter','\t');
fclose(fid);

% indices of relavent events
startInd      = strcmp(c{3},'START');
endInd        = strcmp(c{3},'END');
trialStartInd = strcmp(c{3},'trial_start');
navStartInd   = strcmp(c{3},'trial_nav_start');
recStartInd   = strcmp(c{3},'rec_start');
feedStartInd  = strcmp(c{3},'feedback_start');
homeStartInd  = strcmp(c{3},'homebase_transport');
instStartInd  = strcmp(c{3},'instructions');
objInds       = strcmp(c{3},'object');
chestInds       = strcmp(c{3},'chest');

% timestamps and trials
mstimes = cellfun(@str2num,(c{1}));
trials  = cellfun(@str2num,(c{2}));

% total session time
totalTime = mstimes(endInd) - mstimes(startInd);

% time per trial
timePerTrial = diff(mstimes(trialStartInd | endInd));

% time per homebase transport
timePerHome = mstimes(find(homeStartInd)+1) - mstimes(homeStartInd);

% time per navigation preiod
timePerNav = mstimes(recStartInd) - mstimes(navStartInd);

% time per recall preiod
timePerRec = mstimes(feedStartInd) - mstimes(recStartInd);

% time per feedback
timePerFeed = mstimes(find(feedStartInd)+1) - mstimes(feedStartInd);

% time per instructions
timePerInst = mstimes(find(instStartInd)+1) - mstimes(instStartInd);
trialsInst  = trials(instStartInd);
timePerInstTrial = grpstats(timePerInst,trialsInst,{'sum'});


%%% BAR PLOT BREAKING DOWN TIMES BY CONDITION FOR EACH TRIAL

% ydata is navigation time, recall time, and total time
y = [timePerNav timePerRec timePerTrial - (timePerRec+timePerNav)]/1000;
y = [y;mean(y)];

% plot the bars and make them look nice
clf
x = [1:size(y,1)-1 size(y,1)+1];
h=bar(x,y,'stacked');
h(1).FaceColor = [0 67 88]/255;
h(2).FaceColor = [31 138 112]/255;
h(3).FaceColor = [190 219 57]/255;
set(gca,'xtick',x);

% label by the number of objects per trial
objsForEachTrial = grpstats(objInds,trials,{'sum'});
objsForEachTrial = [objsForEachTrial; mean(objsForEachTrial)];

% figure settings
f = gca;
xtick = f.XTick;
set(gca,'xticklabel',objsForEachTrial);
set(gca,'xlim',[0 xtick(end)+1])
ylabel('Time (s)')
xlabel('# Objects/Trial')
set(gca,'fontsize',18)
hold on
ylim = f.YLim;
plot([xtick(end)-1 xtick(end)-1],ylim,'--k','linewidth',3)
h2=legend('Navigation','Recall','Other') ;
h2.Location = 'EastOutside';

% title with the time per objects
titleStr = sprintf('%.3f s/object',totalTime/sum(objInds)/1000);
title(titleStr);














