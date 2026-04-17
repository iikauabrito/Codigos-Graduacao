/*
  Controle PID de Pêndulo com PWM manual via interrupção (Timer1)
  
  Período do PWM: 2ms (500Hz)
  Tempo de amostragem PID: 50ms (Ts = 0.05s)
  Ganhos do aluno: Kp=0.0246, Ki=0.1515, Kd=0
  
  Funcionamento:
  - Timer1 gera interrupção a cada 2ms → controla o pulso PWM manualmente
  - O loop() calcula o PID a cada 50ms e atualiza a variável DC (razão cíclica)
  - A ISR usa DC para definir quanto tempo o pino fica em HIGH dentro do período de 2ms
*/

#include <TimerOne.h>  

// ─── Pinos ────────────────────────────────────────────────────────────────────
const int pinoPot   = A0;
const int enablePin = 10;   // Pino PWM manual (saída digital)
const int in1       = 9;
const int in2       = 8;

// ─── Parâmetros PID ───────────────────────────────────────────────────────────
float Kp = 0.0246;
float Ki = 0.1515;
float Kd = 0.0;
float Ts = 0.05;            // Tempo de amostragem do PID: 50ms

// ─── Limites de razão cíclica (%) ────────────────────────────────────────────
float DC_min =  1.0;
float DC_max = 48;

// ─── Variáveis PID ────────────────────────────────────────────────────────────
float erro      = 0.0;
float erro_ant  = 0.0;
float integral  = 0.0;
float derivada  = 0.0;
volatile float DC = 0.0;    // Razão cíclica atual (%) — compartilhada com a ISR

// ─── Setpoint variável ────────────────────────────────────────────────────────
float t        = 0.0;
float setPoint = 5.0;
float ajuste   = 0.019;

// ─── Variáveis do PWM manual (usadas na ISR) ─────────────────────────────────
/*
  Estratégia: o período é de 2ms = 2000µs.
  A ISR é chamada a cada 2ms.
  Dentro de cada chamada, calculamos o tempo em HIGH = DC/100 * 2000µs,
  colocamos o pino em HIGH por esse tempo (delayMicroseconds) e depois LOW
  pelo tempo restante — tudo dentro da ISR.

  Isso representa fielmente o conceito de "escrever a razão cíclica no
  período do PWM" sem depender do hardware interno do analogWrite().
*/
const unsigned long PERIODO_US = 2000;  // 2ms em microssegundos

void pwmISR() {
  // Captura local de DC para evitar inconsistência durante a ISR
  float dc_local = DC;

  // Tempo em HIGH dentro do período de 2ms
  unsigned long t_high = (unsigned long)(dc_local / 100.0 * PERIODO_US);

  if (t_high == 0) {
    digitalWrite(enablePin, LOW);
    return;
  }
  if (t_high >= PERIODO_US) {
    digitalWrite(enablePin, HIGH);
    return;
  }

  // Gera o pulso: HIGH por t_high µs, LOW pelo restante
  digitalWrite(enablePin, HIGH);
  delayMicroseconds(t_high);
  digitalWrite(enablePin, LOW);
  // O tempo LOW restante (PERIODO_US - t_high) é coberto até a próxima chamada
}

// ─── Setup ────────────────────────────────────────────────────────────────────
void setup() {
  pinMode(enablePin, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);

  digitalWrite(in1, HIGH);
  digitalWrite(in2, LOW);

  Serial.begin(9600);
  Serial.println("DC(%),AnguloReal,Erro,SetPoint");

  // Configura Timer1 para chamar pwmISR() a cada 2ms (2000µs)
  Timer1.initialize(PERIODO_US);
  Timer1.attachInterrupt(pwmISR);
}

// ─── Loop principal — roda a cada 50ms (PID) ─────────────────────────────────
void loop() {
  // --- Atualiza setpoint baseado no tempo ---
  if (t <= 50.0) {
    setPoint = -40.0;
  } else if (t <= 100.0) {
    setPoint = -30.0;
  } else if (t <= 150.0) {
    setPoint = -20.0;
  } else if (t <= 200.0) {
    setPoint = -30.0;
  } else {
    t=0;
  }

  // --- Leitura do ângulo ---
  int valorPot    = analogRead(pinoPot);
  float anguloReal = (valorPot * (90.0 / 344.0)) - 45.0;

  // --- Cálculo do PID ---
  erro = setPoint - anguloReal;

  // Termo integral com anti-windup
  integral += erro * Ts;
  if (integral >  DC_max / Ki) integral =  DC_max / Ki;
  if (integral <  DC_min / Ki) integral =  DC_min / Ki;

  // Termo derivativo
  derivada = (erro - erro_ant) / Ts;

  // Nova razão cíclica calculada pelo PID
  float DC_novo = Kp * erro + Ki * integral + Kd * derivada;

  // Saturação
  if (DC_novo > DC_max) DC_novo = DC_max;
  if (DC_novo < DC_min) DC_novo = DC_min;

  // Proteção de segurança — ângulo excessivo
  if (anguloReal > 60.0) {
    DC_novo  = 0.0;
    integral = 20.0;
  }

  // Atualiza DC de forma atômica (interrupção pode ler DC a qualquer momento)
  noInterrupts();
  DC = DC_novo;   // ← A ISR usará este valor no próximo período de 2ms
  interrupts();

  // --- Serial ---
  Serial.print(DC, 2);
  Serial.print(",");
  Serial.print(anguloReal, 2);
  Serial.print(",");
  Serial.print(erro, 2);
  Serial.print(",");
  Serial.print(t, 2);
  Serial.print(",");
  Serial.println(setPoint, 2);

  // --- Atualiza estado ---
  erro_ant = erro;
  t += Ts;

  delay((unsigned long)(Ts * 1000));  // Aguarda próxima amostragem (50ms)
}
