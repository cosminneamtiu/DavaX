# WEEK 3 TASK: Working with Sequences and String Formatting

# 1. Working with Lists
print("== 1. Working with Lists ==")
numbers = [10, 20, 30, 40, 50]

print("First element:", numbers[0])
print("Last element:", numbers[-1])
print("Middle element:", numbers[len(numbers) // 2])

numbers.append(60)
print("After append(60):", numbers)

numbers.insert(1, 15)
print("After insert(1, 15):", numbers)

numbers.pop()
print("After pop():", numbers)

print("Length of the list:", len(numbers))

numbers.sort()
print("Sorted list:", numbers)


# 2. Change a Specific Word in a Sentence
print("\n== 2. Replace Word in Sentence Without replace() ==")
sentence = "Python is fun because Python is powerful"
target_word = "Python"
new_word = "Programming"

words = sentence.split()
modified_words = [new_word if word == target_word else word for word in words]
modified_sentence = ' '.join(modified_words)

print("Original:", sentence)
print("Modified:", modified_sentence)


# 3. Palindrome Check Using Slicing
print("\n== 3. Palindrome Check with Slicing ==")
word = input("Enter a word to check if it's a palindrome: ")
is_palindrome = word == word[::-1]

print(f"'{word}' is a palindrome: {is_palindrome}")


# 4. f-string Formatting
print("\n== 4. f-string Formatting ==")
name = "Alice"
age = 30
balance = 1234.56789
membership_date = "2023-08-12"
status = True

print(f"Hello, my name is {name} and I am {age} years old.")
print(f"My current balance is: ${balance:>10.2f}")
print(f"Member since: {membership_date}")
print(f"Active member: {'Yes' if status else 'No'}")
