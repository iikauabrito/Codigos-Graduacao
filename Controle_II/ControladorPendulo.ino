// ==========================================================
// CONFIGURAÇÃO INICIAL (Altere aqui o período de amostragem)
// ==========================================================
float Ts = 0.020; // Período em segundos (Ex: 0.020 = 50Hz, 0.010 = 100Hz)
float DC = 48.0;  // Duty Cycle do degrau (%)

// Definições de Pinos
const uint8_t POT = A0;
const uint8_t PWMPIN = 3;
const uint8_t IN3 = 9;
const uint8_t IN4 = 8;

// Variáveis Globais de Controle
volatile int leituraBruta = 0;
volatile unsigned long contadorAmostras = 0;
volatile bool novoDado = false;
float angulo;

// Constantes e variáveis do PID
const float Kp = 3.44;
const float Ki = 5.03;
const float Kd = 0.589;
const float DC_min = 38.0;
const float DC_max = 70.0;

float ref = -45.0; // Começa na posição inicial de repouso
float erro = 0.0;
float erro_ant = 0.0;
float integral = 0.0;
float derivada = 0.0;

// Protótipo da função
void configurarInterrupcao(float periodo);

void setup() {
  pinMode(POT, INPUT);
  pinMode(PWMPIN, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
  
  Serial.begin(115200);

  analogWrite(PWMPIN, (0 * 255.0) / 100.0);

  // Definição da rotação do motor
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);

  // --- 4. CONFIGURAÇÃO DINÂMICA DA INTERRUPÇÃO ---
  configurarInterrupcao(Ts);
}

// Função que calcula e configura o Timer1 com base no Ts fornecido
void configurarInterrupcao(float periodo) {
  uint32_t valorOCR = (16000000.0 * periodo / 256.0) - 1;

  if (valorOCR > 65535) valorOCR = 65535;
  if (valorOCR < 1) valorOCR = 1;

  noInterrupts();           
  TCCR1A = 0;               
  TCCR1B = 0;
  TCNT1  = 0;               
  
  OCR1A = (uint16_t)valorOCR; 
  
  TCCR1B |= (1 << WGM12);   
  TCCR1B |= (1 << CS12);    
  TIMSK1 |= (1 << OCIE1A);  
  interrupts();             
}

// Rotina de Serviço de Interrupção (ISR)
ISR(TIMER1_COMPA_vect) {
  leituraBruta = analogRead(POT);
  contadorAmostras++;
  novoDado = true;
}

void loop() {
  if (novoDado) {
    // 1. Cópia segura das variáveis da interrupção (Atomic Read)
    noInterrupts();
    int copiaLeitura = leituraBruta;
    unsigned long copiaContador = contadorAmostras;
    novoDado = false; // Já avisa que consumiu o dado
    interrupts();

    // 2. Cálculo do ângulo com o dado seguro
    angulo = (copiaLeitura * (90.0 / 344.0)) - 45.0;
    
    // 3. Tempo decorrido (Movido para cá para atualizar a referência antes do PID)
    float tempoSegundos = copiaContador * Ts;

    // ==========================================================
    // LÓGICA DE DEGRAU AUTOMÁTICO A CADA 10 SEGUNDOS
    // Cria um ciclo de 4 estágios (40 segundos totais)
    // ==========================================================
    int estagio = (int)(tempoSegundos / 10.0) % 4; 
    
    switch(estagio) {
      case 0:
        ref = -45.0; // 0 a 10s (Retorna ao repouso)
        break;
      case 1:
        ref = -30.0; // 10 a 20s (Primeiro degrau)
        break;
      case 2:
        ref = -15.0; // 20 a 30s (Segundo degrau)
        break;
      case 3:
        ref = -5.0;  // 30 a 40s (Terceiro degrau)
        break;
    }

    // 4. Cálculos base do PID
    erro = ref - angulo;
    derivada = (erro - erro_ant) / Ts;
    
    // Cálculo provisório do PID para checar saturação
    float termo_proporcional = Kp * erro;
    float termo_derivativo = Kd * derivada;
    // Soma a integral com o valor atual do erro
    float integral_provisoria = integral + (erro * Ts);
    float termo_integral = Ki * integral_provisoria;

    DC = termo_proporcional + termo_integral + termo_derivativo;

    // 5. ANTI-WINDUP E SATURAÇÃO
    if(DC > DC_max) {
      DC = DC_max;
    } 
    else if(DC < DC_min) {
      DC = DC_min;
    } 
    else {
      integral = integral_provisoria;
    }

    // 6. Atualiza o Hardware
    analogWrite(PWMPIN, (DC * 255.0) / 100.0);

    // 7. Atualiza variáveis passadas
    erro_ant = erro;

    // 8. Envia dados via Serial
    Serial.print(ref, 2);
    Serial.print(",");
    Serial.print(angulo, 2);
    Serial.print(",");
    Serial.print(DC, 2);
    Serial.print(",");
    Serial.println(tempoSegundos);
  }
}