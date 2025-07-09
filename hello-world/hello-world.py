from flask import Flask, jsonify
app = Flask(__name__)
# This is a simple Flask application that returns a JSON response
@app.route('/') 
def hello(): 
    return jsonify({ "id": "1", "message": "Hello world" })  
# This is the main entry point of the application that runs the Flask application on port 5000
if __name__ == '__main__': 
    app.run(host='0.0.0.0', port=5000) 
