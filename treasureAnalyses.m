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
[errMeanListLength,errStdListLength] = grpstats(distErrs',listLengths',{'mean','std'});
[reactMeanListLength,reactStdListLength] = grpstats((reactTimes')/1000,listLengths',{'mean','std'});

figure(1)
clf
plotData    = {errMeanListLength,reactMeanListLength};
plotDataStd = {errStdListLength,reactStdListLength};
ylabels     = {'Distance Error (VR Units)','Reaction Time (s)'};
for i = 1:2
    subplot(1,2,i)
    bar(plotData{i},'w','linewidth',2)
    ylabel(ylabels{i},'fontsize',16)
    xlabel('List Length','fontsize',16)
    set(gca,'fontsize',16)
    grid on
    hold on
    errorbar(1:3,plotData{i},plotDataStd{i},'k','linewidth',2,'linestyle','none')
end
keyboard
%%%% PERFORMANCE BY CONFIDENCE
`
[errMeanConf,errStdConf] = grpstats(distErrs',confs',{'mean','std'});
[reactMeanConf,reactStdConf] = grpstats((reactTimes')/1000,listLengths',{'mean','std'});





listLengths = unique([events.listLength]);
for l = listLengths
    [events(itemRecEvents & [events.listLength]==1).distErr]
end



%[events([events.recFromNearSide]==1).distErr]


% TIME OF TASK