%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is a MATLAB Algorithm for TI AWR1642 capturing and processing
% AUTHOR: Febian
% Last updated: 13/02/2023

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

tic %Time start measure

%% Setup parameters
prf = 4000; % PRF of waveform
duty_cycle = 0.8; % As decimal
RF_bandwidth = 3.1; % GHz 
isReal = 0; % Set to 1 if real only data,  0 if complex data
numADCSamples = 256; % Number of ADC samples per chirp
numADCBits = 16; % Number of ADC bits per sample
numRX = 4; % Number of receivers used
sample_rate = 2500; % ksps

%myFolder = strcat('C:\ti\mmwave_studio_02_01_01_00\mmWaveStudio\PostProc\'); % Path to directory of stored data file
%myFolder = strcat('C:\ti\');
myFolder = strcat('C:\Users\Febian\Documents\Exp_27022023\');
%myFolder = strcat('C:\Users\Febian\Documents\ErrorPar\');

filename = strcat('6_walk30lux.bin');
%filename = strcat('par20cm.bin'); % distance 10cm, 47.5cm, 97.5cm, 147,5cm, 197,5cm, 147.5cm, 257.5cm
%filename = strcat('adc_data.bin'); % data walk simple 21/11/22
%filename = strcat('walk.bin'); % data walk 24/01/23


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% READING IN DATA
%fileName = fullfile(filename);
fileName = fullfile(myFolder,filename);
[retVal,total_chirps] = readDCA1000(fileName,isReal,numADCSamples,numADCBits,numRX);
for channel = 1:numRX
    dataVec = retVal(channel,:);
    if numRX == 1
        dataVec = dataVec(1:2:end);
        total_chirps = total_chirps/2;
    end
    dataMatrix(channel,:,:) = reshape(dataVec,[numADCSamples, total_chirps]);
end


%% Calling signal process function for time-range and doppler profile

cpi_b = 1;
cpi_t = 500; % input value of cpi_t, r_t, and r must be the same
r_b = 1;
r_t = 500;
r = 500;

[logftrtot, dopp_cube, ftRtotMti] = signalProcess(dataMatrix, cpi_b, cpi_t, r, total_chirps);

%% angle?
save('Test.mat','ftRtotMti')
a = real(ftRtotMti(:,:));
b = imag(ftRtotMti(:,:));
angle = deg2rad(atand(b./a));

%% Plotting range time profile 

%defining axis
c = 3*10^8;         % Speed of light
f_sample = 2.5*10^6;    % sampling frequency
slope = 30*10^12;   % Chirp Slope
d = c*f_sample/(2*slope); % Max Distance

range = linspace(10,0.4,5);

figure(1)
fig = imagesc(logftrtot);
xt = get(gca,'Xtick');
time = linspace(((1/length(xt))*total_chirps/r/8),(total_chirps/r/8),length(xt)); % The time when sample taken
set(gca,'XTick',xt,'XTickLabel', time)
yt = get(gca,'YTick');
set(gca,'YTick',yt,'YTickLabel',range,'YDir','reverse')
xlabel('Time/s')
ylabel('Range/m')
title('Range vs Time Profile');
saveas(fig,'range.png')

%% Plot doppler range profile

range2 = linspace(10,0.4,5);
dfreq = linspace(-prf/2,prf/2,9);

% figure(2)
% doppname = 'Doppler.gif';
% for j = 1:total_chirps/r
%     fig2 = imagesc(fftshift(dopp_cube(:,:,j),2));
%     xt2 = get(gca,'Xtick');
%     set(gca,'XTick',xt2,'XTickLabel',[dfreq 2500])
%     yt2 = get(gca,'YTick');
%     set(gca,'YTick',yt2,'YTickLabel',range2,'YDir','reverse')
%     xlabel('Doppler Frequency/Hz')
%     ylabel('Range/m')
%     title('Range vs Doppler Profile');
% 
%     drawnow
%     frame = getframe(2);
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%     if j == 1;
%         imwrite(imind,cm,doppname,'gif', 'Loopcount',inf);
%     else
%         imwrite(imind,cm,doppname,'gif','WriteMode','append');
%     end
% 
%     pause(0.01)
% end
% 

%% CFAR Implementation

cfar_N = 20;        % Number of training cells
cfar_guard = 2;
cfar_pfa = 0.28;       % Desired false alarm rate

[thres_res] = cfarFunction(dopp_cube, cfar_N, cfar_pfa, cfar_guard, r, total_chirps);

%% plotting and generating cfar binary data

velAx = linspace(-prf/2,prf/2,9);

% figure(3)
% cdopname = 'CfarDopp.gif';
% for l = 1:total_chirps/r
%     fig3 = imagesc(fftshift(thres_res(:,:,l),2));
%     xt3 = get(gca,'Xtick');
%     set(gca,'XTick',xt3,'XTickLabel',[velAx 2500])
%     yt3 = get(gca,'YTick');
%     set(gca,'YTick',yt3,'YTickLabel',range2,'YDir','reverse')
%     xlabel('Velocity/Hz')
%     ylabel('Range/m')
% 
%     drawnow
%     frame = getframe(3);
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%     if l == 1;
%         imwrite(imind,cm,cdopname,'gif', 'Loopcount',inf);
%     else
%         imwrite(imind,cm,cdopname,'gif','WriteMode','append');
%     end
% 
%     pause(0.01)
% end


%% Automated range reading & detected object velocity 


time_frame = (1:total_chirps/r)/8;
[distance,velocity, azimuth]= automatedReading(logftrtot,thres_res,r,r_b,r_t,total_chirps,angle);

% plot the automated readings figure
figure(4)
fig_d = plot(time_frame(1,8:end),distance(8:length(time_frame),1),'-o');
title('Automated distance reading vs time')
xlabel('time in s')
ylabel('distance in m')
grid minor; grid on;
saveas(fig_d,'distance.png')

% averaging v algorithm to smooths out noise
for v = 4:1:length(velocity)-3
    velocity(v) = sum(velocity(1,v-3:v+3)/5);
end

figure(5)
fig_v = plot(time_frame,velocity,'-o');
title('Automated velocity readings per each time frame')
xlabel('time in s')
ylabel('velocity in m/s')
grid minor; grid on;
saveas(fig_v,'velocity.png')

figure(6)
plot(time_frame,azimuth,'ok');

save('AutoRes.mat','distance','velocity','time_frame','azimuth')

timeElapsed = toc; %Clock stop measuring time elapsed
procTime = timeElapsed/length(distance)