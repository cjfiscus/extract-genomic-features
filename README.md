# extract-genomic-features
Quick and dirty pipeline to extra genomic features from *Arabidopsis thaliana* genome. Easily adaptable to other genomes given genome assembly and .gff annotation.

## Scripts
### gff_to_fasta.sh
Downloads *A. thaliana* genome and annotation, produces fasta files containing CDS, 5' UTRs, 3' UTRs, intergenic seqs, promoters, and introns.

### keep_prim_annot.py
Python 3 script to subset "primary annotations, which are roughly defined as gene models with .1 (e.g. AT1G01010.1 considered primary, AT1G01010.2 as secondary).  

### define_promoters.py 
Python 3 script to export putative promoter regions defined as 2KB upstream of transcription start site (start of 5' UTR). 
