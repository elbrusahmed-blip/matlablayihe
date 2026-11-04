%% MATLAB R2024a + GitHub: baslangic numunesi
% Bu fayl MATLAB-da isledilmek ucun hazirlanib.
% Hech bir elave toolbox teleb olunmur.
clc;
fprintf('MATLAB versiyasi: %s\n', version);
fprintf('Cari qovluq: %s\n', pwd);

% Riyazi numune: sinus siqnali
t = linspace(0, 2*pi, 400);
y = sin(t);

figure('Name', 'MATLAB GitHub test', 'NumberTitle', 'off');
plot(t, y, 'LineWidth', 1.6);
grid on;
xlabel('t (rad)');
ylabel('sin(t)');
title('MATLAB + GitHub: test ugurludur');
fprintf('Nümunə skript uğurla icra edildi.\n');

%% AI prompt integration test
% GitHub-da uzaqdan elave edilmis yoxlama.
fprintf('PROMPT TEST: GitHub-daki MATLAB kodu yenilendi.\n');
fprintf('Novbeti test ucun prompt_test.m faylini isledin.\n');
