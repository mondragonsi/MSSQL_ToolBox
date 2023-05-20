#create a python code to check the SQL script and find if the workd USE is there or not

import os
import sys
import re


PathSqlScript = "C:\\Users\\bruno.mondragon\\Documents\\Dev\\AzDevOpsRepo\\Database\\MSSQL\\02 - INTERVENCOES\\CheckScript\\"

fileName = input("Enter the name of the file: ")

finalPath = PathSqlScript + fileName


#open the file
file = open(finalPath, "r")

#read the file
fileContent = file.read()

fileContent = fileContent.upper()


print("The File/Path is: " + finalPath)

points = 10

print("Starting with " + str(points) + " points")

#check if the word USE is there or not
if re.search("USE", fileContent):
    print("USE OK")
else:
    print("USE is not there in the file")
    points = points - 2
if re.search("BEGIN", fileContent):
    print("BEGIN OK")
else:
    print("BEGIN is not there in the file")
    points = points - 2
if re.search("ROLLBACK", fileContent):
    print("ROLLBACK OK")
else:
    print("ROLLBACK is not there in the file")
    points = points - 2
if re.search("COMMIT", fileContent):
    print("COMMIT OK")
else:
    print("COMMIT is not there in the file")
    points = points - 2
if re.search("GO", fileContent):
    print("GO OK")
else:
    print("GO is not there in the file")
    points = points - 2


#close the file
file.close()

print("Ending with " + str(points) + " points")

if points == 10:
    print("All good")
else:
    print("Missing important parameters!")

#end of the program

#


