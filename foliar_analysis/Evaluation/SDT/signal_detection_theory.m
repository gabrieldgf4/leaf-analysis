
% Calculate sensitivity index from signal-detection theory

%  USE:
%  dvalue = signal_detection_theory(H,F) returns the sensitivity index, using a
%  standard value for correction of rates of 0 and 1.
%  dvalue = signal_detection_theory(H,F,numTar,numDis) uses the given numbers of
%  targets and distractor trials value for correction.
%
%  Coding by Gabriel da Silva Vieira
% 
%  Input variables: 
%  H, F - hit rate and false alarm rate (max: 1.0, min 0.0)
%
%  Optional: numOfSignal, numOfNoise - number of targets and
%  distractor trials
%  Rates of 0 are replaced with 0.5 / n, and rates of 1 are replaced with 
% (n - 0.5) / n, where n is the number of signal or noise trials
%
% Outputs
%
% zH - the z score that corresponds to the hit rate.
%
% zF - z score that corresponds to the false-alarm rate.
%
% dprime - which measures the distance between the signal and the noise means
% in standard deviation units (sensitivity). A value of 0 indicates an inability to distinguish
% signals from noise, whereas larger values indicate a correspondingly 
% greater ability to distinguish signals from noise
%
% Adprime - If the dprime assumptions are satisfied, Adprime should equal the
% proportion of correct responses that would have been obtained had subjects 
% performed a 2AFC task instead of a yes/no task.
% used to estimate the ROC area.
%
% Aprime - nonparametric measures of sensitivity. Typically ranges from .5, which
% indicates that signals cannot be distinguished from noise,
% to 1, which corresponds to perfect performance.
% Similar to ROC 
%
% Beta - (measure of response bias) Response bias in a yes/no task is often 
% quantified with Beta.
% Use of this measure assumes that responses are based on a likelihood
% ratio. When subjects favor neither the yes response nor the no response,
% Beta = 1. Values less than 1 signify a bias toward responding yes, 
% whereas values of Beta greater than 1 signify a bias toward the no response
% Historically, Beta has been the most popular measure of response bias
%
% c - (measure of response bias) This measure assumes that subjects respond yes when the decision
% variable exceeds the criterion and no otherwise.
% advantage of c is that it is unaffected by changes in dprime, whereas
% Beta is not.
% c s defined as the distance between the criterion and the neutral point,
% where neither response is favored.
% The neutral point is located where the noise and signal distributions
% cross over (i.e., where Beta = 1). If the criterion is located at this
% point, c has a value of 0.
% Deviations from the neutral point are measured in standard deviation units.
% Negative values of c signify a bias toward responding yes (the criterion 
% lies to the left of the neutral point), whereas positive values signify 
% a bias toward the no response (the criterion lies to the right of the neutral point).
%
% Btwoprime - (nonparametric measure of response bias)
% It can range from -1 (extreme bias in favor of yes responses) to 1 (extreme
% bias in favor of no responses). A value of 0 signifies no response bias


% Reference
% Stanislaw H, Todorov N, Behav Res Meth (1999) 31, 137-149, "1/2N rule"

function [zH, zF, dprime, Adprime, Aprime, Beta, c, Btwoprime] = ...
    signal_detection_theory(H,F,numOfSignal,numOfNoise)

%-- Replace rates equalling zero or one
if nargin < 4 % number of distractor presentations
    numOfNoise = 1e8; % if not specified, take a very high number
end
if nargin < 3 % number of target presentations
    numOfSignal = 1e8; % if not specified, take a very high number
end
if H > 1 || F > 1 
    error('Meaningless probabilities. (Do NOT enter percentage values!)');
end % if
if H < 0 || F < 0 
    error('Meaningless negative probabilities.');
end % if

if H == 0
    H = .5/numOfSignal;
end

if F == 0
    F = .5/numOfNoise;
end

if H == 1
    H = (numOfSignal -.5) / numOfSignal;
end 

if F == 1
    F = (numOfNoise -.5) / numOfNoise;
end 

%-- Convert to Z scores, no error checking
zH = norminv(H); %-sqrt(2).*erfcinv(2*H);
zF = norminv(F); %-sqrt(2).*erfcinv(2*F);

% Calculate d-prime
dprime = zH - zF ;

% Calculate A_d'
Adprime = normcdf(dprime/sqrt(2));

% Calculate A'
Aprime = 0.5 + (sign(H-F)*(((H-F)^2 + abs(H-F))/((4*max(H,F)-4*H*F))));

% Calculate B (beta)
Beta = exp((norminv(F)^2 - norminv(H)^2) / 2);

% Calculate c - bias
c = -((norminv(H) + norminv(F)) / 2);

% Calculate B"
Btwoprime = sign(H-F) * ((H*(1-H) - F*(1-F)) / (H*(1-H) + F*(1-F)));


end
