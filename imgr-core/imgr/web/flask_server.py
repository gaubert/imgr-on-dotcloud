'''
Created on Aug 23, 2011

@author: guillaume.aubert@gmail.com
'''
import os
import subprocess
from flask import g, Flask, render_template, request, redirect, flash, url_for, jsonify, send_from_directory
from werkzeug import secure_filename
from imgr.web.views.hello import hello

UPLOAD_FOLDER = '/tmp/uploads'
RESULT_FOLDER = '/tmp/results'

ALLOWED_EXTENSIONS = set(['PNG', 'png', 'JPG', 'jpg', 'JPEG', 'jpeg', 'GIF', 'gif'])

app = Flask(__name__)
app.config['UPLOAD_FOLDER']      = UPLOAD_FOLDER
app.config['RESULT_FOLDER']      = RESULT_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024
app.register_blueprint(hello)

#route index.html and default to product details page
@app.route('/')
@app.route('/index.html')
def index():
    return redirect(url_for('static', filename='index.html'))


# everything for the upload part
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS
           
def build_command(a_in, a_input_text):
    """ build the command to execute """
    
    # on my laptop
    dir = "/home/aubert/workspace/imgr-on-dotcloud/etc/scripts"
    # on dotcloud
    dir = "/home/dotcloud/current/etc/scripts"
    com = "bottom_card.sh"
    
    out = "%s/out_%s" % (RESULT_FOLDER, a_in)
    
    command = "%s/%s" % (dir,com)
    options = ["%s/%s" % (UPLOAD_FOLDER, a_in),"%s" % (a_input_text), "%s" % (out)]
    
    return (command, options, out)

def exec_command(command, options):
    """ execute the command """
    
    #/home/aubert/workspace/imgr-on-dotcloud/etc/scripts/bottom_card.sh, options=["'/tmp/in-1.jpg'", "'Hello World'", "'/tmp/out_in-1.jpg'"]
    #/home/aubert/workspace/imgr-on-dotcloud/etc/scripts/bottom_card.sh
    #return subprocess.check_call([command].extend(options))
    
    command_list = [command]
    command_list.extend(options)
    
    app.logger.debug("Command list %s" % (command_list))
    
    #return subprocess.check_call(["/home/aubert/workspace/imgr-on-dotcloud/etc/scripts/bottom_card.sh", "/tmp/in.jpg", "Hello World !", "/tmp/out_in-1.jpg"])
    return subprocess.check_call(command_list)

    

@app.route('/upload', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        file = request.files['file']
        
        
        text_to_print = request.form.get('text', 'No Text Given')
        
        if file and allowed_file(file.filename):
            
            filename = secure_filename(file.filename)
            
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
        
            app.logger.debug("text_to_print = %s\n" % (text_to_print))
            # run script exec with 
            (command, options, out) = build_command(filename, text_to_print)
            
            app.logger.debug('command = %s, options=%s\n' % (command, options) )

            exec_command(command,options)
            
            app.logger.debug("out file %s\n" % (out))
            
            return redirect(url_for('result_file', filename=os.path.basename(out)))
        else:
            return '''
            <!doctype html>
            <title>Error Bad file type</title>
            <h1> %s is a not supported file type.</h1>
            <h1> Only Support %s.</h1>
            ''' % (file.filename, ALLOWED_EXTENSIONS)
        
    return '''
    <!doctype html>
    <title>Upload new File</title>
    <h1>Upload new File</h1>
    <form action="" method=post enctype=multipart/form-data>
    <p>
    Text<input type=text name=text></input>
    </p>
    <p>
    <input type=file name=file>
    <input type=submit value=Upload>
    </form>
    '''
    
@app.route('/get-upload/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'],
                               filename)

@app.route('/results/<filename>')
def result_file(filename):
    return send_from_directory(app.config['RESULT_FOLDER'],
                               filename)

if __name__ == "__main__":
    app.run(debug=True)
