from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pyodbc
import Models.personModel.person as Pmodel
from fastapi.middleware.cors import CORSMiddleware
import hashlib
import requests
from serpapi import GoogleSearch

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

#connectionString = "Server=localhost;Database=SugarSense;Trusted_Connection=True;"
server = 'sugarsense.database.windows.net'
database = 'sugarsensedb'
username = 'sugaradmin'
password = 'SUG@Rs!!7891'
driver= '{ODBC Driver 17 for SQL Server}'
#driver= '{ODBC Driver 18 for SQL Server}'

connection_string = f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};'


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
    doctorID: int
    insulinSensivity: float
    targetBloodGlucose : int
    carbRatio1 : float
    carbRatio2 : float
    carbRatio3 : float
    privacy : str


conn_str = ("DRIVER={ODBC Driver 17 for SQL Server};"
            "Server=localhost;" #MSI22\SQLEXPRESS
            "Database=SugarSense;"
            "Trusted_Connection=yes;")
cnxn = pyodbc.connect(connection_string)
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
        cursor.execute("INSERT INTO Patients (patientID, doctorID, insulinSensivity, targetBloodGlucose , carbRatio, carbRatio2, carbRatio3, privacy) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                       (id, user.doctorID, user.insulinSensivity, user.targetBloodGlucose, user.carbRatio1, user.carbRatio2, user.carbRatio3, user.privacy))
        cnxn.commit()
        print("Registered patient successfully")
        return {"message": "Registered patient successfully"}
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
    
def checkEmail(email):
    row = cursor.execute("SELECT userID FROM Users WHERE CAST(email AS VARCHAR(255)) = ?",(email,)).fetchone()
    if(row is None):
        return True
    else:
        return False
def getUserById(username):
    row = cursor.execute("SELECT userID FROM Users WHERE CAST(userName AS VARCHAR(255)) = ?",(username,)).fetchone()
    if row is not None:
        return row[0]
    else:
        return None
@app.get("/MealComposition")
async def get_mealComposition():
    cursor.execute("Select * from MealComposition") 
    rows = cursor.fetchall()
    if rows is None:
        return {"error": "No meals found"}
    else:
        return [{description[0]: column for description, column in zip(cursor.description, row)} for row in rows]
    
#News Api Key: 52583f3a26ca4ba0b9631f43f66abb3d
apiKey = 'd9cb4bee70915b0f8ad912e10388ab16f02a2f0b7e84724806d40e5700461781'

@app.get("/News/{query}")
async def get_news(query: str):
    params = {
        "q": query,
        "hl": "en",
        "gl": "us",
        "google_domain": "google.com",
        "api_key": "d9cb4bee70915b0f8ad912e10388ab16f02a2f0b7e84724806d40e5700461781"
    }

    search = GoogleSearch(params)
    results = search.get_dict()
    
    return results["organic_results"]

    
#combined_results = results["organic_results"] + results2["organic_results"]
# Convert each dictionary in the list to a frozenset so it can be added to a set
# This will remove duplicates because sets only allow unique elements
#unique_results = [dict(item) for item in set(frozenset(d.items()) for d in combined_results)]
#return unique_results