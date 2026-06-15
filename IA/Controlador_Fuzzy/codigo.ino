/*
  Controle PI + Fuzzy corretivo para pêndulo acionado por motor DC + ponte H

  Planta:
  - Pêndulo com faixa útil desejada de -45° até 0°
  - Motor gira em apenas um sentido
  - Quanto maior o duty cycle, mais o pêndulo sobe
  - Duty máximo limitado a 48% por segurança

  Estratégia:
  DC = DC_PI + deltaDC_Fuzzy

  Entradas do Fuzzy:
  - erro = setPoint - anguloReal
  - deltaErro = erro atual - erro anterior

  Saída do Fuzzy:
  - deltaDC_Fuzzy, uma correção pequena no duty cycle

  Versão sem biblioteca Fuzzy.
*/

#include <TimerOne.h>

// ─── Pinos ────────────────────────────────────────────────────────────────────
const int pinoPot   = A0;
const int enablePin = 10;
const int in1       = 9;
const int in2       = 8;

// ─── Parâmetros PI ────────────────────────────────────────────────────────────
float Kp = 0.0246;
float Ki = 0.1515;
float Kd = 0.0;

float Ts = 0.05;  // 50 ms

// ─── Limites do duty cycle (%) ────────────────────────────────────────────────
float DC_min = 1.0;
float DC_max = 48.0;

// ─── Limite de segurança angular ──────────────────────────────────────────────
// Como a faixa física vai até +20°, pare antes de bater mecanicamente.
float anguloSeguranca = 15.0;

// ─── Variáveis do controlador ─────────────────────────────────────────────────
float erro       = 0.0;
float erro_ant   = 0.0;
float deltaErro  = 0.0;
float integral   = 0.0;
float derivada   = 0.0;

volatile float DC = 0.0;

// ─── Setpoint em degraus de -45 até 0 ─────────────────────────────────────────
float tempoControle = 0.0;
float setPoint = -45.0;

const float tempoPorDegrau = 50.0;  // segundos em cada referência

// ─── PWM manual ───────────────────────────────────────────────────────────────
const unsigned long PERIODO_US = 2000;  // 2 ms = 500 Hz

void pwmISR() {
  float dc_local = DC;

  if (dc_local < 0.0) dc_local = 0.0;
  if (dc_local > 100.0) dc_local = 100.0;

  unsigned long t_high = (unsigned long)(dc_local / 100.0 * PERIODO_US);

  if (t_high == 0) {
    digitalWrite(enablePin, LOW);
    return;
  }

  if (t_high >= PERIODO_US) {
    digitalWrite(enablePin, HIGH);
    return;
  }

  digitalWrite(enablePin, HIGH);
  delayMicroseconds(t_high);
  digitalWrite(enablePin, LOW);
}

// ─── Funções auxiliares Fuzzy sem biblioteca ──────────────────────────────────

float limitar(float x, float minimo, float maximo) {
  if (x < minimo) return minimo;
  if (x > maximo) return maximo;
  return x;
}

// Função triangular
float trimf(float x, float a, float b, float c) {
  if (x <= a || x >= c) return 0.0;
  if (x == b) return 1.0;
  if (x < b) return (x - a) / (b - a);
  return (c - x) / (c - b);
}

// Ombro esquerdo: pertinência alta no lado mais negativo
float leftShoulder(float x, float a, float b) {
  if (x <= a) return 1.0;
  if (x >= b) return 0.0;
  return (b - x) / (b - a);
}

// Ombro direito: pertinência alta no lado mais positivo
float rightShoulder(float x, float a, float b) {
  if (x <= a) return 0.0;
  if (x >= b) return 1.0;
  return (x - a) / (b - a);
}

/*
  Controlador Fuzzy manual.

  Conjuntos do erro:
  NG = negativo grande
  NP = negativo pequeno
  Z  = zero
  PP = positivo pequeno
  PG = positivo grande

  Conjuntos do deltaErro:
  DNG = diminuindo muito
  DNP = diminuindo pouco
  DZ  = quase constante
  DPP = aumentando pouco
  DPG = aumentando muito

  Saída:
  RM = reduzir muito
  RP = reduzir pouco
  M  = manter
  AP = aumentar pouco
  AM = aumentar muito
*/

float fuzzyControllerManual(float e, float de) {
  // Limita entradas para evitar que valores muito grandes distorçam as regras
  e  = limitar(e,  -20.0, 20.0);
  de = limitar(de, -10.0, 10.0);

  // Pertinências do erro
  float e_NG = leftShoulder(e, -20.0, -10.0);
  float e_NP = trimf(e, -15.0, -7.0, 0.0);
  float e_Z  = trimf(e, -3.0, 0.0, 3.0);
  float e_PP = trimf(e, 0.0, 7.0, 15.0);
  float e_PG = rightShoulder(e, 10.0, 20.0);

  // Pertinências da variação do erro
  float de_DNG = leftShoulder(de, -10.0, -5.0);
  float de_DNP = trimf(de, -8.0, -4.0, 0.0);
  float de_DZ  = trimf(de, -1.5, 0.0, 1.5);
  float de_DPP = trimf(de, 0.0, 4.0, 8.0);
  float de_DPG = rightShoulder(de, 5.0, 10.0);

  float E[5]  = {e_NG, e_NP, e_Z, e_PP, e_PG};
  float DE[5] = {de_DNG, de_DNP, de_DZ, de_DPP, de_DPG};

  /*
    Matriz de regras:

              DNG   DNP   DZ    DPP   DPG
    NG        RM    RM    RM    RP    M
    NP        RM    RP    RP    M     AP
    Z         RP    RP    M     AP    AP
    PP        M     AP    AP    AM    AM
    PG        AP    AM    AM    AM    AM
  */

  float RM = -8.0;
  float RP = -3.0;
  float M  =  0.0;
  float AP =  3.0;
  float AM =  8.0;

  float regras[5][5] = {
    {RM, RM, RM, RP, M },
    {RM, RP, RP, M,  AP},
    {RP, RP, M,  AP, AP},
    {M,  AP, AP, AM, AM},
    {AP, AM, AM, AM, AM}
  };

  // Inferência tipo mínimo no antecedente + média ponderada na saída
  float numerador = 0.0;
  float denominador = 0.0;

  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 5; j++) {
      float ativacao = min(E[i], DE[j]);

      numerador   += ativacao * regras[i][j];
      denominador += ativacao;
    }
  }

  if (denominador == 0.0) {
    return 0.0;
  }

  float deltaDC = numerador / denominador;

  // Segurança extra: limita a correção fuzzy
  deltaDC = limitar(deltaDC, -8.0, 8.0);

  return deltaDC;
}

// ─── Atualização do setpoint ──────────────────────────────────────────────────

float calcularSetPoint(float t) {
  int etapa = (int)(t / tempoPorDegrau);

  switch (etapa) {
    case 0: return -45.0;
    case 1: return -40.0;
    case 2: return -35.0;
    case 3: return -30.0;
    case 4: return -25.0;
    case 5: return -20.0;
    case 6: return -15.0;
    case 7: return -10.0;
    case 8: return -5.0;
    case 9: return 0.0;
    default:
      tempoControle = 0.0;
      return -45.0;
  }
}

// ─── Setup ────────────────────────────────────────────────────────────────────

void setup() {
  pinMode(enablePin, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);

  // Motor em apenas um sentido
  digitalWrite(in1, HIGH);
  digitalWrite(in2, LOW);

  Serial.begin(9600);
  Serial.println("DC,DC_PI,DeltaDC_Fuzzy,AnguloReal,Erro,DeltaErro,SetPoint,Tempo");

  Timer1.initialize(PERIODO_US);
  Timer1.attachInterrupt(pwmISR);
}

// ─── Loop principal ───────────────────────────────────────────────────────────

void loop() {
  setPoint = calcularSetPoint(tempoControle);

  // Leitura do potenciômetro
  int valorPot = analogRead(pinoPot);

  // Calibração informada como correta
  float anguloReal = (valorPot * (90.0 / 344.0)) - 45.0;

  // Cálculo do erro
  erro = setPoint - anguloReal;

  // Variação do erro em graus por amostra
  deltaErro = erro - erro_ant;

  // Derivada em graus por segundo, apenas para registro
  derivada = deltaErro / Ts;

  // Integral com anti-windup
  integral += erro * Ts;

  if (integral > DC_max / Ki) {
    integral = DC_max / Ki;
  }

  if (integral < 0.0) {
    integral = 0.0;
  }

  // Controle PI
  float DC_PI = Kp * erro + Ki * integral;

  // Correção fuzzy
  float deltaDC_Fuzzy = fuzzyControllerManual(erro, deltaErro);

  // Controle final
  float DC_novo = DC_PI + deltaDC_Fuzzy;

  // Saturação do duty
  DC_novo = limitar(DC_novo, DC_min, DC_max);

  // Proteção mecânica
  if (anguloReal > anguloSeguranca) {
    DC_novo = 0.0;
    integral = 0.0;
  }

  // Atualiza DC de forma atômica
  noInterrupts();
  DC = DC_novo;
  interrupts();

  // Serial para análise
  Serial.print(DC_novo, 2);
  Serial.print(",");
  Serial.print(DC_PI, 2);
  Serial.print(",");
  Serial.print(deltaDC_Fuzzy, 2);
  Serial.print(",");
  Serial.print(anguloReal, 2);
  Serial.print(",");
  Serial.print(erro, 2);
  Serial.print(",");
  Serial.print(deltaErro, 2);
  Serial.print(",");
  Serial.print(setPoint, 2);
  Serial.print(",");
  Serial.println(tempoControle, 2);

  erro_ant = erro;
  tempoControle += Ts;

  delay((unsigned long)(Ts * 1000));
}
