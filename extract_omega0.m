function [omega0] = extract_omega0(Z, win_len, PRF, lpf_len)
    [T F S] = radar_stft(Z, win_len, PRF);
    required_time = T(end);
    [resultT, resultF, resultS per] = speos2(T, F, S, required_time, lpf_len);
    omega0 = (2*pi)/(per*3);
end