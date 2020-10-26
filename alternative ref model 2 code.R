#The goal of this reference model is to assess how sparser displacement data may affect our summary statistics. To do this we subsampled our displacement event data so that the number of displacements was reduced to equal the number of crowds (which were the rarer behavior type in our observations)

#There are two parts within the loop:
#  A: Subsample displacements: using raw data of behavioral events (date/time, actor, subject, behavior type), randomly subsample to return the same number of displacements total as we had for total crowd events + Summarize displacements: with the subsampled data, find the total number of displacements per dyad + Bind: bind the observed crowd data (summarized at the dyad level) with the summarized displacement data

#B: Reallocate: randomly re-allocate the total number of aggressive events for each dyad (the number of subsampled displacements and the number of observed crowds)

#Result:
#  100 runs, where each are subsampled and re-allocated

#https://stackoverflow.com/questions/38208529/de-aggregate-reverse-summarise-expand-a-dataset-in-r



```{r}
## Get displacement data ready
#keep only displacements from raw data
obs.disp <- select(observed, actor, subject, displace)  #head(observed,20)
total.disp <- sum(obs.disp$displace)

#subset displacements to retain only dyads with more than 0 displacements
obs.disp.non0 <- subset(obs.disp, displace>0) # check unique(obs.disp.non0$displace)

# displacements in long format (1 event at a time)
obs.disp.non0.events <- obs.disp.non0 %>% as_tibble() %>%
  mutate(disp.event = map(displace, ~rep_len(1, .x))) %>%
  unnest(cols = c(disp.event)) %>%  # got error message, had to include cols = c(disp.event)
  select(-displace)

str(obs.disp.non0.events)
nrow(obs.disp.non0.events)
sum(obs.disp.non0.events$disp.event)

## Get crowd data ready
obs.crowd <- select(observed, actor, subject, crowd) 
obs.dyad.sum.crowd <- obs.crowd %>% group_by(actor, subject) %>% summarize(obs.dyad.crowd = sum(crowd))  # we could make this shorter or use observedXdyad dataframe

# find total number of crowd events
total.obs.crowd<-sum(obs.dyad.sum.crowd$obs.dyad.crowd)


## get loop ready
replicates <- 100

# make empty dataframe to write loop results into
ref.model.sparse <- data.frame(actor=character(),
                               subject=character(),
                               runID=character(),
                               realloc_crowd=numeric(),
                               subsamp_realloc_disp=numeric()
)


# loop
for (run in 1:replicates) { #run=2
  r.seed <- run
  RNGkind(sample.kind="default") 
  set.seed(r.seed)
  
  #### PART A: subsample displacements ####
  ## subsample displacement events (1 row per event) to have same number as total crowd events
  disp.events.subsampled <- sample_n(obs.disp.non0.events, size = total.obs.crowd, replace = FALSE)
  
  ## summarize subsampled displacement events by dyad
  REF2A.dyad.sum.subsampled_disp <- disp.events.subsampled %>% 
    group_by(actor, subject) %>% 
    summarize(disp.events.subsampled = sum(disp.event), .groups = 'drop')
  
  # check, should sum to number of crowds: sum(REF2A.dyad.sum.subsampled_disp$disp.events.subsampled)
  # names(REF2A.dyad.sum.subsampled_disp)
  
  
  ## make runID and merge runID and dyad.sum.subsampled_disp with observed crowd dyad summary
  
  # make runID: generates run IDs that are all 3 digits (001-100), change to 4 digit-padding if running >999
  runID <- rep(paste0("run",str_pad(run, 3, side="left", pad = "0")), nrow(obs.dyad.sum.crowd))  
  
  # bind runID with observed crowd dyad summaries, then merge the subsampled displacement data to that
  run.data <- cbind.data.frame(runID, obs.dyad.sum.crowd)
  run.data <- merge(run.data, REF2A.dyad.sum.subsampled_disp, by=c("actor", "subject"), all.x=TRUE)
  run.data$disp.events.subsampled[is.na(run.data$disp.events.subsampled)] <- 0 #convert any NAs to 0
  
  ### PART B:reallocate the observed crowd data and the subsampled displacement data (use same set seed) ####
  
  #add total aggression
  run.data$total.agg.REF2 <- run.data$obs.dyad.crowd + run.data$disp.events.subsampled
  
  #re-set sampling conditions (use same seed as above, using loop to set r.seed)
  RNGkind(sample.kind="default") 
  set.seed(r.seed)
  
  ref.data <- run.data %>%
    rowwise() %>%
    dplyr::mutate(subsamp_realloc_displace = sample(0:total.agg.REF2, 1),
                  realloc_crowd = total.agg.REF2-subsamp_realloc_displace)
  
  ref.data <- as.data.frame(ref.data)
  ref.model.sparse <- rbind.data.frame(ref.model.sparse, ref.data) # only goes for 1 loop, not all 100. code in the chunk below does work, don't see where I made the mistake. 
  
}

## save output
write.csv(ref.model, file = "ANALYZE_refmodel2.csv")


```

check new and old code 
```{r}
#method 1
names(ref.model)
names(ref.model.sparse)
refmodel2 <- ref.model.sparse %>% select(runID, everything()) %>%
  rename(observed.crowd=obs.dyad.crowd, sample.displace=disp.events.subsampled, 
         total.DC=total.agg.REF2, random.displace=subsamp_realloc_displace, 
         random.crowd=realloc_crowd)
setdiff(refmodel2, ref.model)
setequal(refmodel2, ref.model)

#method 2 (doesn't always work if there are decimal numbers in the dataframes)
sum(refmodel2 == ref.model) # should equal to nrows x ncols of th'e dataframe
nrow(ref.model)*ncol(ref.model)

#method 3
elementwise.all.equal <- Vectorize(function(x, y) {isTRUE(all.equal(x, y))})
elementwise.all.equal(refmodel2, ref.model)


```
