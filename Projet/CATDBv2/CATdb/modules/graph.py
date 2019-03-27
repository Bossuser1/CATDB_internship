#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sat Mar 23 20:39:33 2019

@author: traore
"""
import sys


try:
    from CATdb.modules.requete  import getdata
    from CATdb.modules.palette_color import getcolor
except:
    pass
try:
    from requete  import getdata
    from palette_color import getcolor
except:
    pass
import  pandas as pd
import random


def graph_treatment():    
    requete="SELECT treatment.treatment_type,count(treatment.treatment_type)FROM chips.treatment,chips.experiment "\
    "WHERE experiment.experiment_id = treatment.experiment_id AND experiment.project_id = treatment.project_id group by  treatment.treatment_type;"
    
    r,data=getdata(requete)
    
    xdata=[]
    ydata=[]
    if len(data)>0:
        for i in range(0,len(data)):
            xdata.append(data[i][0])
            ydata.append(int(data[i][1]))
    
    
    
    
    from nvd3 import pieChart
    type = 'pieChart'
    chart = pieChart(name=type, color_category='category70c', height=400, width=400)
    #xdata = ["Orange", "Banana", "Pear", "Kiwi", "Apple", "Strawberry", "Pineapple","Orangesdqq", "Bananaqqss", "Peadsr", "Kiwisd", "Applesd", "Strawberrysd", "PineappleS"]
    #ydata = [3, 4, 6, 1, 5, 7, 3,3, 4, 6, 1, 5, 7, 3]
    extra_serie = {"tooltip": {"y_start": "", "y_end": " cal"}}
    chart.add_serie(y=ydata, x=xdata, extra=extra_serie)
    chart.buildcontent()
    text=chart.htmlcontent
    
    text=text.replace('chart.tooltipContent','/*chart.tooltipContent');
    text=text.replace('return tooltip_str;\n              });\n       ','return tooltip_str;\n              });*\ \n       ')
    
    return text
    