rerun: update logs project clinical features analyses plots

authenticate:
	Rscript utils/authenticate.R ${PARAMS}

update:
	git pull

logs:
	mkdir logs
	
project:
	. env/bin/activate && python3 synapseformation/create_project.py

clinical:
	Rscript feature_extraction/PPACMAN_features.R || exit 1
	Rscript feature_extraction/get_visit_summary.R || exit 1
	
features:
	Rscript feature_extraction/psoriasis_draw_bsa_features.R || exit 1
	Rscript feature_extraction/digitalJarOpen_rotation_features.R || exit 1
	Rscript feature_extraction/jointSummaries_features.R || exit 1
	Rscript feature_extraction/fetch_images.R || exit 1
	Rscript feature_extraction/copy_annotator_scores.R || exit 1
	

analyses:
	Rscript analysis/psorcast_merged_features.R || exit 1
	Rscript analysis/curate_djo_features.R || exit 1
	Rscript analysis/gs_vs_dig_jc_comparison.R || exit 1

plots:
	Rscript figures/plot_bland_altman_figures.R || exit 1
	Rscript figures/run_djo_model_and_figures.R || exit 1
	Rscript figures/plot_djo_boxplot_prediction.R || exit 1
