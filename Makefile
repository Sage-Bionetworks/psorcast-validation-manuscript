all:
	update logs manuscript_rerun

update:
	git pull

logs:
	mkdir logs
	
authenticate:
	Rscript utils/authenticate.R ${PARAMS}
	
project:
	. env/bin/activate && python3 synapseformation/create_project.py

manuscript_rerun:
	Rscript feature_extraction/PPACMAN_features.R || exit 1
	Rscript feature_extraction/get_visit_summary.R || exit 1
	sleep 300s
	Rscript feature_extraction/psoriasis_draw_bsa_features.R || exit 1
	Rscript feature_extraction/digitalJarOpen_rotation_features.R || exit 1
	Rscript feature_extraction/jointSummaries_features.R || exit 1
	sleep 300s
	Rscript feature_extraction/psorcast_merged_features.R || exit 1
	sleep 300s
	Rscript analysis/curate_djo_features.R || exit 1
	Rscript analysis/gs_vs_dig_jc_comparison.R || exit 1
	Rscript analysis/get_joint_summary.R || exit 1
	Rscript figures/plot_bland_altman_figures.R || exit 1
	Rscript figures/run_djo_model_and_figures.R || exit 1
	sleep 300s
	Rscript figures/plot_djo_boxplot_prediction.R || exit 1