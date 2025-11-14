% Material Suplementar MATLAB Toolbox, Versão 7.0 para o livro
% Engenharia de Sistemas de Controle, Sétima Edição.
%
% Traduzido de:
% CONTROL SYSTEMS ENGINEERING, SEVENTH EDITION 
% Portuguese translation copyright © 2016 by LTC - Livros Técnicos e Científicos Editora Ltda. 
% Translated by permission of John Wiley & Sons, Inc. 
% Copyright © 2015, 2011, 2006, 2003, 1996 by John Wiley & Sons, Inc.
% All Rights Reserved. This translation published under license.
% ISBN: 978-1-118-17051-9
%
% Obra publicada pela LTC:
% ENGENHARIA DE SISTEMAS DE CONTROLE, SÉTIMA EDIÇÃO 
% Direitos exclusivos para a língua portuguesa
% Copyright © 2016 by LTC - Livros Técnicos e Científicos Editora Ltda. 
% Uma editora integrante do GEN | Grupo Editorial Nacional
%
% ch13sp3 (Exemplo 13.4)     A Symbolic Math Toolbox do MATLAB pode ser 
% usada para obter a transformada z de uma função de transferência, G(s),
% em castata com um z.o.h. Dois comandos novos são introduzidos. O 
% primeiro, compose(f,g), permite que uma variável g substitua a variável
% t em f(t). Usamos esse comando para substituir t em g2(t) por nT antes
% de aplicar a transformada z. O outro comando novo é subs(S,velha,nova).
% Subs significa substituição simbólica. velha é uma variável contida em
% S. nova é uma grandeza numérica ou simbólica para substituir velha.
% Usamos subs para substituir T em G(z) por um valor numérico. Para obter
% a transformada z de uma função de transferência, G(s), em cascata com um
% z.o.h. usando a Symbolic Math Toolbox do MATLAB, realizamos os seguintes
% passos: (1) construir G2(s)=G(s)/s (2) obter a transformada inversa de
% Laplace de G2(s) (3) substituir t por nT em g2(t) (4) obter G(z) = 
% (1-z^-1)G2(z), (5) substituir um valor numérico para T. Vamos resolver
% o Exemplo 13.4 usando a Symbolic Math Toolbox do MATLAB.

'(ch13sp3) Exemplo 13.4'     % Exibe o título.
syms s z n T                 % Constroi objetos simbólicos para 
                             % 's', 'z', 'n', e 'T'.
G2s=(s+2)/(s*(s+1));         % Cria G2(s) = G(s)/s.
'G2(s)=G(s)/s'               % Exibe o título.
pretty(G2s)                  % Exibe G2(s) em um formato mais adequado.
'g2(t)'                      % Exibe o título.
g2t=ilaplace(G2s);           % Obtém g2(t).
pretty(g2t)                  % Exibe g2(t) em um formato mais adequado.
g2nT=compose(g2t,n*T)       % Obtém g2(nT).
'g2(nT)'                     % Exibe o título.
pretty(g2nT)                 % Exibe g2(nT) em um formato mais adequado.
Gz=(1-z^-1)*ztrans(g2nT)    % Obtém G(z) = (1-z^-1)G2(z).
Gz=simplify(Gz);
Gz=collect(Gz)              % Simplifica G(z). 
'G(z)=(1-z^-1)G2(z)'         % Exibe o título.
pretty(Gz)                   % Exibe G(z) em um formato mais adequado.
Gz=subs(Gz,T,0.5);           % Faz T = 0.5 em G(z).
Gz=vpa(simplify(Gz),4);      % Simplifica G(z) e calcula valores numéricos
                             % usando precisão de 4 dígitos decimais.
'G(z) calculada para T=0.5'  % Exibe o título.
pretty(Gz)                   % Exibe G(z) com valores numéricos em um
                             % formato mais adequado.
