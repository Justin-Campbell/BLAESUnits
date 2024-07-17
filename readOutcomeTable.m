function [trial_img_types, trial_responses, trial_outcomes] = readOutcomeTable(pID, exp, trial_img_codes)

% Load globals
global INMANLab_path;
global session;

% Load Test Data for given patient
if (strcmp(pID, 'BJH045')) || (strcmp(pID, 'BJH046'))
   TDfile = dir(fullfile(INMANLab_path, pID, 'Data', 'BLAES_test', session, 'One-Day', '*Test_Data_One-Day_Loglinear.mat'));
   TDfile2 = dir(fullfile(INMANLab_path, pID, 'Data', 'BLAES_test', session, 'Immediate', '*Test_Data_Immediate_Loglinear.mat'));
elseif strcmp(exp, 'OS')
   TDfile = dir(fullfile(INMANLab_path, pID, 'Data', 'BLAES_test', session, '*Test_Data*.mat'));
   TDfile2 = []; % none
elseif strcmp(exp, 'LD')
   TDfile = dir(fullfile(INMANLab_path, pID, 'Data', 'BLAES_test', 'One-Day-Delay', '*Test_Data_One-Day_Loglinear.mat'));
   TDfile2 = dir(fullfile(INMANLab_path, pID, 'Data', 'BLAES_test', 'Long-Delay', '*Test_Data_Long-Delay_Loglinear.mat'));
elseif strcmp(exp, 'PS')
   TDfile = dir(fullfile(INMANLab_path, pID, 'Data', 'BLAES_test', 'One-Day', '*Test_Data_One-Day_Loglinear.mat'));
   TDfile2 = dir(fullfile(INMANLab_path, pID, 'Data', 'BLAES_test', 'Immediate', '*Test_Data_Immediate_Loglinear.mat'));
elseif strcmp(exp, 'FS')
   TDfile = dir(fullfile(INMANLab_path, pID, 'Data', 'BLAES_test', 'One-Day', '*Test_Data_One-Day_Loglinear.mat'));
   TDfile2 = dir(fullfile(INMANLab_path, pID, 'Data', 'BLAES_test', 'Immediate', '*Test_Data_Immediate_Loglinear.mat'));
end
outcomeTable = load(fullfile(TDfile.folder, TDfile.name)).collectData;
if ~isempty(TDfile2)
    outcomeTable2 = load(fullfile(TDfile2.folder, TDfile2.name)).collectData;
end

% Initialize holders
trial_img_types = {};
trial_responses = {};
trial_outcomes = {};

% Loop through each study trial; get image type (old, new, target, foil) and response (sure/maybe yes/no)
for img = 1:length(trial_img_codes)

    %%% Objects vs. Scenes %%%
    if strcmp(exp, 'OS')
        img_table_idx = find([outcomeTable{:,6}] == trial_img_codes(img));
        trial_img_types{img} = outcomeTable{img_table_idx, 4};
        trial_responses{img} = outcomeTable{img_table_idx, 5};
      
    %%% Long-Delay %%%
    elseif strcmp(exp, 'LD')
        table_ver = 1;
        img_table_idx = find([outcomeTable{:,4}] == trial_img_codes(img));
        if isempty(img_table_idx)
            table_ver = 2;
            img_table_idx = find([outcomeTable2{:,4}] == trial_img_codes(img));
            if isempty(img_table_idx)
                trial_responses{img} = nan;
                trial_outcomes{img} = nan;
                continue
            end
        end
        if table_ver == 1
            trial_img_types{img} = outcomeTable{img_table_idx, 3};
            trial_responses{img} = outcomeTable{img_table_idx, 5};
        elseif table_ver == 2
            trial_img_types{img} = outcomeTable2{img_table_idx, 3};
            trial_responses{img} = outcomeTable2{img_table_idx, 5};
        end
       
    %%% Pattern Separation & Frequency Stim %%%
    elseif strcmp(exp, 'PS') || strcmp(exp, 'FS')
        table_ver = 1;
        img_table_idx = find([outcomeTable{:,4}] == trial_img_codes(img));
        if isempty(img_table_idx)
            table_ver = 2;
            img_table_idx = find([outcomeTable2{:,4}] == trial_img_codes(img));
            if isempty(img_table_idx)
                trial_img_types{img} = nan;
                trial_responses{img} = nan;
                trial_outcomes{img} = nan;
                continue
            end
        end
        if table_ver == 1
            trial_img_types{img} = outcomeTable{img_table_idx, 3};
            trial_responses{img} = outcomeTable{img_table_idx, 9};
        elseif table_ver == 2
            trial_img_types{img} = outcomeTable2{img_table_idx, 3};
            trial_responses{img} = outcomeTable2{img_table_idx, 9};
        end
       
    end

    % Assign outcome based on image type and response
    if (all(trial_responses{img} == 78)) || (all(trial_responses{img} == 66)) || (strcmp(trial_responses{img}, 'Yes')) % sure/maybe yes
        if (strcmp(trial_img_types{img}, 'old')) || (strcmp(trial_img_types{img}, 'Targ')) || (strcmp(trial_img_types{img}, 'Old'))
            trial_outcomes{img} = 'Hit';
        elseif strcmp(trial_img_types{img}, 'new') || (strcmp(trial_img_types{img}, 'New')) || (strcmp(trial_img_types{img}, 'Foil'))
            trial_outcomes{img} = 'FA';
        end
    elseif (all(trial_responses{img} == 67))|| (all(trial_responses{img} == 86)) || (strcmp(trial_responses{img}, 'No')) % sure/maybe no
        if strcmp(trial_img_types{img}, 'old') || (strcmp(trial_img_types{img}, 'Targ')) || (strcmp(trial_img_types{img}, 'Old'))
            trial_outcomes{img} = 'Miss';
        elseif strcmp(trial_img_types{img}, 'new') || (strcmp(trial_img_types{img}, 'New')) || (strcmp(trial_img_types{img}, 'Foil'))
            trial_outcomes{img} = 'CR';
        end
    end
end

end