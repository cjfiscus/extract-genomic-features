#!/usr/bin/python3

## Define Promoters
## cjfiscus
## 4/10/2018

import sys

## Input should be 5'UTRs subsetted from gff 
File=open(sys.argv[1])

for Line in File:
    ## string processing
    parts=Line.split("\t")

    parts[4] = parts[3] # start moves to end of feature 
    parts[3] = str(int(parts[4]) - 2000) # promoter defined as 2KB upstream of start of 5'UTR

    parts[2]=parts[2].replace("five_prime_UTR", "promoter")
    parts[8]=parts[8].replace("five_prime_UTR", "promoter").strip("\n")

    out="\t".join(parts)
    print(out)

