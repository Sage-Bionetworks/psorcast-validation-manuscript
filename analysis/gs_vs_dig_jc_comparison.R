############################################################
# This script will be used for summarizing reported each 
# joint counts for PSA users
# @author: aryton.tediarjo@sagebase.org
############################################################
rm(list=ls())
gc()

# import libraries
library(synapser)
library(data.table)
library(tidyverse)
library(ggplot2)
library(jsonlite)
library(githubr)
source("utils/feature_extraction_utils.R")
source("utils/fetch_id_utils.R")
source('utils/helper_utils.R')
synapser::synLogin()


############################
# Global Vars
############################
SYN_ID_REF <- list(
    removed_data = get_removed_log_ids(),
    feature_extraction = get_feature_extraction_ids(),
    curated_features = get_feature_processing_ids())
PARENT_SYN_ID <- SYN_ID_REF$curated_features$parent
GS_JOINT_COUNT <- config::get("tables")$md_joint_counting
DIG_JOINT_COUNT <- config::get("tables")$joint_counting
PPACMAN_TBL_ID <- SYN_ID_REF$feature_extraction$ppacman
VISIT_REF_ID <- SYN_ID_REF$feature_extraction$visit_summary
FILE_COLUMNS <- "summary.json"
OUTPUT_FILE <- "joint_counts_comparison.tsv"

############################
# Global Vars
############################
SCRIPT_PATH <- file.path(
    'analysis',
    'gs_vs_dig_jc_comparison.R')
GIT_URL <- get_github_url(
    git_token_path = config::get("git")$token_path,
    git_repo = config::get("git")$repo,
    script_path = SCRIPT_PATH,
    ref="branch", 
    refName='main')



#' Function to fetch joint tables summary forms
#' and shape it into tidy-like format
get_joint_summary <- function(){
    entity_gs_jc <- synTableQuery(glue::glue(
        "SELECT * FROM {GS_JOINT_COUNT}"))
    entity_dig_jc <- synTableQuery(glue::glue(
        "SELECT * FROM {DIG_JOINT_COUNT}"))
    tbl <- rbind(entity_gs_jc$asDataFrame() %>%
                     dplyr::mutate(fileColumnName = "gs_joint_count"), 
                 entity_dig_jc$asDataFrame() %>%
                     dplyr::mutate(fileColumnName = "dig_joint_count")) %>%
        dplyr::select(
            everything(), 
            fileHandleId = !!sym(FILE_COLUMNS))
    file_data <- list(
        gs_jc = synDownloadTableColumns(
            entity_gs_jc, FILE_COLUMNS) %>% 
            tibble::enframe() %>%
            dplyr::select(fileHandleId = name, filePath = value),
        dig_jc = synDownloadTableColumns(
            entity_dig_jc, FILE_COLUMNS) %>% 
            tibble::enframe() %>%
            dplyr::select(fileHandleId = name, filePath = value)) %>% 
        purrr::reduce(rbind)
    
    tbl %>% 
        dplyr::inner_join(
            file_data, by = c("fileHandleId"))
}

#' Function to annotate jcounts comparison
#' by pivot (long to wide) based on digital and gold standard
#' and get the column-wise difference of reported joint counts 
#' of both digital and the digitally reported jcounts
annotate_jcounts_comparison <- function(data){
    data %>% 
        dplyr::group_by(participantId, 
                        createdOn, 
                        visit_num, 
                        fileColumnName, 
                        identifier) %>%
        dplyr::summarise(total = sum(isSelected)) %>% 
        ungroup() %>%
        drop_na(fileColumnName, identifier) %>%
        pivot_wider(
            names_from = fileColumnName, 
            values_from = total) %>%
        dplyr::mutate(dig_joint_count = 
                          ifelse(is.na(dig_joint_count), 0,  
                                 dig_joint_count)) %>%
        dplyr::mutate(gs_joint_count = 
                          ifelse(is.na(gs_joint_count), 0,  
                                 gs_joint_count)) %>%
        dplyr::mutate(
            jc_concordance = case_when(
                dig_joint_count == gs_joint_count ~ 0,
                dig_joint_count > gs_joint_count ~ -1, 
                TRUE ~ 1))
}

main <- function(){
    #' get visit reference and curated ppacman table
    visit_ref <- synGet(VISIT_REF_ID)$path %>% fread()
    ppacman <- synGet(PPACMAN_TBL_ID)$path %>% fread()
    result <- get_joint_summary() %>%
        flatten_joint_summary() %>%
        join_with_ppacman(visit_ref, ppacman)  %>%
        annotate_jcounts_comparison() %>%
        dplyr::arrange(desc(createdOn)) %>%
        dplyr::mutate(createdOn = as.character(createdOn)) %>% 
        write_tsv(OUTPUT_FILE)
    file <- synapser::File(OUTPUT_FILE, PARENT_SYN_ID)
    entity <- synStore(file,
             activityName = "get jcounts comparison between gs and self-reported",
             used = c(PPACMAN_TBL_ID, 
                      VISIT_REF_ID,
                      DIG_JOINT_COUNT, 
                      GS_JOINT_COUNT), 
             executed = GIT_URL)
    unlink(OUTPUT_FILE)
    
    #' add annotation
    synSetAnnotations(
        entity$properties$id,
        analysisType = "joint counts analysis",
        analysisSubtype = "gold-Standard joint counts vs joint swelling",
        pipelineStep = "feature curation",
        task = "gold-standard joint count")
}

main()
