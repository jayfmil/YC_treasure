function treasureAnalyses_group(resDir,saveDir)
% function treasureAnalyses_group(resDir,saveDir)
%
% Creates group average report. Code could use cleanup.

% location to save average data
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

%%%% PERFORMANCE BY LIST LENGTH
figs = [];
figure(1)
clf
plotData    = cellfun(@mean,{subjDataAll.errMeanListLength,subjDataAll.reactMeanListLength},'uniformoutput',false);
plotDataStd = cellfun(@std,{subjDataAll.errMeanListLength,subjDataAll.reactMeanListLength},'uniformoutput',false);
ns          = cellfun(@length,{subjDataAll.errMeanListLength,subjDataAll.reactMeanListLength},'uniformoutput',false);
ylabels     = {'Distance Error (VR Units)','Reaction Time (s)'};
for i = 1:2
    subplot(1,2,i)
    bar(plotData{i},'w','linewidth',2)
    ylabel(ylabels{i},'fontsize',16)
    xlabel('List Length','fontsize',16)
    set(gca,'fontsize',16)
    set(gca,'xticklabel',1:3)
    grid on
    hold on
    errorbar(1:length(plotData{i}),plotData{i},plotDataStd{i}./sqrt(ns{i}-1),'k','linewidth',2,'linestyle','none')
end
fname = fullfile(figDir,[subj '_listLength']);
figs.listLength = fname;
print('-depsc2','-loose',[fname '.eps'])

%%%% PERFORMANCE BY CONFIDENCE
figure(2)
clf
plotData    = cellfun(@nanmean,{subjDataAll.errMeanConf,subjDataAll.reactMeanConf},'uniformoutput',false);
plotDataStd = cellfun(@nanstd,{subjDataAll.errMeanConf,subjDataAll.reactMeanConf},'uniformoutput',false);
f = @(x)sum(~isnan(x));
ns          = cellfun(f,{subjDataAll.errMeanConf,subjDataAll.reactMeanConf},'uniformoutput',false);
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
fname = fullfile(figDir,[subj '_conf']);
figs.conf = fname;
print('-depsc2','-loose',[fname '.eps'])

%%%% PERFORMANCE BY TARGET LOCATION (NEAR/FAR)
figure(3)
clf
plotData    = cellfun(@nanmean,{subjDataAll.errMeanTargLoc,subjDataAll.reactMeanTargLoc},'uniformoutput',false);
plotDataStd = cellfun(@nanstd,{subjDataAll.errMeanTargLoc,subjDataAll.reactMeanTargLoc},'uniformoutput',false);
f = @(x)sum(~isnan(x));
ns          = cellfun(f,{subjDataAll.errMeanTargLoc,subjDataAll.reactMeanTargLoc},'uniformoutput',false);
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
fname = fullfile(figDir,[subj '_nearFar']);
figs.nearFar = fname;
print('-depsc2','-loose',[fname '.eps'])

%%% SERIAL POSITION CURVE BY LISTLENGTH
errMat    = nanmean(subjDataAll.errMat,3);
errStdMat = nanstd(subjDataAll.errMat,0,3);
figure(4)
clf
axes('position',[.13 .4 .775 .5]);
errorbar(repmat(1:size(errStdMat,2),size(errStdMat,1),1)',errMat',errStdMat','linewidth',3)
h=legend(strcat(cellfun(@num2str,num2cell([1 2 3]),'uniformoutput',false),' item list'));
set(h,'fontsize',20)
xlabel('','fontsize',16);
ylabel('Distance Error','fontsize',16);
grid on
set(gca,'gridlinestyle',':');
set(gca,'fontsize',16)
set(gca,'xtick',1:size(errMat,2))

axes('position',[.13 .1 .775 .2])

meanRemember = mean(subjDataAll.meanRemember);
bar(meanRemember,'w','linewidth',3)
set(gca,'xtick',1:size(errMat,2))
xlabel('Serial Position','fontsize',16);
ylabel('Percent ','fontsize',16);
grid on
set(gca,'gridlinestyle',':');
set(gca,'fontsize',16)

fname = fullfile(figDir,[subj '_spc']);
figs.spc = fname;
print('-depsc2','-loose',[fname '.eps'])

%%%% DISTANCE ERROR HISTOGRAM
figure(5)
clf
[n,x] = hist(subjDataAll.distErrs,25);
bar(x,n,1,'w','linewidth',2);
xlabel('Distance Error','fontsize',16);
ylabel('Count','fontsize',16);
set(gca,'fontsize',16)
grid on
fname = fullfile(figDir,[subj '_distErr']);
figs.distErr = fname;
print('-depsc2','-loose',[fname '.eps'])

%%%% PERCENT CORRECT AS A FUNCTION OF DISTANCE THRESHOLD
% figure(6)
% clf
% possDists = linspace(0,100,250);
% pCorr = NaN(1,length(possDists));
% for i = 1:length(possDists)
%     pCorr(i) = mean(distErrs < possDists(i));
% end
% pCorr = pCorr*100;
% plot(possDists,pCorr,'linewidth',3)
% grid on
% set(gca,'gridlinestyle',':');
% 
% hold on
% x1 = possDists(sum(possDists < 12.5));
% y1 = pCorr(sum(possDists < 12.5));
% plot([x1 x1],[0 y1],'-k','linewidth',3);
% plot([0 x1],[y1 y1],'-k','linewidth',3);
% 
% half = sum(pCorr <= 50);
% x2 = possDists(half);
% y2 = pCorr(half);
% plot([x2 x2],[0 y2],':k','linewidth',3);
% plot([0 x2],[y2 y2],':k','linewidth',3);
% 
% xlabel('Correct threshold','fontsize',24)
% ylabel('Percent within circle','fontsize',24)
% 
% titleStr = sprintf('%.2f%% at 12.5, 50%% at %.2f',y1,x2);
% title(titleStr);
% set(gca,'TitleFontWeight','normal')
% set(gca,'fontsize',24)
% 
% fname = fullfile(figDir,[subj '_pCorr']);
% figs.pCorr = fname;
% print('-depsc2','-loose',[fname '.eps'])

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




































