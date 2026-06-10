%% QUESTAO 2 - GERADOR SINCRONO EM PU
% Variação de carga: 60%, 70%, 80%, 90% e 100%
% Resistência de armadura desconsiderada

clear;
clc;
close all;

%% ==============================================================
% 1. DADOS NOMINAIS DA MÁQUINA
% ==============================================================

Sbase = 50e6;             % Potência aparente base [VA]
VLbase = 13.8e3;          % Tensão de linha base [V]
fp_nominal = 0.90;        % FP nominal atrasado
Xs_ohm = 2.5;             % Reatância síncrona [ohm]

%% ==============================================================
% 2. GRANDEZAS BASE
% ==============================================================

Vfase_base = VLbase / sqrt(3);

Ibase = Sbase / (sqrt(3) * VLbase);

Zbase = VLbase^2 / Sbase;

Xs_pu = Xs_ohm / Zbase;

fprintf('===========================================\n');
fprintf('             GRANDEZAS BASE\n');
fprintf('===========================================\n');

fprintf('Vfase base = %.3f kV\n', Vfase_base/1e3);
fprintf('Ibase      = %.3f A\n', Ibase);
fprintf('Zbase      = %.4f ohm\n', Zbase);
fprintf('Xs          = %.4f pu\n\n', Xs_pu);

%% ==============================================================
% 3. CONDIÇÃO NOMINAL
% ==============================================================

% Tensão terminal de fase em pu
Vf = 1 + 1j*0;

% Ângulo nominal da corrente
phi_nominal = acos(fp_nominal);

% Corrente nominal em pu
% FP atrasado: corrente possui ângulo negativo
IA_nominal = 1 * exp(-1j * phi_nominal);

% Tensão interna nominal
% EA = Vf + jXsIA
EA_nominal = Vf + 1j * Xs_pu * IA_nominal;

EA_modulo = abs(EA_nominal);
delta_nominal = angle(EA_nominal);

fprintf('===========================================\n');
fprintf('            CONDIÇÃO NOMINAL\n');
fprintf('===========================================\n');

fprintf('|IA nominal| = %.4f pu\n', abs(IA_nominal));
fprintf('Angulo IA    = %.3f graus\n', ...
        rad2deg(angle(IA_nominal)));

fprintf('|EA nominal| = %.4f pu\n', EA_modulo);
fprintf('Angulo EA    = %.3f graus\n\n', ...
        rad2deg(delta_nominal));

%% ==============================================================
% 4. PERCENTUAIS DE CARGA
% ==============================================================

carga = [0.60 0.70 0.80 0.90 1.00];

n = length(carga);

% Vetores para armazenar resultados
P_pu = zeros(1,n);
delta = zeros(1,n);

EA = zeros(1,n);
IA = zeros(1,n);
IL = zeros(1,n);

FP = zeros(1,n);
tipo_FP = strings(1,n);

jXsIA = zeros(1,n);

%% ==============================================================
% 5. CÁLCULO PARA CADA CONDIÇÃO DE CARGA
% ==============================================================

for k = 1:n

    % Potência ativa nominal da máquina:
    % Pnominal = 1 pu * 0,9 = 0,9 pu
    %
    % Para 60%:
    % P = 0,60 * 0,90 = 0,54 pu

    P_pu(k) = carga(k) * fp_nominal;

    % Equação potência-ângulo:
    %
    % P = (EA*Vf/Xs)*sen(delta)

    argumento = P_pu(k) * Xs_pu / ...
                (EA_modulo * abs(Vf));

    % Proteção contra erros numéricos
    if abs(argumento) > 1
        error(['Não existe solução para %.0f%% de carga. ' ...
               'Limite de estabilidade excedido.'], ...
               carga(k)*100);
    end

    delta(k) = asin(argumento);

    % Tensão interna com magnitude constante
    EA(k) = EA_modulo * exp(1j * delta(k));

    % Corrente de armadura
    %
    % EA = Vf + jXsIA
    %
    % IA = (EA - Vf)/(jXs)

    IA(k) = (EA(k) - Vf) / (1j * Xs_pu);

    % Ligação Y
    IL(k) = IA(k);

    % Fasor da queda na reatância síncrona
    jXsIA(k) = 1j * Xs_pu * IA(k);

    % Fator de potência
    FP(k) = cos(angle(IA(k)));

    % Classificação do fator de potência
    if angle(IA(k)) < -1e-6
        tipo_FP(k) = "atrasado";

    elseif angle(IA(k)) > 1e-6
        tipo_FP(k) = "adiantado";

    else
        tipo_FP(k) = "unitário";
    end

end

%% ==============================================================
% 6. EXIBIÇÃO DOS RESULTADOS
% ==============================================================

fprintf('===========================================\n');
fprintf('           RESULTADOS EM PU\n');
fprintf('===========================================\n\n');

fprintf(['Carga    P(pu)    |IA|      angIA      ' ...
         '|IL|      |EA|      delta      FP\n']);

fprintf(['(%%)               (pu)      (graus)     ' ...
         '(pu)      (pu)      (graus)\n']);

fprintf('---------------------------------------------------------------\n');

for k = 1:n

    fprintf('%3.0f     %6.3f   %7.4f   %8.3f   ', ...
            carga(k)*100, ...
            P_pu(k), ...
            abs(IA(k)), ...
            rad2deg(angle(IA(k))));

    fprintf('%7.4f   %7.4f   %8.3f   %6.4f  %s\n', ...
            abs(IL(k)), ...
            abs(EA(k)), ...
            rad2deg(delta(k)), ...
            FP(k), ...
            tipo_FP(k));
end

%% ==============================================================
% 7. CRIAÇÃO DA TABELA MATLAB
% ==============================================================

Carga_percentual = carga.' * 100;
Potencia_pu = P_pu.';

IA_modulo_pu = abs(IA).';
IA_angulo_graus = rad2deg(angle(IA)).';

IL_modulo_pu = abs(IL).';
IL_angulo_graus = rad2deg(angle(IL)).';

EA_modulo_pu = abs(EA).';
EA_angulo_graus = rad2deg(angle(EA)).';

Fator_potencia = FP.';
Classificacao_FP = tipo_FP.';

Resultados = table( ...
    Carga_percentual, ...
    Potencia_pu, ...
    IA_modulo_pu, ...
    IA_angulo_graus, ...
    IL_modulo_pu, ...
    IL_angulo_graus, ...
    EA_modulo_pu, ...
    EA_angulo_graus, ...
    Fator_potencia, ...
    Classificacao_FP);

disp(Resultados);

%% ==============================================================
% 8. CORES DE CADA CONDIÇÃO
% ==============================================================

% Cada linha corresponde a uma condição de carga:
%
% 60% = azul
% 70% = vermelho
% 80% = verde
% 90% = magenta
% 100% = preto

cores = [
    0.0000  0.4470  0.7410;    % Azul
    0.8500  0.1000  0.1000;    % Vermelho
    0.1000  0.6500  0.2000;    % Verde
    0.7500  0.1000  0.7500;    % Magenta
    0.0000  0.0000  0.0000     % Preto
];

%% ==============================================================
% 9. NORMALIZAÇÃO PARA EA ESCORREGAR NO CÍRCULO UNITÁRIO
% ==============================================================

% Nos cálculos elétricos:
%
% |EA| = 1,4153 pu aproximadamente.
%
% Porém o enunciado solicita que EA se movimente sobre um
% círculo unitário.
%
% Para o desenho, todos os fasores são divididos por |EA|.
% Isso preserva os ângulos e a geometria fasorial.

EA_grafico = EA / EA_modulo;

Vf_grafico = Vf / EA_modulo;

IA_grafico = IA / EA_modulo;

jXsIA_grafico = jXsIA / EA_modulo;

%% ==============================================================
% 10. DIAGRAMA FASORIAL CONJUNTO
% ==============================================================

figure('Color','w');

hold on;
grid on;
axis equal;

% Círculo unitário
theta = linspace(0, 2*pi, 800);

plot(cos(theta), sin(theta), ...
     '--', ...
     'Color', [0.50 0.50 0.50], ...
     'LineWidth', 1.5, ...
     'DisplayName', 'Círculo unitário de E_A');

% Eixos
xline(0, 'k:', 'HandleVisibility','off');
yline(0, 'k:', 'HandleVisibility','off');

% Vetores de cada condição
for k = 1:n

    cor = cores(k,:);

    % ----------------------------------------------------------
    % (2) Tensão de fase Vf
    % Origem até a extremidade de Vf
    % ----------------------------------------------------------

    quiver(0, 0, ...
           real(Vf_grafico), imag(Vf_grafico), ...
           0, ...
           'Color', cor, ...
           'LineWidth', 1.8, ...
           'MaxHeadSize', 0.14, ...
           'HandleVisibility','off');

    % ----------------------------------------------------------
    % (4) Tensão induzida EA
    % Origem até EA
    % ----------------------------------------------------------

    quiver(0, 0, ...
           real(EA_grafico(k)), imag(EA_grafico(k)), ...
           0, ...
           'Color', cor, ...
           'LineWidth', 2.3, ...
           'MaxHeadSize', 0.14, ...
           'DisplayName', ...
           sprintf('Carga de %.0f%%', carga(k)*100));

    % ----------------------------------------------------------
    % (3) Fasor jXsIA
    % Começa na ponta de Vf e termina na ponta de EA
    % ----------------------------------------------------------

    quiver(real(Vf_grafico), imag(Vf_grafico), ...
           real(jXsIA_grafico(k)), ...
           imag(jXsIA_grafico(k)), ...
           0, ...
           'Color', cor, ...
           'LineStyle', '--', ...
           'LineWidth', 2.0, ...
           'MaxHeadSize', 0.16, ...
           'HandleVisibility','off');

    % ----------------------------------------------------------
    % (5) Corrente IA
    % Origem até IA
    % ----------------------------------------------------------

    quiver(0, 0, ...
           real(IA_grafico(k)), imag(IA_grafico(k)), ...
           0, ...
           'Color', cor, ...
           'LineStyle', ':', ...
           'LineWidth', 2.1, ...
           'MaxHeadSize', 0.16, ...
           'HandleVisibility','off');

    % Ponto de EA sobre o círculo
    plot(real(EA_grafico(k)), ...
         imag(EA_grafico(k)), ...
         'o', ...
         'Color', cor, ...
         'MarkerFaceColor', cor, ...
         'MarkerSize', 6, ...
         'HandleVisibility','off');

    % Texto identificando a carga
    text(real(EA_grafico(k)) + 0.025, ...
         imag(EA_grafico(k)) + 0.025, ...
         sprintf('E_A - %.0f%%', carga(k)*100), ...
         'Color', cor, ...
         'FontWeight', 'bold', ...
         'FontSize', 9);

end

% Identificação de Vf
text(real(Vf_grafico) + 0.015, ...
     imag(Vf_grafico) - 0.045, ...
     'V_\phi', ...
     'FontWeight', 'bold', ...
     'FontSize', 11);

xlabel('Eixo real — pu normalizado');
ylabel('Eixo imaginário — pu normalizado');

title({ ...
    'Diagramas fasoriais do gerador síncrono'; ...
    'E_A deslocando-se sobre o círculo unitário'});

legend('Location','bestoutside');

xlim([-0.10 1.15]);
ylim([-0.75 0.65]);

%% ==============================================================
% 11. DIAGRAMAS SEPARADOS PARA CADA CARGA
% ==============================================================

for k = 1:n

    figure('Color','w');

    hold on;
    grid on;
    axis equal;

    cor = cores(k,:);

    % Círculo unitário
    plot(cos(theta), sin(theta), ...
         '--', ...
         'Color', [0.55 0.55 0.55], ...
         'LineWidth', 1.4);

    xline(0, 'k:');
    yline(0, 'k:');

    % Vf
    quiver(0, 0, ...
           real(Vf_grafico), imag(Vf_grafico), ...
           0, ...
           'Color', cor, ...
           'LineWidth', 2.2, ...
           'MaxHeadSize', 0.15);

    % EA
    quiver(0, 0, ...
           real(EA_grafico(k)), imag(EA_grafico(k)), ...
           0, ...
           'Color', cor, ...
           'LineWidth', 2.8, ...
           'MaxHeadSize', 0.15);

    % jXsIA partindo da ponta de Vf
    quiver(real(Vf_grafico), imag(Vf_grafico), ...
           real(jXsIA_grafico(k)), ...
           imag(jXsIA_grafico(k)), ...
           0, ...
           'Color', cor, ...
           'LineStyle', '--', ...
           'LineWidth', 2.4, ...
           'MaxHeadSize', 0.17);

    % IA
    quiver(0, 0, ...
           real(IA_grafico(k)), imag(IA_grafico(k)), ...
           0, ...
           'Color', cor, ...
           'LineStyle', ':', ...
           'LineWidth', 2.4, ...
           'MaxHeadSize', 0.17);

    % Ponto de EA no círculo
    plot(real(EA_grafico(k)), ...
         imag(EA_grafico(k)), ...
         'o', ...
         'Color', cor, ...
         'MarkerFaceColor', cor, ...
         'MarkerSize', 7);

    % Textos
    text(real(Vf_grafico) + 0.02, ...
         imag(Vf_grafico) - 0.04, ...
         'V_\phi', ...
         'Color', cor, ...
         'FontWeight', 'bold');

    text(real(EA_grafico(k)) + 0.025, ...
         imag(EA_grafico(k)) + 0.025, ...
         'E_A', ...
         'Color', cor, ...
         'FontWeight', 'bold');

    ponto_medio_X = Vf_grafico + 0.50*jXsIA_grafico(k);

    text(real(ponto_medio_X) + 0.02, ...
         imag(ponto_medio_X), ...
         'jX_sI_A', ...
         'Color', cor, ...
         'FontWeight', 'bold');

    text(0.55*real(IA_grafico(k)), ...
         0.55*imag(IA_grafico(k)) - 0.035, ...
         'I_A', ...
         'Color', cor, ...
         'FontWeight', 'bold');

    xlabel('Eixo real — pu normalizado');
    ylabel('Eixo imaginário — pu normalizado');

    title(sprintf(['Diagrama fasorial — carga de %.0f%%\n' ...
                   '|I_A| = %.4f pu | FP = %.4f %s'], ...
                   carga(k)*100, ...
                   abs(IA(k)), ...
                   FP(k), ...
                   tipo_FP(k)));

    xlim([-0.10 1.15]);
    ylim([-0.75 0.65]);

end