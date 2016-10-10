#!/bin/bash
clear
echo "---------Starting Script---------"
echo
echo "---------Generating Vars---------"
#OUTPUT="OutputFile/"
FILE=output.txt
#echo "---------Making Directories---------"
#mkdir -p OutputFile/
echo "---------Converting---------"
java -Xmx64M -cp "project2/ojdbc6.jar:" project2/TestFakebookOracle > $FILE
echo
echo "---------Finished Script---------"

