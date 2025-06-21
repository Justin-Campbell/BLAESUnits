% Author:    Justin Campbell
% Contact:   justin.campbell@hsc.utah.edu 
% Version:   05-13-2024

% This script loads the 2 kHz BCI2000 data and exports for subsequent processing 

%% Set Paths

INMANLab_path = 'C:\Users\Justin\Box\INMANLab\'; % path to Inman Lab folder in box
if (~exist('load_bcidat')) || (~exist('epoch_BCI_data'))
    addpath(genpath(fullfile(INMANLab_path, 'BCI2000\BCI2000Tools'))); % path to BCI2000Tools
end

rootDir = 'E:\My Drive\Research Projects\BLAESUnits';
saveDir = fullfile(rootDir, 'LFP');

%% Patients

% list of patients with microelectrodes (6/17/24; excludes param sweep)
% excluding: 'UIC202208', 'UIC202210', 
pIDs = {'UIC202202', 'UIC202205', 'UIC202213',...
        'UIC202215', 'UIC202217', 'UIC202302', 'UIC202306', 'UIC202307',...
        'UIC202308', 'UIC202311', 'UIC202314', 'UIC202401', 'BJH024',...
        'BJH025', 'BJH026', 'BJH027', 'BJH028', 'BJH029',...
        'BJH032', 'BJH033', 'BJH035', 'BJH040', 'BJH041',...
        'BJH042', 'BJH045', 'BJH046', 'BJH049'}; % BLAESUnits as of 3/28/24

pIDs = {'BJH025', 'BJH026', 'UIC202302', 'UIC202306'}; % process override (quick process select patients)

% different directory structure (no folder for imageset)
alt_dir_structure = {'UIC202302', 'BJH028', 'BJH029', 'UIC202306',...
    'UIC202307', 'UIC202308', 'UIC202311', 'BJH032',...
    'BJH033', 'BJH035', 'BJH049', 'UIC202314',...
    'UIC202401', 'BJH040', 'BJH041', 'BJH042'};

nPatients = length(pIDs);

%% Load Data

for i = 1:nPatients % loop through patient IDs
    dataPath = fullfile(INMANLab_path, pIDs{i}, 'Data', 'BLAES_study');

    % fix for pts with different dir structure
    if ismember(pIDs{i}, altDirStructure)
        dataDirs = struct;
        dataDirs(1).name = 'imageset1';
    else
        dataDirs = dir(dataPath);
        dataDirs = dataDirs(~ismember({dataDirs.name},{'.','..'}));
    end

    try
        for ii = 1:size(dataDirs,1) % loop through imagesets/sessions
            if ismember(pIDs{i}, altDirStructure)
                dataFiles = dir(fullfile(dataPath, '*.dat'));
            else
                dataFiles = dir(fullfile(dataPath, dataDirs(ii).name, '*.dat'));
            end
            dataFiles = dataFiles(~cellfun(@isempty, regexpi({dataFiles.name}, '\d\d.dat', 'end'))); % isolate 2k .dat files
            signals = cell(length(dataFiles),1);
            states = cell(length(dataFiles),1);
            parameters = cell(length(dataFiles),1);
    
           for iii = 1:size(dataFiles,1) % loop through dataFiles
               fprintf('Loading %s %s file %d... \n', pIDs{i}, dataDirs(ii).name, iii);
               [signals{iii}, states{iii}, parameters{iii}] = load_bcidat(fullfile(dataFiles(iii).folder, dataFiles(iii).name));
           end % file loop
    
           % concatenate data split across .dat files
           signals = cell2mat(signals(:,1));
           stimCodes = [];
           for s = 1:length(states)
               stimCodes = [stimCodes; states{s}.StimulusCode];
           end
           parameters = parameters{1}; % only 1 necessary (consistent across blocks)

           % get channel labels
           chanLabels = parameters.ChannelNames.Value;

           % Export LFP data
           sessionStr = strcat(pIDs{i}, '0', dataDirs(ii).name(end));
           fprintf('Exporting %s... \n', sessionStr);
           save(fullfile(saveDir, strcat(sessionStr, '_signals.mat')), 'signals', 'chanLabels', '-v7.3');

        end % session loop

    catch 
        fprintf('Error preparing data for %s \n', pIDs{i});

    end % try-catch

end % pID loop