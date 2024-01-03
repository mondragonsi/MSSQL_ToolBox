import webbrowser
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import plotly.io as pio
import pyodbc
from gpt_agent import GptAgent
import os

"""# Clear the screen"""
os.system('cls' if os.name == 'nt' else 'clear')


# Database connection parameters
SERVER = '192.168.2.102'
DATABASE = 'DBA'
USERNAME = 'sa'
PASSWORD = 'xxxxxxxx'

# Connect to the database
connectionString = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVER};DATABASE={DATABASE};UID={USERNAME};PWD={PASSWORD}'
conn = pyodbc.connect(connectionString)

# Query for drive space usage data
drive_space_query = """
SELECT DBName, TotalSpace, UsedSpace, AvailableSpace
FROM DriveSpaceTable
"""

# Query for top 5 wait types from sys.dm_exec_session_wait_stats
wait_types_query = """
SELECT TOP 5 wait_type, SUM(wait_time_ms) / 1000.0 AS wait_time_sec
FROM sys.dm_exec_session_wait_stats
GROUP BY wait_type
ORDER BY SUM(wait_time_ms) DESC
"""

# New SQL query for active user information
active_users_query = """
SELECT 
    s.session_id,
    s.login_name,
    DB_NAME(s.database_id) AS database_name,
    r.wait_type,
    r.reads AS physical_reads,
    r.writes AS physical_writes,
    DATEDIFF(MINUTE, s.login_time, GETDATE()) AS time_connected_minutes,
    st.text AS sql_text
FROM 
    sys.dm_exec_sessions s
JOIN 
    sys.dm_exec_requests r ON s.session_id = r.session_id
CROSS APPLY 
    sys.dm_exec_sql_text(r.sql_handle) st
WHERE 
    s.is_user_process = 1;
"""

# New SQL query for readErrorLog
read_error_log_query = """
EXEC sp_readerrorlog 0, 1, 'starting up database ' 
"""


# Execute queries and load into DataFrames
df_drive_space = pd.read_sql(drive_space_query, conn)
df_wait_types = pd.read_sql(wait_types_query, conn)
df_active_users = pd.read_sql(active_users_query, conn)
df_error_log = pd.read_sql(read_error_log_query, conn)

# append all text from df_error_log from column text and put it in a string variable
error_log_text = df_error_log['Text'].str.cat(sep='\n')


# print the error_log_text variable
print("--------------------------> Prompt received from Error Log:")
print(error_log_text)

agent = GptAgent()
user_input = "Make an analysis of this SQL Server Error Log messages: "
user_input = user_input+ error_log_text
response = agent.process_prompt(user_input)
print(f"AI assistant: {response}")

# Close the database connection
conn.close()

# Plotting drive space usage with Plotly
fig_drive_space = px.bar(df_drive_space, x='DBName', y=['UsedSpace', 'AvailableSpace'],
                         title="Drive Space Usage",
                         labels={'value': 'Space in MB', 'variable': 'Space Type'})

# Plotting top 5 wait types with Plotly
fig_wait_types = px.bar(df_wait_types, x='wait_type', y='wait_time_sec',
                        title="Top 5 SQL Server Wait Types",
                        labels={'wait_time_sec': 'Wait Time (Seconds)'})

# Plotting active users with Plotly
fig_active_users = go.Figure(data=[go.Table(
    header=dict(values=list(df_active_users.columns)),
    cells=dict(values=[df_active_users[k].tolist() for k in df_active_users.columns])
)])
fig_active_users.update_layout(title='Active User Sessions')

# Plotting error log with Plotly
fig_error_log = go.Figure(data=[go.Table(
    header=dict(values=list(df_error_log.columns)),
    cells=dict(values=[df_error_log[k].tolist() for k in df_error_log.columns])
)])


#convert error_log_text to df
df_error_log_response = pd.DataFrame(response.split('\n'))

# Plotting response from chatbot from a the variable df_error_log_response
fig_chatbot = go.Figure(data=[go.Table(
    header=dict(values=list(df_error_log_response.columns)),
    cells=dict(values=[df_error_log_response[k].tolist() for k in df_error_log_response.columns])
)])

# Convert all plots to HTML
graph1_html = pio.to_html(fig_drive_space, full_html=False)
graph2_html = pio.to_html(fig_wait_types, full_html=False)
graph3_html = pio.to_html(fig_active_users, full_html=False)
graph4_html = pio.to_html(fig_error_log, full_html=False)
graph5_html = pio.to_html(fig_chatbot, full_html=False)

# Combine all HTML and save to a file
html_file = "sql_server_metrics.html"
html_content = f"""
<html>
<head>
<title>SQL Server Metrics</title>
</head>
<body>
<h1>SQL Server Performance Metrics</h1>
<div>{graph1_html}</div>
<div>{graph2_html}</div>
<div>{graph3_html}</div>
<div>{graph4_html}</div>
<div>{graph5_html}</div>
</body>
</html>
"""

# Convert error log to HTML

graph5_html = pio.to_html(fig_error_log, full_html=False)

with open(html_file, "w") as file:
    file.write(html_content)

# Open in the default web browser
webbrowser.open('file://' + os.path.realpath(html_file))

