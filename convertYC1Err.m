function estError = convertYC1Err(yc1ErrPerc)
% function estError = convertYC1Err(yc1ErrPerc)
%
% Convert a given error percentile in YC1, convert to an estimated
% euclidean distance error in YC treasure task

% YC1 dimensions
yc1X = 64.8;
yc1Y = 36;

% New task dimensions
X = 125.876;
Y = 69.928;

% load all YC1 errors
[allErrors,~,allEucErrors,~] = YC1_loadAllSubjErrors(1);

% find mean error near given percentile
normErr = prctile(allErr,yc1ErrPerc);
yc1EucErr = mean(allEucErrors(allErrors > (normErr - .01) & allErrors < (normErr + .01)));

% convert YC1 euclidean error to new task error. Luckily it is the same
% aspect ratio
scale = Y/yc1Y;
estError = yc1EucErr * scale;
