
close all;
% Definição da planta
num = tf1.Numerator; %tf1.Numerator vem do SystemIdentification
den = tf1.Denominator; %tf1.Denominator vem do SystemIdentification
G = tf(num, den);
% Abrir o PID Tuner (interface gráfica)
pidTuner(G, 'PID');

% % Projeto automático do PID
% C = pidtune(G, 'PID');
% % Mostrar ganhos
% Kp = C.Kp;
% Ki = C.Ki;
% Kd = C.Kd;

%disp('Ganhos do PID:')
%disp(['Kp = ', num2str(Kp)])
%disp(['Ki = ', num2str(Ki)])
%disp(['Kd = ', num2str(Kd)])
