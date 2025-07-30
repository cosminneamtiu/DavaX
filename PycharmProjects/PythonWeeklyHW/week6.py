# WEEKLY TASK: Custom Functions, Lambda Expressions, and Exception Handling

# 1. Custom Calculator Function
print("== 1. Custom Calculator ==")


def calculate(*args, operation='+'):
    if not args:
        return 0

    result = args[0]
    for num in args[1:]:
        try:
            if operation == '+':
                result += num
            elif operation == '-':
                result -= num
            elif operation == '*':
                result *= num
            elif operation == '/':
                if num == 0:
                    raise ZeroDivisionError("Cannot divide by zero.")
                result /= num
            else:
                raise ValueError("Unsupported operation.")
        except ZeroDivisionError as e:
            print(f"Error: {e}")
            return None
    return result


# Example usage
print("Addition:", calculate(1, 2, 3))
print("Multiplication:", calculate(2, 3, 4, operation='*'))
print("Division by zero:", calculate(10, 0, operation='/'))
print("No numbers passed:", calculate(operation='-'))

# 2. Sort Students by Score Using Lambda
print("\n== 2. Sort Students by Score Using Lambda ==")

names = ["Lucas", "Nataly", "Megi", "Maria", "Steven"]
scores = [85, 92, 78, 81, 67]

students = list(zip(names, scores))
filtered_sorted_students = sorted(
    [(name, score) for name, score in students if score >= 80],
    key=lambda x: x[1],
    reverse=True
)

for name, score in filtered_sorted_students:
    print(f"{name}: {score}")

# 3. Validate Age Input
print("\n== 3. Validate Age Input ==")


def check_age(age_input):
    try:
        if age_input == '':
            raise ValueError("Age input cannot be empty.")

        age = int(age_input)

        if age < 0:
            raise ValueError("Age cannot be negative.")
        elif age > 120:
            raise ValueError("Age exceeds valid human range.")

        print(f"Age {age} is valid.")

    except ValueError as ve:
        print(f"Validation Error: {ve}")
    except TypeError as te:
        print(f"Type Error: {te}")
    except Exception as e:
        print(f"Unexpected Error: {e}")
    finally:
        print("Validation complete.")


# Test cases
test_inputs = ['25', '', '-5', 'abc', '130']
for test in test_inputs:
    print(f"\nInput: '{test}'")
    check_age(test)
