function [ y ] = GreyNoise( T, Fs, level)
%GREYNOISE This function returns an equal loudness noise
% 
% Syntax:	[ output_args ] = GreyNoise( input_args )
% 
% Inputs: 
% 	input1 - Description
% 	input2 - Description
% 	input3 - Description
% 
% Outputs: 
% 	output1 - Description
% 	output2 - Description
% 
% Example: 
% 	Line 1 of example
% 	Line 2 of example
% 	Line 3 of example
% 
% See also: List related files here

% Author: Jacob Donley
% University of Wollongong
% Email: jrd089@uowmail.edu.au
% Copyright: Jacob Donley 2015
% Date: 10 October 2015 
% Revision: 0.1
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin <3
    level = 1;
end

N = T * Fs;
if rem(N,2)
    M = N+1;
else
    M = N;
end


x = randn(1, M) / (2*pi); % WGN

% Frequency Domain Tranform
X = fft(x); % Fast Fourier Transform

% Frequencies
NumPts = M/2 + 1;
freqs = linspace(0, Fs/2, NumPts);
cutoff = 20; %Hz

% Equal Loudness Levels
EqLevel_dB = Perceptual_Tools.Threshold_in_Quiet(freqs(freqs>cutoff),'ISO226')';
EqLevel_dB = [linspace(0,EqLevel_dB(1), length(freqs)-length(EqLevel_dB)), EqLevel_dB];

% Apply magnitude weighting
X(1:NumPts) = X(1:NumPts) .* db2mag(EqLevel_dB);

% Apply conjugation for negative frequency side of spectrum
X(NumPts+1:M) = conj(X(M/2:-1:2));

% Time Domain Transform
y = ifft(X); % Inverse Fast Fourier Transform

% prepare output vector y
y = real(y(1, 1:N));

% ensure unity standard deviation and zero mean value
y = y - mean(y);
yrms = sqrt(mean(y.^2));
y = y/yrms;
% Level adjustment
y = y * level;
end

