# BLAES Units

Created by Justin M. Campbell (justin.campbell@hsc.utah.edu)  
*2/12/25*  

#### Abstract
Direct electrical stimulation of the human brain has been used for numerous clinical and scientific applications. Previously, we demonstrated that intracranial theta burst stimulation (TBS) of the basolateral amygdala (BLA) can enhance declarative memory, likely by modulating hippocampal-dependent memory consolidation. At present, however, little is known about how intracranial stimulation affects activity at the microscale. In this study, we recorded intracranial EEG data from a cohort of patients with medically refractory epilepsy as they completed a visual recognition memory task. During the memory task, brief trains of TBS were delivered to the BLA. Using simultaneous microelectrode recordings, we isolated neurons in the hippocampus, amygdala, orbitofrontal cortex, and anterior cingulate cortex and tested whether stimulation enhanced or suppressed firing rates. Additionally, we characterized the properties of modulated neurons, patterns of firing rate coactivity, and the extent to which modulation affected memory task performance. We observed a subset of neurons (~30%) whose firing rate was modulated by TBS, exhibiting highly heterogeneous responses with respect to onset latency, duration, and direction of effect. Notably, location and baseline activity predicted which neurons were most susceptible to modulation, although the impact of this neuronal modulation on memory remains unclear. These findings advance our limited understanding of how focal electrical fields influence neuronal firing at the single-cell level and motivate future neuromodulatory therapies that aim to recapitulate specific patterns of activity implicated in cognition and memory.


> **Campbell, J. M.** et al. Human single-neuron activity is modulated by intracranial theta burst stimulation of the basolateral amygdala. bioRxiv (2024) [doi:10.1101/2024.11.11.622161.](https://www.biorxiv.org/content/10.1101/2024.11.11.622161v1) 


## Code

- `BLAESUnitPrepro.ipynb`: Contains the pipeline for loading the sorted data, epoching the continuous recordings, and counting the number of events (spikes). 
- `GroupAnalyses.ipynb`: Computes summary descriptive statistics and checks for firing-rate modulation using permutation tests.
- `UnitQualityMetrics.ipynb`: Computes common unit quality metrics (e.g., mean firing rate, interspike interval, coefficient of variation).
- `ParameterAnalyses.ipynb`: Tests for differences in the proportion of modulated units as a function of stimulation parameters (subset of data).
- `ControlAnalyses.ipynb`: Removes increasing segments of data around each burst onset to determine whther suppression effects is explained by amplifier saturation.
- `SensitiviyAnalysis.ipynb`: Varies the pre-stim firing-rate threshold used for inclusion/exclusion of units and compares the relative proportion of modulated units.  
- `BehaviorAnalyses.ipynb`: Analyzes behavioral performance on the memory task and checks for associations between change in memory across conditions and the proportion of modulated units.
- `PCAAnalyses.ipynb`: Performs linear dimensionality reduction (PCA) and visualizes the first three principal components. Low-dimensional representations are used to visualize population dynamics and firing rate coactivity.
