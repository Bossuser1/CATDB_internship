from django.db import models

# Create your models here.

import psycopg2
from CATdb.config import config
#from config import config
import psycopg2.extras 

def connect():
    """ Connect to the PostgreSQL database server """
    conn = None
    try:
        # read connection parameters
        params = config()
 
        # connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
 
        # create a cursor
        cur = conn.cursor()
        
        # execute a statement
        print('PostgreSQL database version:')
        cur.execute('SELECT version()')
 
        # display the PostgreSQL database server version
        db_version = cur.fetchone()
        print(db_version)
       
     # close the communication with the PostgreSQL
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')
def read_data_sql(requete):
    "input requete outupt data"
    """
    requete='select * from chips.experiment;'
    """
    data=requete.replace("'","").replace(";","").split()
    if data[0]=='select' and requete[-1]==';':
        conn = None
        params = config()
        conn = psycopg2.connect(**params)
        cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cursor.execute(requete)
        colnames = [desc[0] for desc in cursor.description]
        memory = cursor.fetchall()
        conn.close()
    else:
        print("Merci de verifier")

    cpt=0
    data=dict()
    for ele in memory:
        cpt=cpt+1
        dictionary ={'_key':cpt,"_value":dict(zip(colnames, ele))}
        data[cpt]=dictionary

    return data
