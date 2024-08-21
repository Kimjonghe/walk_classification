%% Filename : single period extraction of spectrogram (SPEOS).m
%    Date : 2019.06.24
%    Author : Young-Jae Choi (HNU RadarLab)
%    Brief : 스펙트로그램에서 단일 주기를 추출한다. 논문 내용 재현
%    T : 시간
%    F : 주파수
%    S : 단일 주기 스펙트로그램 영상

function [resultT, resultF, resultS per] = speos2(T, F, S, required_time, lpf_len)
%     S = log(abs(S)) - min(min(log(abs(S))));
    S = abs(S);
    U = zeros(1,length(T));
    for loop=1:length(T)
        U(loop) = (sum(sign(F').*(S(:,loop))));
    end
    U = U - mean(U);
    LPFU = zeros(1,length(T));
    w = gausswin(lpf_len);
    for loop=1:(length(T)-lpf_len-1)
        LPFU(loop) = (U(loop:(loop+lpf_len-1))*w);
    end
    U = LPFU;
    
%     figure
%     plot(T,U)
    
%     figure
%     imagesc(T,F,S)
    
    % 식 (20)
    J = fft(U);
%     J2 = fft(U,1024);   
%     F2 = linspace(F(1), F(end),1024);

    % 식 (21)
    [val init_freq_idx] = max(abs(J));
%     init_tau = 1/(init_freq_idx/(max(T)));
    
    SSFT = (fft(U));
    observation_time = max(T);
    [val idx] = max(abs(SSFT));
    ff = (idx/(observation_time));
    ffd = (1/(observation_time));
    
    max_iter = 1000;
    for loop=1:max_iter
        F2 = linspace(ff-ffd,ff+ffd,2);
        for f_idx = 1:length(F2)
            f_pivot = F2(f_idx);
            A = exp(j*2*pi*T'*f_pivot);
            M = real(A'*A);
            b = conj(U)';
            est_angle = 0.5*imag(log((conj(A'*b))'*pinv(M)*(A'*b)));
            est_amp(f_idx) = pinv(M)*real(A'*b*exp(-j.*est_angle));
        end
        [val idx] = max(abs(est_amp));
        ff = F2(idx);
        ffd = ffd/length(F2);
        if ffd < 1e-4
            break;
        end
    end
    
    per = 1/abs(ff);
    dt = (T(2)-T(1));
    end_idx = 1 + round(required_time/dt);
    
    resultT = T(1:end_idx);
    resultF = F;
    resultS = abs(S(:,1:end_idx));

    
    U2 = est_amp(idx).*cos(2.*pi.*ff.*T + est_angle);
%     figure
%     plot(T,U, T, U2);
    
%         figure
%     imagesc(resultT, resultF, resultS);    
%         xlabel('Time (s)','FontSize',14)
%     ylabel('Doppler frequency (Hz)','FontSize',14)
%     ylim([-1500 1500])
%     
    %}
end