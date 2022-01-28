library(synapser)
library(data.table)
library(tidyverse)
synapser::synLogin()


get_file_view_ref <- function(){
    project_id <- synFindEntityId(
        yaml::read_yaml("synapseformation/manuscript.yaml")[[1]]$name)
    file_view_id <- synapser::synFindEntityId(
        "Psorcast Manuscript - File View", project_id)
    return(file_view_id)
}

get_removed_log_ids <- function(){
    file_view_id <- get_file_view_ref()
    ref_list <- list()
    data <- synTableQuery(
        glue::glue("SELECT * FROM {file_view_id}", 
                   file_view_id = file_view_id))$asDataFrame() %>%
        tibble::as_tibble()
    ref_list$parent_id <- data %>%
        dplyr::filter(type == "folder",
                      name == "Removed Data Log") %>% .$id
    return(ref_list)
}

get_feature_extraction_ids <- function(){
    file_view_id <- get_file_view_ref()
    ref_list <- list()
    data <- synTableQuery(
        glue::glue("SELECT * FROM {file_view_id}", 
                   file_view_id = file_view_id))$asDataFrame() %>%
        tibble::as_tibble()
    ref_list$parent_id <- data %>%
        dplyr::filter(type == "folder",
                      name == "Features - Extracted") %>% .$id
    ref_list$annotator_folder_id <- data %>%
        dplyr::filter(type == "folder",
                      name == "Psorcast Annotator Scores") %>% .$id
    ref_list$pso_draw_folder_id <- data %>%
        dplyr::filter(type == "folder",
                      name == "Psorcast Psoriasis Draw Images") %>% .$id
    ref_list$ppacman <- data %>% 
        dplyr::filter(
            analysisType == "clinical data",
            pipelineStep == "feature extraction") %>% .$id
    ref_list$visit_summary =  data %>% 
        dplyr::filter(
            analysisType == "visit summary",
            pipelineStep == "feature extraction") %>% .$id
    ref_list$djo <-  data %>% 
        dplyr::filter(
            analysisType == "digital jar open",
            pipelineStep == "feature extraction") %>% .$id
    ref_list$draw <- data %>% 
        dplyr::filter(
            analysisType == "psoriasis draw",
            pipelineStep == "feature extraction",
            is.na(analysisSubtype)) %>% .$id
    ref_list$dig_jc <-  data %>% 
        dplyr::filter(
            analysisType == "joint counts analysis",
            pipelineStep == "feature extraction",
            task == "digital joint count") %>% .$id
    ref_list$gs_jc <-  data %>% 
        dplyr::filter(
            analysisType == "joint counts analysis",
            pipelineStep == "feature extraction",
            task == "gold-standard joint count") %>% .$id
    ref_list$gs_js <-  data %>% 
        dplyr::filter(
            analysisType == "joint counts analysis",
            pipelineStep == "feature extraction",
            task == "gold-standard joint swell") %>% .$id
    return(ref_list)
}


get_feature_processing_ids <- function(){
    file_view_id <- get_file_view_ref()
    ref_list <- list()
    data <- synTableQuery(
        glue::glue("SELECT * FROM {file_view_id}", 
                   file_view_id = file_view_id))$asDataFrame() %>%
        tibble::as_tibble()
    ref_list$parent_id <- data %>%
        dplyr::filter(type == "folder",
                      name == "Features - Processed") %>% .$id
    ref_list$merged <- data %>%
        dplyr::filter(analysisType == "merged feature files",
                      pipelineStep == "feature curation") %>% .$id
    ref_list$curated_djo <- data %>% 
        dplyr::filter(analysisType == "digital jar open",
                      pipelineStep == "feature curation") %>% .$id
    return(ref_list)
}

get_modelling_results_ids <- function(){
    file_view_id <- get_file_view_ref()
    data <- synTableQuery(
        glue::glue("SELECT * FROM {file_view_id}", 
                   file_view_id = file_view_id))$asDataFrame() %>%
        tibble::as_tibble()
    ref_list <- list(
        parent_id = data %>% 
            dplyr::filter(type == "folder",
                          name == "Intermediate Files") %>% .$id,
        psa_pso_md_fpr_tpr = data %>% 
            dplyr::filter(analysisType == "digital jar open",
                          analysisSubtype == "psa vs pso - median iter",
                          pipelineStep == "prediction") %>% .$id,
        psa_pso_auc_iter = data %>% 
            dplyr::filter(analysisType == "digital jar open",
                          analysisSubtype == "psa vs pso - auc iter",
                          pipelineStep == "prediction") %>% .$id,
        uei_pso_md_fpr_tpr = data %>% 
            dplyr::filter(analysisType == "digital jar open",
                          analysisSubtype == "uei - median iter",
                          pipelineStep == "prediction") %>% .$id,
        uei_pso_auc_iter = data %>% 
            dplyr::filter(analysisType == "digital jar open",
                          analysisSubtype == "uei - auc iter",
                          pipelineStep == "prediction") %>% .$id
    )
}


get_figures_ids <- function(){
    file_view_id <- get_file_view_ref()
    data <- synTableQuery(
        glue::glue("SELECT * FROM {file_view_id}", 
                   file_view_id = file_view_id))$asDataFrame() %>%
        tibble::as_tibble()
    ref_list <- list(
        parent_id = data %>% 
            dplyr::filter(type == "folder",
                          name == "Figures") %>% .$id
    )
}
