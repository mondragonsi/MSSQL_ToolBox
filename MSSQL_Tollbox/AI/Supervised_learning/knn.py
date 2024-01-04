import webbrowser
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import plotly.io as pio
import pyodbc
import os

"""# Clear the screen"""
os.system('cls' if os.name == 'nt' else 'clear')


# Database connection parameters
SERVER = '192.168.2.102'
DATABASE = 'IA_DB'
USERNAME = 'python_user'
PASSWORD = 'python123'

# Connect to the database
connectionString = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVER};DATABASE={DATABASE};UID={USERNAME};PWD={PASSWORD}'
conn = pyodbc.connect(connectionString)

# Query for cancer image data
cancer_igm_query = """
select radius,texture,diagnosis 
from cancer_img;
"""


# Execute queries and load into DataFrames
df_cancer_igm = pd.read_sql(cancer_igm_query, conn)

print(df_cancer_igm)

# Use K-NN to predict the diagnosis of a tumor based on its radius and texture

# Import KNeighborsClassifier from sklearn.neighbors
from sklearn.neighbors import KNeighborsClassifier

# Create arrays for the features and the response variable
y = df_cancer_igm['diagnosis'].values
X = df_cancer_igm[['radius', 'texture']].values

# Create a k-NN classifier with 6 neighbors

knn = KNeighborsClassifier(n_neighbors=6)

# Fit the classifier to the data
knn.fit(X,y)

# Predict the labels for the training data X
y_pred = knn.predict(X)

# Plot the boundaries of the k-NN classifier
fig = px.scatter(df_cancer_igm, x="radius", y="texture", color="diagnosis", size="radius",)

# Predict and print the label for the new data point X_new
new_prediction = knn.predict([[18, 30]])

print("Prediction: {}".format(new_prediction))


# Close the database connection
conn.close()

# Plotting df_cancer_igm using the columns of df_cancer_igm columns: Radius, texture and diagnosis

fig_cancer_igm = px.scatter(df_cancer_igm, x="radius", y="texture", color="radius", size="radius",)



# Convert all plots to HTML
graph1_html = pio.to_html(fig_cancer_igm, full_html=False)
graph2_html = pio.to_html(fig, full_html=False)


# Combine all HTML and save to a file
html_file = "cancer_data.html"
html_content = f"""
<html>
<head>
<title>K-NN Cancer Dara</title>
</head>
<body>
<h1>IA K-NN</h1>
<div>{graph1_html}</div>
<div>{graph2_html}</div>

</body>
</html>
"""



with open(html_file, "w") as file:
    file.write(html_content)

# Open in the default web browser
webbrowser.open('file://' + os.path.realpath(html_file))

