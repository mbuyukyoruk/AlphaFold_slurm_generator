# AlphaFold_slurm_generator

Author: Murat Buyukyoruk (python), Tanner Wiegand (R)

Associated lab: Wiedenheft lab

        AlphaFold_sbatch_generator help:

This script is developed to generate sbatch files to submit AlphaFold runs on MSU Tempest server.

![alt text](https://github.com/WiedenheftLab/AlphaFold_slurm_generator/blob/main/Screenshot%202023-05-26%20at%2014.06.43.png?raw=true)

![alt text](https://github.com/WiedenheftLab/AlphaFold_slurm_generator/blob/main/Screenshot%202023-05-26%20at%2014.06.52.png?raw=true)

SeqIO package from Bio is required to to split multifasta to individual files if the multimer option is turned off. Additionally, tqdm is required to provide a progress bar since some multifasta files can contain long and many sequences.
        
Syntax:

        python AlphaFold_sbatch_generator.py -a all -m No -e email@msu.montana.edu -n NetID
        
        python AlphaFold_sbatch_generator.py -i demo.fasta -m Yes -e email@msu.montana.edu -n NetID

AlphaFold_sbatch_generator dependencies:

	Bio module and SeqIO available in this package          refer to https://biopython.org/wiki/Download
	tqdm                                                    refer to https://pypi.org/project/tqdm/
	
Input Paramaters (REQUIRED):
----------------------------
	-i/--input		FASTA		   Specify a fasta file.
	
	-a/--all		FASTA		   Type all if you would like to import all fasta files available in the current directory.
	
	-m/--multimer   	model	           Yes or No for multimer AlphaFold prediction.
	
	-e/--email      	email	           E-mail address to send job notifications.
	
	-n/--netid      	netid	           NetID to set path to file locations on Tempest.

Basic Options:
--------------
	-h/--help		HELP		   Shows this help text and exits the run.
	
