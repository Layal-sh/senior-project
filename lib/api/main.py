from fastapi import FastAPI
import pyodbc
import json
import sqlalchemy as sal
import pandas as pd
import Models.personModel.person as Pmodel



app = FastAPI()

connectionString = "Server=localhost;Database=SugarSense;Trusted_Connection=True;"

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
async def read_item(user_id: int):
    cursor.execute("Select * from Meals")
    row = cursor.fetchall()
    if row is None:
        return {"error": "User not found"}
    else:
        return {description[0]: column for description, column in zip(cursor.description, row)}
