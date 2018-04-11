#!/bin/bash

## Extract genomic features from Arabidopsis thaliana genome 
## Produces fasta files containing CDS, 5' UTRs, 3' UTRs, intergenic seqs, promoters, and introns. 

## requires samtools 1.7 and bedtools v2.27.1

## download genome annotation
wget https://www.arabidopsis.org/download_files/Genes/Araport11_genome_release/Araport11_GFF3_genes_transposons.201606.gff.gz
gunzip Araport11_GFF3_genes_transposons.201606.gff.gz

## download reference genome and generate bed format (for exporting sequences)
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-38/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
gunzip Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
samtools faidx Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
awk 'BEGIN {FS="\t"}; {print $1 FS $2}' Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.fai | grep -vE "Mt|Pt" > genome.bed
sed 's/^/Chr/' genome.bed > genome2.bed && mv genome2.bed genome.bed

## isolate 3'UTR, 5'UCR, CDS and exclude chloroplast and mitochondrial genes and other annotations 
grep -E 'CDS|three_prime_UTR|five_prime_UTR' Araport11_GFF3_genes_transposons.201606.gff | grep -vE 'ChrC|ChrM|exon|gene|mRNA' > CDS_UTRs.gff

## only keep primary annotations 
python keep_prim_annot.py CDS_UTRs.gff > CDS_UTRs_primary.gff

## isolate CDS
grep "CDS" CDS_UTRs_primary.gff | sort -k1,1 -k4n,4n | sed 's/Chr//' > CDS_sorted.gff
bedtools getfasta -fi Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -bed CDS_sorted.gff > CDS.fasta

## isolate 5'UTRs and 3'UTRs
grep "three_prime_UTR" CDS_UTRs_primary.gff | sort -k1,1 -k4n,4n | sed 's/Chr//' > three_prime_UTR_sorted.gff
bedtools getfasta -fi Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -bed three_prime_UTR_sorted.gff > three_prime_UTR.fasta


grep "five_prime_UTR" CDS_UTRs_primary.gff | sort -k1,1 -k4n,4n | sed 's/Chr//' > five_prime_UTR_sorted.gff
bedtools getfasta -fi Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -bed five_prime_UTR_sorted.gff > five_prime_UTR.fasta

## define promoters at 2KB upstream of TSS
python define_promoters.py five_prime_UTR_sorted.gff | sort -k1,1 -k4n,4n | sed 's/Chr//' > promoters_sorted.gff
bedtools getfasta -fi Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -bed promoters_sorted.gff > promoters.fasta

## extract intergenic regions
awk '$3 == "gene" {print}' Araport11_GFF3_genes_transposons.201606.gff | grep -vE 'ChrC|ChrM|mRNA' | sort -k1,1 -k4n,4n > genes_sorted.gff
bedtools complement -i genes_sorted.gff -g genome.bed |sed 's/Chr//' > targets.bed
bedtools getfasta -fi Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -bed targets.bed > intergenic.fasta

## extract introns 
sort -k1,1 -k4n,4n CDS_UTRs_primary.gff > CDS_UTRs_primary_sorted.gff. ## CDS
bedtools complement -i CDS_UTRs_primary_sorted.gff -g genome.bed > targets.bed ## regions not in CDS
bedtools intersect -a targets.bed -b genes_sorted.gff |sed 's/Chr//' > introns.bed ## intersect regions not in CDS and within genes (introns)
bedtools getfasta -fi Arabidopsis_thaliana.TAIR10.dna.toplevel.fa -bed introns.bed > introns.fasta
