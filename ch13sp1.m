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
% Capítulo 13: Sistemas de Controle Digital
%
% ch13sp1 (Exemplo 13.1)     A Symbolic Math Toolbox do Matlab
% e o comando, ztrans(f), podem ser usados para obter a
% transformada z de uma função do tempo, f, representada como f(nT).
% O MATLAB considera que a variável independente padrão de tempo amostrado
% é n e que a variável independente padrão da transformada é z. Caso você
% deseje usar k ao invés de n, isto é, f(kT), use ztrans(f,k,z).
% Este comando sobrepõe os valores padrão do MATLAB e considera a
% variável independente de tempo amostrado como sendo k. Vamos resolver
% o Example 13.1 usando a Symbolic Math Toolbox do MATLAB.

'(ch13sp1) Exemplo 13.1'     % Exibe o título.
syms n T                     % Constrói objetos simbólicos para 
                             % 'n' e 'T'.
'f(nT)'                      % Exibe o título.					 
f=n*T;                       % Define f(nT).
pretty(f)                    % Exibe f(nT) em um formato mais adequado.
'F(z)'                       % Exibe o título.
F=ztrans(f);                 % Obtém a transformada z, F(z).
pretty(F)                    % Exibe F(z) em um formato mais adequado.
