import click
from models import OperationRequest
from math_ops import power, fibonacci, factorial
from db import log_operation

@click.group()
def cli():
    """Math CLI tool"""
    pass

@cli.command()
@click.argument("x", type=int)
@click.argument("y", type=int)
def pow(x, y):
    """Calculate x to the power of y"""
    result = power(x, y)
    log_operation("pow", f"{x},{y}", str(result))
    click.echo(f"Result: {result}")

@cli.command()
@click.argument("n", type=int)
def fib(n):
    """Calculate n-th Fibonacci number"""
    result = fibonacci(n)
    log_operation("fib", str(n), str(result))
    click.echo(f"Result: {result}")

@cli.command()
@click.argument("n", type=int)
def fact(n):
    """Calculate factorial of n"""
    result = factorial(n)
    log_operation("fact", str(n), str(result))
    click.echo(f"Result: {result}")
