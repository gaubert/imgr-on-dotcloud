'''
Created on Sep 2, 2011

@author: guillaume.aubert
'''
from pyres import ResQ
from pyres.job import Job

class Task(object):
    queue ="test-queue"
    
    def __init__(self,payload):
        self.payload = payload
    
    @staticmethod
    def perform(json_dir):
        print "do something %s\n" % (json_dir)
        
        
    



if __name__ == '__main__':
    
    
    r = ResQ()
    print("Enqueue message\n")
    r.enqueue(Task,"{key:id-1, file:'/tmp/toto.jpg'}")
    #print("get message from basic\n")
    #job = Job.reserve('test-queue', r)
    job = None
    
    if job:
        print("job payload %s\n" % (job._payload) )
    else:
        print( "No jobs \n")
    
    