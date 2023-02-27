function [v_source, vs_km] = sourceVelocity(dopp_freq)

c = 3*10^8;
emit_freq = 79*10^9;

v_source = ((emit_freq/(emit_freq-dopp_freq))-1)*c;
vs_km = v_source*36/10;
