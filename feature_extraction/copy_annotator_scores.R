############################################################
#' Function to fetch annotator scores
#' from our Synapse Annotator Portal to 
#' Data Public Release
#' 
#' @author aryton.tediarjo@sagebase.org
############################################################
library(synapser)
library(synapserutils)
library(tidyverse)
source("utils/fetch_id_utils.R")
synapser::synLogin()

ANNOTATIONS <- list(
    pipelineStep = "feature extraction",
    analysisType = "psoriasis plaque",
    analysisSubtype = "psoriasis plaque annotator scores")
SYN_ID_REF <- get_feature_extraction_ids()
PARENT_ID <- SYN_ID_REF$annotator_folder_id
ANNOTATIONS_ID_REF <- c(
    "syn26133763",
    "syn25647975",
    "syn26320741",
    "syn25791623",
    "syn25791622")

purrr::map(ANNOTATIONS_ID_REF, function(id){
    synapserutils::copy(id, PARENT_ID, updateExisting = TRUE)
})

childrens <- synGetChildren(SYN_ID_REF$annotator_folder_id)$asList()
purrr::map(childrens, function(child){
    synSetAnnotations(child$id, ANNOTATIONS)
})




