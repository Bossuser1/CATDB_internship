#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 21 19:12:44 2019

@author: traore
"""

from palette_color import getdata,getcolor


filename='output.html'


#Red

colorpalect=getcolor()

requete="SELECT array_type.array_type_name, count(distinct(array_type.platform_name)) FROM public.array_type group by array_type.array_type_name;"



print(requete)

#"SELECT array_type_name,count(hybridization_id) FROM "+schema+".hybridization group by array_type_name;"
data1=getdata(requete)

otherlist_species=[]
datacol=[]
labelcol=[]
datacol.append({'name':'Array design for species','value':None,'perc':None})
labelcol.append({'name':'Species','value':None,'perc':None})
for element in data1.keys(): 
    datacol.append({'name':data1[element]['_value']['array_type_name'],'value':10,'perc':14})
    labelcol.append({'name':data1[element]['_value']['array_type_name'],'value':None,'perc':None})

data=[labelcol,datacol,datacol]

def celluledesign(cellule,i,optcol=False):
    try:
        val=int(int(cellule['perc']-20)/10)
        colocurrent=colorpalect[i%len(colorpalect)][val]
        if optcol>0:
           colocurrent=colorpalect[optcol%len(colorpalect)][val]
        if int(cellule['perc']):
            text="<div class='wrapper'><span class='bar' style='width:"+str(cellule['perc']+10)+"%; background-color:"+colocurrent+";'></span><span class='val'>"+str(cellule['value'])+"</span></div>"
    except:
        text=""#<div class='wrapper'><span class='bar' style='width:"+str(cellule['perc']+10)+"%; background-color:"+colocurrent+";'></span><span class='val'>"+str(cellule['value'])+"</span></div>"
        pass
    return text

def show_html(data):
    "col:name,value,perc"    
    #col1=[{'name':'Array design','value':None,'perc':None},{'name':'None','value':200,'perc':20},{'name':'None','value':1000,'perc':100}]
    #col2=[{'name':'Nb of micorarrays/Arrays','value':None,'perc':None},{'name':'None','value':1000,'perc':25},{'name':'None','value':3000,'perc':75}]
    #lablelrow=[{'name':'Species','value':None,'perc':None},{'name':'Vitus_ex','value':None,'perc':None},{'name':'Vit_ex','value':None,'perc':None}]
    #data=[lablelrow,col2,col1]
    
        
    td=''
    for j in range(0,len(data)):
        td+="<th class='colheader'>"+str(data[j][0]['name'])+"</th>"
    
    tr='<thead>'+td+'</thead><tbody>'
    for i in range(1,len(data[0])):
        td=''#<td>'+lablelrow[i]+'</td>'
        for j in range(0,len(data)):#def col
            if j==0:
              td+="<th class='rowheader'>"+str(data[j][i]['name'])+"</th>"
            else:
              if j==1:  
                  td+="<td>"+celluledesign(data[j][i],j,2)+"</td>"    
              elif j==2:
                  td+="<td>"+celluledesign(data[j][i],j,5)+"</td>"    
              else:
                  td+="<td>"+celluledesign(data[j][i],j)+"</td>"    
                  
        tr+="<tr>"+td+"</tr>"
    text='<tbody>'
    tr+='</tbody>'
    
    ##head
    html='<head><link type="text/css" rel="stylesheet" href="bootstrap.css"><script src="jquery.js" type="text/javascript"></script></head>'
    
    css="""
    <style>
    table .wrapper {
        display: inline-block;
        position: relative;
        height: 100%;
        width: 100%;
        z-index: -10;
    }
    
    .bar {
        display: block;
        position: absolute;
        top: 0;
        left: 0;
        bottom: 0;
        z-index: -1;
        /*height: 29px;*/
    }
    table .val {
        display: block;
        position: absolute;
        padding: 5px;
        left: 0;
    }
    
    table tr td {
        font-size: 0.9em;
    }
    
    .table > tbody > tr > td, .table > tbody > tr > th, .table > tfoot > tr > td, .table > tfoot > tr > th, .table > thead > tr > td, .table > thead > tr > th {
        padding: 8px;
        line-height: 1.42857143;
        vertical-align: top;
        border-top: 1px solid #ddd;
    }
    
    
    table{
        font-size: 10px;
        overflow-x: scroll;
        /*max-width: 850px;*/
        display: block;
        overflow-y: hidden;
    }
    
    
    .table th, .table td {
        padding-top:0px!important;
        padding-left:0px!important;
        padding-right: 5em;
        padding-bottom: 0px !important;
        vertical-align: top;
        border-top: 1px solid #dee2e6;
    }
    </style>
    """
    
    html=html+css+'<body>'
    
    ##decription de la table
    html+='<div class="row" ><div class="col-md-12"> Test </div> </div><div class="row"><div class="col"> '
    html+='<div class="table container">'
    html+='<table>'
    html+=tr
    html+='</table>'
    
    html+='</div></div></div></body>'
    
    script_js_hmtl="""
    <script>
    
    $('.bar').css('height','20px');
    $('.bar').css('height','20px');
    $('tr td').css('height','20px');
    $('table').css('font-size','10px');
    $('table').css('max-width','400px');
    console.log($(window).width());
    console.log($(window).height());
    
    </script>
    """
    html+=script_js_hmtl
    
    
    with open(filename,'w') as filewrite:
        filewrite.write(html)
        filewrite.close()
        
show_html(data)