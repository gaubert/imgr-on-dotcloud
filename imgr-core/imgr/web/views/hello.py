'''
Created on Aug 23, 2011

@author: guillaume.aubert@gmail.com
'''

from flask import Module, render_template, request, redirect, flash, url_for

print(__name__)

hello = Module(__name__)

@hello.route('/hello')
@hello.route('/hello/<name>')
def view_hello(name=None):
    """ 
       Say Hello from a template 
    """
    return render_template('hello.tpl', name=name)
