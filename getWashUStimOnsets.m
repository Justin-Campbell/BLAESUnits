% Author:    Justin Campbell
% Contact:   justin.campbell@hsc.utah.edu 
% Version:   03-21-2024

%% Set Paths

INMANLab_path = 'C:\Users\Justin\Box\INMANLab\'; % path to Inman Lab folder in box
if (~exist('load_bcidat')) || (~exist('epoch_BCI_data'))
    addpath(genpath(fullfile(INMANLab_path, 'BCI2000\BCI2000Tools'))); % path to BCI2000Tools
end

rootDir = 'Z:\WashU Unit Data\';

%% Stim Code Mapping

% Conditions
codeKeys.noStim = 1501;
codeKeys.stim = 1502;
codeKeys.isi = 1801;

%% Patients

pIDs = {'BJH024', 'BJH025', 'BJH026', 'BJH027', 'BJH028',...
        'BJH029', 'BJH032', 'BJH033', 'BJH035', 'BJH040',...
        'BJH041', 'BJH042', 'BJH045', 'BJH046'}; % WashU micros; as of 3/6/24

altDirStructure = {'BJH028', 'BJH029', 'BJH032', 'BJH033', 'BJH035', 'BJH040', 'BJH041', 'BJH042'}; % different file structure
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
                dataFiles = dir(fullfile(dataPath, '*.dat'));
                dataFiles = dataFiles(~cellfun(@isempty, regexpi({dataFiles.name}, '\d\d.dat', 'end'))); % isolate RAW .dat files
            else
                dataFiles = dir(fullfile(dataPath, dataDirs(ii).name, '*.dat'));
                dataFiles = dataFiles(~cellfun(@isempty, regexpi({dataFiles.name}, '\d\d.dat', 'end'))); % isolate RAW .dat files
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
           stimCodes = [];
           for s = 1:length(states)
               stimCodes = [stimCodes; states{s}.StimulusCode];
           end
           parameters = parameters{1}; % only 1 necessary (consistent across blocks)

           % get stim onsets
           stimOffsets = [];
           for codeIdx = 1:length(stimCodes)
               if stimCodes(codeIdx) == codeKeys.stim
                   if stimCodes(codeIdx+1) == codeKeys.isi
                       stimOffsets = [stimOffsets, codeIdx];
                   end
               end
           end

           stimOnsets = stimOffsets - (parameters.SamplingRate.NumericValue) + 1; % mark 1st sample of stim
           stimOnsets = stimOnsets * 15; % convert to 30kHz indices

           % create data folder (if it doesn't exist)
           dirName = strcat(pIDs{i}, '0', string(ii));
           if exist(fullfile(rootDir, dirName)) ~= 7
               mkdir(fullfile(rootDir, dirName));
           end

           % export .mat file
           fprintf('Exporting data for %s \n', strcat(pIDs{i}, '0', string(ii)));
           writematrix(stimOnsets, fullfile(rootDir, dirName, 'stimOnsets.csv'));

        end % session loop

    catch
        fprintf('Error preparing data for %s \n', strcat(pIDs{i}, '0', string(ii)));

    end
end
toc;