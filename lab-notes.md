# 2020-03-07
## UNIDO
Explore wholes in sectoral UNIDO data. Sector 37 is almost always missing, merge with sector 36. There are 46 countries with only one cell missing (either value added or gross output, in one year in one sector). This we can interpolate.

Gross output numbers look fishy in
* BWA, 2010
* BEL, 2010-2011
* KGZ, 2014-

Value added numbers look fishy in
* BEL, 2010-2011
* SWE, 2011
* KGZ, 2014-

## Correspondance between SITC and ISIC
ISIC3.1 used in UNIDO: https://unstats.un.org/unsd/classifications/Econ/ISIC#ISIC3
can be converted to CPC1.1 via https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC31_CPCv11/ISIC31-CPC11-correspondence.txt

SITC4 (used since 2006) can be coverted to CPC2 using https://unstats.un.org/unsd/classifications/Econ/tables/CPC/CPCv2_SITC4/CPCv2_SITCr4.txt (partial conversion)

CPC2 can be converted to ISIC4 using https://unstats.un.org/unsd/classifications/Econ/tables/CPC/CPCv2_ISIC4/CPC2-ISIC4.txt

At the "group" (3-digit level), 86% of detailed SITC does belong to the same 2-digit ISIC sector. With value weighting, this is probably even higher.

# 2020-04-02
## Explore Oxford data on Covid-19 restrictions
https://www.bsg.ox.ac.uk/research/research-projects/oxford-covid-19-government-response-tracker
