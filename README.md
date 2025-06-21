# BLAES Units

Created by Justin M. Campbell, PhD (justin.campbell@hsc.utah.edu)  
*6/21/25*  

#### Abstract
Direct electrical stimulation of the human brain has been used for numerous clinical and scientific applications. At present, however, little is known about how intracranial stimulation affects activity at the microscale. In this study, we recorded intracranial EEG data from a cohort of patients with medically refractory epilepsy as they completed a visual recognition memory task. During the memory task, brief trains of intracranial theta burst stimulation (TBS) were delivered to the basolateral amygdala (BLA). Using simultaneous microelectrode recordings, we isolated neurons in the hippocampus, amygdala, orbitofrontal cortex, and anterior cingulate cortex and tested whether stimulation enhanced or suppressed firing rates. Additionally, we characterized the properties of modulated neurons, clustered presumed excitatory and inhibitory neurons by waveform morphology, and examined the extent to which modulation affected memory task performance. We observed a subset of neurons (~30%) whose firing rate was modulated by TBS, exhibiting highly heterogeneous responses with respect to onset latency, duration, and direction of effect. Notably, location and baseline activity predicted which neurons were most susceptible to modulation, although the impact of this neuronal modulation on memory remains unclear. These findings advance our limited understanding of how focal electrical fields influence neuronal firing at the single-cell level.

> **Campbell, J. M.** et al. Human single-neuron activity is modulated by intracranial theta burst stimulation of the basolateral amygdala. *eLife* (2025). [doi.org/10.7554/eLife.106481.1.sa2](https://elifesciences.org/reviewed-preprints/106481)

## Code

- `BLAESUnitPrepro.ipynb`: Contains the pipeline for loading the sorted data, epoching the continuous recordings, and counting the number of events (spikes). 
- `GroupAnalyses.ipynb`: Computes summary descriptive statistics and checks for firing-rate modulation using permutation tests.
- `UnitQualityMetrics.ipynb`: Computes common unit quality metrics (e.g., mean firing rate, interspike interval, coefficient of variation).
- `ParameterAnalyses.ipynb`: Tests for differences in the proportion of modulated units as a function of stimulation parameters (subset of data).
- `ControlAnalyses.ipynb`: Removes increasing segments of data around each burst onset to determine whther suppression effects is explained by amplifier saturation.
- `SensitiviyAnalysis.ipynb`: Varies the pre-stim firing-rate threshold used for inclusion/exclusion of units and compares the relative proportion of modulated units.  
- `BehaviorAnalyses.ipynb`: Analyzes behavioral performance on the memory task and checks for associations between change in memory across conditions and the proportion of modulated units.
- `PCAAnalyses.ipynb`: Performs linear dimensionality reduction (PCA) and visualizes the first three principal components. Low-dimensional representations are used to visualize population dynamics and firing rate coactivity.
- `NeuronClassify.ipynb`: Extracts waveforms for each sorted unit and performs k-means clustering to determine putative cell types (excitatory vs. inhibitory).
- `Rhythmicity.ipynb`: Tests whether spiking rhymicity is altered by stimulation (by analyzing the spike timing autocorrelograms).
- `WMProximity.ipynb`: Tests whether behavioral effects of stimulation are mediated by distance to white matter.
- `MUAPrepro.ipynb`: Pipeline for extracting multiunit responses from the continuous data and determining the number of threshold crossings.
- `MUAGroup.ipynb`: Computes summary statistics on the MUA threshold crossing data.