def BLAES_Visbrain(xyz, colors = None, roi_smoothing = 8, elec_size = 20, show_brain = True, ROIs = None, animate = False, save = False):
    """plotBLAESStim() uses the visbrain package (visbrain.org) to generate a 3D model of an MNI brain w/ electrode contacts superimposed. Electrode locations (MNI XYZ coordinates) are defined in each patient's CSMap.mat file.

    Inputs:
        xyz (pd.DataFrame): X,Y,Z coordinates of electrodes (use MNI space if >1 patient).
        colors (pd.DataFrame, optional): values used to color electrodes.
        elec_size (float, optional): Marker size for electrode contact(s).
        roi_smoothing (int, optional): Amount of smoothing to apply to ROI voxels.
        
    Justin M. Campbell (justin.campbell@hsc.utah.edu)
    07/31/23
    """
        
    # Import libraries
    from visbrain.objects import BrainObj, ColorbarObj, SceneObj, SourceObj, RoiObj
    
    # Scene object
    scene_obj = SceneObj(bgcolor='white', size=(1000, 1000))
    
    # Brain object(s)
    if show_brain == True:
        brain_obj = BrainObj('B2', translucent = True)
        scene_obj.add_to_subplot(brain_obj, row=0, col=0, use_this_cam=True)
    
    # ROI object(s)
    if (ROIs is not None) and 'AMY' in ROIs:
        roiAMY = RoiObj('aal')
        roiAMY.select_roi(roiAMY.where_is('amygdala'), translucent = True, smooth = roi_smoothing, roi_to_color={41: 'pink', 42: 'pink'})
        scene_obj.add_to_subplot(roiAMY, row=0, col=0)
    if (ROIs is not None) and 'HC' in ROIs:
        roiHC = RoiObj('aal')
        roiHC.select_roi(roiHC.where_is('hippocampus'), translucent = True, smooth = roi_smoothing, roi_to_color={37: 'green', 38: 'green'})
        scene_obj.add_to_subplot(roiHC, row=0, col=0)
    
    # Source object(s)
    if colors is not None:
        iEEG_obj = SourceObj('iEEG', xyz, radius_min = elec_size, edge_color = 'black', edge_width = 0.5)
        iEEG_obj.color_sources(data = t_stats, cmap = 'coolwarm')
        # Colorbar object
        CBAR_STATE = dict(cbtxtsz=15, txtsz=10, txtcolor = 'black', width=.1, cbtxtsh=3., rect=(-.3, -2., 1., 4.), clim = (-5,5))
        cbar_obj = ColorbarObj(iEEG_obj, cblabel='Paired t-Stat \n (Pre vs. Post)', **CBAR_STATE)
        scene_obj.add_to_subplot(cbar_obj, row=0, col=1, width_max=200)
    else:
        iEEG_obj = SourceObj('iEEG', xyz, color = (['#000000'] * len(xyz)), radius_min = elec_size) # All black
    scene_obj.add_to_subplot(iEEG_obj)

    # Preview
    if animate == True:
        scene_obj.preview() # static
        brain_obj.animate(step = 0.5) # video
    else:
        scene_obj.preview() # static
    
    # Export
    if save is True:
        if animate:
            scene_obj.record_animation('/Users/justincampbell/Library/CloudStorage/GoogleDrive-u0815766@gcloud.utah.edu/My Drive/Research Projects/BLAES/Results/BLAES_A2/Group/' + feature + '_iEEGModel.gif', n_pic=100) # save video as gif
        else:
            scene_obj.screenshot('/Users/justincampbell/Desktop/iEEGModel.png', transparent=True, print_size = (5,5), autocrop = True, dpi = 1000) # save as image

### IMPLEMENTATION
if __name__ == '__main__':
    import pandas as pd
    feature = 'Theta'
    mergedDF = pd.read_csv('/Users/justincampbell/Library/CloudStorage/GoogleDrive-u0815766@gcloud.utah.edu/My Drive/Research Projects/BLAES/Results/BLAES_A2/Group/' + feature + '_MergedDF.csv', index_col = 0)
    mergedDF = mergedDF[mergedDF['Perm Sig'] == True]
    all_xyz = mergedDF[['X', 'Y', 'Z']].to_numpy()
    t_stats = mergedDF['t Stat'].to_numpy()
    BLAES_Visbrain(all_xyz, t_stats, elec_size = 12.5, animate = True, show_brain = True, ROIs = None, save = True)