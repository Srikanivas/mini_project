import math
import os
from datetime import datetime

r = {'Economy': 10, 'Premium': 18, 'SUV': 25}

history = []

class FareError(Exception):
    pass

class InputError(FareError):
    pass

class VehicleError(FareError):
    pass

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
    try:
        with open("rides.log", "a") as f:
            f.write(f"{datetime.now()} | {t} | {km}km | hr={h} | total={total:.2f}\n")
    except OSError as e:
        print(f"Log write failed: {e}")

def load_history():
    try:
        with open("rides.log", "r") as f:
            lines = f.readlines()
            return lines
    except FileNotFoundError:
        return []
    except PermissionError:
        print("No permission to read log.")
        return []

def calculate_fare(km, t, h):
    if not isinstance(km, (int, float)):
        raise InputError("km must be a number")
    if not isinstance(h, int):
        raise InputError("hour must be an integer")
    if t not in r:
        raise VehicleError(f"Service Not Available: '{t}'")
    m = surge(h)
    total = r[t] * km * m
    total = math.ceil(total)
    receipt(t, km, h, r[t], m, total)
    history.append((t, km, h, total))
    save_log(t, km, h, total)
    return total

def show_history():
    if not history:
        print("No rides this session.")
        return
    print("\n--- Session History ---")
    for i, (t, km, h, total) in enumerate(history, 1):
        print(f"{i}. {t} | {km}km | hr={h} | {total}")
    print("-----------------------\n")

def show_rates():
    print("\nAvailable Rates:")
    for k, v in r.items():
        print(f"  {k}: {v}/km")
    print()

def get_input():
    try:
        show_rates()
        t = input("Vehicle type: ").strip().title()
        km = float(input("Distance in km: "))
        h = int(input("Hour of day (0-23): "))
        if not (0 <= h <= 23):
            raise InputError("Hour must be 0-23.")
        if km <= 0:
            raise InputError("Distance must be positive.")
        return km, t, h
    except ValueError:
        raise InputError("Invalid number entered.")

def main():
    print("Welcome to CityCab FareCalc")
    while True:
        try:
            cmd = input("\n[1] New Ride  [2] History  [3] Past Logs  [q] Quit: ").strip()
            if cmd == 'q':
                print("Goodbye!")
                break
            elif cmd == '1':
                try:
                    km, t, h = get_input()
                    calculate_fare(km, t, h)
                except InputError as e:
                    print(f"Input Error: {e}")
                except VehicleError as e:
                    print(f"Vehicle Error: {e}")
                except FareError as e:
                    print(f"Error: {e}")
            elif cmd == '2':
                show_history()
            elif cmd == '3':
                logs = load_history()
                if logs:
                    print("\n--- Past Rides ---")
                    for l in logs[-5:]:
                        print(l.strip())
                    print("------------------\n")
                else:
                    print("No past logs found.")
            else:
                print("Invalid option.")
        except KeyboardInterrupt:
            print("\nInterrupted. Type 'q' to quit.")
        except EOFError:
            break

main()
