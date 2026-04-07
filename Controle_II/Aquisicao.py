import serial
import serial.tools.list_ports
import csv
import time
from datetime import datetime

BAUD = 9600
ARQUIVO = "amostras_pendulo.csv"

# ---------- FUNÇÃO PARA ENCONTRAR A PORTA ----------
def encontrar_porta():
    portas = serial.tools.list_ports.comports()
    if not portas:
        print("Nenhuma porta serial encontrada.")
        return None

    print("Portas disponíveis:")
    for porta in portas:
        print(f"- {porta.device}")

    return portas[1].device  # pega a primeira automaticamente


PORTA = encontrar_porta() # -------< Coloque aqui a porta que o ARDUINO IDE mostrar

if PORTA is None:
    exit()

# ---------- TENTA CONECTAR ----------
try:
    ser = serial.Serial(PORTA, BAUD, timeout=2)
    time.sleep(2)
except Exception as e:
    print(f"Erro ao conectar na porta {PORTA}: {e}")
    exit()

print(f"Conectado em {PORTA}. Aguardando dados...")

# ---------- CONTROLE DE VARIAÇÃO ----------
ultimo_angulo = None
ultima_velocidade = None
TOL = 0.01  # tolerância para evitar ruído

# ---------- ABRE CSV ----------
with open(ARQUIVO, "w", newline="", buffering=1) as f:
    writer = csv.writer(f)

    # Cabeçalho fixo
    writer.writerow(["timestamp", "tempo", "angulo", "velocidade"])

    try:
        while True:
            linha = ser.readline().decode("utf-8", errors="ignore").strip()
            if not linha:
                continue

            print(linha)

            dados = linha.split(",")

            # Espera: tempo,angulo,velocidade
            if len(dados) < 3:
                continue

            try:
                tempo = float(dados[0])
                angulo = float(dados[1])
                velocidade = float(dados[2])
            except ValueError:
                continue  # ignora linha inválida

            # Salva só se houver mudança relevante
            if (ultimo_angulo is None or 
                abs(angulo - ultimo_angulo) > TOL or 
                abs(velocidade - ultima_velocidade) > TOL):

                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")

                writer.writerow([timestamp, tempo, angulo, velocidade])

                ultimo_angulo = angulo
                ultima_velocidade = velocidade

    except KeyboardInterrupt:
        print(f"\nCaptura encerrada. Arquivo salvo: {ARQUIVO}")

    finally:
        ser.close()
