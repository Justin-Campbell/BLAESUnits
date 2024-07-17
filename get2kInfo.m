% Author:    Justin Campbell
% Contact:   justin.campbell@hsc.utah.edu 
% Version:   06-20-2024

% This script loads the 2 kHz BCI2000 stimulus codes, finds the epoch
% onsets/offsets, and exports the trial info and 2 kHz recording.

%% Clear workspace
clear all; close all; clc;


%% Set Paths

global INMANLab_path;
INMANLab_path = 'C:\Users\Justin\Box\INMANLab\'; % path to Inman Lab folder in box
if (~exist('load_bcidat')) || (~exist('epoch_BCI_data'))
    addpath(genpath(fullfile(INMANLab_path, 'BCI2000\BCI2000Tools'))); % path to BCI2000Tools
end

rootDir = 'E:\My Drive\Research Projects\BLAESUnits';
saveDir = fullfile(rootDir, 'TrialInfo');

%% Patients

% list of patients with microelectrodes (6/17/24; excludes param sweep)
% excluding: 'UIC202201', 'UIC202208', 'UIC202210' (bad data) 
pIDs = {'UIC202202', 'UIC202205', 'UIC202211', 'UIC202213',...
        'UIC202215', 'UIC202217', 'UIC202302', 'UIC202306', 'UIC202307',...
        'UIC202308', 'UIC202311', 'UIC202314', 'UIC202401', 'BJH024',...
        'BJH025', 'BJH026', 'BJH027', 'BJH028', 'BJH029',...
        'BJH032', 'BJH033', 'BJH035', 'BJH040', 'BJH041',...
        'BJH042', 'BJH045', 'BJH046', 'BJH049'};
nPatients = length(pIDs);

% separate by experiment (for stim code indexing)
pIDs_OS = {'UIC202202', 'UIC202205', 'UIC202208', 'UIC202210', 'UIC202211', 'UIC202213',...
    'UIC202215', 'UIC202217', 'BJH024', 'BJH025', 'BJH026', 'BJH027'}; % objects vs. scenes
pIDs_LD = {'UIC202302', 'BJH028', 'BJH029'}; % long delay
pIDs_PS = {'UIC202306', 'UIC202307', 'UIC202308', 'UIC202311', 'BJH032',...
    'BJH033', 'BJH035', 'BJH049'}; % pattern separation
pIDs_FS = {'UIC202314', 'UIC202401', 'BJH040', 'BJH041', 'BJH042',...
    'BJH045', 'BJH046'}; % frequency stim

% different directory structure (no folder for imageset)
alt_dir_structure = {'UIC202302', 'BJH028', 'BJH029', 'UIC202306',...
    'UIC202307', 'UIC202308', 'UIC202311', 'BJH032',...
    'BJH033', 'BJH035', 'BJH049', 'UIC202314',...
    'UIC202401', 'BJH040', 'BJH041', 'BJH042'};

%% Export TrialInfo.csv & 2K data

% for i = 1:nPatients % loop through patient IDs
for i = 17
    f_type = pIDs{i}(1:3);
    dataPath = fullfile(INMANLab_path, pIDs{i}, 'Data', 'BLAES_study');

    % fix for pts with different dir structure
    if ismember(pIDs{i}, alt_dir_structure)
        dataDirs = struct;
        dataDirs(1).name = 'imageset1';
    else
        dataDirs = dir(dataPath);
        dataDirs = dataDirs(~ismember({dataDirs.name},{'.','..'}));
    end

    try % loading data
        for ii = 1:size(dataDirs,1) % loop through imagesets/sessions
            if ismember(pIDs{i}, alt_dir_structure)
                dataFiles = dir(fullfile(dataPath, '*.dat'));
            else
                dataFiles = dir(fullfile(dataPath, dataDirs(ii).name, '*.dat'));
                global session;
                session = dataDirs(ii).name;
            end
            dataFiles = dataFiles(~cellfun(@isempty, regexpi({dataFiles.name}, '\d\d.dat', 'end'))); % isolate 2k .dat files
            signals = cell(length(dataFiles),1);
            states = cell(length(dataFiles),1);
            parameters = cell(length(dataFiles),1);
    
           % load .dat file using BCI2000 functions
           for iii = 1:size(dataFiles,1) % loop through dataFiles
               fprintf('Loading %s %s file %d... \n', pIDs{i}, dataDirs(ii).name, iii);
               [signals{iii}, states{iii}, parameters{iii}] = load_bcidat(fullfile(dataFiles(iii).folder, dataFiles(iii).name));
           end % file loop
    
           % concatenate data split across .dat files
           signals = cell2mat(signals(:,1));
           stimCodes = [];
           PD = [];
           for s = 1:length(states)
               stimCodes = [stimCodes; states{s}.StimulusCode];
               if strcmp(f_type, 'BJH')
                   PD = [PD; states{s}.DC03]; % get PD (WashU)
               end
           end

           parameters = parameters{1}; % only 1 necessary (consistent across blocks)
           fs = parameters.SamplingRate.NumericValue;

           % get channel labels
           chanLabels = parameters.ChannelNames.Value;

           % check what experiment the patient ran & lookup codes
           if ismember(pIDs{i}, pIDs_OS)
               exp = 'OS';
               codekey.stim = [1502];
               codekey.nostim = [1501];
               codekey.images = [101:472];
           elseif ismember(pIDs{i}, pIDs_LD)
               exp = 'LD';
               codekey.stim = [2702];
               codekey.nostim = [2701];
               codekey.images = [1:2000];
           elseif ismember(pIDs{i}, pIDs_PS)
               exp = 'PS';
               codekey.stim = [2702];
               codekey.nostim = [2701];
               codekey.images = [1:1000];
           elseif ismember(pIDs{i}, pIDs_FS)
               exp = 'FS';
               codekey.stim = [2702, 2703];
               codekey.nostim = [2701];
               codekey.images = [1:2000];
           end

           % find stim/no-stim onsets
           stim_onsets = [];
           nostim_onsets = [];
           stim_bool = find(ismember(stimCodes, codekey.stim));
           nostim_bool = find(ismember(stimCodes, codekey.nostim));

           for sc = 1:length(stim_bool)
               if sc == 1 || stim_bool(sc) ~= stim_bool(sc-1) + 1
                   stim_onsets = [stim_onsets, stim_bool(sc)];
               end
           end
           for sc = 1:length(nostim_bool)
               if sc == 1 || nostim_bool(sc) ~= nostim_bool(sc-1) + 1
                   nostim_onsets = [nostim_onsets, nostim_bool(sc)];
               end
           end

           % combine stim/nostim trial onsets
           trial_onsets = [stim_onsets, nostim_onsets];
           trial_onsets = sort(trial_onsets);
           trial_types = ismember(trial_onsets, stim_onsets);

           % get PD (Utah)
           if strcmp(f_type, 'UIC')
               PD_idx = find(cellfun(@(x) isequal(x, 'PD'), chanLabels));
               PD = signals(:, PD_idx);
           end

           % get PD onsets (matched to trial)
           PD_onsets = matchTrialToPD(PD, trial_onsets);
           if strcmp(pIDs{i}, 'UIC202202')
               PD_onsets = [repelem(nan, length(trial_onsets))]; % all noise, no signal
           end

           % get indices for epochs
           trial_epochs = {};
           stim_epochs = {};
           nostim_epochs = {};
           for to = 1:length(trial_onsets)
               trial_epochs{to} = [trial_onsets(to)-fs:trial_onsets(to)+(2*fs)-1];
           end
           epochs_arr = reshape(cell2mat(trial_epochs), [], length(trial_epochs))';

           % remove scrambled images (OS experiment)
           if strcmp(exp, 'OS')
               keeps = []; % klugey solution for getting rid of scrambled images not present during test phase
               keepCounter = 1;
               for e = 1:size(epochs_arr,1) % loop through epochs
                   noStimImg = unique(stimCodes(epochs_arr(e,:))); % find image code
                   if any(codekey.images == noStimImg(1))
                       keeps = [keeps, keepCounter]; % indices of non-scrambled images
                   end
                   keepCounter = keepCounter + 1;
               end
               epochs_arr = epochs_arr(keeps, :);
               trial_onsets = trial_onsets(keeps);
               trial_types = trial_types(keeps);
               PD_onsets = PD_onsets(keeps);
           end

           % get stim parameters
           if strcmp(exp, 'FS')
               stim_gamma = [];
               stim_uA = [];
               stim_PW = [];
               for tt = 1:length(trial_types)
                   if trial_types(tt) == 0
                       stim_gamma = [stim_gamma, nan];
                       stim_uA = [stim_uA, nan];
                       stim_PW = [stim_PW, nan];
                   elseif trial_types(tt) == 1
                       stim_type = stimCodes(trial_onsets(tt));
                       if stim_type == 2702
                           stim_gamma = [stim_gamma, parameters.StimulationConfigurations.NumericValue(7,1)];
                           stim_uA = [stim_uA, parameters.StimulationConfigurations.NumericValue(3,1)];
                           stim_PW = [stim_PW, parameters.StimulationConfigurations.NumericValue(5,1)];
                       elseif stim_type == 2703
                           stim_gamma = [stim_gamma, parameters.StimulationConfigurations.NumericValue(7,3)];
                           stim_uA = [stim_uA, parameters.StimulationConfigurations.NumericValue(3,3)];
                           stim_PW = [stim_PW, parameters.StimulationConfigurations.NumericValue(5,3)];
                       end
                       
                   end
               end

           else % fixed parameters
               stim_gamma = repelem(nan, length(trial_onsets));
               stim_gamma(trial_types) = 50; % overwrite stim trials to 50 Hz
               stim_uA = repelem(nan, length(trial_onsets));
               stim_uA(trial_types) = parameters.StimulationConfigurations.NumericValue(3,1);
               stim_PW = repelem(nan, length(trial_onsets));
               stim_PW(trial_types) = parameters.StimulationConfigurations.NumericValue(5,1);
           end

           % get trial image codes
           trial_img_codes = [];
           for ep = 1:size(epochs_arr,1)
               ep_codes = unique(stimCodes(epochs_arr(ep,:)));
               trial_img_codes = [trial_img_codes, ep_codes(ismember(ep_codes, codekey.images))];
           end

           % get trial outcomes
           [trial_img_types, trial_responses, trial_outcomes] = readOutcomeTable(pIDs{i}, exp, trial_img_codes);

           % add trial index & structure as table
           trial_idx = [1:size(epochs_arr,1)];
           trial_info = table(trial_idx', trial_types', trial_outcomes', trial_responses', trial_onsets', PD_onsets', stim_uA', stim_gamma', stim_PW');
           trial_info.Properties.VariableNames = ["Trial", "Condition", "Outcome", "Response", "Onset_SC", "Onset_PD", "uA", "Gamma", "PW"];

           % Exporting
           sessionStr = strcat(pIDs{i}, '0', dataDirs(ii).name(end));
           fprintf('Exporting %s... \n', sessionStr);
%            save(fullfile(rootDir, 'Data_2k', strcat(sessionStr, '_2kData.mat')), 'signals', 'chanLabels', 'PD', '-v7.3');
           writetable(trial_info, fullfile(rootDir, 'TrialInfo', strcat(sessionStr, '_TrialInfo.csv')));

        end % session loop

    catch 
        fprintf('Error preparing data for %s \n', pIDs{i});

    end % try-catch

end % pID loop











