import requests
from flask import Flask, jsonify
app = Flask(__name__)
@app.route('/')
# This is a simple Flask application that fetches a message from hello-world service and reverses it
def reverse_message():
    response = requests.get("http://hello-world:5000/")
    data = response.json()
    reversed_message = data["message"][::-1]
    return jsonify({ "id": data["id"], "message": reversed_message })
# This is the main entry point of the application that runs the Flask application on port 8000
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
