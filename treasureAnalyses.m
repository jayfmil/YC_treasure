function treasureAnalyses(events,saveDir)
%
% What analyses do we want to do?

% DISTANCE ERROR X CONDITION
% Condition categories: List length
%                       Confidence
%                       Target location (near/far)

if ~exist(saveDir,'dir')
    mkdir(saveDir);
end

% recall events, used for most analyses
itemRecEvents = strcmp({events.type},'REC');

%%%% PERFORMANCE BY LIST LENGTH
listLengths = [events(itemRecEvents).listLength];
distErrs    = [events(itemRecEvents).distErr];
reactTimes  = [events(itemRecEvents).reactionTime];
[errMeanListLength,errStdListLength,nMeanDistLength] = grpstats(distErrs',listLengths',{'mean','std','numel'});
[reactMeanListLength,reactStdListLength,nMeanReactLength] = grpstats((reactTimes')/1000,listLengths',{'mean','std','numel'});

figs = [];
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
    set(gca,'xticklabel',unique(listLengths))
    grid on
    hold on
    errorbar(1:length(plotData{i}),plotData{i},plotDataStd{i}./sqrt(ns{i}-1),'k','linewidth',2,'linestyle','none')
end
fname = fullfile(saveDir,'listLength');
figs.listLength = fname;
print('-depsc2','-loose',[fname '.eps'])

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
    set(gca,'xticklabel',{'Low','High'})
    set(gca,'fontsize',16)
    grid on
    hold on
    errorbar(1:length(plotData{i}),plotData{i},plotDataStd{i}./sqrt(ns{i}-1),'k','linewidth',2,'linestyle','none')
end
fname = fullfile(saveDir,'conf');
figs.conf = fname;
print('-depsc2','-loose',[fname '.eps'])

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
    set(gca,'xticklabel',{'Near','Far'})
    set(gca,'fontsize',16)
    grid on
    hold on
    errorbar(1:length(plotData{i}),plotData{i},plotDataStd{i}./sqrt(ns{i}-1),'k','linewidth',2,'linestyle','none')
end
fname = fullfile(saveDir,'nearFar');
figs.nearFar = fname;
print('-depsc2','-loose',[fname '.eps'])

%%% SERIAL POSITION CURVE BY LISTLENGTH
itemPresEvents = strcmp({events.type},'CHEST') & ~isnan([events.rememberBool]);
presListLength = [events(itemPresEvents).listLength];
presSerPos     = [events(itemPresEvents).chestNum];
distErrsPres   = [events(itemPresEvents).distErr];
rememberBool   = [events(itemPresEvents).rememberBool] ;
uniqListLen    = unique(presListLength);

errMat    = NaN(length(uniqListLen),max([events.chestNum]));
errStdMat = NaN(length(uniqListLen),max([events.chestNum]));
for i = 1:length(uniqListLen)
    trials = presListLength == uniqListLen(i);
    [err,errStd,n] = grpstats(distErrsPres(trials)',presSerPos(trials)',{'mean','std','numel'});
    errMat(i,unique(presSerPos(trials))) = err;
    errStdMat(i,unique(presSerPos(trials))) = errStd./sqrt(n-1);
end
figure(4)
clf
axes('position',[.13 .4 .775 .5]);
errorbar(repmat(1:size(errStdMat,2),size(errStdMat,1),1)',errMat',errStdMat','linewidth',3)
h=legend(strcat(cellfun(@num2str,num2cell(uniqListLen),'uniformoutput',false),' item list'));
set(h,'fontsize',20)
xlabel('','fontsize',16);
ylabel('Distance Error','fontsize',16);
grid on
set(gca,'gridlinestyle',':');
set(gca,'fontsize',16)
set(gca,'xtick',1:size(errMat,2))

axes('position',[.13 .1 .775 .2])
[meanRemember,errRemember,nRemember] = grpstats(rememberBool',presSerPos',{'mean','std','numel'});
bar(meanRemember,'w','linewidth',3)
set(gca,'xtick',1:size(errMat,2))
xlabel('Serial Position','fontsize',16);
ylabel('Percent ','fontsize',16);
grid on
set(gca,'gridlinestyle',':');
set(gca,'fontsize',16)

fname = fullfile(saveDir,'spc');
figs.spc = fname;
print('-depsc2','-loose',[fname '.eps'])

%%%% DISTANCE ERROR HISTOGRAM
figure(5)
clf
[n,x] = hist(distErrs);
bar(x,n,1,'w','linewidth',2);
xlabel('Distance Error','fontsize',16);
ylabel('Count','fontsize',16);
set(gca,'fontsize',16)
grid on
fname = fullfile(saveDir,'distErr');
figs.distErr = fname;
print('-depsc2','-loose',[fname '.eps'])

%%%% PERCENT CORRECT AS A FUNCTION OF DISTANCE THRESHOLD
figure(6)
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
x1 = possDists(sum(possDists < 12.5));
y1 = pCorr(sum(possDists < 12.5));
plot([x1 x1],[0 y1],'-k','linewidth',3);
plot([0 x1],[y1 y1],'-k','linewidth',3);

half = sum(pCorr <= 50);
x2 = possDists(half);
y2 = pCorr(half);
plot([x2 x2],[0 y2],':k','linewidth',3);
plot([0 x2],[y2 y2],':k','linewidth',3);

xlabel('Correct threshold','fontsize',24)
ylabel('Percent within circle','fontsize',24)

titleStr = sprintf('%.2f%% at 12.5, 50%% at %.2f',y1,x2);
title(titleStr);
set(gca,'TitleFontWeight','normal')
set(gca,'fontsize',24)

fname = fullfile(saveDir,'pCorr');
figs.pCorr = fname;
print('-depsc2','-loose',[fname '.eps'])


% make report
texName = 'treasureReport.tex';
write_texfile(saveDir,texName,figs)

curr_dir = pwd;
cd(saveDir);
fprintf('Compiling pdf...\n');
unix(['pdflatex -shell-escape ' fullfile(saveDir, texName)]);
unix(['rm ' texName(1:end-3) 'aux']);
unix(['rm ' texName(1:end-3) 'log']);
fprintf('Done!\n');
cd(curr_dir);

% Start making the tex file
function write_texfile(saveDir,texName, figs)

% Write the document. If you do not have write permission, this will crash.
fid = fopen(fullfile(saveDir,texName),'w');

if fid==-1;
    error(sprintf('cannot open %s',texName))
end

% Write out the preamble to the tex doc. This is standard stuff and doesn't
% need to be changed
fprintf(fid,'\\documentclass[a4paper]{article} \n');
fprintf(fid,'\\usepackage[usenames,dvipsnames,svgnames,table]{xcolor}\n');
fprintf(fid,'\\usepackage{graphicx,multirow} \n');
fprintf(fid,'\\usepackage{epstopdf} \n');
fprintf(fid,'\\usepackage[small,bf,it]{caption}\n');
fprintf(fid,'\\usepackage{subfigure,amsmath} \n');
% fprintf(fid,'\\usepackage{wrapfig} \n');
% fprintf(fid,'\\usepackage{longtable} \n');
% fprintf(fid,'\\usepackage{pdfpages}\n');
% fprintf(fid,'\\usepackage{mathtools}\n');
% fprintf(fid,'\\usepackage{array}\n');
% fprintf(fid,'\\usepackage{enumitem}\n');
% fprintf(fid,'\\usepackage{sidecap} \\usepackage{soul}\n');

% fprintf(fid,'\\setlength\\belowcaptionskip{5pt}\n');
fprintf(fid,'\n');
fprintf(fid,'\\addtolength{\\oddsidemargin}{-.875in} \n');
fprintf(fid,'\\addtolength{\\evensidemargin}{-.875in} \n');
fprintf(fid,'\\addtolength{\\textwidth}{1.75in} \n');
fprintf(fid,'\\addtolength{\\topmargin}{-.75in} \n');
fprintf(fid,'\\addtolength{\\textheight}{1.75in} \n');
fprintf(fid,'\n');
fprintf(fid,'\\newcolumntype{C}[1]{>{\\centering\\let\\newline\\\\\\arraybackslash\\hspace{0pt}}m{#1}} \n');

fprintf(fid,'\\usepackage{fancyhdr}\n');
fprintf(fid,'\\pagestyle{fancy}\n');
fprintf(fid,'\\fancyhf{}\n');
% fprintf(fid,'\\lhead{Report: %s }\n',strrep(subj,'_','\_'));
fprintf(fid,'\\rhead{Date created: %s}\n',date);

fprintf(fid,'\\usepackage{hyperref}\n');

% Start the document
fprintf(fid,'\\begin{document}\n\n\n');

% fprintf(fid,'\\hypertarget{%s}{}\n',region{1});

% This section writes the figures
for s = 1:length(figs)
    
    fprintf(fid,'\\begin{figure}\n');
    fprintf(fid,'\\centering\n');    
    fprintf(fid,'\\subfigure[]{{\\includegraphics[width=0.49\\textwidth]{%s}}}\n',figs(s).listLength);
    fprintf(fid,'\\subfigure[]{{\\includegraphics[width=0.49\\textwidth]{%s}}}\n',figs(s).conf);
    fprintf(fid,'\\subfigure[]{{\\includegraphics[width=0.49\\textwidth]{%s}}}\n',figs(s).nearFar);
    fprintf(fid,'\\subfigure[]{{\\includegraphics[width=0.49\\textwidth]{%s}}}\n',figs(s).distErr);    
    fprintf(fid,'\\subfigure[]{{\\includegraphics[width=0.49\\textwidth]{%s}}}\n',figs(s).spc);        
    fprintf(fid,'\\subfigure[]{{\\includegraphics[width=0.49\\textwidth]{%s}}}\n',figs(s).pCorr);        
    fprintf(fid,'\\caption{a: Performance as a factor of number of objects. b: Performance as a factor of confidence. c: Performance as a factor of item near/far from test side. d: distance error histogram. e: serial position curve. f: Percent correct by threshold.}\n');
    fprintf(fid,'\\end{figure}\n\n\n');
    if mod(s,2) == 0
        fprintf(fid,'\\clearpage\n\n\n');
    end
end

fprintf(fid,'\\end{document}\n\n\n');















































