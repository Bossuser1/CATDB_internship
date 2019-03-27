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
import nvd3 as d3

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
    chart = pieChart(name=type, color_category='category20c', height=800, width=800)
    extra_serie = {"tooltip": {"y_start": "", "y_end": " cal"}}
    chart.add_serie(y=ydata, x=xdata, extra=extra_serie)
    chart.buildcontent()
    text=chart.htmlcontent
    
    
    argument1="""chart.color(d3.scale.category20c().range());\n\n    chart.tooltipContent(function(key, y, e, graph) {\n          var x = String(key);\n              var y =  String(y)  + \' cal\';\n\n              tooltip_str = \'<center><b>\'+x+\'</b></center>\' + y;\n              return tooltip_str;\n              });\n"""
    argument2=""
    
    
    text=text.replace(argument1,argument2);
    #text=text.replace('return tooltip_str;\n              });\n       ','return tooltip_str;\n              });*\ \n       ')
    
    return text

#text=graph_treatment()
#print(text)
