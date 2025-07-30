# FILE: oop_tasks.py

from abc import ABC, abstractmethod
import math


# 1. Shape Area Calculator with Inheritance
class Shape(ABC):
    """Abstract base class for all shapes."""

    @abstractmethod
    def area(self):
        """Compute the area of the shape."""
        pass


class Rectangle(Shape):
    """Rectangle: Initialized with width and height. Area = width * height."""

    def __init__(self, width, height):
        self.width = width
        self.height = height

    def area(self):
        return self.width * self.height

    def __str__(self):
        return f"Rectangle({self.width} x {self.height}) = {self.area():.2f}"


class Circle(Shape):
    """Circle: Initialized with radius. Area = π * r^2."""

    def __init__(self, radius):
        self.radius = radius

    def area(self):
        return math.pi * self.radius ** 2

    def __str__(self):
        return f"Circle(r={self.radius}) = {self.area():.2f}"


# 2. Bank Account with Encapsulation
class BankAccount:
    """A bank account class with encapsulated balance and validation."""

    def __init__(self):
        self.__balance = 0

    @property
    def balance(self):
        return self.__balance

    @balance.setter
    def balance(self, value):
        if value < 0:
            raise ValueError("Balance cannot be negative.")
        self.__balance = value

    def deposit(self, amount):
        if amount <= 0:
            raise ValueError("Deposit must be positive.")
        self.__balance += amount
        print(f"Deposited ${amount}. New balance: ${self.__balance}")

    def withdraw(self, amount):
        if amount <= 0:
            raise ValueError("Withdrawal must be positive.")
        if amount > self.__balance:
            raise ValueError("Insufficient funds.")
        self.__balance -= amount
        print(f"Withdrew ${amount}. New balance: ${self.__balance}")


# 3. Notification System with Polymorphism
class EmailNotification:
    def send(self, message):
        print(f"Email: ✉️ '{message}' sent to your inbox.")


class SMSNotification:
    def send(self, message):
        print(f"SMS: 📱 '{message}' delivered to your phone.")


def send_bulk(notifiers, message):
    for notifier in notifiers:
        notifier.send(message)


# MAIN TEST LOGIC
def main():
    # --- Task 1: Inheritance ---
    print("\n== Task 1: Inheritance - Shape Area ==")
    print(Rectangle.__doc__)
    print(Circle.__doc__)

    shapes = [
        Rectangle(3, 4),
        Circle(5),
        Rectangle(10, 2),
        Circle(2.5)
    ]

    rect_count = sum(1 for s in shapes if isinstance(s, Rectangle))
    circ_count = sum(1 for s in shapes if isinstance(s, Circle))

    for shape in shapes:
        print(shape)

    print(f"Total Rectangles: {rect_count}")
    print(f"Total Circles: {circ_count}")

    # --- Task 2: Encapsulation ---
    print("\n== Task 2: Encapsulation - BankAccount ==")
    account = BankAccount()
    try:
        account.deposit(100)
        account.withdraw(30)
        account.balance = 150  # direct set using @setter
        print(f"Updated balance manually: ${account.balance}")
        account.withdraw(200)  # should raise error
    except Exception as e:
        print(f"Error: {e}")

    try:
        account.balance = -50  # should raise error
    except Exception as e:
        print(f"Error: {e}")

    # --- Task 3: Polymorphism ---
    print("\n== Task 3: Polymorphism - Notifications ==")
    notifiers = [EmailNotification(), SMSNotification()]
    send_bulk(notifiers, "Meeting at 3 PM today.")


if __name__ == "__main__":
    main()
