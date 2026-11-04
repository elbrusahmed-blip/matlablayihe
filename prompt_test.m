%% MATLAB R2024a - Prompt-to-code test
% Bu skript GitHub vasitəsilə uzaqdan yaradılıb.
% Məqsəd: MATLAB kodunun prompt əsasında dəyişdirilib lokal
% MATLAB-a pull edilə bildiyini yoxlamaq.
% Toolbox tələb olunmur.

clc;
f = 50;              % Frequency in Hz
Vrms = 230;          % RMS voltage in V
Vpeak = Vrms*sqrt(2);
fs = 10000;          % Sampling frequency in Hz
duration = 0.1;      % 5 cycles at 50 Hz
t = (0:round(duration*fs)-1)/fs;
voltage = Vpeak*sin(2*pi*f*t);
measuredRMS = sqrt(mean(voltage.^2));

fprintf('PROMPT TEST UGURLU: Fayl GitHub-dan MATLAB-a catdi.\n');
fprintf('Tezlik: %.0f Hz\n', f);
fprintf('Hesablanan RMS: %.2f V (hedef %.2f V)\n', measuredRMS, Vrms);

figure('Name', 'Prompt -> GitHub -> MATLAB Test', 'NumberTitle', 'off');
plot(t*1000, voltage, 'LineWidth', 1.6);
grid on;
xlabel('Zaman (ms)');
ylabel('Gerginlik (V)');
title(sprintf('50 Hz sinus - %.0f V RMS (olculen %.2f V)', Vrms, measuredRMS));
drawnow;
