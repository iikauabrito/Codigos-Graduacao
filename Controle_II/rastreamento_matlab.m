%% Pêndulo – Visualização dos dados
%% ESSE CÓDIGO É PARA NO FINAL OBSERVAR A RESPOSTA DO CONTROLE DA PLANTA 
%% RASTREMENTO PÓS IMPLEMENTAÇÃO DO CONTROLADOR
clear; clc; close all;

% Leitura do arquivo
T = readtable('amostras_pendulo.csv', 'TextType', 'string');

% Converte timestamp para segundos
timestamps = datetime(T.timestamp, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
t = seconds(timestamps - timestamps(1));

% Gráfico 1 – Razão Cíclica
figure;
plot(t, T.DC);
xlabel('Tempo (s)');
ylabel('DC (%)');
title('Razão Cíclica x Tempo');
grid on;

% Gráfico 2 – Rastreamento: Ângulo e Setpoint
figure;
plot(t, T.angulo, t, T.setPoint, '--');
xlabel('Tempo (s)');
ylabel('Ângulo (°)');
title('Rastreamento: Ângulo x Setpoint');
legend('Ângulo', 'Setpoint');
grid on;
