function [chanceErrors] = calcChanceForTrial(objectLocations,nSamples)
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

chanceErrors = NaN(1,size(objectLocations,1));
for i = 1:size(objectLocations,1)
    objectLocation = objectLocations(i,:);
    
    % difference between object location and all samples
    possibleErrors = sqrt(sum((repmat(objectLocation,[size(randomPoints,1) 1]) - randomPoints).^2,2));

    % 50th percentile (chance)
    chanceErrors(i) = prctile(possibleErrors,50);
end

% set of random points to sample environment
% x = 359.9 + (409.9-359.9).*rand(nSamples,1);
% y = 318 + (399.3-318).*rand(nSamples,1);
% randomPoints = [x y];
% 
% % set of random points to sample environment
% x = 359.9 + (409.9-359.9).*rand(nSamples,1);
% y = 318 + (399.3-318).*rand(nSamples,1);
% randomPoints2 = [x y];
% keyboard