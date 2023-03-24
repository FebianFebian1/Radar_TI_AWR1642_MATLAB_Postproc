function [angle] = AngleEstimates(dataMatrix, cpi_b, cpi_t, r, total_chirps, numRx)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function is very similar to the signalProcess.m 
% but all the signal is process per each receiver rather than the sum

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Normalisation

for i = 1:numRx
    dataMatrix(i,:,:) = dataMatrix(i,:,:)-mean(dataMatrix(i,:,:)); 
end

%% Tapering

for i = 1:numRx
    dataMatrix(i,:,:) = dataMatrix(i,:,:).*hann(size(dataMatrix(i,:,:),1));
end

%% Processing data 1-fft

dataMatrix = permute(dataMatrix,[2,3,1]);
ftRtot = zeros(256,total_chirps,numRx);
for i = 1:numRx
    ftRtot(:,:,i) = fft(dataMatrix(:,:,i));
end


%% Applying MTI Filter

ftRtotMti = zeros(256,total_chirps-1,numRx);
for i = 1:numRx
    for j = 1:total_chirps-1
        ftRtotMti(:,j,i) = ftRtot(:,j+1,i) - ftRtot(:,j,i);
    end
end

%% processing data 2-fft and 3-fft across channel for angle

ftRtot2 = zeros(r,256,numRx);
ftRtot3 = zeros(1,256,1);

x = linspace(90,-90,256); % angle in x axis

ftRtotMti = permute(ftRtotMti,[2,1,3]);

for j = 1:(length(ftRtotMti(:,1,1))/r)
    for i = 1:numRx
        ftRtot2(:,:,i) = fft((ftRtotMti(cpi_b:cpi_t,:,i)));
    end
        ftRtot2_restructure = permute(ftRtot2,[2,3,1]);
    
        [indx,indy] = find(ftRtot2==max(max(ftRtot2)));
        index = [indx(1); indy(1)];
    
        ftRtot3(:,:,:) = fft(ftRtot2_restructure(index(2),:,index(1)),256);
%         plot(x,fftshift(abs(ftRtot3),2)) %To see the peak plot
%         title('Angle using phase difference over pairs of receiver channel')
%         xlabel('angle in deg')
%         ylabel('Magnitude')
%         grid on; grid minor;

        %capture the x location of the peak existed
        indx2 = find(ftRtot3==(max(ftRtot3)));
        
        %account for the fftshift
        if indx2<128
            indx2 = indx2+128;
        elseif indx2>128
            indx2 = indx2-128;
        end

        angle(j) = x(indx2); %angle array
        
        cpi_b = cpi_b+r;
        cpi_t = cpi_t+r;
        pause(0.01)
end