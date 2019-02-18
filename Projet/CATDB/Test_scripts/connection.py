#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 15 00:20:20 2019

@author: traore
"""
import sys
sys.path.append("/home/traore/anaconda3/lib/python3.6/site-packages")

import psycopg2

try:
    conn = psycopg2.connect("dbname='myproject' user='postgres' host='localhost' password='t'")
    cur = conn.cursor()
    "dbname=suppliers user=postgres password=postgres"
    cur.execute("""SELECT * FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';""")
    #cur.execute("""SELECT version();""")
    rows = cur.fetchall()
    for row in rows:
        print(row)
    cur.close()
except:
    print("I am unable to connect to the database")