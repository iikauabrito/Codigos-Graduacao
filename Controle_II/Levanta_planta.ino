float pinoPot = A0;      // Pino do potenciômetro
int enablePin = 10;      // Pino PWM (ENABLE da ponte H)
int in1 = 9;             // Direção 1
int in2 = 8;             // Direção 2

float Ts = 0.05;         // Tempo de amostragem (50ms = 0.05s)
DC = 47;
setpoint = DC/100;
void setup() {
  pinMode(enablePin, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  Serial.begin(9600);

  // Define direção do motor (ajuste conforme necessário)
  digitalWrite(in2, LOW);
  digitalWrite(in1, HIGH);
  
  Serial.println("DC,AnguloReal,Erro,SetPoint"); // Cabeçalho para CSV
}

void loop(){
  // Leitura do ângulo real do potenciômetro
  int valorPot = analogRead(pinoPot);
  
  // Duas formas de conversão - use a que for mais adequada
  // Forma 1: Baseada no primeiro código (linear)
  float anguloReal = (valorPot * (90.0 / 344.0)) - 45.0;

    // Aplica PWM ao motor
  analogWrite(enablePin, DC * 255.0 / 100.0);

  // Envia dados via Serial para monitoramento
  Serial.print(DC, 2);
  Serial.print(",");
  Serial.print(anguloReal, 2);
  Serial.print(",");
  Serial.print(erro, 2);
  Serial.print(",");
  Serial.println(setPoint, 2);

   delay(Ts * 1000); // Converte para milissegundos
}
