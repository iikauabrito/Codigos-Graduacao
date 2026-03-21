clc
clear

a = exp(1j*2*pi/3);   % 1∠120
a2 = a^2;             % 1∠-120

ZA = 12.5907+9.0467i;
ZB = 10.6745+4.3583i;
ZC = 14.428+7.9213i;

Z0 = (ZA + ZB + ZC)/3;
Z1 = (ZA + a*ZB + a2*ZC)/3;
Z2 = (ZA + a2*ZB + a*ZC)/3;

Z0L= 0.15+0.025i;
ZNN= 0.15+0.025i;

Z = [Z0L+Z0+3*ZNN Z2 Z1;
     Z1 Z0L+Z0 Z2;
     Z2 Z1 Z0L+Z0];
Zinv= inv(Z); %%ISOLEI NO SISTEMA DE EQUAÇÃO

VA = [52.5-54.37i; 146.67-18.28i; 20.83+72.65i]; %%TENSÃO COMPONENTE SIMÉTRICA
IA_COMP=Zinv*VA; %%



T = [1 1 1;
     1 a2 a;
     1 a a2];


I_REAIS = T*IA_COMP;

