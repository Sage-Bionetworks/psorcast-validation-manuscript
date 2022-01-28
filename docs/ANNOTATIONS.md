# Annotations Guide

The current workflow utilizes [Synapse Vile Fiew](https://python-docs.synapse.org/build/html/Views.html) to control data I/O, meaning that to run the end to end pipeline, data will be required to be properly annotated so that the worfkflow will be able to refer to each Synapse ID location in every step of the data pipeline. 
**Each Synapse ID should be annotated uniquely under the Synapse Project and be refered as a query statement in `utils/fetch_id_utils.R`.**

### Annotations Mapping 
| pipelineStep |
| :-------------- |
| feature extraction |
| feature curation |
| analysis | 
| prediction |
| figures |

| analysisType | analysisSubtype |
| :-------------- | :-----------|
| digital jar open | psa vs pso - auc iter </br> psa vs pso - median iter </br> uei - auc iter </br> uei - median iter
| psoriasis draw | psoriasis draw images
| clinical data | 
| joint counts analysis | average joint reports </br> gold-standard joint counts vs joint swelling
| visit summary |
| psorcast plaque | psorcast plaque annotator scores


| task  | 
| :---- |
| digital jar open |
| psorisasis draw  |
| digital joint count |
| gold-standard joint count |
| gold-standard joint swell |
| psoriasis photo |
