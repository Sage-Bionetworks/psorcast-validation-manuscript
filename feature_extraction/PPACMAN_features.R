########################################################################
# Psoriasis Validation
# Purpose: To extract features from the PPACMAN assessor table
# Author: Meghasyam Tummalacherla
# email: meghasyam@sagebase.org
########################################################################
rm(list=ls())
gc()

##############
# Required libraries
##############
library(synapser)
library(githubr)
library(data.table)
library(tidyr)
library(plyr)
library(dplyr)
source("utils/feature_extraction_utils.R")
source('utils/helper_utils.R')
source("utils/fetch_id_utils.R")


synapser::synLogin()

# output reference
SYN_ID_REF <- list(
    removed_data = get_removed_log_ids(),
    feature_extraction = get_feature_extraction_ids())
PPACMAN_SYN_ID <- config::get("tables")$ppacman
PARENT_SYN_ID <- SYN_ID_REF$feature_extraction$parent_id # synId of folder to upload your file to
OUTPUT_FILE <- 'PPACMAN_assessor_features.tsv' # name your file

# Github link
SCRIPT_PATH <- file.path(
    'feature_extraction', 
    "PPACMAN_features.R")
GIT_URL <- get_github_url(
    git_token_path = config::get("git")$token_path,
    git_repo = config::get("git")$repo,
    script_path = SCRIPT_PATH,
    ref="branch", 
    refName='main')

main <- function(){
    ppacman.syn <- synapser::synTableQuery(paste0(
        'select * from ', PPACMAN_SYN_ID))
    ppacman.tbl <- ppacman.syn$asDataFrame()
    
    ppacman.ftrs <- ppacman.tbl %>% 
        dplyr::select(-ROW_ID, -ROW_VERSION) %>% 
        dplyr::select(participantId,
                      createdOn = `Date`,
                      visit_num = `Visit Number`,
                      age = Age,
                      sex = Sex,
                      diagnosis = Diagnosis,
                      finger_dactylitis = `Finger Dactylitis`,
                      toe_dactylitis = `Toe Dactylitis`,
                      finger_nail = `Finger Nail Involvement`,
                      toe_nail = `Toe Nail Involvement`,
                      tjc_backup = `(Optional backup) MD TJC`,
                      sjc_backup = `(Optional backup) MD SJC`,
                      enthesitis = `Enthesitis Notes`,
                      gs_bsa = `Overall BSA (%)`) %>%
        dplyr::mutate(tjc_backup = stringr::str_replace_all(tjc_backup, "[\r\n]|:" , ""),
                      sjc_backup = stringr::str_replace_all(sjc_backup, "[\r\n]|:" , ""),
                      participantId = tolower(participantId))
    
    #' write to synapse
    entity <- save_to_synapse(
        data = ppacman.ftrs,
        output_filename = OUTPUT_FILE, 
        parent = PARENT_SYN_ID, 
        name = "get ppacman features",
        executed = GIT_URL, 
        used = PPACMAN_SYN_ID)
    
    synSetAnnotations(
        entity$properties$id,
        analysisType = "clinical data",
        pipelineStep = "feature extraction")
}

log_process(main(), SCRIPT_PATH)
