from pydantic import BaseModel
from typing import Optional

class Person(BaseModel):
    id: int
    firstname: str
    lastname: str
    username: str
    password: str

