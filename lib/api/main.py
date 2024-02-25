from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pyodbc
import json
import sqlalchemy as sal
import pandas as pd
import Models.personModel.person as Pmodel
from passlib.context import CryptContext
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()


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

class User(BaseModel):
    email: str
    password: str

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
    # Query the database for the user
    cursor.execute("SELECT userPassword FROM Users WHERE email = ?", (user.email,))
    row = cursor.fetchone()

    # If the user doesn't exist or the password is incorrect, return a 401 Unauthorized response
    if row is None or not pwd_context.verify(user.password, row[0]):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    #If the email and password are correct, return a 200 OK response
    return {"message": "Authenticated successfully"}

