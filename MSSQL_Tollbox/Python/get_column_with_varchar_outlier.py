import pandas as pd

# Path to the CSV file
file_path = '/content/file_with_data_and_row_truncating_your_table.csv'

# Read the CSV file
df = pd.read_csv(file_path)

#IN THIS EXAMPLE THE COLUMN DESCRIPTION WAS THE ONE HAVING PROBLEM
#AND MY COLUMN IN SQL SERVER WAS NVARCHAR(50)
# Ensure the 'Description' column exists
if 'Description' in df.columns:
    # Calculate the length of each description
    df['Description Length'] = df['Description'].apply(len)

    # Get maximum length accepted from the user
    try:
        max_length = int(input("Enter the maximum column length accepted in the table: "))
    except ValueError:
        print("Please enter a valid integer for the maximum length.")
    else:
        # Filter and display rows where description length is greater than the user-specified value
        filtered_df = df[df['Description Length'] > max_length]
        print(filtered_df[["Description", "Description Length"]])
else:
    print("The 'Description' column was not found in the DataFrame.")
