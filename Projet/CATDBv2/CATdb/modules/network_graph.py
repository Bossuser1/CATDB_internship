#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sat Mar 23 20:39:33 2019

@author: traore
"""
import sys
import numpy as np

try:
    from CATdb.modules.requete  import getdata,getdata_map
    from CATdb.modules.palette_color import getcolor
except:
    pass
try:
    from requete  import getdata,getdata_map
    from palette_color import getcolor
except:
    pass
import  pandas as pd


def get_network_graph():
    requete="SELECT project.project_id,project.project_name,experiment.experiment_id,experiment.experiment_name,EXTRACT('year' from project.public_date) as year, EXTRACT('month' from project.public_date) as month FROM chips.project, chips.experiment WHERE  experiment.project_id = project.project_id order by year,month ;"
    r,data=getdata(requete)
    data=pd.DataFrame(data,columns=r)
    data=data.dropna()
    unique_year=data.year.unique()
    
    list_export_lev0={}
    list_export_lev1={}
    list_export_lev2={}
    list_export_lev3={}
    cpt0=0
    cpt1=0
    cpt2=0
    cpt3=0
    for key in data.index:
        element0=['CATDB',str(int(data.year[key]))]
        if element0 not in list_export_lev0.values():
            cpt0+=1
            list_export_lev0[cpt0]=element0
        element1=[data.year[key],str(data.year[key])+'-'+str(data.month[key])]
        if element1 not in list_export_lev1.values():
            cpt1+=1
            list_export_lev1[cpt1]=element1
        #str(int(data.year[key]))
        element2=['CATDB',str(data.project_id[key])+'#'+data.project_name[key]]
        if element2 not in list_export_lev2.values():
            cpt2+=1
            list_export_lev2[cpt2]=element2
        element3=[str(data.project_id[key])+'#'+data.project_name[key],str(data.experiment_id[key])+'#'+data.experiment_name[key]]
        if element3 not in list_export_lev3.values():
            cpt3+=1
            list_export_lev3[cpt3]=element3
    textexport=""
    #for elment in list_export_lev0.values():
    #    textexport+=str(elment)+', \n'
    for elment in list_export_lev2.values():
        textexport+=str(elment)+', \n'
    #for elment in list_export_lev3.values():
    #    textexport+=str(elment)+', \n'
    
    return textexport

data=get_network_graph()
