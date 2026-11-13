float pinoPot = A0;      // Pino do potenciÃ´metro
int enablePin = 10;      // Pino PWM (ENABLE da ponte H)
int in1 = 9;             // DireÃ§Ã£o 1
int in2 = 8;             // DireÃ§Ã£o 2

// Controle PID
float ref = -30;        // ReferÃªncia de Ã¢ngulo (graus)
float erro = 0.0;
float erro_ant = 0.0;
float integral = 0.0;
float derivada = 0.0;

float Kp = 176838.829;    // Ganho proporcional
float Ki = 5;             // Ganho integral
float Kd = 8841;         // Ganho derivativo (ajuste conforme necessÃ¡rio)

float Ts = 0.05;          // Tempo de amostragem (50ms = 0.05s)

float DC = 36;            // Duty cycle do PWM (%)
float DC_min = 35.0;      // Limite mÃ­nimo do PWM
//float DC_max = 46.5;      // Limite mÃ¡ximo do PWM

// Coeficientes do filtro IIR (modelo planta: PWM -> Ã‚ngulo)
const float a1 = 1.999;
const float a2 = -0.9995;
const float b0 = 2.151e-6;

// Vetores para histÃ³rico do filtro
float x[3] = {0, 0, 0};   // Entradas PWM
float y[3] = {0, 0, 0};   // SaÃ­das estimadas do Ã¢ngulo

void setup() {
  pinMode(enablePin, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  Serial.begin(9600);

  digitalWrite(in2, LOW);
  digitalWrite(in1, HIGH);
}

void loop() {
  // Leitura do Ã¢ngulo real do potenciÃ´metro
  int valorPot = analogRead(pinoPot);
  float anguloReal = (valorPot * (90.0 / 344.0)) - 45.0;

  // CÃ¡lculo do erro
  erro = ref - anguloReal;
  integral += erro * Ts;                            // Integral acumulada
  derivada = (erro - erro_ant) / Ts;                // Derivada do erro

  // Controle PID (controle do PWM)
  //DC = Kp * erro + Ki * integral + Kd * derivada;

  // SaturaÃ§Ã£o do PWM
 // if (DC > DC_max) DC = DC_max;
 // if (DC < DC_min) DC = DC_min;

  // Atualiza histÃ³rico do filtro
  x[2] = x[1];
  x[1] = x[0];
  x[0] = DC;

  y[2] = y[1];
  y[1] = y[0];

  // Modelo da planta (simula Ã¢ngulo estimado)
  y[0] = b0 * x[0] + a1 * y[1] + a2 * y[2];

  // Aplica PWM ao motor
  analogWrite(enablePin, DC * 255.0 / 100.0);

  // Envia dados via Serial
  Serial.print(ref, 2);
  Serial.print(",");
  Serial.print(anguloReal, 2);
  Serial.print(",");
  Serial.print(y[0], 6);
  Serial.print(",");
  Serial.println(DC, 2);

  // Atualiza erro anterior
  erro_ant = erro;

  delay(50); // Amostragem ~20 Hz (50 ms)
}