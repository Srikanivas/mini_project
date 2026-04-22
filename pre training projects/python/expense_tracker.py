import csv
import os
from datetime import datetime

FILE = "expenses.csv"
CATS = ["Food", "Travel", "Bills", "Shopping", "Other"]

def load():
    data = []
    if not os.path.exists(FILE):
        return data
    try:
        f = open(FILE, "r")
        r = csv.DictReader(f)
        for row in r:
            data.append(row)
        f.close()
    except Exception:
        print("Error reading file.")
    return data

def save(row):
    exists = os.path.exists(FILE)
    try:
        f = open(FILE, "a", newline="")
        w = csv.DictWriter(f, fieldnames=["date", "cat", "amt", "desc"])
        if not exists:
            w.writeheader()
        w.writerow(row)
        f.close()
    except Exception:
        print("Error saving expense.")

def show_cats():
    print("Categories:")
    for i in range(len(CATS)):
        print(f"  {i+1}. {CATS[i]}")

def monthly_summary(data):
    m = {}
    for row in data:
        mon = row["date"][:7]
        amt = float(row["amt"])
        if mon not in m:
            m[mon] = 0
        m[mon] += amt
    print("\n--- Monthly Summary ---")
    for k in sorted(m):
        print(f"  {k} : Rs.{m[k]:.2f}")
    print()

def cat_breakdown(data):
    c = {}
    for row in data:
        cat = row["cat"]
        amt = float(row["amt"])
        if cat not in c:
            c[cat] = 0
        c[cat] += amt
    print("\n--- Category Breakdown ---")
    for k, v in sorted(c.items(), key=lambda x: x[1], reverse=True):
        print(f"  {k} : Rs.{v:.2f}")
    if len(c) > 0:
        top = max(c, key=lambda x: c[x])
        print(f"\n  Highest Spending: {top} (Rs.{c[top]:.2f})")
        print(f"  Suggestion: Try to reduce spending on {top}.")
    print()

def add_expense():
    show_cats()
    try:
        ci = int(input("Choose category (1-5): ")) - 1
        if ci < 0 or ci > 4:
            print("Invalid category.")
            return
        cat = CATS[ci]
        amt = float(input("Amount (Rs.): "))
        if amt <= 0:
            print("Amount must be positive.")
            return
    except ValueError:
        print("Invalid input.")
        return
    desc = input("Description: ").strip()
    dt = datetime.now().strftime("%Y-%m-%d")
    row = {"date": dt, "cat": cat, "amt": amt, "desc": desc}
    save(row)
    print("Expense saved.")

def show_all(data):
    if len(data) == 0:
        print("No expenses found.")
        return
    print("\n--- All Expenses ---")
    for r in data:
        print(f"  {r['date']} | {r['cat']} | Rs.{r['amt']} | {r['desc']}")
    print()

def pie_chart(data):
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not installed. Run: pip install matplotlib")
        return
    c = {}
    for row in data:
        cat = row["cat"]
        amt = float(row["amt"])
        if cat not in c:
            c[cat] = 0
        c[cat] += amt
    if len(c) == 0:
        print("No data to plot.")
        return
    plt.pie(
        list(c.values()),
        labels=list(c.keys()),
        autopct="%1.1f%%"
    )
    plt.title("Expense Breakdown")
    plt.show()

def main():
    print("=== Smart Expense Tracker ===")
    while True:
        print("\n[1] Add Expense")
        print("[2] View All")
        print("[3] Monthly Summary")
        print("[4] Category Breakdown")
        print("[5] Pie Chart")
        print("[q] Quit")
        cmd = input("Choice: ").strip()
        data = load()
        if cmd == "1":
            add_expense()
        elif cmd == "2":
            show_all(data)
        elif cmd == "3":
            monthly_summary(data)
        elif cmd == "4":
            cat_breakdown(data)
        elif cmd == "5":
            pie_chart(data)
        elif cmd == "q":
            print("Bye!")
            break
        else:
            print("Invalid option.")

main()
