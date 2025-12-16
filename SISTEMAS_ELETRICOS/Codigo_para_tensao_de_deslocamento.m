% Delta -> Y
Za = 1 + 2i;%ETNRE B E C
Zb = 10; %ETNRE A E C
Zc = 3 - 4i; %ETNRE A E B
T = Za + Zb + Zc;

ZF = 0.1 + 0.2i; % COLOCAR A IMPEDANCIA DO FIO

Van = 110 + 63.508552i; %TENSÃO DE FASE
Vbn = -110 + 63.508552i;
Vcn = -127.01705i;

%SE A CARGA JÁ ESTIVER EM Y, COMENTAR ESSAS PROXIMAS 3 LINHAS. E SETAR Z1,
%Z2, Z3
Z1 = (Zb * Zc) / T;
Z2 = (Za * Zc) / T;
Z3 = (Za * Zb) / T;

fprintf('\nDelta -> Y:\n');
fprintf('Z1 = %.4f + %.4fi\n', real(Z1), imag(Z1));
fprintf('Z2 = %.4f + %.4fi\n', real(Z2), imag(Z2));
fprintf('Z3 = %.4f + %.4fi\n', real(Z3), imag(Z3));

YA = 1/(Z1+ZF);
YB = 1/(Z2+ZF);
YC = 1/(Z3+ZF);
Vno = - (Van*YA + Vbn*YB + Vcn*YC) / (YA + YB + YC);
modulo = abs(Vno);
angulo = angle(Vno);
angulo_graus = rad2deg(angulo);

fprintf('Vno = %f fase %f°', modulo, angulo_graus);

