#!/usr/bin/env python3
"""http interface for custom hardware.
	Custom reactor control hardware can send its status here.
	Needs python packages fastapi and uvicorn installed.
"""

from fastapi import FastAPI, Request
import uvicorn

app = FastAPI()

@app.post("/reactor_control")
async def reactor_control(request: Request):
	# for this to work, header "content-type" must be set to "application/json".
	j = await request.json()
	print(j)

@app.post("/pingpost")
async def ping():
	pass

if __name__ == "__main__":
	uvicorn.run("test_reactor:app", host="127.0.0.1", port=8002, reload=False)
	
	# Test (from outside of this script)
	# requests.post("http://127.0.0.1:8002/reactor_control", json={"mode": "test", "data": {"something_nested": "a", "something_else": "b"}}).json()

