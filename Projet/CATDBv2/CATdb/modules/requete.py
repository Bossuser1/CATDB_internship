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


def getdata_map(requete):
    colnames,memory=getdata(requete)
    cpt=0
    data=dict()
    for ele in range(len(memory)):
        cpt=cpt+1
        col=[]
        for ele1 in memory[ele]:
            col.append(str(ele1))
        dictionary ={'_key':cpt,"_value":dict(zip(colnames,col))}
        data[cpt]=dictionary
    return data