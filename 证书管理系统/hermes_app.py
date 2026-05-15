from flask import Flask, jsonify
import datetime

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({"status": "running", "engine": "Hermes", "version": "1.0.0", "timestamp": str(datetime.datetime.now())})

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
