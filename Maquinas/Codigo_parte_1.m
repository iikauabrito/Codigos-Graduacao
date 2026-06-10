%% GERADOR SÍNCRONO - RESOLUÇÃO DOS ITENS A ATÉ F
clear;
clc;
close all;

%% 1. Dados do gerador

S_nominal = 50e6;        % Potência aparente nominal [VA]
VL_nominal = 13.8e3;     % Tensão nominal de linha [V]
fp = 0.9;                % Fator de potência
f = 60;                  % Frequência [Hz]
polos = 4;               % Número de polos

Ra = 0.2;                % Resistência de armadura por fase [ohm]
Xs = 2.5;                % Reatância síncrona por fase [ohm]

P_atrito_vent = 1e6;     % Perdas por atrito e ventilação [W]
P_nucleo = 1.5e6;        % Perdas no núcleo [W]

Vcampo = 120;            % Tensão CC do circuito de campo [V]
If_max = 10;             % Corrente de campo máxima [A]

%% 2. Curva característica a vazio - CAV
% Valores aproximados retirados do gráfico.
% If em ampères e tensão de linha a vazio em kV.

If_CAV = [0 1 2 3 4 5 6 7 8 9 10];
VL_CAV_kV = [1.0 5.5 9.6 12.7 14.9 16.5 17.6 18.4 19.1 19.6 20.0]; %%aproximado!
VL_CAV = VL_CAV_kV * 1e3;     % Conversão para volts

%% Item a
% Corrente de campo necessária para produzir 13,8 kV a vazio.
If_vazio = interp1(VL_CAV, If_CAV, VL_nominal, 'linear', 'extrap');

%% Item b
% Tensão interna gerada EA em condições nominais.
% Corrente nominal de linha.
% Na ligação Y: Ilinha = Ifase.

Ia_mag = S_nominal / (sqrt(3) * VL_nominal);

% Ângulo correspondente ao fator de potência.
phi = acos(fp);

% Como o fator de potência é atrasado, a corrente atrasa a tensão.
Ia = Ia_mag * exp(-1j * phi);

% Tensão terminal por fase.
Vfase = VL_nominal / sqrt(3);

% Tensão interna gerada por fase:
% EA = Vfase + (Ra + jXs)*Ia
Zs = Ra + 1j * Xs;
EA = Vfase + Zs * Ia;
EA_mag = abs(EA);
EA_ang = rad2deg(angle(EA));

% Valor equivalente de linha da tensão interna.
%%SERÁ USADO PARA INTERPOLAR QUANDO FOR NO ITEM D)
EA_linha = sqrt(3) * EA_mag;

%% Item c
% Tensão nominal de fase.

Vfase_nominal = VL_nominal / sqrt(3);

%% Item d
% Corrente de campo necessária para produzir EA_linha na CAV.
EA_linha = sqrt(3) * EA_mag;
If_carga = interp1(VL_CAV, If_CAV, EA_linha,'linear', 'extrap');

%% Item e
% Quando a carga é retirada, Ia = 0.
% Mantendo a corrente de campo, a tensão terminal é obtida pela CAV.

%%VL_sem_carga = interp1(If_CAV, VL_CAV, If_carga,'linear', 'extrap');
%%Vfase_sem_carga = VL_sem_carga / sqrt(3);
VL_sem_carga = sqrt(3) * EA_mag;

%% Item f
% Potência e conjugado fornecidos pela máquina motriz.
% Potência ativa elétrica entregue à carga.
P_saida = S_nominal * fp;

% Perdas no cobre da armadura.
P_cobre = 3 * Ia_mag^2 * Ra;

% Potência mecânica fornecida pela máquina motriz.
P_mecanica = P_saida + P_cobre + P_nucleo + P_atrito_vent;

% Velocidade síncrona em rpm.
ns = 120 * f / polos;

% Velocidade angular mecânica.
omega_m = 2 * pi * ns / 60;

% Conjugado mecânico.
T_mecanico = P_mecanica / omega_m;

%% Potência do circuito de campo
% Essa potência normalmente é fornecida por uma fonte CC separada
% e não entra na potência mecânica da máquina motriz.
P_campo = Vcampo * If_carga;

%% Exibição dos resultados
fprintf('=============================================\n');
fprintf('       RESULTADOS DO GERADOR SINCRONO\n');
fprintf('=============================================\n\n');

fprintf('Item a:\n');
fprintf('Corrente de campo a vazio = %.3f A\n\n', If_vazio);

fprintf('Item b:\n');
fprintf('Corrente nominal de armadura = %.2f A\n', Ia_mag);
fprintf('Angulo da corrente = %.2f graus\n', -rad2deg(phi));
fprintf('EA por fase = %.3f kV < %.2f graus\n',EA_mag/1e3, EA_ang);
fprintf('EA equivalente de linha = %.3f kV\n\n',EA_linha/1e3);

fprintf('Item c:\n');
fprintf('Tensao nominal de fase = %.3f kV\n\n',Vfase_nominal/1e3);

fprintf('Item d:\n');
fprintf('Corrente de campo em carga nominal = %.3f A\n', If_carga);

if If_carga > If_max
    fprintf('ATENCAO: corrente de campo acima do limite de %.1f A.\n\n',If_max);
else
    fprintf('A corrente de campo esta dentro do limite permitido.\n\n');
end

fprintf('Item e:\n');
fprintf('Tensao de linha apos retirar a carga = %.3f kV\n', VL_sem_carga/1e3);
%%fprintf('Tensao de fase apos retirar a carga = %.3f kV\n\n',Vfase_sem_carga/1e3);

fprintf('Item f:\n');
fprintf('Potencia ativa de saida = %.3f MW\n',P_saida/1e6);
fprintf('Perdas no cobre = %.3f MW\n',P_cobre/1e6);
fprintf('Potencia mecanica necessária = %.3f MW\n', P_mecanica/1e6);
fprintf('Velocidade sincrona = %.0f rpm\n', ns);
fprintf('Conjugado mecanico = %.3f kN.m\n\n', T_mecanico/1e3);

fprintf('Informacao adicional:\n');
fprintf('Potencia do circuito de campo = %.3f kW\n', ...
        P_campo/1e3);

%% Gráfico da CAV

If_grafico = linspace(0, 10, 500);

VL_grafico = interp1(If_CAV, VL_CAV_kV, If_grafico, 'pchip');

figure;

plot(If_grafico, VL_grafico,'LineWidth', 2);

hold on;
plot(If_vazio, VL_nominal/1e3,'o', 'MarkerSize', 8, 'LineWidth', 2);
plot(If_carga, EA_linha/1e3,'s', 'MarkerSize', 8, 'LineWidth', 2);

grid on;
xlabel('Corrente de campo I_F (A)');
ylabel('Tensão a vazio de linha (kV)');
title('Característica a vazio do gerador síncrono');
legend('CAV - "OLHÔMETRO"', 'Operação a vazio - 13,8 kV', 'Excitação em carga nominal','Location', 'southeast');