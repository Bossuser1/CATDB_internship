#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 27 20:23:16 2019

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
import random

def tableau_treatment():    
    requete="SELECT experiment.project_id,experiment.experiment_id,treatment.treatment_type,experiment.experiment_name ,project.title,project.project_name FROM chips.treatment,chips.experiment,chips.project"\
    " WHERE experiment.experiment_id = treatment.experiment_id AND experiment.project_id = treatment.project_id and project.project_id=treatment.project_id ;"
    sep='#'
    colname,data=getdata(requete)
    #dat=pd.DataFrame(data,columns=colname)
    
    dat1=dict()
    for i in range(len(data)):
        if data[i][2] not in dat1.keys():
            dat1[data[i][2]]=[str(data[i][0])+sep+str(data[i][1])+sep+str(data[i][3])+sep+str(data[i][4])+sep+str(data[i][5])+sep]
        else:
            cpt=dat1[data[i][2]]
            cpt.append(str(data[i][0])+sep+str(data[i][1])+sep+str(data[i][3])+sep+str(data[i][4])+sep+str(data[i][5])+sep)
            dat1[data[i][2]]=list(set(cpt))
    #print("=========new======")
    html="<script> function gotolink(key){ window.location='project.html?project='+key;}; </script>"
    html+="<table><thead><th>Treatment</th><th>Project</th></thead><tbody>" #<th>Experiment</th>
    for key in dat1.keys():
        try:
            text="<tr>"+"<td>"+key+"</td>"
            row1=""
            row2=""
            for el in range(len(dat1[key])):
                row1+='<div onclick="gotolink(\''+dat1[key][el].split(sep)[0]+'\');">'+dat1[key][el].split(sep)[4]+"</div>"
                #row2+="<div>"+dat1[key][el].split(sep)[2]+"</div>"
            text+="<td>"+row1+"</td>"+"</tr>"#+"<td>"+row2+"</td>"
            html+=text
        except:
            pass
    html+="</tbody></table>"
    return html

def tableau_treatment_specifique(key):    
    requete="SELECT experiment.project_id,experiment.experiment_id,treatment.treatment_type,experiment.experiment_name ,project.title,project.project_name FROM chips.treatment,chips.experiment,chips.project"\
    " WHERE experiment.experiment_id = treatment.experiment_id AND experiment.project_id = treatment.project_id and project.project_id=treatment.project_id and treatment.treatment_type='"+key+"';"
    sep='#'
    colname,data=getdata(requete)
    #dat=pd.DataFrame(data,columns=colname)
    
    dat1=dict()
    for i in range(len(data)):
        if data[i][2] not in dat1.keys():
            dat1[data[i][2]]=[str(data[i][0])+sep+str(data[i][1])+sep+str(data[i][3])+sep+str(data[i][4])+sep+str(data[i][5])+sep]
        else:
            cpt=dat1[data[i][2]]
            cpt.append(str(data[i][0])+sep+str(data[i][1])+sep+str(data[i][3])+sep+str(data[i][4])+sep+str(data[i][5])+sep)
            dat1[data[i][2]]=list(set(cpt))
    #print("=========new======")
    html="<script> function gotolink(key){ window.location='project.html?project='+key;}; </script>"
    html+="<table><thead><th>Treatment</th><th>Project</th></thead><tbody>" #<th>Experiment</th>
    for key in dat1.keys():
        try:
            text="<tr>"+"<td>"+key+"</td>"
            row1=""
            row2=""
            for el in range(len(dat1[key])):
                row1+='<div onclick="gotolink(\''+dat1[key][el].split(sep)[0]+'\');">'+dat1[key][el].split(sep)[4]+"</div>"
                #row2+="<div>"+dat1[key][el].split(sep)[2]+"</div>"
            text+="<td>"+row1+"</td>"+"</tr>"#+"<td>"+row2+"</td>"
            html+=text
        except:
            pass
    html+="</tbody></table>"
    return html



#print(html)    