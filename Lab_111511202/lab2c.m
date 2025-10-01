clear; clc;  
analog_wp = 5;              
analog_ws = 14;              
fs = 36 / (2 * pi);          
Ts = 1 / fs;                 

% 類比頻率轉數位頻率（rad/sample）
wp = analog_wp * Ts;         
ws = analog_ws * Ts;         
wc = (wp + ws) / 2;          
transition_BW = ws - wp;     

% Parks-McClellan 設計參數（轉換為 Hz）
analog_fp = analog_wp / (2 * pi);     
analog_fs = analog_ws / (2 * pi);     
r_pass = 1 - (10 ^ (-0.2 / 20));      
r_stop = 10 ^ (-60 / 20);             

% 頻率邊界與設計規格
Fedge = [analog_fp analog_fs];       
dev = [r_pass r_stop];                
mags = [1 0];                         

% 計算 FIR 階數與設計參數
[M, fo, ao, w] = firpmord(Fedge, mags, dev, fs);
LP_Parks = firpm(M+3, fo, ao, w);   % 多加 3 階以符合要求

% 畫出脈衝響應
x = 0 : M+3;                  
figure;
stem(x, LP_Parks);              
title('Impulse Response of Parks-McClellan FIR Filter');       
xlabel('Sampling(n)');         
ylabel('Amplitude');
grid on;

% 使用 freqz 畫頻率響應（橫軸轉換為 rad/sec）
[H, w] = freqz(LP_Parks, 1, 2048);
omega = w * fs;  % 將 rad/sample → rad/sec

figure;
plot(omega, 20*log10(abs(H)), 'LineWidth', 1.3); grid on;
xlabel('Frequency (rad/sec)');
ylabel('Magnitude (dB)');
title('Frequency Response of Parks-McClellan FIR Filter');
xlim([0, pi * fs]);
