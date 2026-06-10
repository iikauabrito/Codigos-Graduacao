%% GERADOR SINCRONO
% Carga nominal constante
% Corrente de campo variando de 6 a 10 A
% Resistência de armadura desprezada

clear;
clc;
close all;

%% =============================================================
% 1. DADOS NOMINAIS
% =============================================================

Sbase  = 50e6;        % Potência aparente trifásica [VA]
VLbase = 13.8e3;      % Tensão de linha base [V]
Xs_ohm = 2.5;         % Reatância síncrona [ohm]
fp_nom = 0.90;        % Fator de potência nominal
Ppu    = fp_nom;      % Carga ativa nominal = 0,9 pu

% Tensão terminal em pu
Vf = 1 + 1j*0;

%% =============================================================
% 2. GRANDEZAS BASE
% =============================================================

Vfase_base = VLbase/sqrt(3);

Ibase = Sbase/(sqrt(3)*VLbase);

Zbase = VLbase^2/Sbase;

Xs_pu = Xs_ohm/Zbase;

fprintf('Zbase = %.5f ohm\n', Zbase);
fprintf('Xs = %.5f pu\n', Xs_pu);
fprintf('Ibase = %.2f A\n\n', Ibase);

%% =============================================================
% 3. CURVA CARACTERÍSTICA A VAZIO
% =============================================================

% Pontos aproximados retirados da CAV
IF_CAV = 0:10;

VL_CAV_kV = [ ...
    1.0, ...
    5.5, ...
    9.6, ...
    12.7, ...
    14.9, ...
    16.5, ...
    17.6, ...
    18.4, ...
    19.1, ...
    19.6, ...
    20.0];

% Valores de corrente de campo solicitados
IF = 6:10;

% Interpolação da CAV
VL_vazio_kV = interp1(IF_CAV, VL_CAV_kV, IF,'pchip');

% Em pu, a relação pode ser feita usando tensão de linha,
% pois a base também é tensão de linha.
EA_mod = VL_vazio_kV/(VLbase/1e3);

%% =============================================================
% 4. INICIALIZAÇÃO DAS VARIÁVEIS
% =============================================================

n = length(IF);

delta = zeros(1,n);

EA = zeros(1,n);
IA = zeros(1,n);
IL = zeros(1,n);

jXsIA = zeros(1,n);

FP = zeros(1,n);
Qpu = zeros(1,n);

tipo_FP = strings(1,n);

%% =============================================================
% 5. CÁLCULO PARA CADA CORRENTE DE CAMPO
% =============================================================

for k = 1:n

    % ---------------------------------------------------------
    % Ângulo de carga
    %
    % P = EA*Vf/Xs * sen(delta)
    % ---------------------------------------------------------

    argumento = Ppu*Xs_pu/(EA_mod(k)*abs(Vf));

    if abs(argumento) > 1
        error(['Não existe solução estável para IF = %.1f A. ' ...
               'O argumento do arco seno ultrapassou 1.'], IF(k));
    end

    delta(k) = asin(argumento);

    % ---------------------------------------------------------
    % Tensão interna
    % ---------------------------------------------------------

    EA(k) = EA_mod(k)*exp(1j*delta(k));

    % ---------------------------------------------------------
    % Corrente da armadura
    %
    % EA = Vf + jXs*IA
    % IA = (EA - Vf)/(jXs)
    % ---------------------------------------------------------

    IA(k) = (EA(k) - Vf)/(1j*Xs_pu);

    % Ligação em Y
    IL(k) = IA(k);

    % Queda na reatância
    jXsIA(k) = 1j*Xs_pu*IA(k);

    % ---------------------------------------------------------
    % Potência complexa
    %
    % S = V*conj(I)
    % ---------------------------------------------------------

    Spu = Vf*conj(IA(k));

    Qpu(k) = imag(Spu);

    % ---------------------------------------------------------
    % Fator de potência
    % ---------------------------------------------------------

    FP(k) = abs(real(Spu))/abs(Spu);

    % Outra forma equivalente:
    % FP(k) = abs(cos(angle(Vf) - angle(IA(k))));

    if imag(Spu) > 1e-8
        tipo_FP(k) = "atrasado";

    elseif imag(Spu) < -1e-8
        tipo_FP(k) = "adiantado";

    else
        tipo_FP(k) = "unitário";
    end

end

%% =============================================================
% 6. TABELA DE RESULTADOS
% =============================================================

IF_A = IF.';

EA_mod_pu = abs(EA).';
EA_ang_graus = rad2deg(angle(EA)).';

IA_mod_pu = abs(IA).';
IA_ang_graus = rad2deg(angle(IA)).';

IL_mod_pu = abs(IL).';
IL_ang_graus = rad2deg(angle(IL)).';

Q_pu = Qpu.';
Fator_potencia = FP.';
Classificacao = tipo_FP.';

Resultados = table( ...
    IF_A, ...
    EA_mod_pu, ...
    EA_ang_graus, ...
    IA_mod_pu, ...
    IA_ang_graus, ...
    IL_mod_pu, ...
    IL_ang_graus, ...
    Q_pu, ...
    Fator_potencia, ...
    Classificacao);

disp(Resultados);

%% =============================================================
% 7. RESULTADOS NO COMMAND WINDOW
% =============================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf(' IF    |EA|    delta    |IA|    angIA      Q       FP\n');
fprintf(' (A)   (pu)    (graus)  (pu)    (graus)   (pu)\n');
fprintf('============================================================\n');

for k = 1:n

    fprintf('%3.0f   %6.4f   %7.3f   %6.4f   %8.3f   ', ...
        IF(k), ...
        abs(EA(k)), ...
        rad2deg(angle(EA(k))), ...
        abs(IA(k)), ...
        rad2deg(angle(IA(k))));

    fprintf('%7.4f   %6.4f  %s\n', ...
        Qpu(k), ...
        FP(k), ...
        tipo_FP(k));
end

%% =============================================================
% 8. CORES
% =============================================================

% Uma cor para cada corrente de campo:
%
% 6 A  = azul
% 7 A  = vermelho
% 8 A  = verde
% 9 A  = magenta
% 10 A = preto

cores = [
    0.0000  0.4470  0.7410
    0.8500  0.1000  0.1000
    0.1000  0.6500  0.2000
    0.7500  0.1000  0.7500
    0.0000  0.0000  0.0000
];

%% =============================================================
% 9. DIAGRAMA FASORIAL - VERSÃO MAIS NÍTIDA
% =============================================================

fig1 = figure( ...
    'Color','w', ...
    'Name','Diagramas fasoriais', ...
    'NumberTitle','off', ...
    'Position',[100 80 1200 780]);

set(fig1,'Renderer','painters');

ax1 = axes(fig1);

hold(ax1,'on');
grid(ax1,'on');
box(ax1,'on');
axis(ax1,'equal');

% Melhora a nitidez dos textos e dos eixos
ax1.FontSize = 13;
ax1.LineWidth = 1.1;
ax1.GridAlpha = 0.18;
ax1.MinorGridAlpha = 0.10;

xlabel(ax1,'Parte real [pu]', ...
    'FontSize',15, ...
    'FontWeight','bold');

ylabel(ax1,'Parte imaginária [pu]', ...
    'FontSize',15, ...
    'FontWeight','bold');

title(ax1, ...
    'Diagramas fasoriais — carga ativa nominal constante', ...
    'FontSize',17, ...
    'FontWeight','bold');

%% -------------------------------------------------------------
% (1) RETA HORIZONTAL SOBRE A QUAL EA SE DESLOCA
% -------------------------------------------------------------

% Como:
%
% P = EA*Vf/Xs * sen(delta)
%
% Im{EA} = EA*sen(delta) = P*Xs/Vf

y_reta_EA = Ppu*Xs_pu/abs(Vf);

x_inicio_EA = min(real(EA)) - 0.10;
x_final_EA  = max(real(EA)) + 0.18;

plot(ax1, ...
    [x_inicio_EA x_final_EA], ...
    [y_reta_EA y_reta_EA], ...
    '--', ...
    'Color',[0.35 0.35 0.35], ...
    'LineWidth',2.2, ...
    'DisplayName','Reta de E_A');

% Não inserir mais o texto "Reta de P constante"

%% -------------------------------------------------------------
% RETAS VERTICAIS DA POTÊNCIA ATIVA CONSTANTE
% -------------------------------------------------------------

% Como Vphi = 1 pu:
%
% Ppu = Re{IA} = |IA|*cos(theta)
%
% Logo, todas as pontas de IA têm x = Ppu = 0,9.

x_IA_constante = Ppu/abs(Vf);

% Extremo inferior dos vetores IA
y_min_IA = min(imag(IA)) - 0.08;

% Primeira reta vertical: origem
plot(ax1, ...
    [0 0], ...
    [y_min_IA 0.08], ...
    '--', ...
    'Color',[0.30 0.30 0.30], ...
    'LineWidth',1.8, ...
    'HandleVisibility','off');

% Segunda reta vertical: finais dos vetores IA
plot(ax1, ...
    [x_IA_constante x_IA_constante], ...
    [y_min_IA 0.08], ...
    '--', ...
    'Color',[0.30 0.30 0.30], ...
    'LineWidth',1.8, ...
    'HandleVisibility','off');

% Linha horizontal inferior para fechar a representação
plot(ax1, ...
    [0 x_IA_constante], ...
    [y_min_IA y_min_IA], ...
    '--', ...
    'Color',[0.30 0.30 0.30], ...
    'LineWidth',1.5, ...
    'HandleVisibility','off');

% Identificação da componente ativa constante
text(ax1, ...
    x_IA_constante/2, ...
    y_min_IA - 0.045, ...
    '|I_A|cos(\theta)=0,9 pu', ...
    'HorizontalAlignment','center', ...
    'FontSize',12, ...
    'FontWeight','bold', ...
    'Color',[0.25 0.25 0.25]);

%% -------------------------------------------------------------
% EIXOS DE REFERÊNCIA
% -------------------------------------------------------------

plot(ax1, ...
    [-0.15 1.65], ...
    [0 0], ...
    ':', ...
    'Color',[0.45 0.45 0.45], ...
    'LineWidth',1.2, ...
    'HandleVisibility','off');

%% -------------------------------------------------------------
% FASORES PARA CADA CORRENTE DE CAMPO
% -------------------------------------------------------------

for k = 1:n

    cor = cores(k,:);

    % =========================================================
    % (2) TENSÃO DE FASE Vf
    % Desenhar apenas uma vez evita sobreposição
    % =========================================================

    if k == 1

        quiver(ax1, ...
            0,0, ...
            real(Vf),imag(Vf), ...
            0, ...
            'Color',[0 0 0], ...
            'LineWidth',3.0, ...
            'MaxHeadSize',0.14, ...
            'HandleVisibility','off');
    end

    % =========================================================
    % (4) TENSÃO INTERNA EA
    % =========================================================

    quiver(ax1, ...
        0,0, ...
        real(EA(k)),imag(EA(k)), ...
        0, ...
        'Color',cor, ...
        'LineWidth',2.8, ...
        'MaxHeadSize',0.13, ...
        'DisplayName',sprintf('I_F = %.0f A',IF(k)));

    % =========================================================
    % (3) jXsIA
    % Parte da extremidade de Vf e termina na ponta de EA
    % =========================================================

    quiver(ax1, ...
        real(Vf),imag(Vf), ...
        real(jXsIA(k)),imag(jXsIA(k)), ...
        0, ...
        'Color',cor, ...
        'LineWidth',2.4, ...
        'LineStyle','--', ...
        'MaxHeadSize',0.15, ...
        'HandleVisibility','off');

    % =========================================================
    % (5) CORRENTE IA
    % =========================================================

    quiver(ax1, ...
        0,0, ...
        real(IA(k)),imag(IA(k)), ...
        0, ...
        'Color',cor, ...
        'LineWidth',2.4, ...
        'LineStyle',':', ...
        'MaxHeadSize',0.15, ...
        'HandleVisibility','off');

    % Ponto na ponta de EA
    plot(ax1, ...
        real(EA(k)), ...
        imag(EA(k)), ...
        'o', ...
        'Color',cor, ...
        'MarkerFaceColor',cor, ...
        'MarkerSize',6, ...
        'HandleVisibility','off');

    % Foram removidos os números 6, 7, 8, 9 e 10
    % que apareciam próximos às pontas de EA

end

%% -------------------------------------------------------------
% IDENTIFICAÇÕES PRINCIPAIS
% -------------------------------------------------------------

text(ax1, ...
    real(Vf)+0.025, ...
    imag(Vf)-0.065, ...
    'V_\phi', ...
    'FontWeight','bold', ...
    'FontSize',14, ...
    'Color',[0 0 0]);

% Identificação genérica de EA
text(ax1, ...
    max(real(EA))+0.025, ...
    y_reta_EA+0.035, ...
    'E_A', ...
    'FontWeight','bold', ...
    'FontSize',14);

% Identificação genérica da corrente
text(ax1, ...
    x_IA_constante+0.025, ...
    min(imag(IA))-0.015, ...
    'I_A', ...
    'FontWeight','bold', ...
    'FontSize',14);

text(ax1, ...
    1.25, ...
    0.30, ...
    'jX_sI_A', ...
    'FontWeight','bold', ...
    'FontSize',14);

%% -------------------------------------------------------------
% LEGENDA E LIMITES
% -------------------------------------------------------------

legend(ax1, ...
    'Location','northwest', ...
    'FontSize',12, ...
    'Box','on');

xlim(ax1,[-0.15 1.65]);
ylim(ax1,[y_min_IA-0.10 0.82]);

drawnow;

%% -------------------------------------------------------------
% EXPORTAÇÃO COM ALTA NITIDEZ
% -------------------------------------------------------------

exportgraphics( ...
    fig1, ...
    'diagrama_fasorial_nitido.png', ...
    'Resolution',400);