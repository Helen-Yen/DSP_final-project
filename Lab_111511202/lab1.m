clear; clc;

fs = 300e3;                                % Sampling rate (Hz)
Ts = 1/fs;                                 % Sampling period (sec)
analog_wp = 30e3 * 2 * pi;                 % Passband cutoff (rad/sec)
analog_ws = 90e3 * 2 * pi;                 % Stopband cutoff (rad/sec)
r_pass = 0.3;                              % Passband ripple in dB
r_stop = 80;                               % Stopband attenuation in dB

wp = analog_wp * Ts;                       % Normalized digital passband (rad/sample)
ws = analog_ws * Ts;                       % Normalized digital stopband

% Pre-warp the frequencies
wp2 = (2/Ts) * tan(wp/2);                  % Prewarped analog passband
ws2 = (2/Ts) * tan(ws/2);                  % Prewarped analog stopband

% Find minimum order of Butterworth filter
[N, wc2] = buttord(wp2, ws2, r_pass, r_stop, 's');

% Analog prototype filter using buttap
[z, p, k] = buttap(N);                     % s-domain prototype
[b_, a_] = zp2tf(z, p, k);                 % Convert to transfer function
[b, a] = lp2lp(b_, a_, wc2);               % Scale to desired analog cutoff

% Bilinear transformation to digital
[bz, az] = bilinear(b, a, fs);             % Convert to digital filter

% Frequency response
[H, W] = freqz(bz, az, 1024, fs);          % Now W is in Hz

% Plot magnitude in dB
subplot(2,1,1);
plot(W, 20*log10(abs(H))); grid on;
title('Magnitude Response (dB)');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');

% Plot phase in radians
subplot(2,1,2);
plot(W, angle(H)); grid on;
title('Phase Response');
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');
