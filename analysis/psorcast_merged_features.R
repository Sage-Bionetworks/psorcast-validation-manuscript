########################################################################
#' Psoriasis Validation
#' 
#' Purpose: 
#' This script is used to merge all of the .tsv files
#' used for analysis of psorcast, it will clean redundant record by taking
#' the most recent record of a given day (assuming one day per test). 
#' 
#' It will also output a fully row-binded tables containing each 
#' participant_id, date of test, and source table info 
#' for future debugging purposes.
#'
#' Author: Aryton Tediarjo
#' email: aryton.tediarjo@sagebase.org
########################################################################
rm(list=ls())
gc()

# import libraries
library(synapser)
library(data.table)
library(tidyverse)
library(githubr)
library(config)
source("utils/feature_extraction_utils.R")
source('utils/helper_utils.R')
source('utils/fetch_id_utils.R')
synLogin()

############################
# Global Vars
############################
SYN_ID_REF <- list(
    removed_data = get_removed_log_ids(),
    feature_extraction = get_feature_extraction_ids(),
    curated_features = get_feature_processing_ids())
OUTPUT_REF <- list(
    merged_file = "psorcast_merged_features.tsv",
    removed_records = "error_log_psorcast_merged_features.tsv")
PARENT_REF <- list(
    merged_file = SYN_ID_REF$curated_features$parent_id,
    removed_records = SYN_ID_REF$removed_data$parent_id)
PPACMAN_TBL_ID <- SYN_ID_REF$feature_extraction$ppacman
FEATURES_ID <- list(
    djo = SYN_ID_REF$feature_extraction$djo,
    dig_jc = SYN_ID_REF$feature_extraction$dig_jc,
    gs_jc = SYN_ID_REF$feature_extraction$gs_jc,
    gs_swell = SYN_ID_REF$feature_extraction$gs_js,
    pso_draw = SYN_ID_REF$feature_extraction$draw
)

############################
# Git Reference
############################
SCRIPT_PATH <- file.path(
    'analysis', 
    'psorcast_merged_features.R')
GIT_URL <- get_github_url(
    git_token_path = config::get("git")$token_path,
    git_repo = config::get("git")$repo,
    script_path = SCRIPT_PATH,
    ref="branch", 
    refName='main')

main <- function(){
    #' get ppacman
    ppacman <- synGet(PPACMAN_TBL_ID)$path %>% fread()
    
    #' get entirety of feature set
    all_data_list <- 
        purrr::map(FEATURES_ID, function(syn_id){
            entity <- synGet(syn_id)
            feature_tbl_id <- entity$properties$id
            feature_tbl_name <- entity$properties$name
            features <- entity$path %>% 
                fread() %>%
                dplyr::mutate(source = feature_tbl_name,
                              id = feature_tbl_id) %>%
                dplyr::select(-createdOn)})
        
    #' merge all features using reduce operation, and right-join PPACMAN
    #' table to keep all users with ppacman information
    merged_features <- 
        all_data_list %>% 
        purrr::reduce(dplyr::full_join, 
                      by = c("participantId", "visit_num")) %>%
        tibble::as_tibble() %>%
        dplyr::right_join(ppacman, 
                          by = c("participantId", "visit_num")) %>%
        dplyr::group_by(participantId, createdOn, visit_num) %>%
        dplyr::summarise_all(last) %>%
        dplyr::select(-starts_with("recordId"),
                      -starts_with("source"),
                      -starts_with("id")) %>%
        dplyr::select(participantId, 
                      createdOn, 
                      visit_num, 
                      everything()) %>% 
        dplyr::arrange(desc(createdOn))
    
    #' save merged file to synapse
    entity <- save_to_synapse(data = merged_features,
                    output_filename = OUTPUT_REF$merged_file, 
                    parent = PARENT_REF$merged_file,
                    name = "get merged file",
                    executed = GIT_URL,
                    used = c(FEATURES_ID %>% purrr::reduce(c), 
                             PPACMAN_TBL_ID))
    synSetAnnotations(
        entity$properties$id,
        analysisType = "merged feature files",
        pipelineStep = "feature curation")
}

log_process(main(), SCRIPT_PATH)


