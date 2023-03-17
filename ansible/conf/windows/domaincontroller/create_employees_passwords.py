"""
Windows Active Directory users creations from csv
"""
# Import required libraries
import csv
import secrets
import string

# Configure variables
INPUT_EMPLOYEES = "template_employees.csv"
OUTPUT_EMPLOYEES = "employees.csv"
PASSWORD_LENGTH = 24
PASSWORD_CHARACTERS = string.ascii_letters + string.digits

# Create 'password' column in new CSV file
# - https://stackoverflow.com/questions/11070527/how-to-add-a-new-column-to-a-csv-file
# - https://docs.python.org/3/library/secrets.html
with open(INPUT_EMPLOYEES, "r", encoding="ascii") as csvInput, open(
    OUTPUT_EMPLOYEES, "w", encoding="ascii"
) as csvOutput:
    csvWriter = csv.writer(csvOutput, lineterminator="\n")
    csvReader = csv.reader(csvInput)

    # Write first row with column headers to output file
    allusers = []
    row = next(csvReader)
    allusers.append(row)

    # Check for empty cells in password column, add random passwords as needed
    for row in csvReader:
        RANDOM_PASSWORD = "".join(
            secrets.choice(PASSWORD_CHARACTERS) for i in range(PASSWORD_LENGTH)
        )
        if not row[7]:
            row = row[:-1]  # removes comma at end of row before appending password
            row.append(RANDOM_PASSWORD)
        allusers.append(row)
    csvWriter.writerows(allusers)
