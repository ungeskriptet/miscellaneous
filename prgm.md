
## My personal programs for the TI-82 Stats calculator

```
/*
* Your warranty is now void.
*
* I am not responsible for bricked devices, flat batteries,
* thermonuclear war, or you getting trouble from your teacher because you couldn't. 
* calculate the inverse function of y=2^(2-x)-3. Please do some research if you have
* any concerns about features included in these programs before running them! YOU are
* choosing to run these programs, and if you point the finger at me for messing up
* your device, I will laugh at you.
*/
```
***
#### **Program name:** `prgmSLEEP`
**Description:** Makes the calculator wait.\
**Usage:** Set the variable `J` to a desired positive integer. 1 `J` value is roughly 1 second.\
**Source:** http://celtickane.com/labs/ti-83-delay-temporary-pause-during-a-program
```
0➔I
J*65➔J
While J≥I
I+1➔I
End
```
***
#### **Program name:** `prgmTTY`
**Description:** Nothing more than a blinking cursor.\
**Usage:** Set the variable `B` to a desired positive integer for the number of blinks.\
**Dependencies:** `prgmSLEEP`
```
ClrHome
For(A,1,B
Output(1,1,"-
.45➔J
prgmSLEEP
Output(1,1," 
.45➔J
prgmSLEEP
End
```
***
#### **Program name:** `prgmPASSWD`
**Description:** A *very secure* password prompt.
```
Lbl D
Input "PASSWORD: ",S
While S≠290106
Disp "PASSWORD WRONG
Goto D
```
***
#### **Program name:** `prgmPMOS`
**Description:** *Real* postmarketOS on your calculator!\
**Dependencies:** `prgmSLEEP`, `prgmTTY`, `prgmPASSWD`
```
ExprOff
AxesOff
CordOff
DelVar Y1
ClrDraw
ClrHome
Disp "U-BOOT LOADING..
3➔J
prgmSLEEP
3➔B
prgmTTY
RecallPic 7
5➔J
prgmSLEEP
DISP "UDHCP     [ OK ]
.9➔J
prgmSLEEP
DISP "SSHD      [ OK ]
.9➔J
prgmSLEEP
Disp "GETTY     [ OK ]
.9➔J
prgmSLEEP
Disp "LINUX 5.14-PMOS
randInt(1,30➔G
0➔R
Lbl E
Input "LOGIN :",Str1
If Str1≠"TI
Then
Disp "INCORRECT
Goto E
Else
prgmPASSWD
Disp "TYPE HLP FOR CMD
Lbl C
If R=0
Then
Input "> ",Str1
Else
Input "[*]> ",Str1
End
If Str1="SCRSVR
Then
ClrDraw
0➔Z
Lbl V
randInt(⁻10,10➔A
randInt(⁻10,10➔B
randInt(⁻10,10➔C
randInt(⁻10,10➔D
randInt(⁻10,10➔E
randInt(⁻10,10➔F
randInt(⁻5,5➔G
randInt(0,5➔Y
If Y=0
Then
Circle(E,F,G
Else
Line(A,B,C,D
End
If Z=50
Goto C
1+Z➔Z
Goto V
Else
If Str1="FETCH
Then
ClrHome
Disp "=== = OS: PMOS
Disp " =  = prgm:
Output(2,13,randInt(1,10
Disp " =  = CPU: Z80
Goto C
Else
If Str1="SU
Then
If R=1
Then
Disp "ALREADY ROOT
Goto C
End
prgmPASSWD
1➔R
1➔J
prgmSLEEP
Goto C
Else
If Str1="UNSU
Then
If R=0
Then
Disp "ALREADY NON-ROOT
Goto C
End
0➔R
Goto C
Else
If Str1="LS
Then
DISP "/ETC /USR /BIN
Goto C
Else
If Str1="UWU
Then
Disp "OWO
Goto C
Else
If Str1="CLS
Then
ClrHome
Goto C
Else
If Str1="REBOOT
Then
prgmPMOS
Else
If Str1="HLP
Then
Disp "REBOOT UWU APK
Disp "SU UNSU RNDM
Disp "RM PWD FETCH
Goto C
Else
If Str1="APK
Then
If G=0
Then
Disp "ALREADY UPDATED
Goto C
End
Disp "SYNCING DATABASE
randInt(0,5➔J
prgmSLEEP
Disp G,"UPDATES FOUND
Disp "UPDATE? (Y/N)
Input "≤ ",F
If F≠Y
Then
Disp "CANCELLED
Goto C
End
Disp "UPDATING...
randInt(0,5➔J
prgmSLEEP
0➔G
Goto C
Else
If Str1="EXIT
Then
Stop
Else
If Str1="RM
Then
If R=0
Then
Disp "PREMISS. DENIED
Goto C
End
Disp "ERROR:
Disp "KERNEL PANIC
3➔J
prgmSLEEP
ClrHome
0➔M
Lbl A
M+1➔M
randInt(0,1➔T
randInt(1,8➔R
randInt(1,16➔C
Output(R,C,T
If M=30
Then
ClrHome
Disp "- NOT SYNCING -
Stop
End
Goto A
Else
If Str1="RNDM
Then
Input "MIN= ",A
Input "MAX= ",B
Disp randInt(A,B
Goto C
Else
If Str1="PWD
Then
If R=1
Then
Disp "/ROOT
Goto C
End
Disp "/HOME/TI
Goto C
Else
Disp Str1
Disp "NOT FOUND
Goto C
```
