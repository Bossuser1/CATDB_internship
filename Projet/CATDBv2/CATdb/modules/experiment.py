#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 29 08:48:28 2019

@author: traore
"""

import pandas as pd
import numpy as np

from requete import getdata

sep_ident='#'
sep_experiment='@'

requete="SELECT project.project_id, CONCAT(experiment.experiment_id,'"+sep_ident+"',experiment.experiment_name) AS EXPERIMENT "\
"FROM chips.project, chips.experiment WHERE project.project_id = experiment.project_id ORDER BY project_id ;"
r,data=getdata(requete)

key_project={}
for el in data:
    if el[0] not in key_project.keys():
        key_project[el[0]]={'project_id':el[0],'experiment':el[1],'len':1}
    else:
        leng=key_project[el[0]]['len']+1
        exper=key_project[el[0]]['experiment']+sep_experiment+el[1]
        key_project[el[0]]={'project_id':el[0],'experiment':exper,'len':leng,}
        #element=key_project[el[0]]
        #element=element+sep_experiment+el[1]
        #key_project[el[0]]=element

proj=np.transpose(pd.DataFrame(key_project))