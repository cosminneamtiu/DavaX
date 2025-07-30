from fastapi import APIRouter
from app.models import PowerRequest, SingleIntRequest, OperationResponse
from app.math_ops import power, fibonacci, factorial
from app.db import log_operation

router = APIRouter()

@router.post("/power", response_model=OperationResponse)
def calculate_power(data: PowerRequest):
    result = power(data.x, data.y)
    log_operation("power", f"x={data.x},y={data.y}", str(result))
    return {"result": result}

@router.post("/fibonacci", response_model=OperationResponse)
def calculate_fibonacci(data: SingleIntRequest):
    result = fibonacci(data.n)
    log_operation("fibonacci", f"n={data.n}", str(result))
    return {"result": result}

@router.post("/factorial", response_model=OperationResponse)
def calculate_factorial(data: SingleIntRequest):
    result = factorial(data.n)
    log_operation("factorial", f"n={data.n}", str(result))
    return {"result": result}
