%
% genElectrodeInfo.m generates a .csv file from electrode information in each patient's 
% "Registered" folder. The table contains information for the clinical label, 
% atlas label, XYZ coordinates in patient space, and XYZ coordinates in MNI space.
%
% Author:    Justin Campbell
% Contact:   justin.campbell@hsc.utah.edu 
% Version:   03-23-2024 (updated for BLAES Units)

%% Clear workspace
clear all; clc;

%% Get list of patients from processed data folder

processedDataPath = 'E:\My Drive\Research Projects\BLAESUnits\ElectrodeInfo';
% processedDataPath = 'C:\Users\Justin\Box\Utah ElecInfo';

dataPrefixes = {'UIC', 'SLC', 'BJH'};
% 
% pIDs = {'UIC202202', 'UIC202205', 'UIC202208', 'UIC202210', 'UIC202213',...
%         'UIC202215', 'UIC202217', 'UIC202306', 'UIC202307',...
%         'UIC202308', 'UIC202311', 'UIC202314', 'UIC202401', 'BJH024',...
%         'BJH025', 'BJH026', 'BJH027', 'BJH028', 'BJH029',...
%         'BJH032', 'BJH033', 'BJH035', 'BJH040', 'BJH041',...
%         'BJH042'}; % BLAESUnits

% pIDs = {'BJH040', 'BJH041', 'BJH042', 'UIC202313', 'UIC202314',...
%         'UIC202401', 'SLCH018', 'BJH045'}; % BLAES FreqStim

pIDs = {'UIC202202', 'UIC202205', 'UIC202208', 'UIC202210', 'UIC202211', 'UIC202213',...
         'UIC202215', 'UIC202217', 'UIC202302', 'UIC202306', 'UIC202307',...
         'UIC202308', 'UIC202311', 'UIC202313', 'UIC202314', 'UIC202401', 'UIC202407'}; % all Utah

% NOT YET PROCESSED IN LEGUI
% pIDs = {'BJH049'};

% Find the unique patients
uniquePIDs = unique(pIDs);

%% Find Electrodes.mat file for patient and load Brainnetome labels


for i = 1:length(uniquePIDs)
    pID = uniquePIDs{i};
    
    if (contains(pID, 'BJH')) || contains(pID,'SLC') % WashU
        load(fullfile('Z:\BLAES_WashU_Pts', pID, 'Imaging\Registered\Electrodes.mat'))
    
    elseif contains(pID, 'UIC') % Utah
        load(fullfile('Z:\', pID, 'Imaging\Registered\Electrodes.mat'));
    
    end
    
    % Locate index for Brainnetome labels
    BrainnetomeAtlasIdx = find(strcmp(AtlasNames, 'Brainnetome'));
    
    % Grab the labels (most likely label, probabalistic method)
    atlasLabels = ElecAtlasProbProjRaw(:,BrainnetomeAtlasIdx);
    for ii = 1:length(atlasLabels)
    
        if isempty(atlasLabels{ii})
            atlasLabels{ii} = '';
        else
            atlasLabels{ii} = atlasLabels{ii}{1,1};
        end
    end

    % Grab clinical labels
    clinicalLabels = ElecMapRaw(:,1);

    % Grab XYZ coords
    XYZs = num2cell(ElecXYZProjRaw(:,1:3));
    XYZs_MNI = num2cell(ElecXYZMNIProjRaw(:,1:3));

    % Construct table with electrode info
    elecTable = table('Size', [length(clinicalLabels), 8], ...
        'VariableTypes', {'string', 'string', 'double', 'double', 'double', 'double', 'double', 'double'}, ...
        'VariableNames', {'chanLabel', 'atlasLabel', 'X', 'Y', 'Z', 'MNI_X', 'MNI_Y', 'MNI_Z'});
    elecTable(:,1) = clinicalLabels;
    elecTable(:,2) = atlasLabels;
    elecTable(:,3:5) = XYZs;
    elecTable(:,6:8) = XYZs_MNI;

     % export
     fprintf('Exporting electrode info for %s... \n', pID)
     writetable(elecTable, fullfile(processedDataPath, 'ElectrodeInfo', strcat(pID, '_ElectrodeInfo.csv')));

end
