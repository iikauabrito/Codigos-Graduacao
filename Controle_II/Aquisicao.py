import serial
import serial.tools.list_ports
import csv
import os
import time
from datetime import datetime

BAUD = 9600
ARQUIVO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "amostras_pendulo.csv")

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


PORTA = encontrar_porta()

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
ultimo_DC = None
TOL = 0.01  # tolerância para evitar ruído

# ---------- ABRE CSV ----------
with open(ARQUIVO, "w", newline="", buffering=1) as f:
    writer = csv.writer(f)

    # Cabeçalho fixo
    writer.writerow(["timestamp", "DC", "angulo", "erro", "tempo", "setPoint"])

    try:
        while True:
            linha = ser.readline().decode("utf-8", errors="ignore").strip()
            if not linha:
                continue

            print(linha)

            dados = linha.split(",")
            
            # Espera: DC,angulo,erro,tempo,setPoint
            if len(dados) < 5:
                continue

            try:
                DC = float(dados[0])
                angulo = float(dados[1])
                erro = float(dados[2])
                tempo = float(dados[3])
                setPoint = float(dados[4])
            except ValueError:
                continue  # ignora linha inválida

            # Salva só se houver mudança relevante
            if (ultimo_angulo is None or
                abs(angulo - ultimo_angulo) > TOL or
                abs(DC - ultimo_DC) > TOL):

                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")

                writer.writerow([timestamp, DC, angulo, erro, tempo, setPoint])

                ultimo_angulo = angulo
                ultimo_DC = DC
    except KeyboardInterrupt:
        print(f"\nCaptura encerrada. Arquivo salvo: {ARQUIVO}")

    finally:
        ser.close()
