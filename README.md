# 802.11b-DCF-Simulation

Files Submitted:
-wifi-dcf.cc
-wifi-phy.cc
-Computation.m
-Report.pdf

Procedure to be followed:

-->Prior to running the code, the source code must be edited for wifi-phy.cc

The attached file wifi-phy.cc must be replaced in the below directory
/home/ee597/ns-3-allinone/ns-3-dev/src/wifi/model

Changes made in file wifi-phy.cc:
SIFS and Slot values were changed to the ones specified in the paper by Bianchi. Lines 1019 and 1020 were changed:
  SetSifs (MicroSeconds (28));
  SetSlot (MicroSeconds (50)); 
  
-->Place the file wifi-dcf.cc in /home/ee597/ns-3-allinone/ns-3-dev/scratch/

Once done, to run the code please use one of the below syntax depending on different cases by varying the datarate and/or nWifi.

./waf --run "scratch/wifi-dcf --datarate=1000000 --nWifi=20 --mincw=1 --maxcw=1023"
./waf --run "scratch/wifi-dcf --datarate=1000000 --nWifi=20 --mincw=63 --maxcw=127"

Note: 
-nWifi represents the number of STA nodes
-Default datamode is DsssRate1Mbps
-Present working directory must be /home/ee597/ns-3-allinone/ns-3-dev


-->In order to set different Datamodes, the lines 61 to 78 must be uncommented and below syntax must be used for throughput calculation.

-For DsssRate1Mbps
./waf --run "scratch/wifi-dcf --datarate=1000000 --nWifi=20 --mincw=1 --maxcw=1023"

-For DsssRate2Mbps
./waf --run "scratch/wifi-dcf --datarate=2000000 --nWifi=20 --mincw=1 --maxcw=1023"

-For DsssRate5_5Mbps
./waf --run "scratch/wifi-dcf --datarate=5500000 --nWifi=20 --mincw=1 --maxcw=1023"

-For DsssRate11Mbps
./waf --run "scratch/wifi-dcf --datarate=11000000 --nWifi=20 --mincw=1 --maxcw=1023"

A similar syntax can be followed for contention window {63,127}
