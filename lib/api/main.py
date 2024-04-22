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
import platform
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

if platform.system() == "Windows":
    driver = '{ODBC Driver 17 for SQL Server}'
else:
    driver= '{ODBC Driver 18 for SQL Server}'

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
globalEmail = ""
maxTime = ""
generatedCode = ""
maxTime = ""
AppPassword = "onux jcdl joir mvld"
##############################################################

###########################################
############|Random Variables|#############
###########################################
##############################################################
timeAfterMonth = ""

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

class NewEntry(BaseModel):
    patientID: int
    entryDate: str
    entryID: int
    glucoseLevel: float
    insulinDosage: int
    totalCarbs: float
    unit: int
    hasMeals: str
    

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
@app.get("/updatePassword/{password}")
def UpdatePassword(password):
    global globalEmail
    print(globalEmail)
    hashed_password = hashlib.md5(password.encode()).hexdigest()
    response = cursor.execute("UPDATE Users SET userPassword = ? WHERE CAST(email AS NVARCHAR(MAX)) = ?", (hashed_password, globalEmail))
    cnxn.commit()
    return {"message": "Password updated successfully"}
        

@app.get("/forgotPassword/{email}")
def forgot_password(email: str):
    global maxTime
    global globalEmail
    global generatedCode
    globalEmail = email
    maxTime = datetime.datetime.now() + datetime.timedelta(minutes=10)
    user = cursor.execute("SELECT * FROM Users WHERE CAST(email AS NVARCHAR(MAX)) = ?", (email,)).fetchone()
    if(user is None):
        print("Email not found")
        raise HTTPException(status_code=401, detail="Email not found")
    else:
        generateCode()
        message = ("""From: From the SugarSense team <sugarsenseteam@gmail.com>
To: <{}>
Subject: Password Reset

To reset your password, please enter the following code: {}
This code will expire in 10 minutes.
If you did not request a password reset, please ignore this email.
From the SugarSense team""").format(email, generatedCode)
    sendEmail(FROM_EMAIL, globalEmail, AppPassword, message)
    return 1


@app.get("/checkCode/{code}")
def checkCode(code):
    global generatedCode
    global maxTime
    currentTime = datetime.datetime.now()
    if currentTime > maxTime:
        raise HTTPException(status_code=402, detail="Code has expired")
    if code == generatedCode:
        generatedCode = ""
        return "Code is correct"
    else:
        raise HTTPException(status_code=401, detail="Code is incorrect")



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
        raise HTTPException(status_code=401, detail="Doctor not found")
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
        cursor.execute("SELECT userPassword,userID FROM Users WHERE CAST(userName AS NVARCHAR(MAX)) = ?", (user.username,))
        rowUsername = cursor.fetchone()
        cursor.execute("SELECT userPassword,userID FROM Users WHERE CAST(email AS NVARCHAR(MAX)) = ?",(user.username,))
        rowEmail = cursor.fetchone()


        # If the user doesn't exist or the password is incorrect, return a 401 Unauthorized response

        hashed_password = hashlib.md5(user.password.encode()).hexdigest()


        if (rowUsername is None or hashed_password != rowUsername[0]) and (rowEmail is None or hashed_password != rowEmail[0]):
            if(rowUsername is None and rowEmail is None):
                raise HTTPException(status_code=401, detail="Invalid email or username")
            else:
                raise HTTPException(status_code=401, detail="Incorrect password")

        # If the email and password are correct, return a 200 OK response
        uid = getUserById(user.username);
        cursor.execute("SELECT * FROM Patients WHERE patientID = ?", uid);
        pid = cursor.fetchone();
        if(pid is None):
            raise HTTPException(status_code=401, detail="This user is not a patient");
        else:
            return {"message": "Authenticated successfully", "ID": uid}
            #rowUsername[1] 
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

###########################################
##########|Change User Info|###############
###########################################   
##############################################################
    
@app.get("/changeUsername/{username}/{id}")
async def changeUsername(username,id):
    if checkUsername(username):
        print("ebetred if ")
        print(username , id)
        cursor.execute("UPDATE Users SET userName = ? where userID  = ?",(username,id))
        cnxn.commit()

        if cursor.rowcount > 0:
            return True
        else:
            raise HTTPException(status_code=500, detail="couldn't change username")
    else:
        raise HTTPException(status_code=401, detail="Username already exists")

@app.get("/changeEmail/{email}/{id}")
def changeEmail(email,id):
    if checkEmail(email):
        row = cursor.execute("UPDATE Users SET email = ? where userID  = ?",(email,id))
        cnxn.commit()
        if row is not None:
            return True
        else:
            return False
    else:
        raise HTTPException(status_code=401, detail="email already exists")
    
@app.get("/changePhone/{phoneNumber}/{id}")
def changePhone(phoneNumber,id):
    if checkPhoneNumber(phoneNumber):
        row = cursor.execute("UPDATE Users SET phoneNumber = ? where userID  = ?",(phoneNumber,id))
        cnxn.commit()
        if row is not None:
            return True
        else:
            return False
    else:
        raise HTTPException(status_code=401, detail="phone number already exists")

@app.get("/changePhoto/{photo}/{id}")
def changePhoto(photo,id):
    row = cursor.execute("UPDATE Users SET profilePhoto = ? where patientID  = ?",(photo,id))
    cnxn.commit()
    if row is not None:
        return True
    else:
         return False

@app.get("/changeTargetGlucose/{targetGlucose}/{id}")
def changeTargetGlucose(targetGlucose, id):
    row = cursor.execute("UPDATE Patients SET targetBloodGlucose = ? where patientID  = ?",(targetGlucose,id))
    cnxn.commit()
    if row is not None:
        return True
    else:
        raise HTTPException(status_code=500, detail="couldn't change target glucose level")
        
@app.get("/changeInsulinSensitivity/{insulinSensitivity}/{id}")
def changeInsulinSensitivity(insulinSensitivity, id):
    row = cursor.execute("UPDATE Patients SET insulinSensivity = ? where patientID  = ?",(insulinSensitivity,id))
    cnxn.commit()
    if row is not None:
        return True
    else:
        raise HTTPException(status_code=500, detail="couldn't change insuling sensitivity")

@app.get("/changeCarbRatios/{carbRatio1}/{carbRatio2}/{carbRatio3}/{id}")
def changeCarbRatios(carbRatio1, carbRatio2, carbRatio3, id):
    row = cursor.execute("""
        UPDATE Patients 
        SET carbRatio = ?, carbRatio2 = ?, carbRatio3 = ? 
        WHERE patientID = ?
    """, (carbRatio1, carbRatio2, carbRatio3, id))
    cnxn.commit()
    if row is not None:
        return True
    else:
        raise HTTPException(status_code=500, detail="couldn't change carb ratios")

@app.get("/changePrivacy/{privacy}/{id}")
def changePrivacy(privacy, id):
    row = cursor.execute("UPDATE Patients SET privacy = ? where patientID  = ?",(privacy,id))
    cnxn.commit()
    if row is not None:
        return True
    else:
        raise HTTPException(status_code=500, detail="couldn't change privacy")

@app.get("/changeDoctor/{doctorCode}/{id}")
async def changeDoctor(doctorCode, id):
    if doctorCode == "None" or doctorCode is None:
        print("removing doc")
        row = cursor.execute("UPDATE Patients SET doctorCode = NULL where patientID  = ?", (id,))
    else:
        doc = await getDocInfo(doctorCode)
        print(f"Doc info: {doc}")
        if(doc is not None):
            print("printing doc:")
            print(doc)
            row = cursor.execute("UPDATE Patients SET doctorCode = ? where patientID  = ?", (doctorCode, id))
        else:
            raise HTTPException(status_code=500, detail="couldn't change doctor")
    cnxn.commit()
    if row is not None:
        return True
    else:
        raise HTTPException(status_code=500, detail="couldn't change doctor")

@app.get("/getDoctorInfo/{doctorCode}")
async def getDocInfo(doctorCode):
    try:
        row = cursor.execute("SELECT * FROM Users, Doctors WHERE userID = doctorID AND CAST(doctorCode AS NVARCHAR(MAX)) = ?",(doctorCode)).fetchone()
        if row is not None:
            print(row)
            return {description[0]: column for description, column in zip(cursor.description, row)}
        else:
            return None
    except Exception as e:
        print("Exception occurred: {e}")
        return None
##############################################################

def isConnectedToWifi():
    try:
        requests.get("http://www.google.com", timeout=3)
        return True
    except requests.ConnectionError:
        return False

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
    
def checkPhoneNumber(phoneNumber):
    row = cursor.execute("SELECT userID FROM Users WHERE CAST(phoneNumber AS VARCHAR(255)) = ?",(phoneNumber,)).fetchone()
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

#0abfbff3f1efcf35311a048b948c01aed8b7f17f552a4b882aa3c8544f9410dc
#eb03e6986533c14f2abb8e891cd2438a7f519c1e05935951a61141e23f9fd3b0


apiKey = 'eb03e6986533c14f2abb8e891cd2438a7f519c1e05935951a61141e23f9fd3b0'
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

###########################################
########|SYNCING AAAAAAAAAAAAAAAA|#########
###########################################

@app.post("/addNewEntry")
async def addNewEntry(entry: NewEntry):
    print("entered /addNewEntry")
    try:
        print(entry)
        row = cursor.execute("INSERT INTO Entry (patientID, entryID, entryDate, glucoseLevel , insulinDosage, totalCarbs, unit, hasMeals) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                       (entry.patientID, entry.entryID, entry.entryDate, entry.glucoseLevel, entry.insulinDosage, entry.totalCarbs, entry.unit, entry.hasMeals))
        print(row)
        cnxn.commit()
        
        print("inserted entry successfully")
        return {"message": "inserted entry successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        print(e)
        return {"error": str(e)}