choice=$(zenity --entry --text="1. Quality

2. pseudo Alignment

3. Deseq

4. David enrichment Analysis

5. Plot

Please enter your choice" --width=400 --title "Analysis")

if [ $choice -lt 1 ] || [ $choice -gt 5 ]; then
zenity --warning --text="Invalid choice" --no-wrap
else


if [ $choice = 1 ]; then


quality=$(zenity --entry --text="1. Create fastQC

2. View FastQC

3. Shuffle

4. Extract Data from the middle

Please enter your choice" --width=400 --title "Quality")

if [ $quality = 1 ]; then
notify-send "FastQC" "Please wait until it is downloaded"
sudo apt install fastqc



fastq_folder=$(zenity --file-selection --title="Choose the directory which have the fastq files" --directory)
notify-send "FastQC" "Please wait until it is done"
for f in $fastq_folder/*.fastq.gz;do fastqc -t 1 -f fastq -noextract $f; done


elif [ $quality = 2 ]; then

fastqc_html=$(zenity --file-selection --title="Select the fastqc report you want to view" --file-filter="*.html")

firefox $fastqc_html


elif [ $quality = 3 ]; then
conda install -y seqkit

fastq_folder=$(zenity --file-selection --title="Choose the directory which have the fastq files" --directory)
notify-send "Shuffling" "Please wait, Shuffling is in progress"
for f in $fastq_folder/*.fastq.gz;do seqkit shuffle $f; done



elif [ $quality = 4 ]; then

from=$(zenity --entry --text="From:" --width=400 --title "Extract Data")
to=$(zenity --entry --text="To:" --width=400 --title "Extract Data")

notify-send "Extracting" "Please wait.."

esearch -db sra -query PRJNA714081 | efetch -format runinfo | cut -d "," -f 1 | grep SRR | xargs fastq-dump -N $from -X $to --skip-technical --read-filter pass --gzip


else
zenity --warning --text="Invalid choice" --no-wrap

fi # end of quality 

fi #end of choice 1
##########################################################################3
if [ $choice = 2 ]; then

fastq_folder=$(zenity --file-selection --title="Choose the directory which have the fastq files" --directory)

transcriptome_file=$(zenity --file-selection --title="Select a transcriptome file for indexing" --file-filter="*.idx")
notify-send "Kallisto" "Please wait until it is downloaded"
conda install -c bioconda -y kallisto


kallisto index -i $transcriptome_file -k 25 gencode.v29.pc_transcripts.chr22.simplified.fa

mkdir -p outputs
notify-send "Kallisto" "Alignment is in progress"
for i in $fastq_folder/*.fastq.gz; do kallisto quant -i $transcriptome_file --single -l 200 -s 20 -o outputs/${i:57:25} "$i" --pseudobam; done

fi #end of choice 2
#####################################################################
if [ $choice = 3 ]; then
notify-send "Kallisto" "Please wait while R is downloading"
sudo apt-get install r-base


h5_folder=$(zenity --file-selection --title="Choose the directory which have the h5 files" --directory)

metadata_file=$(zenity --file-selection --title="Select the metadata file" --file-filter="*.txt")

notify-send "Kallisto" "Alignment is in progress"
Rscript deseq.R $h5_folder $metadata_file --save


fi #end choice 3
#####################################################################
if [ $choice = 4 ]; then
touch genes.txt


genes_file=$(zenity --file-selection --title="choose the file to copy genes" --file-filter="*.csv")

cat $genes_file | cut -d, -f1 > genes.txt

zenity --text-info --width=700 --height=700 --title="Copy the genes to use them in david" --filename=genes.txt

firefox https://david.ncifcrf.gov/tools.jsp

fi #end choice 4
#####################################################################
if [ $choice = 5 ]; then
file1=$(zenity --file-selection --title="Select the 1st file to plot" --file-filter="*.xlsx")

file2=$(zenity --file-selection --title="Select the 2nd file to plot" --file-filter="*.xlsx")

plot=$(zenity --entry --text="1. Circle

2. Chord

3. Heatmap

Please enter your choice" --width=400 --title "Plot")
if [ $plot = 1 ]; then
Rscript circle_plot.R $file1 $file2 --save
elif [ $plot = 2 ]; then
Rscript chord_plot.R $file1 $file2 --save
elif [ $plot = 3 ]; then
Rscript heatmap_plot.R $file1 $file2 --save
fi #end plot


fi #end choice 5
fi #end of main if 
