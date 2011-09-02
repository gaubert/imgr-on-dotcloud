'''
Created on Sep 2, 2011

@author: aubert
'''
import logging
import pyres
from pyres.worker import Worker
import pyres.scripts 
from resqueue_test import Task





if __name__ == '__main__': 
    
    pyres.scripts.pyres_worker()
    
    #log_level = getattr(logging, 'INFO', 'INFO')
    #pyres.setup_logging(log_level=log_level, filename='/tmp/test.log')
    #Worker.run(["test-queue"],"localhost:6379")