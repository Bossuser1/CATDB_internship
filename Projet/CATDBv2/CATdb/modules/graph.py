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
import random
import nvd3 as d3

def graph_treatment():    
    key2='piegraph'
    requete="SELECT treatment.treatment_type,count(treatment.treatment_type)FROM chips.treatment,chips.experiment "\
    "WHERE experiment.experiment_id = treatment.experiment_id AND experiment.project_id = treatment.project_id group by  treatment.treatment_type;"
    r,data=getdata(requete)
    xdata=[]
    ydata=[]
    if len(data)>0:
        for i in range(0,len(data)):
            xdata.append(data[i][0])
            ydata.append(int(data[i][1]))
    dimwith=800
    dimheight=700
    
    from nvd3 import pieChart
    type =key2
    chart = pieChart(name=type, color_category='category20c', height=dimheight, width=dimwith)
    extra_serie = {"tooltip": {"y_start": "", "y_end": " cal"}}
    chart.add_serie(y=ydata, x=xdata, extra=extra_serie)
    
    chart.buildcontent()
    text=chart.htmlcontent
    argument1="""chart.color(d3.scale.category20c().range());\n\n    chart.tooltipContent(function(key, y, e, graph) {\n          var x = String(key);\n              var y =  String(y)  + \' cal\';\n\n              tooltip_str = \'<center><b>\'+x+\'</b></center>\' + y;\n              return tooltip_str;\n              });\n"""
    ##$('#piechart svg.nvd3-svg').attr('width')=dimwith+100
    argument2=" "
    argument7="""});\n        var datum ="""
    argument8="""});\n  chart.legendPosition("right");\n      var datum ="""
    text=text.replace(argument7,argument8)
    text=text.replace(argument1,argument2)
    #text=text.replace('return tooltip_str;\n              });\n       ','return tooltip_str;\n              });*\ \n       ')
    argument3="nv.addGraph(function() {\n"
    argument4="function rungraphpi(){ \n nv.addGraph(function() {\n"
    text=text.replace(argument3,argument4) 
    argument5="</script>"
    argument6=" $('#piegraph').ready(function(){ d3.selectAll('.nv-slice').on('click',function(e){ var col=e.data.label; window.location='treatment.html?treatment='+col;   });}); } ;\n rungraphpi(); alert(); \n </script>"
    text=text.replace(argument5,argument6)   


    return text

def graph_ecotype():
    key='organsim'
    key2="multigraph"
    requete="SELECT  "\
        "  distinct(organism.organism_name), "\
        "  ecotype.ecotype_name,  "\
        "  sample_source.project_id  "\
        " FROM   "\
        "  chips.sample_source,  "\
        "  chips.organism,  "\
        "  chips.ecotype  "\
        "WHERE   "\
        "  sample_source.ecotype_id = ecotype.ecotype_id AND  "\
        "  organism.organism_id = sample_source.organism_id  "\
        "order by ecotype_name,organism.organism_name;  "
    r,data=getdata(requete)
    dat=pd.DataFrame(data)
    dat2=pd.crosstab(dat[0],dat[1])
    
    #test du plus lon
    
    dat2=pd.crosstab(dat[0],dat[1])
    dat2=pd.DataFrame(np.transpose(dat2))
    
    #r,data=getdata(requete)
    
    #if len(data)>0:
    #    for i in range(0,len(data)):
    #        xdata.append(data[i][0])
    #        ydata1.append(int(data[i][1]))
    split=dict(np.transpose(dat2).sum())
    list1=[]
    list2=[]
    for element in split.keys():
        if split[element]>1:
            list1.append(element)
        else:
            list2.append(element)    
    
    from nvd3 import multiBarChart
    chart1 = multiBarChart(name=key2,width=800, height=800, x_axis_format=None)
    #text_white="chart.stacked(true);"
    #chart1.add_chart_extras(text_white)
    chart2 = multiBarChart(width=800, height=800, x_axis_format=None)
    xdata = list(dat2.index)#['one', 'two', 'three', 'four']
    #ydata1 = [6, 12, 9, 16]
    serie_lab=list(dat2.columns)    
    for ele in range(0,len(serie_lab)):
        if ele!=1:
            chart1.add_serie(name=serie_lab[ele], y=list(dat2.loc[list1,serie_lab[ele]]), x=list1)
        #chart2.add_serie(name=serie_lab[ele], y=list(dat2.loc[list2,serie_lab[ele]]), x=list1)            
    chart1.buildhtml()
    text=chart1.htmlcontent
    argument1="var chart = nv.models.multiBarChart();\n\n"
    argument2="var chart"+key+" = nv.models.multiBarChart();\n\n \n\n"
    text=text.replace(argument1,argument2)
    text=text.replace("chart.","chart"+key+".")

    argument7="""});\n        var datum ="""
    argument8="""});\n  chart"""+key+""".legendPosition("right");\n      var datum ="""
    text=text.replace(argument7,argument8)

    text=text.replace(".call(chart);",".call(chart"+key+");")
    text=text.replace("</script>","$('#multigraph1 .nv-controlsWrap .nv-series:eq(0)').addClass('nv-disabled');\n </script>")    
    argument3="nv.addGraph(function() {\n"
    argument4="function rungraph(){ \n nv.addGraph(function() {\n"
    text=text.replace(argument3,argument4) 
    argument5="</script>"
    argument6="};\n rungraph(); \n alert(); </script>"
    text=text.replace(argument5,argument6)                                
    return text     

def graph_experiment_factors():
    requete="SELECT experiment.experiment_factors,experiment.project_id  "\
    "FROM chips.experiment;"
    r,data=getdata(requete)
    list_element=[]
    comptability={}
    for j in range(len(data)):
        text=data[j][0]
        for elemnt in text.split(','):
            if elemnt[0]==' ':
               elemnt=elemnt[1:]
            elemnt=elemnt.replace('\t','')
            if elemnt[-1]==' ':
               elemnt=elemnt[0:-1]
            if elemnt[-5:]=='a wt)':
               elemnt=elemnt[0:-4]
            if elemnt[0:2]!='--':
               list_element.append(elemnt)
               if elemnt not in comptability.keys():
                   comptability[elemnt]=[data[j][1]]
               else:
                   cpt=comptability[elemnt]
                   cpt.append(data[j][1])
                   comptability[elemnt]=list(set(cpt))
    #data_plot={}
    #for element in comptability.keys():
    #    data_plot[0]
    
    from nvd3 import discreteBarChart
    chart = discreteBarChart(name='discreteBarChart', height=400, width=800)
    
    xdata=[]
    ydata=[]
    list1=list(comptability.keys())#[0:20]

    
    dataplost={}
    for element in list1:
        dataplost[element]=len(comptability[element])
    a=sorted(dataplost,key=dataplost.__getitem__,reverse=True)
    
    ######a corriger car fixer
    for element in a[0:30]:
        xdata.append(element)
        ydata.append(dataplost[element])
    #xdata.append(element)# = ["A", "B", "C", "D", "E", "F"]
        #ydata.append(len(comptability[element]))# = [3, 4, 0, -3, 5, 7]
    #array=np.array([xdata,ydata])
    #a=np.sort(array,axis=1)
    chart.add_serie(y=ydata, x=xdata)
    chart.buildhtml()

    
    text=chart.htmlcontent

    argument1="var chart = nv.models.discreteBarChart();\n\n"
    argument2="var chart = nv.models.discreteBarChart();\n\n chart.xAxis.rotateLabels(-90); \n\n"
    text=text.replace(argument1,argument2)

    argument3="nv.addGraph(function() {\n"
    argument4="function rungraphdiscret(){ \n nv.addGraph(function() {\n"
    text=text.replace(argument3,argument4) 
    argument5="</script>"
    argument6="};\n rungraphdiscret(); alert();\n </script>"
    text=text.replace(argument5,argument6)                                

    
    return text
#
#requete="SELECT project.project_id, project.gem2net_id,date_part('year',project.public_date) as year,1 as nbr  "\
#"FROM chips.project where project.is_public='yes' order by project.gem2net_id;"
#r,data=getdata(requete)
#verif=len(data)
#dat=pd.DataFrame(data,columns=r)
#
#dat2=dat[['year','project_id']].groupby(['year']).cumsum()
#
#dat1=pd.crosstab(dat['year'], dat['project_id'],margins=True)
    
#dat1['cum_sum'] = dat1.all.cumsum()
#def graph_experiment_type():
#    requete="SELECT experiment.experiment_factors,experiment.project_id  "\
#    "FROM chips.experiment;"
#    from nvd3 import multiBarHorizontalChart
#graph_experiment_factors()
#print(graph_experiment_factors())  


#import operator
#
#split=dict(np.transpose(dat2).sum())
#list1=[]
#list2=[]
#for element in split.keys():
#    if split[element]>1:
#       list1.append(element)
#    else:
#       list2.append(element)   
#
#dat2.loc[list2,u'Vitis vinifera']

#.legendPosition("right");

def fespeces(df):
    if df['organsim_name']=='Arabidopsis thaliana':
        val = 'Arabidopsis thaliana'
    else:
        val='Others Species'
    return val


def crosstablespeciesbytechnologie():
    requete="SELECT distinct project.project_id, project.project_name, experiment.analysis_type,experiment.array_type, project.public_date, organism.organism_id, organism.organism_name "\
    "FROM chips.project, chips.experiment, chips.sample_source, chips.organism WHERE project.project_id = experiment.project_id AND sample_source.experiment_id = experiment.experiment_id AND sample_source.project_id = experiment.project_id AND organism.organism_id = sample_source.organism_id and project.is_public='yes';"
    r,data=getdata(requete)
    data=pd.DataFrame(data,columns=r)
    data[u'organism_class']=data[u'organism_name'].apply(lambda x: 'Arabidopsis thaliana' if x == 'Arabidopsis thaliana' else 'Others Species')
    data_pth=pd.crosstab([data[u'organism_class'], data[u'analysis_type']], data[u'array_type'],margins=True)
    data_pth1=pd.crosstab([data[u'organism_name'], data[u'analysis_type']], data[u'array_type'],margins=True)
    element='"series":[{"name":"Species","colorByPoint": true,"data":['
    souselemen=""
    current_data1='["v43.0",0.17],["v41.0",0.17],["v47.0",0.17]'
    current_data=""#"['CATMA_2',146],['CATMA_2.1',352],['CATMA_2.2',1384],['CATMA_2.3',868], ['CATMA_5',1833],[' CATMAv6-HD12',101],['CATMAv6.2-HD12',371],[' CATMAv6.1-HD12',24],[' CATMAv7_4PLEX',453]"
    for i in range(0,len(list(data_pth.index))-1):
        key=list(data_pth.index)[i]
        element+='{"name":"'+key[0]+' '+key[1]+'", \n "y":'+str(data_pth.loc[key,'All'])+',\n "drilldown":"'+key[0].replace(' ','')+key[1].replace(' ','')+'" \n },'
        souselemen+='{"name":"'+key[0]+' '+key[1]+'","id":"'+key[0].replace(' ','')+key[1].replace(' ','')+'", \n'
        current_data=""
        for j in range(0,len(list(data_pth.columns))):
            if data_pth.loc[key,list(data_pth.columns)[j]]!=0 and list(data_pth.columns)[j]!='All' and key[0]=='Arabidopsis thaliana': 
                current_data+='["'+list(data_pth.columns)[j]+'",'+str(data_pth.loc[key,list(data_pth.columns)[j]])+'],'
            if  key[0]!='Arabidopsis thaliana' and list(data_pth.columns)[j]!='All':
                for k in range(0,len(list(data_pth1.index))):
                    key1=list(data_pth1.index)[k]
                    if key1[0]!='Arabidopsis thaliana' and key1[1]==key[1] and data_pth1.loc[key1,list(data_pth.columns)[j]]!=0:
                        current_data+='["'+key1[0]+' by '+list(data_pth.columns)[j]+'",'+str(data_pth1.loc[key1,list(data_pth.columns)[j]])+'],'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
        souselemen+='"data":['+current_data
        souselemen+=']},'
    text=element[:-1]+']}], \n "drilldown":{"series":['+souselemen[:-1]+']}'  
    return text

#"series":[{"name":"Species","colorByPoint": true,"data":[{"name":"Arabidopsis thaliana Arrays","y":276,"drilldown":"ArabidopsisthalianaArrays"},{"name":"Arabidopsis thaliana RNA-Seq","y":1,"drilldown":"ArabidopsisthalianaRNA-Seq"},{"name":"Other Arrays","y":76,"drilldown":"OtherArrays"},{"name":"Other CGH","y":1,"drilldown":"OtherCGH"},{"name":"Other RNA-Seq","y":2,"drilldown":"OtherRNA-Seq"}],"drilldown":{"series":[{"name":"Arabidopsis thaliana Arrays","id":ArabidopsisthalianaArrays"data":[["v43.0",0.17],["v41.0",0.17],["v47.0",0.17]]},{"name":"Arabidopsis thaliana RNA-Seq","id":ArabidopsisthalianaRNA-Seq"data":[["v43.0",0.17],["v41.0",0.17],["v47.0",0.17]]},{"name":"Other Arrays","id":OtherArrays"data":[["v43.0",0.17],["v41.0",0.17],["v47.0",0.17]]},{"name":"Other CGH","id":OtherCGH"data":[["v43.0",0.17],["v41.0",0.17],["v47.0",0.17]]},{"name":"Other RNA-Seq","id":OtherRNA-Seq"data":[["v43.0",0.17],["v41.0",0.17],["v47.0",0.17]]}]}
#
#text=crosstablespeciesbytechnologie()
#       
#"series":[{"name":"Species","colorByPoint": true,"data":
#	 [{
#            "name": "Arabidopsis RNASeq",
#            "y": 62.74,
#            "drilldown":"RnasArib"
#        },{
#            "name": "Other",
#            "y": 7.62,
#            "drilldown":"other"
#        }]
#	}],"drilldown": {
#"series":[{"name": "Arabidopsis RNASeq",
#            "id": "RnasArib",
#            "data":[["v43.0",0.17],
#                ["v43.0",0.17],
#                ["v29.0",0.26]]},
#        {"name": "Other",
#         "id": "other",
#         "data":[["v43.0",0.17],
#                ["v43.0",0.17],
#                ["v29.0",0.26]]}
#	]}
#    
#text,data_pth=crosstablespeciesbytechnologie()
