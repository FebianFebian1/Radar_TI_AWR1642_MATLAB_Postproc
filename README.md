# Radar_Object_Detection
A 4th-year project on sensor combination of Radar, Lidar and Camera for Autonomous Vehicle (AV) imaging systems. This repository contains the code for the post-processing of Radar Data using MATLAB.
The radar module used is Texas Instrument TI AWR1642 using capture module DCA1000EVM

The main file for running the code and functions will be operating.m
The parameter used in mmWaveStudio is shown below. Any changes in parameter require manual adjustment in input parameter in operating.m

![Parameter](https://user-images.githubusercontent.com/51969569/221611035-aa957233-2c2b-41f5-bcfc-855ea8cc340d.png)

The wave/frame parameter is:
1. No of Chirp Loops = 200
2. Periodicity = 50ms
3. PRF = 200/50ms = 4000
4. Duty Cycle = 80%


Processing Algorithm Outline:
1. Reading the binary file at the directed folder and name (ReadDCA1000.m)
2. DataMatrix is produced and get into SignalProcess.m function
3. Normalisation, Tapering of the signal respectively
4. MTI Filter is applied
5. 1st order fft is applied to get Range vs time profile
6. CPI is conducted with 'r' variable to determine the width
7. 2nd order fft over the cpi range is applied to get Doppler vs range profile
8. 2D-CFAR algorithm was created and used to thresholding the signal (cfarFunction.m)
9. Then, automated reading was conducted to get a 1-to-1 value of time vs range and time vs velocity
10. The array is saved as distance, velocity, time_frame in a AutoRes.mat file.


