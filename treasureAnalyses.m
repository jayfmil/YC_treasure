function treasureAnalyses(events,saveDir)
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

% euclidean distance error for each recall
distErrs    = [events(itemRecEvents).distErr];

% reaction time for each recall
reactTimes  = [events(itemRecEvents).reactionTime]/1000;

% correct/incorrect bool
correct = distErrs < 10;

% whether the object location is near or far from test location
nearFar = ~[events(itemRecEvents).isRecFromNearSide];

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


%%%% make report
% texName = 'treasureReport.tex';
% write_texfile(saveDir,texName,figs)
% 
% curr_dir = pwd;
% cd(saveDir);
% fprintf('Compiling pdf...\n');
% unix(['pdflatex -shell-escape ' fullfile(saveDir, texName)]);
% unix(['rm ' texName(1:end-3) 'aux']);
% unix(['rm ' texName(1:end-3) 'log']);
% fprintf('Done!\n');
% cd(curr_dir);

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















































