# WEEK 4 TASK: Loops and Control Flow

# 1. Currency Conversion with Unpacking and f-strings
print("== 1. Currency Conversion ==")
data = [
    (100, 'USD', 'EUR', 0.83),
    (100, 'USD', 'CAD', 1.27),
    (100, 'CAD', 'EUR', 0.65)
]

for amount, from_curr, to_curr, rate in data:
    converted = amount * rate
    print(f"{amount} {from_curr} = {converted:.2f} {to_curr}")

# 2. Sum of Odd Numbers from 1 to 100
print("\n== 2. Sum of Odd Numbers (1-100) ==")
total = 0
for num in range(1, 101):
    if num % 2 != 0:
        total += num
print("Sum of odd numbers from 1 to 100:", total)

# 3. Number Guessing Game (while loop)
print("\n== 3. Number Guessing Game ==")
secret_number = 7
attempts = 0
max_attempts = 3

while attempts < max_attempts:
    guess = int(input("Guess the secret number (1-10): "))
    attempts += 1
    if guess == secret_number:
        print("Congratulations! You guessed it right.")
        break
else:
    print("Sorry, you've used all your attempts. The number was 7.")

# 4. Enumerate List Items with Index
print("\n== 4. Enumerate Fruits ==")
fruits = ['apple', 'banana', 'cherry', 'date']
for index, fruit in enumerate(fruits, start=1):
    print(f"{index}: {fruit} ({len(fruit)} letters)")

# 5. Mutate the Data
print("\n== 5. Mutate and Analyze Data ==")
data = [
    ['2021-01-01', 20, 10],
    ['2021-01-02', 20, 18],
    ['2021-01-03', 10, 10],
    ['2021-01-04', 102, 100],
    ['2021-01-05', 45, 25]
]

max_diff = -1
max_diff_date = ""

for row in data:
    diff = row[1] - row[2]
    row.insert(1, diff)  # Insert difference at index 1
    if diff > max_diff:
        max_diff = diff
        max_diff_date = row[0]

print("Data after mutation:")
for row in data:
    print(row)

print(f"Largest difference was on: {max_diff_date}")
