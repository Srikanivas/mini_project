import math
from datetime import datetime

r = {'Economy': 10, 'Premium': 18, 'SUV': 25}

history = []

def surge(h):
    return 1.5 if 17 <= h <= 20 else 1.0

def receipt(t, km, h, base, m, total):
    print("\n===== CityCab Price Receipt =====")
    print(f"Vehicle   : {t}")
    print(f"Distance  : {km} km")
    print(f"Rate/km   : {base}")
    print(f"Hour      : {h:02d}:00  {'[SURGE 1.5x]' if m > 1 else ''}")
    print(f"Base Fare : {base * km:.2f}")
    print(f"Total     : {total:.2f}")
    print(f"Time      : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=================================\n")

def save_log(t, km, h, total):
    f = open("rides.log", "a")
    f.write(f"{datetime.now()} | {t} | {km}km | hr={h} | total={total:.2f}\n")
    f.close()

def load_history():
    f = open("rides.log", "r")
    lines = f.readlines()
    f.close()
    return lines

def show_rates():
    print("\nAvailable Rates:")
    for k, v in r.items():
        print(f"  {k}: {v}/km")
    print()

def calculate_fare(km, t, h):
    if t not in r:
        print("Service Not Available:", t)
        return
    m = surge(h)
    total = math.ceil(r[t] * km * m)
    receipt(t, km, h, r[t], m, total)
    history.append((t, km, h, total))
    save_log(t, km, h, total)

def show_history():
    if len(history) == 0:
        print("No rides this session.")
        return
    print("\n--- Session History ---")
    for i in range(len(history)):
        t, km, h, total = history[i]
        print(f"{i+1}. {t} | {km}km | hr={h} | {total}")
    print("-----------------------\n")

def get_input():
    show_rates()
    t = input("Vehicle type: ").strip().title()
    try:
        km = float(input("Distance in km: "))
        h = int(input("Hour of day (0-23): "))
    except ValueError:
        print("Invalid input, enter numbers only.")
        return None
    if h < 0 or h > 23:
        print("Hour must be between 0 and 23.")
        return None
    if km <= 0:
        print("Distance must be positive.")
        return None
    return km, t, h

def main():
    print("Welcome to CityCab FareCalc")
    while True:
        cmd = input("\n[1] New Ride  [2] History  [3] Past Logs  [q] Quit: ").strip()
        if cmd == 'q':
            print("Goodbye!")
            break
        elif cmd == '1':
            data = get_input()
            if data != None:
                km, t, h = data
                calculate_fare(km, t, h)
        elif cmd == '2':
            show_history()
        elif cmd == '3':
            logs = load_history()
            if len(logs) > 0:
                print("\n--- Past Rides ---")
                for l in logs[-5:]:
                    print(l.strip())
                print("------------------\n")
            else:
                print("No past logs found.")
        else:
            print("Invalid option.")

main()
