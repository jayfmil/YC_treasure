function treasureAnalyses(events)
%
% What analyses do we want to do?

% DISTANCE ERROR X CONDITION
% Condition categories: List length
%                       Confidence
%                       Target location (near/far)

itemRecEvents = strcmp({events.type},'REC');

%%%% PERFORMANCE BY LIST LENGTH
listLengths = [events(itemRecEvents).listLength];
distErrs    = [events(itemRecEvents).distErr];
reactTimes  = [events(itemRecEvents).reactionTime];
[errMeanListLength,errStdListLength,nMeanDistLength] = grpstats(distErrs',listLengths',{'mean','std','numel'});
[reactMeanListLength,reactStdListLength,nMeanReactLength] = grpstats((reactTimes')/1000,listLengths',{'mean','std','numel'});

figure(1)
clf
plotData    = {errMeanListLength,reactMeanListLength};
plotDataStd = {errStdListLength,reactStdListLength};
ns          = {nMeanDistLength,nMeanReactLength};
ylabels     = {'Distance Error (VR Units)','Reaction Time (s)'};
for i = 1:2
    subplot(1,2,i)
    bar(plotData{i},'w','linewidth',2)
    ylabel(ylabels{i},'fontsize',16)
    xlabel('List Length','fontsize',16)
    set(gca,'fontsize',16)
    grid on
    hold on
    errorbar(1:length(plotData{i}),plotData{i},plotDataStd{i}./sqrt(ns{i}-1),'k','linewidth',2,'linestyle','none')
end

%%%% PERFORMANCE BY CONFIDENCE
confs = [events(itemRecEvents).isHighConf];
[errMeanConf,errStdConf,nMeanDistConf] = grpstats(distErrs',confs',{'mean','std','numel'});
[reactMeanConf,reactStdConf,nMeanReactConf] = grpstats((reactTimes')/1000,confs',{'mean','std','numel'});

figure(2)
clf
plotData    = {errMeanConf,reactMeanConf};
plotDataStd = {errStdConf,reactStdConf};
ns          = {nMeanDistConf,nMeanReactConf};
ylabels     = {'Distance Error (VR Units)','Reaction Time (s)'};
for i = 1:2
    subplot(1,2,i)
    bar(plotData{i},'w','linewidth',2)
    ylabel(ylabels{i},'fontsize',16)
    xlabel('Confidence','fontsize',16)
    set(gca,'fontsize',16)
    grid on
    hold on
    errorbar(1:length(plotData{i}),plotData{i},plotDataStd{i}./sqrt(ns{i}-1),'k','linewidth',2,'linestyle','none')
end

%%%% PERFORMANCE BY TARGET LOCATION (NEAR/FAR)
nearFar = ~[events(itemRecEvents).isRecFromNearSide];
[errMeanTargLoc,errStdDistLoc,nMeanDistTargLoc] = grpstats(distErrs',nearFar',{'mean','std','numel'});
[reactMeanTargLoc,reactStdTargLoc,nMeanReactTargLoc] = grpstats((reactTimes')/1000,nearFar',{'mean','std','numel'});

figure(3)
clf
plotData    = {errMeanTargLoc,reactMeanTargLoc};
plotDataStd = {errStdDistLoc,reactStdTargLoc};
ns          = {nMeanDistTargLoc,nMeanReactTargLoc};
ylabels     = {'Distance Error (VR Units)','Reaction Time (s)'};
for i = 1:2
    subplot(1,2,i)
    bar(plotData{i},'w','linewidth',2)
    ylabel(ylabels{i},'fontsize',16)
    xlabel('Near/Far Target','fontsize',16)
    set(gca,'fontsize',16)
    grid on
    hold on
    errorbar(1:length(plotData{i}),plotData{i},plotDataStd{i}./sqrt(ns{i}-1),'k','linewidth',2,'linestyle','none')
end

%%%% DISTANCE ERROR HISTOGRAM
figure(4)
[n,x] = hist(distErrs);
bar(x,n,1,'w','linewidth',2);
xlabel('Distance Error','fontsize',16);
ylabel('Count','fontsize',16);
set(gca,'fontsize',16)
grid on
keyboard


% TIME OF TASK





















