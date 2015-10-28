function [errorPercentile,chanceError] = calcNormError(objectLocation,responseLocation,nSamples)
% function error_percentile = calcNormError(objectLocation,responseLocation,nSamples)
%
% INPUTS
%
%         objectLocation: [x,y] coordinates of the object location
%       responseLocation: [x,y] coordinates of the response location
%               nSamples: number random points used to calculate the
%                         percentile. Default = 100000
%
% OUTPUTS
%
%       errorPercentile: percentile for the error, relative to all
%                        possible errors. 0 = best, 1 = worst
%   
%           chanceError: 50th percentile of all possible errors

% number of samples to use
if ~exist('nSamples','var') || isempty(nSamples)
    nSamples = 100000;
end

% set of random points to sample environment
x = 359.9 + (409.9-359.9).*rand(nSamples,1);
y = 318 + (399.3-318).*rand(nSamples,1);
randomPoints = [x y];

% difference between object location and all samples
possibleErrors = sqrt(sum((repmat(objectLocation,[size(randomPoints,1) 1]) - randomPoints).^2,2));

% calculate actual error
actErr = sqrt(sum((objectLocation - responseLocation).^2));

% percentile of error
errorPercentile = mean(possibleErrors<=actErr);

% 50th percentile (chance)
chanceError = prctile(possibleErrors,50);

% set of random points to sample environment
x = 359.9 + (409.9-359.9).*rand(nSamples,1);
y = 318 + (399.3-318).*rand(nSamples,1);
randomPoints = [x y];

% set of random points to sample environment
x = 359.9 + (409.9-359.9).*rand(nSamples,1);
y = 318 + (399.3-318).*rand(nSamples,1);
randomPoints2 = [x y];