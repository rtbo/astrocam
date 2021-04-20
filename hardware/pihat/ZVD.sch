EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 3 3
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Astrocam:DMG2305UX Q?
U 1 1 5EBD3BAA
P 4000 3900
AR Path="/5EBD1287/5EBD3BAA" Ref="Q?"  Part="1" 
AR Path="/5EBB2A08/5EBBD401/5EBD3BAA" Ref="Q?"  Part="1" 
AR Path="/5EBD3BAA" Ref="Q?"  Part="1" 
F 0 "Q?" V 4292 3900 50  0000 C CNN
F 1 "DMG2305UX" V 4201 3900 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23" H 4000 3900 50  0001 C CNN
F 3 "" H 4000 3900 50  0001 C CNN
	1    4000 3900
	0    -1   -1   0   
$EndComp
$Comp
L Astrocam:DMMT5401 Q?
U 1 1 5EBD9F45
P 3450 4550
AR Path="/5EBD1287/5EBD9F45" Ref="Q?"  Part="1" 
AR Path="/5EBB2A08/5EBBD401/5EBD9F45" Ref="Q?"  Part="1" 
AR Path="/5EBD9F45" Ref="Q?"  Part="1" 
F 0 "Q?" H 3591 4504 50  0000 L CNN
F 1 "DMMT5401" H 3591 4595 50  0000 L CNN
F 2 "Package_TO_SOT_SMD:SOT-23-6" H 3500 4550 50  0001 C CNN
F 3 "" H 3500 4550 50  0001 C CNN
	1    3450 4550
	-1   0    0    1   
$EndComp
$Comp
L Astrocam:DMMT5401 Q?
U 1 1 5EBDA82D
P 4550 4550
AR Path="/5EBD1287/5EBDA82D" Ref="Q?"  Part="2" 
AR Path="/5EBB2A08/5EBBD401/5EBDA82D" Ref="Q?"  Part="1" 
AR Path="/5EBDA82D" Ref="Q?"  Part="2" 
F 0 "Q?" H 4691 4504 50  0000 L CNN
F 1 "DMMT5401" H 4691 4595 50  0000 L CNN
F 2 "Package_TO_SOT_SMD:SOT-23-6" H 4600 4550 50  0001 C CNN
F 3 "" H 4600 4550 50  0001 C CNN
	1    4550 4550
	1    0    0    1   
$EndComp
$Comp
L Device:R R?
U 1 1 5EBDB333
P 3400 5150
AR Path="/5EBD1287/5EBDB333" Ref="R?"  Part="1" 
AR Path="/5EBB2A08/5EBBD401/5EBDB333" Ref="R?"  Part="1" 
F 0 "R?" H 3470 5196 50  0000 L CNN
F 1 "R" H 3470 5105 50  0000 L CNN
F 2 "" V 3330 5150 50  0001 C CNN
F 3 "~" H 3400 5150 50  0001 C CNN
	1    3400 5150
	1    0    0    -1  
$EndComp
$Comp
L Device:R R?
U 1 1 5EBDB399
P 4600 5150
AR Path="/5EBD1287/5EBDB399" Ref="R?"  Part="1" 
AR Path="/5EBB2A08/5EBBD401/5EBDB399" Ref="R?"  Part="1" 
F 0 "R?" H 4670 5196 50  0000 L CNN
F 1 "R" H 4670 5105 50  0000 L CNN
F 2 "" V 4530 5150 50  0001 C CNN
F 3 "~" H 4600 5150 50  0001 C CNN
	1    4600 5150
	1    0    0    -1  
$EndComp
Wire Wire Line
	4000 4150 4000 4900
Wire Wire Line
	4000 4900 4600 4900
Wire Wire Line
	4600 4900 4600 5000
Wire Wire Line
	4600 4750 4600 4900
Connection ~ 4600 4900
Wire Wire Line
	4300 4550 4150 4550
Wire Wire Line
	4150 4550 4150 4850
Wire Wire Line
	4150 4850 3700 4850
Wire Wire Line
	3700 4850 3700 4550
Wire Wire Line
	3700 4850 3400 4850
Wire Wire Line
	3400 4850 3400 5000
Connection ~ 3700 4850
Wire Wire Line
	3400 4750 3400 4850
Connection ~ 3400 4850
Wire Wire Line
	3400 4350 3400 3850
Wire Wire Line
	3400 3850 3800 3850
Wire Wire Line
	4200 3850 4600 3850
Wire Wire Line
	4600 3850 4600 4350
$Comp
L power:GND #PWR?
U 1 1 5EBDCF25
P 4000 5650
AR Path="/5EBD1287/5EBDCF25" Ref="#PWR?"  Part="1" 
AR Path="/5EBB2A08/5EBBD401/5EBDCF25" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 4000 5400 50  0001 C CNN
F 1 "GND" H 4005 5477 50  0000 C CNN
F 2 "" H 4000 5650 50  0001 C CNN
F 3 "" H 4000 5650 50  0001 C CNN
	1    4000 5650
	1    0    0    -1  
$EndComp
Wire Wire Line
	3400 5300 3400 5500
Wire Wire Line
	3400 5500 4000 5500
Wire Wire Line
	4000 5500 4000 5650
Wire Wire Line
	4000 5500 4600 5500
Wire Wire Line
	4600 5500 4600 5300
Connection ~ 4000 5500
Text HLabel 5050 3850 2    50   Input ~ 0
CA
Text HLabel 2900 3850 0    50   Input ~ 0
AN
Wire Wire Line
	2900 3850 3400 3850
Connection ~ 3400 3850
Wire Wire Line
	4600 3850 5050 3850
Connection ~ 4600 3850
$EndSCHEMATC
