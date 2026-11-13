//PARA UTILIZAÇÃO DO AQUISICAO.PY COM 5 POSICOES
float pinoPot = A0;      // Pino do potenciômetro
int enablePin = 10;      // Pino PWM (ENABLE da ponte H)
int in1 = 9;             // Direção 1
int in2 = 8;             // Direção 2

float Ts = 0.05;         // Tempo de amostragem (50ms = 0.05s)
float DC = 47.0;
float setPoint = DC / 100.0;
float erro = 0.0;

void setup() {
  pinMode(enablePin, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  Serial.begin(9600);

  digitalWrite(in2, LOW);
  digitalWrite(in1, HIGH);
}

void loop() {
  int valorPot = analogRead(pinoPot);
  float anguloReal = (valorPot * (90.0 / 344.0)) - 45.0;
  float tempo = millis() / 1000.0; // Tempo decorrido em segundos

  analogWrite(enablePin, DC * 255.0 / 100.0);

  // Envia os 5 campos na ordem exata esperada pelo Aquisicao.py
  Serial.print(DC, 2);
  Serial.print(",");
  Serial.print(anguloReal, 2);
  Serial.print(",");
  Serial.print(erro, 2);
  Serial.print(",");
  Serial.print(tempo, 3);
  Serial.print(",");
  Serial.println(0, 2);

  delay(Ts * 1000);
}
