'''
Created on Aug 24, 2011

@author: guillaume.aubert@gmail.com
'''

from flask import Module, render_template, request, redirect, flash, url_for
from werkzeug import secure_filename

UPLOAD_FOLDER = '/path/to/the/uploads'
ALLOWED_EXTENSIONS = set(['txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'])

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


upload = Module(__name__)

@hello.route('/hello')
@hello.route('/hello/<name>')
def view_hello(name=None):
    """ 
       Say Hello from a template 
    """
    return render_template('hello.tpl', name=name)
