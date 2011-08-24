'''
Created on Aug 23, 2011

@author: guillaume.aubert@gmail.com
'''

from flask import g, Flask, render_template, request, redirect, flash, url_for, jsonify

from imgr.web.views.hello import hello

app = Flask(__name__)
app.register_blueprint(hello)
#app.register_module(hello)

#route index.html and default to product details page
@app.route('/')
@app.route('/index.html')
def index():
    return redirect(url_for('static', filename='index.html'))

if __name__ == "__main__":
    app.run(debug=True)
