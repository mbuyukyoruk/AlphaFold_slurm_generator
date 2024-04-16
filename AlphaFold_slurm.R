### Generate Slurm script for AlphaFold Predictions on Tempest

rm(list=ls())

### Initial setup
# Navigate to home folder
  # cd ~
# Make AlphaFold data folder
  # mkdir AlphaFold
# Add subdirectories
  # mkdir AlphaFold/fasta
  # mkdir AlphaFold/models
  # mkdir AlphaFold/scripts
  # mkdir AlphaFold/logs

###########################################################################

#### Get user input on needed fields #### 
options <- commandArgs(trailingOnly = TRUE)

protein.id <- options[1]
protein.id <- gsub(" ", "_", protein.id)

fasta.name <- options[2]

multi <- options[3]
multi <- substr(tolower(multi), 1, 1)

email <- options[4]

netid <- options[5]
netid <- tolower(netid)

# Add time value
now <- as.character(Sys.time())
now <- strsplit(now, " ")[[1]]
datez <- now[1]
time <- now[2]
time <- gsub(":", ".", time)

id <- paste0(protein.id, "_AF_", datez, "_", time)

######################################
######### Monomer prediction ######### 
######################################

if(!multi == "y") {

slurm <- as.character(paste0("#!/bin/bash
#SBATCH --account=priority-blakewiedenheft	# account name
#SBATCH --job-name=", id, "          # job name
#SBATCH --partition=gpupriority         # queue partition to run the job in
#SBATCH --nodes=1                       # number of nodes to allocate
#SBATCH --ntasks-per-node=1             # number of descrete tasks - keep at one except for MPI
#SBATCH --cpus-per-task=14		# number of cores to allocate - do not allocate more than 16 cores per GPU
#SBATCH --gpus-per-task=1		# number of GPUs to allocate - all GPUs are currently A40 model
#SBATCH --mem=80G                     # 2000 MB of Memory allocated - do not allocate more than 128000 MB mem per GPU
#SBATCH --time=0-08:00:00               # Maximum job run time
#SBATCH --output=/home/", netid,"/AlphaFold/logs/", id, "-%j.out # standard output file (%j = jobid)
#SBATCH --error=/home/", netid,"/AlphaFold/logs/", id, "-%j.err	# standard error file
#SBATCH --mail-user=", email, "	# email address to recieve job updates
#SBATCH --mail-type=ALL
singularity run -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/):/data \\
                -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/bfd):/data/bfd \\
                -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/mgnify):/data/mgnify \\
                -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/pdb70):/data/pdb70 \\
                -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/uniclust30):/data/uniclust30 \\
                -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/uniref90):/data/uniref90 \\
--env TF_FORCE_UNIFIED_MEMORY=1,XLA_PYTHON_CLIENT_MEM_FRACTION=4.0,OPENMM_CPU_THREADS=14 --pwd /app/alphafold --nv /home/group/blakewiedenheft/software/alphafold_latest.sif \\
--fasta_paths /home/", netid,"/AlphaFold/fasta/", fasta.name, " \\
--output_dir  /home/", netid,"/AlphaFold/models/ \\
--data_dir /data \\
--bfd_database_path /data/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \\
--uniref90_database_path /data/uniref90/uniref90.fasta \\
--uniclust30_database_path /data/uniclust30/uniclust30_2018_08/uniclust30_2018_08 \\
--mgnify_database_path /data/mgnify/mgy_clusters_2018_12.fa \\
--pdb70_database_path /data/pdb70/pdb70 \\
--template_mmcif_dir /data/pdb_mmcif/mmcif_files \\
--obsolete_pdbs_path /data/pdb_mmcif/obsolete.dat \\
--max_template_date=2021-07-28 \\
--use_gpu_relax
"))

}

#######################################
######### Multimer prediction ######### 
#######################################


if(multi == "y") {
  
  
  cat("\n")
  cat("***Input fasta should contain all sequences to be predicted***\n")
  cat("\n")
  
  slurm <- as.character(paste0("#!/bin/bash
#SBATCH --account=priority-blakewiedenheft	# account name
#SBATCH --job-name=", id, "          # job name
#SBATCH --partition=gpupriority         # queue partition to run the job in
#SBATCH --nodes=1                       # number of nodes to allocate
#SBATCH --ntasks-per-node=1             # number of descrete tasks - keep at one except for MPI
#SBATCH --cpus-per-task=14		# number of cores to allocate - do not allocate more than 16 cores per GPU
#SBATCH --gpus-per-task=1		# number of GPUs to allocate - all GPUs are currently A40 model
#SBATCH --mem=100G                     # 2000 MB of Memory allocated - do not allocate more than 128000 MB mem per GPU
#SBATCH --time=3-00:00:00               # Maximum job run time
#SBATCH --output=/home/", netid,"/AlphaFold/logs/", id, "-%j.out # standard output file (%j = jobid)
#SBATCH --error=/home/", netid,"/AlphaFold/logs/", id, "-%j.err	# standard error file
#SBATCH --mail-user=", email, "	# email address to recieve job updates
#SBATCH --mail-type=ALL
singularity run -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/):/data \\
                -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/bfd):/data/bfd \\
                -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/mgnify):/data/mgnify \\
                -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/pdb70):/data/pdb70 \\
                -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/uniclust30):/data/uniclust30 \\
                -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/uniref90):/data/uniref90 \\
                -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/pdb_seqres):/data/pdb_seqres \\
                -B $(realpath /home/group/blakewiedenheft/AlphaFold_databases/uniprot):/data/uniprot \\
--env TF_FORCE_UNIFIED_MEMORY=1,XLA_PYTHON_CLIENT_MEM_FRACTION=4.0,OPENMM_CPU_THREADS=14 --pwd /app/alphafold --nv /home/group/blakewiedenheft/software/alphafold_latest.sif \\
--fasta_paths /home/", netid,"/AlphaFold/fasta/", fasta.name, " \\
--output_dir  /home/", netid,"/AlphaFold/models/ \\
--data_dir /data \\
--bfd_database_path /data/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \\
--uniref90_database_path /data/uniref90/uniref90.fasta \\
--uniclust30_database_path /data/uniclust30/uniclust30_2018_08/uniclust30_2018_08 \\
--pdb_seqres_database_path /data/pdb_seqres/pdb_seqres.txt \\
--mgnify_database_path /data/mgnify/mgy_clusters_2018_12.fa \\
--uniprot_database_path /data/uniprot/uniprot.fasta \\
--template_mmcif_dir /data/pdb_mmcif/mmcif_files \\
--obsolete_pdbs_path /data/pdb_mmcif/obsolete.dat \\
--is_prokaryote_list=true \\
--model_preset=multimer \\
--max_template_date=2021-11-01 \\
--use_gpu_relax
"))
  
}



#######################################
############ Script Output ############ 
#######################################

writeChar(slurm, "temp.txt")
system(paste0("sed '$d' temp.txt > ./", id, ".sbatch"))
system("rm temp.txt")
system(paste0("chmod +x ./", id, ".sbatch"))

cat("\n")
cat("------------------------------------------------")
cat("\n")
cat("Success!\n")
cat("\n")
cat(paste0("Slurm script output = ", id, ".sbatch \n"))
cat("***Use GLOBUS to transfer Slurm script to AlphaFold/scripts/ on Tempest***\n")
cat(paste0("FASTA file = ", fasta.name, "\n"))
cat("***Use GLOBUS to transfer FASTA file to AlphaFold/fasta/ on Tempest***\n")
cat("\n")
cat("\n")
cat("Start prediction by entering the following command on tempest:")
cat(paste0("\t sbatch ", id, ".sbatch"))
cat("\n")
cat(paste0("Progress updates will be sent to ", email, "\n"))
cat("\n")


