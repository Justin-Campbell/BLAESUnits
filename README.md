# BLAES Units

Created by Justin M. Campbell (justin.campbell@hsc.utah.edu)  
*11/11/24*  

## Paper

#### SUMMARY
The amygdala is a highly connected cluster of nuclei with input from multiple sensory modalities, particularly the ventral visual stream, and vast projections to distributed cortical and subcortical regions involved in autonomic regulation and cognition. Numerous studies have described the amygdala’s capacity to facilitate the encoding of long-lasting emotional memories. Recently, direct electrical stimulation of the basolateral complex of the amygdala (BLA) in humans revealed a more generalized ability to enhance declarative memory irrespective of the emotional valence, likely by promoting synaptic plasticity-related processes underlying memory consolidation in the hippocampus and medial temporal lobe. These effects were achieved with rhythmic theta-burst stimulation (TBS), which is known to induce long-term potentiation (LTP), a key mechanism in memory formation. Emerging evidence suggests that intracranial TBS may also enhance memory specificity, evoke theta-frequency oscillations, and facilitate short-term plasticity in local field potential recordings. However, how amygdalar TBS modulates activity at the single-cell level and to what extent this modulation is associated with memory performance remains poorly understood. Here, we address this knowledge gap by conducting simultaneous microelectrode recordings from prefrontal and medial temporal structures during a memory task in which intracranial TBS was applied to the BLA. We observed a subset of neurons whose firing rate was modulated by TBS and exhibited highly heterogeneous responses with respect to onset latency, duration, and direction of effect. Notably, location and baseline activity predicted which neurons were most susceptible to modulation. These findings provide direct empirical support for stimulation-evoked modulation of single-neuron activity in humans, which has implications for the development and refinement of neuromodulatory therapies.


> **Campbell, J. M.** et al. Human single-neuron activity is modulated by intracranial theta burst stimulation of the basolateral amygdala. bioRxiv (2024) [doi:10.1101/2024.11.11.622161.](https://www.biorxiv.org/content/10.1101/2024.11.11.622161v1) 


## Code

- `BLAESUnitPrepro.ipynb`: Contains the pipeline for loading the sorted data, epoching the continuous recordings, and counting the number of events (spikes). 
- `GroupAnalyses.ipynb`: Computes summary descriptive statistics and checks for firing-rate modulation using permutation tests.
- `UnitQualityMetrics.ipynb`: Computes common unit quality metrics (e.g., mean firing rate, interspike interval, coefficient of variation).
- `ParameterAnalyses.ipynb`: Tests for differences in the proportion of modulated units as a function of stimulation parameters (subset of data).
- `ControlAnalyses.ipynb`: Removes increasing segments of data around each burst onset to determine whther suppression effects is explained by amplifier saturation.
- `SensitiviyAnalysis.ipynb`: Varies the pre-stim firing-rate threshold used for inclusion/exclusion of units and compares the relative proportion of modulated units.  
- `BehaviorAnalyses.ipynb`: Analyzes behavioral performance on the memory task and checks for associations between change in memory across conditions and the proportion of modulated units.
