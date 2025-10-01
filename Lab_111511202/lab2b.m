clear; clc;
analog_wp = 5;                  
analog_ws = 14;                  % 阻帶邊界頻率改爲14rad/sec
fs = 36 / (2 * pi);             
Ts = 1 / fs;                    

% 數位化頻率（rad/sample）w=analog_w*Ts
wp = analog_wp * Ts;
ws = analog_ws * Ts;
wc = (wp + ws) / 2;             
transition_BW = ws - wp;        

% 計算 Kaiser 所需參數
analog_fp = analog_wp / (2 * pi);    
analog_fs = analog_ws / (2 * pi);    
r_pass = 1 - 10^(-0.2 / 20);         
r_stop = 10^(-60 / 20);              % 阻帶誤差改成 -60dB

% Kaiser 濾波器設計參數
Fedge = [analog_fp analog_fs];       % 邊界頻率 (Hz)
dev = [r_pass r_stop];               % 通帶與阻帶誤差
mags = [1 0];                        % 頻帶響應：通帶=1，阻帶=0

% 使用 kaiserord 計算所需的階數與參數
[M_kaiser, Wn, beta, ftype] = kaiserord(Fedge, mags, dev, fs);
M_kaiser = M_kaiser + 3;

% 理想濾波器脈衝響應乘上 Kaiser window
n = -M_kaiser / 2 : M_kaiser / 2;
hd = (wc / pi) * sinc((wc / pi) * n);      
w_kaiser = kaiser(M_kaiser + 1, beta)';    
LP_Kaiser = hd .* w_kaiser;

% 畫出脈衝響應圖
x = 0 : M_kaiser;
figure;
stem(x, LP_Kaiser);
title('Impulse Response of Kaiser Window FIR Filter');
xlabel('Sampling(n)');
ylabel('Amplitude');
grid on;

% 使用 freqz 畫頻率響應（橫軸轉換為 rad/sec）
[H, w] = freqz(LP_Kaiser, 1, 2048);
omega = w * fs;  % 將 rad/sample → rad/sec

figure;
plot(omega, 20*log10(abs(H)), 'LineWidth', 1.3); grid on;
xlabel('Frequency (rad/sec)');
ylabel('Magnitude (dB)');
title('Frequency Response of Kaiser FIR Filter (rad/sec)');
xlim([0, pi * fs]);  % 限制在 Nyquist 頻率（rad/sec）
