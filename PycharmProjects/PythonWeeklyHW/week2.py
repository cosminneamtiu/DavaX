# 1. Immutable Data Types
print("== 1. Immutable Data Types ==")
a = 10
b = a
a += 5
print(f"a: {a}, b: {b} (integers are immutable)")

x = 3.14
y = x
x *= 2
print(f"x: {x}, y: {y} (floats are immutable)")

# 2. Leap Year Checker
print("\n== 2. Leap Year Checker ==")
year_str = input("Enter desired year: ")
year = int(year_str)
if (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0):
    print("This is a leap year.")
else:
    print("This isn't a leap year.")

# 3. Ternary Conditional Operator
print("\n== 3. Ternary Conditional Operator ==")
num = int(input("Enter a number: "))
print("Positive" if num >= 0 else "Negative")

# 4. Boolean Logic Practice
print("\n== 4. Boolean Logic Practice ==")
x = 5
y = 0
z = -3

print("All greater than zero:", x > 0 and y > 0 and z > 0)
print("At least one is zero:", x == 0 or y == 0 or z == 0)
print("None are negative:", not (x < 0 or y < 0 or z < 0))

# 5. Type Conversion and Identity
print("\n== 5. Type Conversion and Identity ==")
x = 100
y = -30
z = 0

# Conversion examples
print(f"int to float: float(x) = {float(x)}")
print(f"int to bool: bool(y) = {bool(y)}")
print(f"zero to bool: bool(z) = {bool(z)}")

# Identity checks
a = float(x)
b = bool(y)
print(f"id(x): {id(x)}")
print(f"id(float(x)): {id(a)}")
print(f"id(bool(y)): {id(b)}")
print("x == float(x):", x == a)
print("x is float(x):", x is a)  # False: different object types
