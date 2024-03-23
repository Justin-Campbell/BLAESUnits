% Author:    Justin Campbell
% Contact:   justin.campbell@hsc.utah.edu 
% Version:   03-06-2024

%% Set Paths

INMANLab_path = 'C:\Users\Justin\Box\INMANLab\'; % path to Inman Lab folder in box
% INMANLab_path = '/Users/justincampbell/Library/CloudStorage/Box-Box/INMANLab'; % MBP
if (~exist('load_bcidat')) || (~exist('epoch_BCI_data'))
    addpath(genpath(fullfile(INMANLab_path, 'BCI2000\BCI2000Tools'))); % path to BCI2000Tools
%     addpath(genpath(fullfile(INMANLab_path, 'BCI2000/BCI2000Tools'))); % MBP
end

rootDir = 'D:\WashU Unit Data\';
% rootDir = '/Volumes/155.100.91.44/Data/WashU Unit Data';

%% Patients

pIDs = {'BJH024', 'BJH025', 'BJH026', 'BJH027', 'BJH028',...
        'BJH029', 'BJH032', 'BJH033', 'BJH035', 'BJH040',...
        'BJH041', 'BJH042', 'BJH045', 'BJH046'}; % WashU micros; as of 3/6/24

altDirStructure = {'BJH028', 'BJH029', 'BJH032', 'BJH033', 'BJH035', 'BJH040', 'BJH041', 'BJH042'}; % different file structure
needsV73Compression = {'BJH032', 'BJH033', 'BJH035', 'BJH040', 'BJH042', 'BJH045'};
exclude = {};

nPatients = length(pIDs);

%% Load & Export Data

tic;
fCounter = 0;

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
                dataFiles = dir(fullfile(dataPath, '*_1.dat'));
            else
                dataFiles = dir(fullfile(dataPath, dataDirs(ii).name, '*_1.dat'));
            end
            signals = cell(length(dataFiles),1);
            states = cell(length(dataFiles),1);
            parameters = cell(length(dataFiles),1);
            fCounter = fCounter + 1; % track number of recording sessions
    
           for iii = 1:size(dataFiles,1) % loop through dataFiles
               fprintf('Loading %s %s file %d... \n', pIDs{i}, dataDirs(ii).name, iii);
               [signals{iii}, states{iii}, parameters{iii}] = load_bcidat(fullfile(dataFiles(iii).folder, dataFiles(iii).name));
           end % file loop
    
           % concatenate data split across .dat files
           signals = cell2mat(signals(:,1));
           parameters = parameters{1}; % only 1 necessary (consistent across blocks)

           % get channel labels
           chanLabels = parameters.ChannelNames.Value;

           % remove analog input chans
           ainpIdxs = find(cellfun(@(x) contains(x, 'ainp'), chanLabels));
           chanLabels(ainpIdxs) = [];
           signals(:, ainpIdxs) = [];

           % transpose for Plexon import
           signals = signals';

           % create data folder (if it doesn't exist)
           dirName = strcat(pIDs{i}, '0', string(ii));
           if exist(fullfile(rootDir, dirName)) ~= 7
               mkdir(fullfile(rootDir, dirName));
           end

           % export .mat file
           fprintf('Exporting data for %s \n', strcat(pIDs{i}, '0', string(ii)));
           if ismember(pIDs{i}, needsV73Compression)
               save(fullfile(rootDir, dirName, 'BLAES_study_units.mat'), 'signals', 'chanLabels', '-v7.3');
           else
               save(fullfile(rootDir, dirName, 'BLAES_study_units.mat'), 'signals', 'chanLabels');
           end

        end % session loop

    catch
        fprintf('Error preparing data for %s \n', strcat(pIDs{i}, '0', string(ii)));

    end
end
toc;