function [thres_res] = cfarFunction(dopp_cube, cfar_N, cfar_pfa, cfar_guard, r, total_chirps)

%% 1-D cfar averaging cell algorithm

cfar_a = cfar_N*((cfar_pfa)^(-1/cfar_N)-1);  % Threshold factor

c_index = 0;
for k1 = 1:1:total_chirps/r
    for k2 = 1:1:r
        for k3 = 1:1:256
            if k3 <= (cfar_N/2+cfar_guard)
                cfar_pn_up = sum(dopp_cube((k3+cfar_guard):((k3+cfar_guard)+cfar_N/2),k2,k1));
                cfar_pn_down = sum(dopp_cube(1:k3,k2,k1));
                cfar_pn(k3,k2,k1) = (1/(length(1:k3)+length((k3+cfar_guard):((k3+cfar_guard)+cfar_N/2)))*(cfar_pn_down+cfar_pn_up));
            elseif k3 >= (256-cfar_N/2-cfar_guard)
                cfar_pn_up = sum(dopp_cube((k3-cfar_guard-(cfar_N/2)):(k3-cfar_guard),k2,k1));
                cfar_pn_down = sum(dopp_cube(k3:256,k2,k1));
                cfar_pn(k3,k2,k1) = (1/(length(k3:256)+length((k3-cfar_guard-(cfar_N/2)):(k3-cfar_guard)))*(cfar_pn_down+cfar_pn_up));
            elseif (k3 >= cfar_N/2+cfar_guard+1) && (k3 <= 256-cfar_N/2-cfar_guard-1)
                cfar_pn_up = sum(dopp_cube((k3+cfar_guard):((k3+cfar_guard)+cfar_N/2),k2,k1));
                cfar_pn_down = sum(dopp_cube((k3-cfar_guard-(cfar_N/2)):(k3-cfar_guard),k2,k1));
                 cfar_pn(k3,k2,k1) = (1/(length((k3+cfar_guard):((k3+cfar_guard)+cfar_N/2))+length((k3-cfar_guard-(cfar_N/2)):(k3-cfar_guard)))*(cfar_pn_down+cfar_pn_up));
            end
        end
    end
end

cfar_t = cfar_a*cfar_pn;

%% Comparing cfar threshold vs actual value

for k1 = 1:1:total_chirps/r
    for k2 = 1:1:r
        for k3 = 1:1:256
            if dopp_cube(k3,k2,k1) >= cfar_t(k3,k2,k1)
                thres_res (k3,k2,k1) = dopp_cube(k3,k2,k1);
            else
                thres_res(k3,k2,k1) = 0;
            end
        end
    end
end