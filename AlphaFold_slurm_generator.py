import os
import subprocess
import sys
import argparse
import re
import textwrap

try:
    from Bio import SeqIO
except:
    print("SeqIO module is not installed! Please install SeqIO and try again.")
    sys.exit()

try:
    import tqdm
except:
    print("tqdm module is not installed! Please install tqdm and try again.")
    sys.exit()

orig_stdout = sys.stdout

parser = argparse.ArgumentParser(prog='python AlphaFold_slurm_generator.py',
      formatter_class=argparse.RawDescriptionHelpFormatter,
      epilog=textwrap.dedent('''\

# AlphaFold_slurm_generator

Author: Murat Buyukyoruk

        AlphaFold_slurm_generator help:

This script is developed to generate sbatch files to submit AlphaFold runs on MSU Tempest server.

SeqIO package from Bio is required to to split multifasta to individual files if the multimer option is turned off. Additionally, tqdm is required to provide a progress bar since some multifasta files can contain long and many sequences.
        
Syntax:

        python AlphaFold_slurm_generator.py -a all -m No -e email@msu.montana.edu -n NetID
        
        python AlphaFold_slurm_generator.py -i demo.fasta -m Yes -e email@msu.montana.edu -n NetID

AlphaFold_slurm_generator dependencies:

	Bio module and SeqIO available in this package          refer to https://biopython.org/wiki/Download
	tqdm                                                    refer to https://pypi.org/project/tqdm/
	
Input Paramaters (REQUIRED):
----------------------------
	-i/--input		FASTA			Specify a fasta file.
	
	-a/--all		FASTA			Type all if you would like to import all fasta files available in the current directory.
	
	-m/--multimer   model           Yes or No for multimer AlphaFold prediction.
	
	-e/--email      email           E-mail address to send job notifications.
	
	-n/--netid      netid           NetID to set path to file locations on Tempest.

Basic Options:
--------------
	-h/--help		HELP			Shows this help text and exits the run.
	
      	'''))
parser.add_argument('-i', '--input', required=False, type=str, dest='filename', default="non_provided",
                    help='Specify a original fasta file.\n')
parser.add_argument('-a', '--all', required=False, type=str, dest='all', default="non_provided",
                    help='Type all if you would like to import all fasta files available in the current directory.\n')
parser.add_argument('-m', '--multimer', required=False, type=str, dest='model', default= "No",
                    help='Yes or No for multimer AlphaFold prediction.\n')
parser.add_argument('-e', '--email', required=True, type=str, dest='email',
                    help='E-mail address to send job notifications.\n')
parser.add_argument('-n', '--netid', required=True, type=str, dest='netid',
                    help='NetID to set path to file locations on Tempest.\n')

results = parser.parse_args()
filename = results.filename
all = results.all
model = results.model
email = results.email
netid = results.netid

wd = os.getcwd()

filenames = []

if all.lower() not in ["all", "a", "non_provided"]:
    print(all + " is not accepted as -a/--all option please use -a all, -a All, -a ALL, -a A or -a a.")
    sys.exit()

if all == "non_provided" and filename == "non_provided":
    print("Please provide infput fasta or use -a option to import all fasta files in the current directory.")
    sys.exit()

if all == "non_provided":
    proc = subprocess.Popen("grep -c '>' " + filename, shell=True, stdout=subprocess.PIPE, text=True)
    length = int(proc.communicate()[0].split('\n')[0])

    if length == 1:
        filenames.append(filename)

    else:
        if model.lower() in ["no", "n"]:
            with tqdm.tqdm(range(length)) as pbar:
                pbar.set_description('Spliting fasta...')
                for record in SeqIO.parse(filename, "fasta"):
                    pbar.update()
                    out = filename.split(".fasta")[0] + "_" + record.id.replace("*","_prime") + ".fasta"
                    os.system("> " + out)
                    f = open(out, 'a')
                    sys.stdout = f
                    print(">" + record.description)
                    print(re.sub("(.{60})", "\\1\n", str(record.seq).replace("*",""), 0, re.DOTALL))

            try:
                os.mkdir("original")
            except:
                pass
            os.system("mv " + filename + " original/")

            sys.stdout = orig_stdout

            workdir = os.path.abspath(os.getcwd())

            for file in os.listdir(workdir):
                if file.endswith(".fasta"):
                    filenames.append(file)

            filenames.sort()
        elif model.lower() in ["yes", "y"]:
            print("Using the input file and applying multimer model setup! This script assumes that the sequences in file are subunits of a multimer.")
            filenames.append(filename)

if all != "non_provided":
    workdir = os.path.abspath(os.getcwd())

    for file in os.listdir(workdir):
        if file.endswith(".fasta"):
            filenames.append(file)
    if len(filenames) == 0:
        print("No fasta file available in the current directory!")
        sys.exit()
    else:
        filenames.sort()

    filenames_multi = []

    for l in range(len(filenames)):

        proc_sub = subprocess.Popen("grep -c '>' " + filenames[l], shell=True, stdout=subprocess.PIPE, text=True)
        length = int(proc_sub.communicate()[0].split('\n')[0])

        if length == 1:
            filenames_multi.append(filenames[l])

        else:
            if model.lower() in ["no", "n"]:
                with tqdm.tqdm(range(length)) as pbar:
                    pbar.set_description('Spliting fasta...')
                    for record in SeqIO.parse(filenames[l], "fasta"):
                        pbar.update()
                        out = filenames[l].split(".fasta")[0] + "_" + record.id.replace("*", "_prime") + ".fasta"
                        os.system("> " + out)
                        f = open(out, 'a')
                        sys.stdout = f
                        print(">" + record.description)
                        print(re.sub("(.{60})", "\\1\n", str(record.seq).replace("*", ""), 0, re.DOTALL))

                try:
                    os.mkdir("original")
                except:
                    pass
                os.system("mv " + filenames[l] + " original/")

                sys.stdout = orig_stdout

                workdir = os.path.abspath(os.getcwd())

                for file in os.listdir(workdir):
                    if file.endswith(".fasta"):
                        filenames_multi.append(file)
                        if filenames[l] in filenames_multi:
                            filenames_multi.remove(filenames[l])

            elif model.lower() in ["yes", "y"]:
                print("Using the input file and applying multimer model setup! This script assumes that the sequences in file are subunits of a multimer.")
                filenames_multi.append(filenames[l])
    if len(filenames_multi) != 0:
        res = [i for n, i in enumerate(filenames_multi) if i not in filenames_multi[:n]]
        filenames_multi = res
        filenames_multi.sort()
        filenames = filenames_multi

with tqdm.tqdm(range(len(filenames))) as pbar:
    pbar.set_description('Generating...')
    for i in range(len(filenames)):
        pbar.update()
        if model.lower() in ["no", "n"]:
            subprocess.call("Rscript " + wd + "/AlphaFold_slurm.R " + filenames[i].replace(filename.split(".fasta")[0] + "_","").split(".fasta")[0] + " " + filenames[i] + " No " + email + " " + netid, shell=True)
        elif model.lower() in ["yes", "y"]:
            subprocess.call("Rscript " + wd + "/AlphaFold_slurm.R " + filenames[i].replace(filename.split(".fasta")[0] + "_","").split(".fasta")[0] + " " + filenames[i] + " Yes " + email + " " + netid, shell=True)

print('\x1b[1;34;42m' + 'Success! Move .fasta files to /AlphaFold/fasta and .sbatch files to /AlphaFold/scripts on Tempest!' + '\x1b[0m' + '\n')

print('\x1b[1;34;42m' +'for i in *.sbatch; do sbatch "$i"; done' + '\x1b[0m')
