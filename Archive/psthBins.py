def psthBins(times, binsize, fs, n_trials, trial_len):
    '''
    psthBins computes the peri-stimulus time histogram from spike times (code adapted from Rajiv Narayan's psthBins.m).
    
    Inputs:
        - times: spike times (samples)
        - binsize: bin size (ms)
        - fs: sampling rate (Hz)
        - n_trials: number of trials
        - trial_len: length of each trial (samples)
    
    Outputs:
        - binned_FR: binned firing rate
        - smooth_FR: smoothed firing rate
        - T: peri-stimulus time histogram edges
    '''
    
    # Import libraries
    import numpy as np
    
    # Compute PSTH
    last_bin = binsize * np.ceil(trial_len / (1000 / (fs*binsize)))
    edges = np.arange(0, last_bin, binsize)
    x = np.mod(times, trial_len) * (1000 / fs)
    binned_FR = (np.histogram(x, edges) * 1000) / (n_trials * binsize)

    # Smoothing
    # smooth_FR = 
    
    return binned_FR, edges