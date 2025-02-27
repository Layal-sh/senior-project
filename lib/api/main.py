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
#from serpapi import GoogleSearch


import time
import threading
import platform
import base64
from fastapi import Depends, HTTPException, status
from fastapi import Body
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta
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

class Token(BaseModel):
    access_token: str
    token_type: str
    message: str
    ID: int

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


class freeUser(BaseModel):
    userId: int
    birthDate: str
    address: str
    doctorCode: str
    idCard1: str
    idCard2: str
    
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
    
class UserForm(BaseModel):
    username: str
    password: str

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


SECRET_KEY = "bfedd62227958245913f74acc9ed79a86b3e1df1863e428a5e4728bfe0986315"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 42800

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def create_access_token(data: dict, expires_delta: timedelta):
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: UserForm = Body(...)):
    user = User(username=form_data.username, password=form_data.password)
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
        uid = getUserById(user.username)
        cursor.execute("SELECT * FROM Patients WHERE patientID = ?", uid)
        pid = cursor.fetchone() 
        subs=await getSubscription(uid)
        print(subs)
        if(subs == 0):
            raise HTTPException(status_code=400, detail="This user is not subscribed")
        elif(pid is None):
            raise HTTPException(status_code=402, detail="This user is not a patient")
        else:
            access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
            access_token = create_access_token(
                data={"sub": user.username}, expires_delta=access_token_expires
            )
            return {"message": "Authenticated successfully", "ID": uid,"access_token": access_token, "token_type": "bearer"}
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=403, detail=str(e))
    
def get_current_user(token: str = Depends(oauth2_scheme)):
    print(f"Token: {token}")
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        print(f"Payload: {payload}")
        username: str = payload.get("sub")
        print(username)
        if username is None:
            raise credentials_exception
        return username
    except JWTError:
        raise credentials_exception
############################################################## 

###########################################
##########|User Registration|##############
###########################################   
##############################################################
@app.get("/spam")
async def spamFunction():
    for i in range(1000,  1500):
        # cursor.execute("INSERT INTO Users (firstName, lastName, userName, email, userPassword) VALUES (?, ?, ?, ?, ?)",
        #                ("test", "test", "test" + str(i), "test", "test"))
        cursor.execute("INSERT INTO Entry (entryId, patientID, glucoseLevel, insulinDosage, entryDate, unit, totalCarbs, hasMeals) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                       (i, i, 80.0, 5, "test", 1, 20.0, "test"))
        #id = getUserById("test" + str(i))
        # cursor.execute("INSERT INTO Patients (patientID, doctorCode, insulinSensivity, targetBloodGlucose , carbRatio, carbRatio2, carbRatio3, privacy) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        #                (id, "test", 20.0, 100, 3.0, 4.0, 5.0, "test"))
        #
        # cursor.execute("INSERT INTO Doctors (doctorID, doctorCode) VALUES (?, ?)",
        #                (id, "test"+str(i)))
        cnxn.commit()
        print("current i: "+ str(i))
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

@app.get("/changePassword/{old}/{new}/{id}")
async def changeUsername(old,new,id):
    if(checkPassword(old,id)):
        hashed_passwordOld = hashlib.md5(old.encode()).hexdigest()
        hashed_passwordNew = hashlib.md5(new.encode()).hexdigest()
        cursor.execute("UPDATE Users SET userPassword = ? where userID  = ?",(hashed_passwordNew,id))
        cnxn.commit()
        if(hashed_passwordOld == hashed_passwordNew):
            raise HTTPException(status_code=400, detail="new password can't be the same as the old one")
        if cursor.rowcount > 0:
            return True
        else:
            raise HTTPException(status_code=500, detail="couldn't change password")
    else:
        raise HTTPException(status_code=401, detail="incorrect password")
    

# @app.get("/changeEmail/{email}/{id}")
# def changeEmail(email,id):
#     if checkEmail(email):
#         row = cursor.execute("UPDATE Users SET email = ? where userID  = ?",(email,id))
#         cnxn.commit()
#         if row is not None:
#             return True
#         else:
#             return False
#     else:
#         raise HTTPException(status_code=401, detail="email already exists")

@app.get("/changeEmail/{email}")
def changeEmail(email: str, current_user: str = Depends(get_current_user)):
    try:
        if checkEmail(email):
            uid = getUserById(current_user)
            row = cursor.execute("UPDATE Users SET email = ? where userID  = ?",(email, uid))
            cnxn.commit()
            if row is not None:
                return {"message": "Email updated successfully"}
            else:
                return {"message": "Failed to update email"}
        else:
            raise HTTPException(status_code=403, detail="email already exists")
    except HTTPException:
        raise
    except Exception as e:
        print(e)
        return {"error": str(e)}
    
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
        cnxn.commit()
        if row is not None:
            return {"message": "removed"}
        else:
            raise HTTPException(status_code=500, detail="couldn't remove doctor")
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
        return {"message":"added","firstName":doc['firstName'], "lastName":doc['lastName']}
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
        print(e) #cries
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

def checkPassword(passold, id):##used in /register and in checkUsername##
    hashed_password = hashlib.md5(passold.encode()).hexdigest()
    row = cursor.execute("SELECT userPassword FROM Users WHERE userID = ?",(id,)).fetchone()
    if(hashed_password == row[0]):
        return True
    else:
        return False

def checkEmail(email):##used in /register and in checkEmail##
    try:
        row = cursor.execute("SELECT userID FROM Users WHERE CAST(email AS VARCHAR(255)) = ?",(email,)).fetchone()
        print("printing row from check email")
        print(row)
        if(row is None):
            return True
        else:
            return False
    except Exception as e:
        print(e)
        return {"error":e}
    
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
    
@app.get("/getUserId/{username}")   
async def getUserId(username):##used in /getPatientDetails and in /regPatient##
    row = cursor.execute("SELECT userID FROM Users WHERE CAST(userName AS VARCHAR(255)) = ?",(username,)).fetchone()
    if row is not None:
        return row[0]
    else:
        raise HTTPException(status_code=401, detail="could not get the user ID")
    
@app.get("/updateSubscription/{userID}/{subscription}")   
async def updateSubscription(userID,subscription):##used in /getPatientDetails and in /regPatient##
    row = cursor.execute("UPDATE Users SET subscription = ? where userID  = ?", (subscription, userID))
    cnxn.commit() 
    if cursor.rowcount > 0:
        return {"message": "subscription updated"}
    else:
        raise HTTPException(status_code=500, detail="couldn't update subscription")

@app.get("/getSubscription/{userid}")   
async def getSubscription(userid):##used in /getPatientDetails and in /regPatient##
    row = cursor.execute("SELECT subscription FROM Users WHERE userID = ?",(userid,)).fetchone()
    if row is not None:
        return row[0]
    else:
        return None

@app.post("/freeRequest")
async def freeRequest(user: freeUser):
    image_bytes1 = base64.b64decode(user.idCard1)
    image_bytes2 = base64.b64decode(user.idCard2)
    try:
        if(await checkUserFree(user.userId)):
            raise HTTPException(status_code=401, detail="user already applied")
        
        cursor.execute("INSERT INTO freeAccount (userId, birthdayDate, address, doctorCode, idCard1,idCard2) VALUES (?, ?, ?, ?, ?,?)",
                       (user.userId, user.birthDate,user.address, user.doctorCode, image_bytes1, image_bytes2))
        cnxn.commit()
        return {"message": "Registered successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        print(e)
        raise HTTPException(status_code=500, detail="couldn't register")

#@app.get("/checkUserFree/{userid}")   
async def checkUserFree(userid):##used in /getPatientDetails and in /regPatient##
    row = cursor.execute("SELECT birthdayDate FROM freeAccount WHERE userId = ?",(userid,)).fetchone()
    if row is not None:
        return True
    else:
        return False
 
@app.get("/getBirthday/{userid}")   
async def getBirthday(userid):##used in /getPatientDetails and in /regPatient##
    row = cursor.execute("SELECT birthdayDate FROM freeAccount WHERE userId = ?",(userid,)).fetchone()
    if row is not None:
        return row[0]
    else:
        raise HTTPException(status_code=500, detail="couldn't get birthday")
 
###########################################
########|Articles API Integration|#########
###########################################
##############################################################

#0abfbff3f1efcf35311a048b948c01aed8b7f17f552a4b882aa3c8544f9410dc
#eb03e6986533c14f2abb8e891cd2438a7f519c1e05935951a61141e23f9fd3b0
#6947fb817c89933b817e45fc405c8ac73f6ebcd227ce30702e943fab23304733 layal

apiKey = '6947fb817c89933b817e45fc405c8ac73f6ebcd227ce30702e943fab23304733'
'''def get_results(search):
    global results
    results = search.get_dict()
    
@app.get("/News/{query}")
async def get_news(query: str):
    params = {
        "q": query,
        "hl": "en",
        "gl": "us",
        "google_domain": "google.com",
        "api_key": apiKey
    }
    search = GoogleSearch(params)

    for i in range(10):  # Retry up to 3 times
        thread = threading.Thread(target=get_results, args=(search,))
        thread.start()
        thread.join(10)

        if thread.is_alive():
            time.sleep(5)  # Wait for 5 seconds before retrying
        else:
            
            return results["organic_results"]
    return {"error": "Failed to get results after 3 attempts"}   
'''
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

@app.get("/deleteEntry/{entryID}/{patientId}")
async def deleteEntry(entryID: int, patientId: int):
    try:
        row = cursor.execute("DELETE FROM Entry WHERE entryID = ? and patientID = ?", (entryID, patientId))
        cnxn.commit()
        if row is not None:
            return True
        else:
            return False
    except Exception as e:
        return {"error": str(e)}
    
@app.get("/getEntries/{id}")
async def getEntries(id:int):
    cursor.execute("SELECT * FROM Entry WHERE patientID = ?", (id,))
    rows = cursor.fetchall()
    column_names = [column[0] for column in cursor.description]
    if rows is None:
        return None
    else:
        return [{column_name: column for column_name, column in zip(column_names, row)} for row in rows]
    
@app.get("/getAppointment/{id}")
async def getAppointment(id:int):
    row = cursor.execute("SELECT nextAppointment from Patients where patientID = ?",(id)).fetchone()
    if row is not None:
        return row[0]
    else:
        raise HTTPException(status_code=404, detail="No apointment found")
    
############################3333
##############################3
#######delete account##########
###############################
@app.post("/deleteAccount")
async def deleteAccount(user:User):
    authentication = await authenticate(user)
    if 'error' not in authentication:
        id = getUserById(user.username)
        row = cursor.execute("DELETE FROM Entry WHERE patientID = ?", (id,))
        print("deleted entries")
        row1 = cursor.execute("DELETE FROM Patients WHERE patientID = ?", (id,))
        print("deleted patient")
        row2 = cursor.execute("DELETE FROM Users WHERE userID = ?", (id,))
        print("deleted user")
        cnxn.commit()
        if (row is not None) and (row1 is not None) and (row2 is not None):
            return True
        else:
            raise HTTPException(status_code=500, detail="couldn't delete account")
    else:
        raise HTTPException(status_code=400, detail="couldn't authenticate user")
    