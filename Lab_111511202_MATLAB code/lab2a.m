clear; clc;
analog_wp = 5;       % 通帶邊界頻率（rad/sec）
analog_ws = 12;      % 阻帶邊界頻率（rad/sec）
fs = 36 / (2 * pi);  % 將 36 rad/sec 轉換為 Hz
Ts = 1 / fs;         % 取樣週期（秒）

% 數位化頻率 
wp = analog_wp * Ts; 
ws = analog_ws * Ts; 
wc = (ws + wp) / 2;  
transition_BW = ws - wp; 

%  濾波器階數M估算，取到整數
M_Hann     = ceil(8 * pi / transition_BW);      
M_Hamming  = ceil(8 * pi / transition_BW);     
M_Blackman = ceil(12 * pi / transition_BW);    

% 時間軸
n1 = -M_Hamming / 2 : M_Hamming / 2;
n2 = -M_Hann / 2    : M_Hann / 2;
n3 = -M_Blackman / 2: M_Blackman / 2;

% 利用理想低通濾波器的脈衝響應（sinc 函數）乘上對應窗函數，設計出 FIR 濾波器係數
L_Hann     = ((wc / pi) * sinc((wc / pi) * n2)) .* hanning(M_Hann + 1)';     
L_Hamming  = ((wc / pi) * sinc((wc / pi) * n1)) .* hamming(M_Hamming + 1)';  
L_Blackman = ((wc / pi) * sinc((wc / pi) * n3)) .* blackman(M_Blackman + 1)';

%時域係數圖
x1 = 0:M_Hamming;
x2 = 0:M_Hann;
x3 = 0:M_Blackman;

figure;
subplot(3,1,1)
stem(x1, L_Hamming); grid on;
title('Hamming');
xlabel('Sampling (n)');
ylabel('Amplitude');

subplot(3,1,2)
stem(x2, L_Hann); grid on;
title('Hann');
xlabel('Sampling (n)');
ylabel('Amplitude');

subplot(3,1,3)
stem(x3, L_Blackman); grid on;
title('Blackman');
xlabel('Sampling (n)');
ylabel('Amplitude');

% 頻率響應（使用 freqz，橫軸為 rad/sec）
n_fft = 2048;
[H1, w1] = freqz(L_Hamming, 1, n_fft);
[H2, ~]  = freqz(L_Hann, 1, n_fft);
[H3, ~]  = freqz(L_Blackman, 1, n_fft);

% 轉換為 rad/sec：ω = (rad/sample) * fs
omega = w1 * fs;

% 畫頻率響應圖
figure;
plot(omega, 20*log10(abs(H1)), 'LineWidth', 1.2); hold on;
plot(omega, 20*log10(abs(H2)), 'LineWidth', 1.2);
plot(omega, 20*log10(abs(H3)), 'LineWidth', 1.2); grid on;

xlabel('Frequency (rad/sec)');
ylabel('Magnitude (dB)');
legend('Hamming','Hann','Blackman');
title('Gain Response Comparison of FIR Filters (rad/sec)');
xlim([0, pi*fs]);  % 限制 Nyquist 頻率
