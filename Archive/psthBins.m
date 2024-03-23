function  [r,rSmo,t] = psthBins(times, binsize, fs, ntrials, triallen)
% PSTHBINS Computes the peri-stimulus time histogram from spike times.
% 
% H = PSTH(TIMES, BINSIZE, FS,NTRIALS,TRIALLEN)
% TIMES - spike times (samples)
% BINSIZE - binwidth (ms)
% FS - sampling rate (hz)
% NTRIALS - number of trials
% TRIALLEN - length of a trial (samples)
%
% R - binned firing rate. 
% rSmo - smoothed firing rate (look inside function for smoothing window
% T - peri stimulus time histogram edges



% Author: Rajiv Narayan
% askrajiv@gmail.com
% Boston University, Boston, MA
%
% edited: [EHS::20211108]

%Compute PSTH        
lastBin = binsize * ceil((triallen)*(1000/(fs*binsize)));
edges = 0 : binsize : lastBin;	
x = (mod(times,triallen))*(1000/fs);
r = (histc(x,edges)*1000) / (ntrials*binsize);
t = edges;

% and smoothing
rSmo = smoothdata(r,'movmean',5);

