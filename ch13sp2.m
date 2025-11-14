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
% ch13sp2 (Exemplo 13.2)     A Symbolic Math Toolbox do MATLAB
% e o comando iztrans(F) podem ser usados para obter a
% função de tempo amostrado representada como f(nT), dada sua 
% transformada z, F(z). Caso você deseje a função de tempo amostrada
% retornada como f(kT), então altere a variável independente padrão
% de tempo amostrado do MATLAB usando o comando iztrans(F,k). 
% Vamos resolver o Exemplo 13.2 usando a Symbolic Math Toolbox do MATLAB.

'(ch13sp2) Exemplo 13.2'     % Exibe o título.
syms z k                     % Constrói objetos simbólicos para
                             % 'z' e 'k'.
'F(z)'                       % Exibe o título.					 
F=0.5*z/((z-0.5)*(z-0.7))   % Define F(z).
pretty(F)                    % Exibe F(z) em um formato mais adequado.
'f(kT)'                      % Exibe o título.
f=iztrans(F,k)              % Obtém a transformada z inversa, f(kT).
pretty(f)                    % Exibe f(kT) em um formato mais adequado.
'f(nT)'                      % Exibe o título.
f=iztrans(F)                % Obtém a transformada z inversa, f(nT).
pretty(f)                    % Exibe f(nT)em um formato mais adequado.
