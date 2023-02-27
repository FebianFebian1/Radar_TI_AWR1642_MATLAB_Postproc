function [logftrtot, dopp_cube, ftRtotMti] = signalProcess(dataMatrix, cpi_b, cpi_t, r, total_chirps)

%% Extracting The data per each receiver and add them all up

R1 = dataMatrix(1,:,:);
SR1 = squeeze(R1);

R2 = dataMatrix(2,:,:);
SR2 = squeeze(R2);

R3 = dataMatrix(3,:,:);
SR3 = squeeze(R3);

R4 = dataMatrix(4,:,:);
SR4 = squeeze(R4);

%Rtot = SR1+SR2+SR3+SR4;
Rtot = SR4;

%% Normalisation

Rtot = Rtot - mean(Rtot);

%% Tapering

Rtot = Rtot.*hann(size(Rtot,1));

%% MTI
RtotMti = zeros(256,total_chirps);
for i = 1:1:(total_chirps-1)
    RtotMti(:,i) = Rtot(:,i+1) - Rtot(:,i);
end

%% Processing data 1-fft

ftRtot = zeros(256,total_chirps);
for i = 1:1:total_chirps
    ftRtot(:,i) = fft(Rtot(:,i));
end


%% Applying MTI Filter

ftRtotMti = zeros(256,total_chirps);
for i = 1:1:(total_chirps-1)
    ftRtotMti(:,i) = ftRtot(:,i+1) - ftRtot(:,i);
end

logftrtot = 20*log10(abs(ftRtotMti(:,:)));

%% processing data 2-fft

ftRtot2 = zeros(256,total_chirps);
for j = 1:(total_chirps/r)
    ftRtot2 = fft(ftRtotMti(:,cpi_b:cpi_t)');
    logftrtot2 = 20*log10(abs(ftRtot2(:,:)'));
    dopp_cube(:,:,j)=logftrtot2;
    cpi_b = cpi_b+r;
    cpi_t = cpi_t+r;
end


