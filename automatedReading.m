function [distance, velocity, azimuth] = automatedReading(logftrtot, thres_res,r, r_b, r_t,total_chirps,angle)

%% automated range reading

doppFreq_arr = linspace(-2000,2000,r);
distance_arr = linspace(12.5,0,256);
distance = zeros(round(total_chirps/r),1);
distance(1) = 2; % initial ref value
velocity(1) = 0; % initial ref velocity
max_index = r_t/2; % ref value for shifting the index due to fftshift

for h = 2:total_chirps/r
    %Reading Distance
    [indx,indy] = find(logftrtot(:,r_b:r_t)==max(max(logftrtot(:,r_b:r_t))));
    if max(max(logftrtot(:,r_b:r_t)))>47
        distance(h) = distance_arr(indx);
        azimuth(h) = angle(indx,indy+r_b);
    else
        distance(h) = distance(h-1);
        azimuth(h) = angle(h-1);
    end
        
    % algortithm to remove spikes
    
    if distance(h)>6
        if abs(distance(h)-distance(h-1))> 0.5
            distance(h) = distance(h-1);
        end
    elseif distance(h)>5
        if abs(distance(h)-distance(h-1))> 1
            distance(h) = distance(h-1);
        end
    elseif distance(h)>4
        if abs(distance(h)-distance(h-1))> 1.5
            distance(h) = distance(h-1);
        end
    else
        if abs(distance(h)-distance(h-1))> 2
            distance(h) = distance(h-1);
        end
    end

    % Reading Velocity
    if indx+2>256 
        [indx2,indy2] = find(thres_res(indx-3:indx+1,:,h));
    else
        [indx2,indy2] = find(thres_res(indx-2:indx+2,:,h));
    end

    for g = 1:length(indy2)
        if indy2(g)<max_index
            indy2(g) = indy2(g)+max_index;
        elseif indy2(g)>max_index
            indy2(g) = indy2(g)-max_index;
        end
            
    end

    %building the velocity array in a time frame domain
    indYv = round(sum(indy2)/length(indy2));
    
    if isnan(indYv) %if no input to the vsource function
        velocity(h) = velocity(h-1);
        fprintf('distance is: %f\n', distance(h))
        fprintf('Object Velocity in m/s: %f\n',velocity(h))
    else
        dopp_freq = doppFreq_arr(indYv);
        [v_source, vs_km] = sourceVelocity(dopp_freq);
        velocity(h) = v_source;
        fprintf('distance is: %f\n', distance(h))
        fprintf('Object Velocity in m/s: %f\n',v_source)
        fprintf('Object Velocity in km/h: %f\n',vs_km)
    end

    r_b = r_b+r;
    r_t = r_t+r;
    pause(0.05)
end
