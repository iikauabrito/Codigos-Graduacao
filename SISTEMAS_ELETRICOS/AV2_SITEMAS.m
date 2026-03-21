clc
clear

a = exp(1j*2*pi/3);   % 1∠120
a2 = a^2;             % 1∠-120

ZAL = 0;
ZBL = 0;
ZCL = 0;

ZA = 0;
ZB = 0;
ZC = 0;

VA = 0;
VB = 0;
VC = 0;

Z0L = (ZAL + ZBL + ZCL)/3;
Z1L = (ZAL + a*ZBL + a2*ZCL)/3;
Z2L = (ZAL + a2*ZBL + a*ZCL)/3;

Z0 = (ZA + ZB + ZC)/3;
Z1 = (ZA + a*ZB + a2*ZC)/3;
Z2 = (ZA + a2*ZB + a*ZC)/3;


T = [1 1 1;
     1 a2 a;
     1 a a2];

Tinv = (1/3)*[1 1 1;
              1 a a2;
              1 a2 a];


VA = Tinv*[VA; VB; VC];

ZL = [Z0L Z2L Z1L;
      Z1L Z0L Z2L;
      Z2L Z1L Z0L];

Z = [Z0 Z2 Z1;
      Z1 Z0 Z2;
      Z2 Z1 Z0];

IA = [IA0; IA1; IA2];

VA = ZL*IA + Z*IA +3*ZNN*IA0*[1; 0; 0]
VA = (ZL + Z)*IA +3*ZNN*IA0*[1; 0; 0]