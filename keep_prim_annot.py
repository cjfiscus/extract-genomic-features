#!/usr/bin/python3

## Keep Primary Annotations
## cjfiscus
## 4/10/2018

import sys

File=open(sys.argv[1])

for Line in File:
    ## string processing
    parts=Line.split("\t")
    check=parts[8].split(";")[1].strip("Parent=").split(".")[1]

    if check == str(1):
        ## keep line
        print(Line.strip("\n"))
