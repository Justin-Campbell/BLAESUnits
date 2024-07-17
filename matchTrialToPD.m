function PD_onsets = matchTrialToPD(PD, trial_onsets)

if isempty(PD)
    disp('No PD available.')
    PD_onsets = [repelem(nan, length(trial_onsets))];
    return
end

% get trial onsets (per PD)
PD = double(PD);
% PD_norm = (PD - min(PD)) / (max(PD) - min(PD)); % min-max scaling
% PD_norm_abs = abs(PD_norm);
PD_onsets = [];

% find PD peak within window following trial_onset
for i = 1:length(trial_onsets)
    t_onset = trial_onsets(i);
    PD_win = [t_onset:t_onset + 2000];
    PD_early = mean(PD(PD_win(1:250)));
    PD_late = mean(PD(PD_win(1750:end)));

    if (PD_late < PD_early) && abs(PD_late - PD_early) > 0.1
        PD_trial = PD(PD_win) * -1; % invert shape
    else
        PD_trial = PD(PD_win);
    end

    [~, loc] = findpeaks(PD_trial, 'MinPeakDistance', 1000, 'NPeaks', 1);

    if isempty(loc)
        PD_onsets = [PD_onsets, nan];
    else
        PD_onsets = [PD_onsets, loc + t_onset];
    end
end

% visualize
% figure;
% plot(PD);
% hold on;
% for x = 1:length(PD_onsets)
%     xline(PD_onsets(x))
%     xline(trial_onsets(x), 'Color', 'red')
% end

end