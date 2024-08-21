%{
    Filename : radar_STFT.m
    Author : YoungJae Choi
    Date : 2017.10.31
    Brief : STFT 함수
        잘라서 뿌리기
%}
function [T F S] = radar_stft(E, win_len, PRF)
    dt = 1/PRF;
    BW = PRF/2;    
    NFFT = win_len;
    len = (length(E));
    %NFFT = length(E);
    T = 0:dt:(dt*(len-1-NFFT));
    F = linspace(-BW,BW,NFFT);
    xwin = gausswin(NFFT);
    %% 시간 주파수 분석
    S = zeros(NFFT, len-NFFT);
    for idx=1:(len-NFFT)
        start_idx = idx;
        end_idx = idx + NFFT -1;
        EE = E(start_idx:end_idx);
        EE = EE .* xwin;
        S(:,idx) = fftshift(fft(EE));
    end
    S = S ./ win_len;
end