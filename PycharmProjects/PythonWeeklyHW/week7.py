# FILE: weekly_file_tasks.py

# 1. File Filtering with Context Manager
def filter_names_starting_with_vowel():
    print("\n== Task 1: Filter Names Starting with Vowel ==")
    vowels = {'A', 'E', 'I', 'O', 'U'}

    # Step 1: Create students.txt
    with open("students.txt", "w") as f:
        f.write("\n".join([
            "Alice", "Ethan", "Bob", "Uma", "Charlie", "Oscar", "David", "Irene"
        ]))

    # Step 2: Read and write names that start with vowels
    with open("students.txt", "r") as infile, open("filtered.txt", "w") as outfile:
        for line in infile:
            name = line.strip()
            if name and name[0].upper() in vowels:
                outfile.write(name + "\n")
                print(f"Written to filtered.txt: {name}")


# 2. Reverse File Content
def reverse_log_file():
    print("\n== Task 2: Reverse Log File Content ==")

    # Step 1: Create log.txt with multiple lines
    with open("log.txt", "w") as f:
        f.writelines([
            "Line one\n",
            "Line two\n",
            "Line three\n",
            "Line four\n",
            "Line five\n"
        ])
    print("log.txt created.")

    # Step 2: Read and reverse lines
    with open("log.txt", "r") as f:
        lines = f.readlines()

    with open("reversed_log.txt", "w") as f:
        f.writelines(reversed(lines))
    print("Reversed content written to reversed_log.txt.")


# 3. Student Report Generator (modularized-style function)
def generate_report(data: dict) -> str:
    passed = {name: score for name, score in data.items() if score >= 80}
    sorted_report = sorted(passed.items(), key=lambda x: x[1], reverse=True)

    report_lines = ["\n== Task 3: Student Report (Score >= 80) =="]
    for name, score in sorted_report:
        report_lines.append(f"{name:10} - {score}")

    return "\n".join(report_lines)


def main():
    # Call Task 1
    filter_names_starting_with_vowel()

    # Call Task 2
    reverse_log_file()

    # Call Task 3
    student_scores = {
        'Lisa': 85,
        'Bart': 72,
        'Homer': 91,
        'Maggie': 88,
        'Milhouse': 74
    }

    report = generate_report(student_scores)
    print(report)


if __name__ == "__main__":
    main()
