close all
clear all

d = 0.47;        
num_amostras = 5;

figure;
hold on;

Ts      = zeros(1, num_amostras);
saida   = cell(1, num_amostras);
entrada = cell(1, num_amostras);
tempo = cell(1, num_amostras);

for i = 1:num_amostras
    nome = sprintf('amostra%d.csv', i);
    dados = readtable(nome);

    % Converte timestamp para segundos relativos
    t = datetime(dados{:,1}, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSSSS');
    tempo{i} = seconds(t - t(1));

    % Saída: ângulo
    saida{i} = dados{:,3};

    % Período de amostragem individual
    Ts(i) = mean(diff(tempo{i}));

    % Entrada: degrau com amplitude d
    entrada{i} = d * ones(size(saida{i}));

    fprintf('amostra%d → Ts = %.4f s (%.2f Hz)\n', i, Ts(i), 1/Ts(i));

    plot(tempo{i}, saida{i}, 'LineWidth', 1, 'DisplayName', sprintf('amostra%d', i));
end

hold off;
legend show;
xlabel('Tempo (s)');
ylabel('Ângulo (°)');
title('Ângulo vs Tempo');
grid on;

Ts_comum = mean(Ts);
fprintf('\nTs comum (média dos 12): %.4f s (%.2f Hz)\n', Ts_comum, 1/Ts_comum);
