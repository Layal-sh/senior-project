from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pyodbc
import json
import sqlalchemy as sal
import pandas as pd
import Models.personModel.person as Pmodel
from passlib.context import CryptContext
from fastapi.middleware.cors import CORSMiddleware
import requests


app = FastAPI()
# Set up logging

origins = [
    "http://localhost:8000",  # Allow requests from your FastAPI server
    "http://localhost:49581",
    "http://localhost:3000"  # Allow requests from your Flutter app
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

connectionString = "Server=localhost;Database=SugarSense;Trusted_Connection=True;"

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

dummypass = "#botato3452"

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


conn_str = ("DRIVER={ODBC Driver 17 for SQL Server};"
            "Server=localhost;"
            "Database=SugarSense;"
            "Trusted_Connection=yes;")
cnxn = pyodbc.connect(conn_str)
cursor = cnxn.cursor()
print(Pmodel.BaseModel)
row = cursor.execute("Select * from Users WHERE userId = 1")
print(row.fetchone())
#print(row)
#print(type(Pmodel.BaseModel))
#engine = sal.create_engine('mssql+pyodbc://localhost/SugarSense')
#sql_query = pd.read_sql_query('SELECT * FROM Users')
#conn = engine.connect()
#row = cursor.fetchone()

#cursor.execute("INSERT INTO Users (firstName, lastName, userName, email, userPassword) VALUES ({user.fname}, {user.lname}, {user.username}, {user.email}, {user.password})")
#row = cursor.execute("INSERT INTO Users (firstName, lastName, userName, email, userPassword) VALUES ('botato', 'sweet', 'sweet botato', 'sweetbotato@gmail.com', 'unsweetbotato')")
#print(cursor.rowcount)
#cnxn.commit()

@app.get('/')
def get():
    return {"Hello":"get request"}

@app.post('/')
def post():
    return {"Success":"Post request"}

@app.patch('/')
def patch():
    return {"Success": "You just Patched"}

@app.get("/users/{user_id}")
async def read_item(user_id: int):
    cursor.execute("Select * from Users WHERE userId = ?", (user_id,))
    row = cursor.fetchone()
    if row is None:
        return {"error": "User not found"}
    else:
        return {description[0]: column for description, column in zip(cursor.description, row)}
    
@app.get("/meals")
async def get_meals():
    cursor.execute("Select * from Meals")
    rows = cursor.fetchall()
    if rows is None:
        return {"error": "No meals found"}
    else:
        return [{description[0]: column for description, column in zip(cursor.description, row)} for row in rows]

@app.get("/meals/{meal_id}")
async def read_item(meal_id: int):
    cursor.execute("Select * from Meals WHERE mealID = ?", (meal_id,))
    row = cursor.fetchone()
    if row is None:
        return {"error": "Meal not found"}
    else:
        return {description[0]: column for description, column in zip(cursor.description, row)}
    

@app.post("/authenticate")
async def authenticate(user: User):
    try:
        # Query the database for the user
        cursor.execute("SELECT userPassword FROM Users WHERE CAST(userName AS VARCHAR(255)) = ?",(user.username,))
        rowUsername = cursor.fetchone()
        cursor.execute("SELECT userPassword FROM Users WHERE CAST(email AS VARCHAR(255)) = ?",(user.username,))
        rowEmail = cursor.fetchone()
        # If the user doesn't exist or the password is incorrect, return a 401 Unauthorized response
        if (rowUsername is None or user.password != rowUsername[0]) and (rowEmail is None or user.password != rowEmail[0]):
            raise HTTPException(status_code=401, detail="Invalid email or password")

        # If the email and password are correct, return a 200 OK response
        return {"message": "Authenticated successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        return {"error": str(e)}
    
@app.post("/register")
async def registerfunction(user: NewUser):
    try:
        print('entered register')
        '''
        if(checkUsername(user.username)):
            print('username does not exist')
            if user.password != user.confirmPassword:
                print('password not equal')
                raise HTTPException(status_code=401, detail="password does not match with Confirm Password")
            else:
                cursor.execute("INSERT INTO Users (firstName, lastName, userName, email, userPassword) VALUES ('test', 'test', 'test', 'tesst', 'tesst')")
                cnxn.commit()
        else:
            raise HTTPException(status_code=401, detail="Username already exists")
        '''
        cursor.execute("INSERT INTO Users (firstName, lastName, userName, email, userPassword) VALUES (?, ?, ?, ?, ?)",(user.firstName, user.lastName, user.username, user.email, user.password))
        cnxn.commit()
        # If the email and password are correct, return a 200 OK response
        return {"message": "Registered successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        return {"error": str(e)}
    
def checkUsername(username):
    row = cursor.execute("SELECT userID FROM Users WHERE CAST(userName AS VARCHAR(255)) = ?",(username,)).fetchone()
    if(row is None):
        return True
    else:
        return False

