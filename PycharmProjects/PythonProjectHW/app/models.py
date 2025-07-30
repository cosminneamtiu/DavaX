from pydantic import BaseModel

class PowerRequest(BaseModel):
    x: int
    y: int

class SingleIntRequest(BaseModel):
    n: int

class OperationResponse(BaseModel):
    result: int
