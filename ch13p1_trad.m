% Nise, N.S.
% Control Systems Engineering, 5th ed.
% John Wiley & Sons, Hoboken, NJ, 07030
%
% Control Systems Engineering Toolbox Version 5.0
% Copyright © 2008 by John Wiley & Sons, Inc.
% All rights reserved. This translation published under license
%
% Direitos exclusivos para a língua portuguesa
% Nise, N.S.
% Engenharia de Sistemas de Controle, 5a. ed.
% Copyright © 2009 by
% LTC - Livros Técnicos e Científicos Editora S.A.
% Uma editora integrante do GEN| Grupo Editorial Nacional
% Reservados todos os direitos. É proibida a duplicação ou
% reprodução deste material, no todo ou em parte, sob quaisquer formas
% ou por quaisquer meios,(eletrônico, mecânico, gravação, fotocópia,
% distribuição na internet e outros), sem permissão expressa da Editora.
%
% Capítulo 13: Sistemas de Controle Digital 
% (ch13p1) Exemplo 13.4:  Pode-se converter G1(s) em cascata com um extrapolador 
% de ordem zero (z.o.h. – zero-order hold) em G(z) utilizando o comando MATLAB 
% G = c2d(G1,T,’zoh’), onde G1 é um objeto de sistema contínuo LIT e G é um objeto 
% de sistema amostrado LIT. T é o período de amostragem e ‘zoh’ é um método de 
% transformação que supõe G1(s) em cascata com um z.o.h. Coloca-se simplesmente 
% G1(s) no comando (o z.o.h. é automaticamente considerado) e o comando retorna G(z). 
% Aplica-se este conceito ao Exemplo 13.4. Você entrará com o valor de T através 
% do teclado.

'(ch13p1) Exemplo 13.4'             % Exibe o título.
T=input('Digite T ');               % Entra com o período de amostragem.
numg1s=[1 2];                       % Define o numerador de G1(s).
deng1s=[1 1];                       % Define o denominador de G1(s).
'G1(s)'                             % Exibe o título.
G1=tf(numg1s,deng1s)                % Cria G1(s) e exibe.
'G(z)'                              % Exibe o título.
G=c2d(G1,T,'zoh')                   % Converte G1(s) em cascata com z.o.h.
                                    % em G1(z) e exibe na tela.

