# WEEK 5 TASK: Dictionaries, Sets, and Comprehensions

# 1. Are two words anagrams?
print("== 1. Anagram Checker ==")
word1 = "listen"
word2 = "silent"

def count_letters(word):
    freq = {}
    for letter in word:
        freq[letter] = freq.get(letter, 0) + 1
    return freq

dict1 = count_letters(word1)
dict2 = count_letters(word2)

print("Original frequency dictionaries:")
print(f"{word1}: {dict1}")
print(f"{word2}: {dict2}")
print("Are they anagrams?", dict1 == dict2)

# Modify one dictionary
del dict1['l']
print("\nAfter deleting 'l' from first dictionary:")
print(f"{word1}: {dict1}")
print(f"{word2}: {dict2}")

# 2. Invert dictionary with duplicates in values
print("\n== 2. Invert Dictionary ==")
grades = {
    "Alice": "A",
    "Bob": "B",
    "Charlie": "A",
    "Diana": "C"
}

inverted = {}
for student, grade in grades.items():
    inverted.setdefault(grade, []).append(student)

print("Inverted dictionary:", inverted)

# 3. Set Analysis for Conference Attendees
print("\n== 3. Set Analysis ==")
testing = {"Ana", "Bob", "Charlie", "Diana"}
development = {"Charlie", "Eve", "Frank", "Ana"}
devops = {"George", "Ana", "Bob", "Eve"}

# Attendees in all sessions
all_three = testing & development & devops
print("Attended all three sessions:", all_three)

# Only one session attendees
only_one = (
    (testing - development - devops) |
    (development - testing - devops) |
    (devops - testing - development)
)
print("Attended only one session:", only_one)

# Are all testing attendees in devops?
print("All testing attendees in devops:", testing <= devops)

# All unique attendees sorted
all_attendees = sorted(testing | development | devops)
print("All unique attendees sorted:", all_attendees)

# Copy development and clear original
development_copy = development.copy()
development.clear()
print("Development (after clear):", development)
print("Copied development:", development_copy)

# 4. Create Data with Comprehensions
print("\n== 4. Comprehensions ==")

# List of squares from 1 to 10
squares = [x**2 for x in range(1, 11)]
print("Squares 1-10:", squares)

# Set of numbers divisible by 7 from 1 to 50
div7 = {x for x in range(1, 51) if x % 7 == 0}
print("Divisible by 7 (1–50):", div7)

# Dictionary of passed students
score = {"Alice": 85, "Bob": 59, "Charlie": 92}
passed = {name: val for name, val in score.items() if val >= 60}
print("Passed students:", passed)

# Nested dictionary for weekly attendance
students = ["Michael", "David", "Liza"]
weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri"]
attendance = {
    student: {day: (day in ["Mon", "Wed"]) for day in weekdays}
    for student in students
}
print("Weekly attendance log:")
for student, days in attendance.items():
    print(f"{student}: {days}")
