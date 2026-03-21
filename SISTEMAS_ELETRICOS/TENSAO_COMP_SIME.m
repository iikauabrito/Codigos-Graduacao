

a = exp(1j*2*pi/3);   % 1∠120
a2 = a^2;             % 1∠-120

Tinv = (1/3)*[1 1 1;
              1 a a2;
              1 a2 a];
VA = 220;
VB = 220*a2;
VC = 54.8482*exp(1j*pi/6);

VA_COM = Tinv*[VA; VB; VC];