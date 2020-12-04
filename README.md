# pool-separate-behaviors

van der Marel, A., Prasher, S., Carminito, C., O’Connell, C., Phillips, A., Kluever, B. M., & Hobson, E. A. (2020). A framework to evaluate whether to pool or separate behaviors in a multilayer network. ArXiv, 2007.09743. 

We developed a 3-step framework to examine the implications of splitting or pooling potentially-related behaviors before deciding on how to construct the layers of networks in a multilevel network analysis. For this framework, we used two agonistic behaviors (crowds and displacements) in monk parakeets. 

In step 1 (initial check), we questioned whether:
  - the same or different dyads perform the both behaviors?
  - there is data sparsity?
  - the two behaviors are correlated?

In step 2, we test the observed patterns with randomized reference model 1: Using this reference model, we test whether randomizing the number of interactions across two behavior types results in indistinguishable structural patterns in a reference model compared to the observed data.
  - Change: Randomly re-allocate aggression to number of displacements and number of crowds by dyad. 
  - Preserve: Keep total events (n disp + n crowd) by dyad the same

In step 3, we test the observed patterns with randomized reference model 2: The goal of this reference model is to assess how the sparser displacement data may affect our summary statistics. To do this we subsampled our displacement event data so that the number of displacements was reduced to equal the number of crowds (which were the rarer behavior type in our observations). There are 2 parts to this model:
- Part A: subsample displacements to equal the rare interaction type and add observed crowds to this dataframe
- Part B: randomly re-allocate the total observed crowds and subsample displacements back to the 2 interaction types.

The R markdown files in the folder R-code contain all the code to reproduce our research:
 - Observed data.Rmd contains the code to summarize the observed behaviors (crowds and displacements) of the monk parakeets. 
 - reference model 1.Rmd contains the code to create reference model 1 and to summarize that model. 
 - reference model 1.Rmd contains the code to create reference model 2 and to summarize that model. 
 - visualizing results.Rmd shows the plots of the distribution of the reference models and the observed values. 

The output of the code is available in the folder cached-data and the plots in the folder raw-plots. 
The datafile is called "ANALYZE.aggDC.csv"

https://zenodo.org/badge/latestdoi/266793386 
This work is licensed under CC BY-NC 4.0
