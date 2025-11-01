from flask import Flask, render_template
app = Flask(__name__)
app.secret_key = "REPLACE_THIS_SECRET"
@app.route("/")
def dashboard():
    return render_template("dashboard.html")
@app.route("/login")
def login():
    return render_template("login.html")
@app.route("/add_user")
def add_user():
    return render_template("add_user.html")
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
