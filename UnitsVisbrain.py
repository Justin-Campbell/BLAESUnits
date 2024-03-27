def UnitsVisbrain(elec_size = 20, animate = False, save = False):
    """plotBLAESStim() uses the visbrain package (visbrain.org) to generate a 3D model of an MNI brain w/ electrode contacts superimposed. Electrode locations (MNI XYZ coordinates) are defined in each patient's CSMap.mat file.

    Inputs:
        - elec_size (float, optional): Marker size for electrode contact(s).
        - animate (bool, optional): If True, the 3D model will rotate. Default is False.
        - save (bool, optional): If True, the 3D model will be saved as a .png or .giv. Default is False.
        
    Justin M. Campbell (justin.campbell@hsc.utah.edu)
    03/25/24
    """
        
    # Import libraries
    from visbrain.objects import BrainObj, SceneObj, SourceObj
    
    # Scene object
    scene_obj = SceneObj(bgcolor='white', size=(10000, 10000))
    
    # Brain object(s)
    brain_obj_L = BrainObj('B2', translucent = True, hemisphere = 'left')
    brain_obj_R = BrainObj('B2', translucent = True, hemisphere = 'right')
    scene_obj.add_to_subplot(brain_obj_L, row = 0, col = 0)
    scene_obj.add_to_subplot(brain_obj_R, row = 0, col = 1)
    brain_obj_L.rotate(fixed = 'right')
    brain_obj_R.rotate(fixed = 'left')
    
    # Source object(s)
    iEEG_obj_L = SourceObj(name = 'iEEG', xyz = xyz_L, color = colors_L, radius_min = elec_size, edge_color = 'black', edge_width = 0.5)
    iEEG_obj_R = SourceObj(name = 'iEEG', xyz = xyz_R, color = colors_R, radius_min = elec_size, edge_color = 'black', edge_width = 0.5)
    scene_obj.add_to_subplot(iEEG_obj_L, row = 0, col = 0)
    scene_obj.add_to_subplot(iEEG_obj_R, row = 0, col = 1)

    # Export
    if save is True:
        if animate is True:
            brain_obj_L.animate(step = 0.5) # video
            brain_obj_R.animate(step = 0.5) # video
            scene_obj.preview()
            
            scene_obj.record_animation(os.path.join(resultsPath, 'Figures', 'iEEGModelGIF.gif'), n_pic=100) # save video as gif
        else:
            scene_obj.preview()
            scene_obj.screenshot(os.path.join(resultsPath, 'Figures', 'iEEGModel.png'), transparent=False, print_size = (3,3), autocrop = True, dpi = 1000) # save as image
    else:
        scene_obj.preview()
            

### IMPLEMENTATION
if __name__ == '__main__':
    import os
    import pandas as pd
    
    # Results path
    resultsPath = '/Users/justincampbell/Library/CloudStorage/GoogleDrive-u0815766@gcloud.utah.edu/My Drive/Research Projects/BLAESUnits/Results/Group/'
    
    # Load data
    statsDF = pd.read_csv(os.path.join(resultsPath, 'SpikeStats.csv'), index_col = 0)
    regionColorMap = pd.read_csv(os.path.join(resultsPath, 'RegionColorMap.csv'))
    
    # Set default
    regions = statsDF['Region'].unique()
    xyz = statsDF[['MNI_X', 'MNI_Y', 'MNI_Z']].to_numpy()
    colors = ['#000000'] * len(xyz)
    sizes = [20] * len(xyz)
    
    # # Color stim contacts
    # stimIdxs = elecXYZs[elecXYZs['Stim'] == True].index.tolist()
    # for idx in stimIdxs:
    #     colors[idx] = '#6bc2a8'
    
    # Color by region
    for region in regions:
        regionIdxs = statsDF[statsDF['Region'] == region].index.tolist()
        color = regionColorMap[regionColorMap['Region'] == region]['Color'].values[0]
        for idx in regionIdxs:
            colors[idx] = color

    # Split by hemisphere
    xyz_L = xyz[xyz[:,0] < 0]
    colors_L = [colors[i] for i in range(len(colors)) if xyz[i,0] < 0]
    xyz_R = xyz[xyz[:,0] > 0]
    colors_R = [colors[i] for i in range(len(colors)) if xyz[i,0] > 0]
    
    ### Different version that scale electrode size for optimal viewing ###
    
    # Preview/localization version:
    # UnitsVisbrain(elec_size = 40, animate = False, save = False)
    
    # Export screenshot version:
    UnitsVisbrain(elec_size = 80, animate = False, save = True)
    
    # Export gif version:
    # UnitsVisbrain(elec_size = 25, animate = True, save = True)