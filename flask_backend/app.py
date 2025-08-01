from flask import Flask
from routes.api import api
from flask_cors import CORS

app = Flask(__name__)
app.register_blueprint(api)
CORS(app)


@app.route('/')
def home():
    return "Hello from Flask!"

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)