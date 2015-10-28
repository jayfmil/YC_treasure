function treasureAnalyses_group(resDir,saveDir)
% function treasureAnalyses_group(resDir,saveDir)
%
% Creates group average report. Code could use cleanup.

% location to save average data
if ~exist(saveDir,'var') || isempty(saveDir)
    saveDir = resDir;
end
if ~exist(saveDir,'dir')
    mkdir(saveDir);
end
figDir = fullfile(saveDir,'figs');
if ~exist(figDir,'dir')
    mkdir(figDir);
end

% list of files to load and concat
subjFiles = dir(fullfile(resDir,['*res.mat']));

% This loop loads the data from each subject and concatenates all subjects
% in to one large structure
subjDataAll =  [];
for s = 1:length(subjFiles)                
    
    subjFile = subjFiles(s).name;
    subjFile = fullfile(resDir,subjFile);
     
    % load subject datasav
    subjData = load(subjFile);
    
    % if we haven't done it yet, initialze structure to hold concatenated
    % data from all subjects
    if isempty(subjDataAll)
       fields = fieldnames(subjData.res);
       for f = fields'
           subjDataAll.(f{1}) = [];
           if isstruct(subjData.res.(f{1}))               
               subfields = fieldnames(subjData.res.(f{1}));
               for subf = subfields'
                   subjDataAll.(f{1}).(subf{1}) = [];
               end
           end
       end
    end    
    
    % merge current subject data into larger struct
    subjDataAll = mergestruct(subjDataAll,subjData.res);  
end
subj = 'all';
figs = [];




%--------------------------------------------------------------------------
% PERFORMANCE BY LIST LENGTH BAR
fields      = {'errMeanListLength','normErrMeanListLength','reactMeanListLength','correctMeanListLength'};
ylabels     = {'Distance Error (VR Units)','Normalized Distance Error','Reaction Time (s)','Prob. Correct'};
for f = 1:length(fields)
    
    % calculate mean, std, and counts of errors and reaction time    
    m = nanmean(subjDataAll.(fields{f}));
    s = nanstd(subjDataAll.(fields{f}));
    n = sum(~isnan(subjDataAll.(fields{f})));
    
    % plot it
    figure(1)
    clf    
    bar(m,'w','linewidth',2)
    ylabel(ylabels{f},'fontsize',16)
    xlabel('List Length','fontsize',16)
    set(gca,'fontsize',16)
    set(gca,'xticklabel',1:3)
    grid on
    hold on
    errorbar(1:length(m),m,s./sqrt(n-1),'k','linewidth',2,'linestyle','none')
            
    % save to res structure and print figure    
    fname = fullfile(figDir,[subj '_' fields{f}]);    
    figs.(fields{f}) = fname;    
    print('-depsc2','-loose',[fname '.eps'])
end
%--------------------------------------------------------------------------




%--------------------------------------------------------------------------
% PERFORMANCE BY CONFIDENCE
fields      = {'errMeanConf','normErrMeanConf','reactMeanConf','correctMeanConf','probConf'};
ylabels     = {'Distance Error (VR Units)','Normalized Distance Error','Reaction Time (s)','Prob. Correct','Probability of Confidence'};
colors      = {[0,0.4470, 0.7410],[0.8500, 0.3250, 0.0980],[0.9290,0.6940,0.1250]};
for f = 1:length(fields)
    
    % calculate mean, std, and counts of errors and reaction time    
    m = nanmean(subjDataAll.(fields{f}));
    s = nanstd(subjDataAll.(fields{f}));
    n = sum(~isnan(subjDataAll.(fields{f})));
    
    % plot it
    figure(2)
    clf    
    for c = 1:3
        hold on
        h=bar(c,m(c),'w','linewidth',2);
        h.FaceColor = colors{c};
    end
    ylabel(ylabels{f},'fontsize',16)
    xlabel('Confidence','fontsize',16)
    set(gca,'xtick',1:3)
    set(gca,'xticklabel',{'Pass','Low','High'})
    set(gca,'fontsize',16)    
    grid on
    hold on
    errorbar(1:length(m),m,s./sqrt(n-1),'k','linewidth',2,'linestyle','none')
            
    % save to res structure and print figure    
    fname = fullfile(figDir,[subj '_' fields{f}]);    
    figs.(fields{f}) = fname;    
    print('-depsc2','-loose',[fname '.eps'])
end
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% PERFORMANCE BY TARGET LOCATION (NEAR/FAR)
fields = {'errTargetLoc','normErrTargetLoc','reactTargetLoc','correctTargetLoc'};
for f = 1:length(fields)
    
    % calculate mean, std, and counts of errors and reaction time    
    m = nanmean(subjDataAll.(fields{f}));
    s = nanstd(subjDataAll.(fields{f}));
    n = sum(~isnan(subjDataAll.(fields{f})));
    
    % plot it
    figure(3)
    clf    
    bar(m,'w','linewidth',2)
    ylabel(ylabels{f},'fontsize',16)
    xlabel('Near/Far Target','fontsize',16)
    set(gca,'fontsize',16)
    set(gca,'xticklabel',{'Near','Far'})
    grid on
    hold on
    errorbar(1:length(m),m,s./sqrt(n-1),'k','linewidth',2,'linestyle','none')
            
    % save to res structure and print figure    
    fname = fullfile(figDir,[subj '_' fields{f}]);    
    figs.(fields{f}) = fname;    
    print('-depsc2','-loose',[fname '.eps'])
end
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
% SERIAL POSITION CURVE BY LISTLENGTH
errMat    = nanmean(subjDataAll.errMat,3);
errStdMat = nanstd(subjDataAll.errMat,0,3);
figure(4)
clf
errorbar(repmat(1:size(errStdMat,2),size(errStdMat,1),1)',errMat',errStdMat','linewidth',3)
h=legend(strcat(cellfun(@num2str,num2cell([1 2 3]),'uniformoutput',false),' item list'),'location','best');
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
figure(6)
clf
[n,x] = hist(subjDataAll.distErrs,25);
bar(x,n,1,'w','linewidth',2);
xlabel('Distance Error','fontsize',16);
ylabel('Count','fontsize',16);
set(gca,'fontsize',16)
grid on
fname = fullfile(figDir,[subj '_distErrHist']);
figs.distErrHist = fname;
print('-depsc2','-loose',[fname '.eps'])

% DISTANCE ERROR HISTOGRAM CONFIDENCE
chance = 34.7263;
distMat    = nanmean(subjDataAll.distByConfHist,3);
edges = 0:5:100;
binMean = mean([edges(1:end-1)' edges(2:end)'],2);
figure(7)
clf
plot(binMean,distMat','linewidth',3)
h=legend('Pass','Low Confidence','High Confidence');
set(h,'fontsize',20)
xlabel('Distance Error','fontsize',20);
ylabel('Probability','fontsize',20);
grid on
hold on
ylim = get(gca,'ylim');
plot([chance chance],ylim,'--k','linewidth',2)
set(gca,'gridlinestyle',':');
set(gca,'fontsize',20)
fname = fullfile(figDir,[subj '_distErrConfHist']);
print('-depsc2','-loose',[fname '.eps'])

% NORMALIZED DISTANCE ERROR HISTOGRAM CONFIDENCE
distMat    = nanmean(subjDataAll.normDistByConfHist,3);
edges = 0:.05:1;
binMean = mean([edges(1:end-1)' edges(2:end)'],2);
figure(8)
clf
plot(binMean,distMat','linewidth',3)
h=legend('Pass','Low Confidence','High Confidence');
set(h,'fontsize',20)
xlabel('Normalized Distance Error','fontsize',20);
ylabel('Probability','fontsize',20);
grid on
set(gca,'gridlinestyle',':');
set(gca,'fontsize',20)
fname = fullfile(figDir,[subj '_normDistErrConfHist']);
print('-depsc2','-loose',[fname '.eps'])
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------


%%%% PERCENT CORRECT AS A FUNCTION OF DISTANCE THRESHOLD
figure(9)
clf
possDists = linspace(0,100,250);
pCorr = NaN(1,length(possDists));
for i = 1:length(possDists)
    pCorr(i) = mean(subjDataAll.distErrs < possDists(i));
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

%%%% make report
texName = 'treasureReport_group.tex';
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
fprintf(fid,'\\lhead{All Subjects}\n');
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
%     fprintf(fid,'\\subfigure[]{{\\includegraphics[width=0.49\\textwidth]{%s}}}\n',figs(s).pCorr);        
    fprintf(fid,'\\caption{a: Performance as a factor of number of objects. b: Performance as a factor of confidence. c: Performance as a factor of item near/far from test side. d: distance error histogram. e: serial position curve.}\n');
    fprintf(fid,'\\end{figure}\n\n\n');
    if mod(s,2) == 0
        fprintf(fid,'\\clearpage\n\n\n');
    end
end

fprintf(fid,'\\end{document}\n\n\n');











function sout = mergestruct(struct1,struct2)

if isempty(struct1) & ~isempty(struct2)
    sout = struct2;
    return
elseif ~isempty(struct1) & isempty(struct2)
    sout = struct1;
    return
end

fields1 = fieldnames(struct1);
fields2 = fieldnames(struct2);

if isequal(fields1,fields2)
    sout = cell2struct(fields1,fields1,1);
    for f = 1:length(fields1)
        if isrow(struct2.(fields1{f})) || isrow(struct2.(fields1{f})')
            sout.(fields1{f}) = cat(1,struct1.(fields1{f}),struct2.(fields1{f}));       
        else
            sout.(fields1{f}) = cat(3,struct1.(fields1{f}),struct2.(fields1{f}));       
        end
    end
end




































