import psycopg2
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

params={'database':"postgresql",
'host':'localhost',
'database':'catdb',
'user':'uselect2',
'password':'seloct06',
'port':'5432'}

def getdata(requete):
    conn = psycopg2.connect(**params)
    cursor = conn.cursor()
    cursor.execute(requete)
    colnames = [desc[0] for desc in cursor.description]
    memory = cursor.fetchall()  
    conn.close()   
    return colnames,memory    

