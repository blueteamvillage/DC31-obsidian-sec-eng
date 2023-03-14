# Import required libraries
import csv
import secrets, string

# Configure variables
input_employees = 'template_employees.csv'
output_employees = 'employees.csv'
password_length = 24
password_characters = string.ascii_letters + string.digits

# Create 'password' column in new CSV file
# - https://stackoverflow.com/questions/11070527/how-to-add-a-new-column-to-a-csv-file
# - https://docs.python.org/3/library/secrets.html
with open(input_employees, 'r') as csvInput, open(output_employees, 'w') as csvOutput:
    csvWriter = csv.writer(csvOutput, lineterminator='\n')
    csvReader = csv.reader(csvInput)

    # Write first row with column headers to output file
    all = []
    row = next(csvReader)
    all.append(row)

    # Check for empty cells in password column, add random passwords as needed
    for row in csvReader:
        random_password = ''.join(secrets.choice(password_characters) for i in range(password_length))
        if not row[7]:
            row = row[:-1] # removes comma at end of row before appending password
            row.append(random_password)
        all.append(row)
    csvWriter.writerows(all)
