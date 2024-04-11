import datetime
import random
import smtplib
import string
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pyodbc
import Models.personModel.person as Pmodel
from fastapi.middleware.cors import CORSMiddleware
import hashlib
import requests
from serpapi import GoogleSearch
import time
import threading
###########################################
##########|API functionality|##############
###########################################
##############################################################
app = FastAPI()

#what localhosts the api accepts (i think they don't do anything anymore but i'm too scared to remove them)
origins = [
    "http://localhost:8000",  
    "http://localhost:49581",
    "http://localhost:3000"  
]

#this is to fix the cors error to allow all ports to access the api
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

###########################################
######|Database Connection String|#########
###########################################
##############################################################
server = 'sugarsense.database.windows.net'
database = 'sugarsensedb'
username = 'sugaradmin'
password = 'SUG@Rs!!7891'
driver= '{ODBC Driver 17 for SQL Server}'
#driver= '{ODBC Driver 18 for SQL Server}'

connection_string = f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};'
cnxn = pyodbc.connect(connection_string)
cursor = cnxn.cursor()
##############################################################

###########################################
######|Forgot Password Variables|##########
###########################################
##############################################################
HOST = "smtp.gmail.com"
PORT = 465
FROM_EMAIL = "sugarsenseteam@gmail.com"
email = "alisinno16@gmail.com"
maxTime = ""
generatedCode = ""
maxTime = ""
AppPassword = "onux jcdl joir mvld"
##############################################################

###########################################
############|Pydantic Models|##############
###########################################
##############################################################
class User(BaseModel):
    username: str
    password: str

class NewUser(BaseModel):
    firstName: str
    lastName: str
    username: str
    email: str
    password: str
    confirmPassword: str
    
class NewPatient(BaseModel):
    username: str
    doctorID: str
    insulinSensivity: float
    targetBloodGlucose : int
    carbRatio1 : float
    carbRatio2 : float
    carbRatio3 : float
    privacy : str

class ForgetPasswordRequest(BaseModel):
    email: str

##############################################################

###########################################
############|Forgot Password|##############
###########################################
##############################################################

def sendEmail(fromEmail, toEmail, password, message):
    maxTime = datetime.datetime.now() + datetime.timedelta(minutes=10)
    try:
        server = smtplib.SMTP_SSL(HOST, PORT)
        server.ehlo()
        server.login(fromEmail, password)
        server.sendmail(fromEmail, toEmail, message)
        server.close()
        print("Email sent")
        
    except Exception as e:
        print("SOMETHING NO WORKY: ", e)
        return {"message": "Error connecting to the server"}

def generateCode():
    global generatedCode
    code = ""
    for i in range(6):
        code += str(random.choice(string.ascii_letters))
    code = code.upper()
    print(code)
    generatedCode = code
    return code

def checkCode(code):
    global generatedCode
    currentTime = datetime.datetime.now()
    if currentTime > maxTime:
        print("code expired")
        return "Code has expired"
    if code == generatedCode:
        generatedCode = ""
        print("code is goooddddd")
        return "Code is correct"
    else:
        print("CODE IS NU UHHH")

def UpdatePassword(email, password):
    hashed_password = hashlib.md5(password.encode()).hexdigest()
    response = cursor.execute("UPDATE Users SET userPassword = ? WHERE email = ?", (hashed_password, email))
    if response is None:
        return False
    return True

@app.get("/forgotPassword/{email}")
def forgot_password(email: str):
    global maxTime
    global generatedCode
    maxTime = datetime.datetime.now() + datetime.timedelta(minutes=10)
    user = cursor.execute("SELECT * FROM Users WHERE email = ?", (email,)).fetchone()
    if(user is None):
        return {"error": "Email not found"}
    else:
        generateCode()
        message = ("""From: From the SugarSense team <sugarsenseteam@gmail.com>
To: <{}>
Subject: Password Reset

To reset your password, please enter the following code: {}
This code will expire in 10 minutes.
If you did not request a password reset, please ignore this email.
From the SugarSense team""").format(email, generatedCode)
    sendEmail(FROM_EMAIL, email, AppPassword, message)


@app.get("/checkCode/{code}")
def checkCode(code):
    global maxTime
    currentTime = datetime.datetime.now()
    if currentTime > maxTime:
        return "Code has expired"
    if code == generatedCode:
        generatedCode = ""
        return "Code is correct"



##############################################################

@app.get('/')
def get():
    return {"Success":"get request"}

@app.post('/')
def post():
    return {"Success":"Post request"}
 
@app.patch('/')
def patch():
    return {"Success": "You just Patched"}

###########################################
############|Checking Users|###############
###########################################
##############################################################
@app.get("/checkUsername/{user_id}")
async def checkUsername(user_id: str):
    cursor.execute("Select * from Users WHERE CAST(userName AS NVARCHAR(MAX)) = ?", (user_id,))
    row = cursor.fetchone()
    if row is None:
        return None
    else:
        return {description[0]: column for description, column in zip(cursor.description, row)}

@app.get("/checkEmail/{user_id}")
async def checkEmail(user_id: str):
    cursor.execute("Select * from Users WHERE CAST(email AS NVARCHAR(MAX)) = ?", (user_id,))
    row = cursor.fetchone()
    if row is None:
        return None
    else:
        return {description[0]: column for description, column in zip(cursor.description, row)}

@app.get("/checkDoc/{user_id}")
async def checkDoc(user_id: str):
    cursor.execute("Select * from Doctors WHERE CAST(doctorCode AS NVARCHAR(MAX)) = ?", (user_id,))
    row = cursor.fetchone()
    if row is None:
        return None
    else:
        return {description[0]: column for description, column in zip(cursor.description, row)}
    
##############################################################       
        
###########################################
#|Displaying Meals and Meals Composition|##
###########################################
##############################################################

@app.get("/MealComposition")
async def get_mealComposition():
    cursor.execute("Select * from MealComposition") 
    rows = cursor.fetchall()
    if rows is None:
        return {"error": "No meals found"}
    else:
        return [{description[0]: column for description, column in zip(cursor.description, row)} for row in rows]
   
@app.get("/meals")
async def get_meals():
    cursor.execute("Select * from Meals") 
    rows = cursor.fetchall()
    if rows is None:
        return {"error": "No meals found"}
    else:
        return [{description[0]: column for description, column in zip(cursor.description, row)} for row in rows]

@app.get("/meals/{meal_id}")
async def DisplayMeal(meal_id: int):
    cursor.execute("Select * from Meals WHERE mealID = ?", (meal_id,))
    row = cursor.fetchone()
    if row is None:
        return {"error": "Meal not found"}
    else:
        return {description[0]: column for description, column in zip(cursor.description, row)}
    
############################################################## 

###########################################
########|Getting Users' Details|###########
###########################################
##############################################################
@app.post("/getUserDetails")
async def getUserDetails(user: User):
    cursor.execute("SELECT userPassword FROM Users WHERE CAST(userName AS NVARCHAR(MAX)) = ?", (user.username,))
    rowUsername = cursor.fetchone()
    cursor.execute("SELECT userPassword FROM Users WHERE CAST(email AS NVARCHAR(MAX)) = ?",(user.username,))
    rowEmail = cursor.fetchone()
    hashed_password = hashlib.md5(user.password.encode()).hexdigest()
    if(rowUsername is not None and hashed_password == rowUsername[0]):
        cursor.execute("SELECT * FROM Users WHERE CAST(userName AS NVARCHAR(MAX)) = ?", (user.username,))
        row = cursor.fetchone()
        return {description[0]: column for description, column in zip(cursor.description, row)}
    elif(rowEmail is not None and hashed_password == rowEmail[0]):
        cursor.execute("SELECT * FROM Users WHERE CAST(email AS NVARCHAR(MAX)) = ?",(user.username,))
        row = cursor.fetchone()
        return {description[0]: column for description, column in zip(cursor.description, row)}
    return "stop trying to hack me man"

@app.post("/getPatientDetails")
async def getPatientDetails(user: User):
    id = getUserById(user.username)
    
    cursor.execute("SELECT * FROM Patients WHERE patientID = ?",(id))
    row = cursor.fetchone()
    return {description[0]: column for description, column in zip(cursor.description, row)}
##############################################################

###########################################
##########|User Authentication|############
###########################################
##############################################################
@app.post("/authenticate")
async def authenticate(user: User):
    try:
        # Query the database for the user
        cursor.execute("SELECT userPassword FROM Users WHERE CAST(userName AS NVARCHAR(MAX)) = ?", (user.username,))
        rowUsername = cursor.fetchone()
        cursor.execute("SELECT userPassword FROM Users WHERE CAST(email AS NVARCHAR(MAX)) = ?",(user.username,))
        rowEmail = cursor.fetchone()

        # If the user doesn't exist or the password is incorrect, return a 401 Unauthorized response

        hashed_password = hashlib.md5(user.password.encode()).hexdigest()


        if (rowUsername is None or hashed_password != rowUsername[0]) and (rowEmail is None or hashed_password != rowEmail[0]):
            if(rowUsername is None and rowEmail is None):
                raise HTTPException(status_code=401, detail="Invalid email or username")
            else:
                raise HTTPException(status_code=401, detail="Incorrect password")

        # If the email and password are correct, return a 200 OK response
        return {"message": "Authenticated successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        return {"error": str(e)}
############################################################## 

###########################################
##########|User Registration|##############
###########################################   
##############################################################
@app.post("/register")
async def registerfunction(user: NewUser):
    try:
        print('entered register')
        
        if not checkUsername(user.username):
            raise HTTPException(status_code=401, detail="Username already exists")
        
        if not checkEmail(user.email):
            raise HTTPException(status_code=401, detail="Email already exists")
        
        hashed_password = hashlib.md5(user.password.encode()).hexdigest()
        
        cursor.execute("INSERT INTO Users (firstName, lastName, userName, email, userPassword) VALUES (?, ?, ?, ?, ?)",
                       (user.firstName, user.lastName, user.username, user.email, hashed_password))
        cnxn.commit()
        return {"message": "Registered successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        return {"error": str(e)}
    
@app.post("/regPatient")
async def registerfunction(user: NewPatient):
    print("entered /regPatient")
    try:
        id = getUserById(user.username)
        print(id)
        print(user)
        cursor.execute("INSERT INTO Patients (patientID, doctorCode, insulinSensivity, targetBloodGlucose , carbRatio, carbRatio2, carbRatio3, privacy) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                       (id, user.doctorID, user.insulinSensivity, user.targetBloodGlucose, user.carbRatio1, user.carbRatio2, user.carbRatio3, user.privacy))
        cnxn.commit()
        print("Registered patient successfully")
        return {"message": "Registered patient successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        return {"error": str(e)}
##############################################################
###########################################
######|Functions Used In Routes|###########
###########################################
##############################################################
def checkUsername(username):##used in /register and in checkUsername##
    row = cursor.execute("SELECT userID FROM Users WHERE CAST(userName AS VARCHAR(255)) = ?",(username,)).fetchone()
    if(row is None):
        return True
    else:
        return False
    
def checkEmail(email):##used in /register and in checkEmail##
    row = cursor.execute("SELECT userID FROM Users WHERE CAST(email AS VARCHAR(255)) = ?",(email,)).fetchone()
    if(row is None):
        return True
    else:
        return False
def getUserById(username):##used in /getPatientDetails and in /regPatient##
    row = cursor.execute("SELECT userID FROM Users WHERE CAST(userName AS VARCHAR(255)) = ?",(username,)).fetchone()
    if row is not None:
        return row[0]
    else:
        return None
 
 
###########################################
########|Articles API Integration|#########
###########################################
##############################################################

apiKey = '0abfbff3f1efcf35311a048b948c01aed8b7f17f552a4b882aa3c8544f9410dc'
def get_results(search):
    global results
    results = search.get_dict()
    
@app.get("/News/{query}")
async def get_news(query: str):
    print("We got here")
    params = {
        "q": query,
        "hl": "en",
        "gl": "us",
        "google_domain": "google.com",
        "api_key": apiKey
    }
    search = GoogleSearch(params)
    print("we searched :D")

    for i in range(10):  # Retry up to 3 times
        thread = threading.Thread(target=get_results, args=(search,))
        thread.start()
        thread.join(10)

        if thread.is_alive():
            print("get_dict() is stuck, retrying...")
            time.sleep(5)  # Wait for 5 seconds before retrying
        else:
            print("get_dict() finished successfully")
            print("frfr")
            return results["organic_results"]
    print("wifi do be no cap not working")
    return {"error": "Failed to get results after 3 attempts"}   