#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun Mar 17 21:04:36 2019

@author: traore
"""
import sys
import json
import os
import csv
import requests
from bs4 import BeautifulSoup




sys.path.insert(0, '../')

import os
import psycopg2


from configparser import ConfigParser


direction="/home/traore/Bureau/Dossier_Stage/CATDB_internship/Projet/CATDB/CATdb/"

def config(direct,section='postgresql'):
    if os.getcwd()[0:12]!="/home/traore":
        filename=direction+'/database2.ini'
    	#filename=os.getcwd()+'/CATdb/database.ini'
    else:
        filename=direction+'/database2.ini'
    	#filename=os.getcwd()+'/CATdb/database2.ini'
    # create a parser
    parser = ConfigParser()
    # read config file
    parser.read(filename)
    # get section, default to postgresql
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception('Section {0} not found in the {1} file'.format(section, filename))
 
    return db



def connect(direction):
    """ Connect to the PostgreSQL database server """
    conn = None
    try:
        # read connection parameters
        params =config(direction)
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


def read_data_sql(direction,requete,element):
    """
    input requete outupt data
    requete='select * from chips.experiment;'
    """
    conn = None
    params = config(direction)
    conn = psycopg2.connect(**params)
    cursor = conn.cursor()#cursor_factory=psycopg2.extras.DictCursor
    cursor.execute(requete)
    colnames = [desc[0] for desc in cursor.description]
    memory = cursor.fetchall()
    conn.close()
    cpt=0
    data=dict()
    for ele in range(len(memory)):
        cpt=cpt+1
        col=[]
        for ele1 in memory[ele]:
            col.append(str(ele1))
        dictionary ={'_key':cpt,"_value":dict(zip(colnames,col))}
        data[cpt]=dictionary
    name=element+'.csv'     
    return data


project='450'


direct=direction+'/static/data/'
#from connection import *
   

def read_data(experiment):
    statut=False
    try:
        link="http://urgv.evry.inra.fr/cgi-bin/projects/CATdb/consult_expce.pl?experiment_id="+str(experiment)
        requete1 = requests.get(link)
        page = requete1.content
        soup = BeautifulSoup(page)
        h1 = soup.find("div", {"class": "entete"}).text
        statut=h1.replace('\n','').replace(' ','')=="****SORRY,THISPROJECTISNOTAVAILABLE****"
    except:
        link="http://urgv.evry.inra.fr/cgi-bin/projects/CATdb/consult_expce.pl?experiment_id="+str(1000000000)
    if statut==True:
        try:
            conn = None
            params = config(direction)
            conn = psycopg2.connect(**params)
            requete='select experiment.project_id from public.experiment where experiment_id='+str(experiment)+';'
            cursor = conn.cursor()#cursor_factory=psycopg2.extras.DictCursor
            cursor.execute(requete)
            colnames = [desc[0] for desc in cursor.description]
            memory = cursor.fetchall()
            conn.close()
            data_project=dict(zip(colnames,memory[0]))
        except:
            pass
        try:
            requete='select * from public.project,public.experiment where project.project_id='+str(data_project['project_id'])+';'
            conn = psycopg2.connect(**params)
            cursor = conn.cursor()#cursor_factory=psycopg2.extras.DictCursor
            cursor.execute(requete)
            colnames = [desc[0] for desc in cursor.description]
            memory = cursor.fetchall()
            conn.close()
            data_project=dict(zip(colnames,memory[0]))
        except:
            pass
        with open(direct+'rna_seq.json') as json_file:  
            data = json.load(json_file)
            for key in data.keys():
                if int(data[key]['_value']['project_id'])==int(project) and int(data[key]['_value']['experiment_id'])==int(experiment):
                    data[key]
        return data[key]   
    else:
       return link  
                   
answer=read_data(634)

