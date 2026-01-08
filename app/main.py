import time
import sys

print("--- Starting Service Monitor v1.0 ---")
print("[INFO] Initializing environment...")
time.sleep(1)
print("[INFO] Connection established.")

# Une boucle infinie qui fait semblant de travailler
counter = 0
while True:
    print(f"[LOG] System checking... Tick {counter}")
    counter += 1
    sys.stdout.flush()
    time.sleep(5)
