#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Apr  2 17:24:27 2019

@author: traore
"""
import pandas as pd
import numpy as np


def parsercountword(tex,colname_varname,colname_varweight):
    """
    tex is dataframe ,  
    take data panda dataframe
    
    example
    ---
    tex=pd.DataFrame(np.transpose([["Organ1","Organ2","Organ3"],[2,3,5]]),columns=['name','weight'])
    parsercountword(tex,'name','weight')
    [{'name':Organ1,'weight':2}, {'name':Organ2,'weight':3}, {'name':Organ3,'weight':5}]
    """
    data_retunr=[]
    for key in list(tex.index):
        data_retunr.append("{'name':'"+str(eval('tex.'+colname_varname)[key]).replace(',','').replace(' ','')+"','weight':"+str(eval('tex.'+colname_varweight)[key])+"}")   
    text=str(data_retunr).replace('"','')[1:]
    return text[:-1]
    

def countword(tex,plot_titre,serie_name,identificant_div,data_name,columname,height_name):
    """
    count word 
    function qui  returne html au format higraph
    
    data_name="data"
    identificant_div="container"
    plot_titre="Wordcloud of Lorem Ipsum"
    serie_name="Occurrences"
    """
    data=parsercountword(tex,columname,height_name)
    
    javascript="""
    <style>
      ."""+identificant_div+"""plot-element_view .plot-handle_resize {
        position: absolute;
        bottom: 0;
        width: 100%;
        height: 10px;
        background-color: #dedede;
        cursor: row-resize;
        padding: 1px 0;
        border-top: 1px solid #ededed;
        -moz-transition: background-color 0.1s;
        -webkit-transition: background-color 0.1s;
        transition: background-color 0.1s;
    }
    ."""+identificant_div+"""plot-element_view .plot-handle_resize span {
        display: block;
        height: 1px;
        width: 20px;
        margin: 1px auto;
        background-color: #999;
    }
    </style>
    
    <div class='"""+identificant_div+"""plot-element_view'>
    <div id='"""+identificant_div+"""'>
      
    </div>
    <div class="plot-handle_resize"><span></span><span></span><span></span></div> 
    </div>
    
    <script>
    var mov_pos_"""+identificant_div+"""=false;
    var x_"""+identificant_div+"""=0;
    var y_"""+identificant_div+"""=0;
    function """+identificant_div+"""_text_run(e){
      mov_pos_"""+identificant_div+"""=true; 
      x_"""+identificant_div+"""=e.pageY;
      return x_"""+identificant_div+""",mov_pos_"""+identificant_div+""";
    };
    
    function """+identificant_div+"""_reduction(a,b,c){
      var calcul=b-a;
      var outupt=c-calcul;
      var outupt1=c+calcul;
      if (outupt>=0 && outupt<$(document).height()){
        return outupt;
      }else if (outupt1>=0 && outupt1<$(document).height()) {
        return outupt1; 
      } else{
        return c;
      }
    };
    
    $('."""+identificant_div+"""plot-element_view .plot-handle_resize').on("click",function(e){
        """+identificant_div+"""_text_run(e);
    });
    
    $(document).on('mousemove',function(e){
    if (mov_pos_"""+identificant_div+"""==true){
      var realsize="""+identificant_div+"""_reduction(e.pageY,x_"""+identificant_div+""",$('#"""+identificant_div+"""').height());
      $('#"""+identificant_div+"""').height(realsize+"px");
      $(document).on('click',function(ev){if (mov_pos_"""+identificant_div+"""==true){mov_pos_"""+identificant_div+"""=false;}else{mov_pos_"""+identificant_div+"""=true;};});  
    };
    });
    </script>
    """ 
    output_htm="""
    <script type="text/javascript">
    var """+data_name+"""=[];
    """+data_name+""".push("""+data+""");
    
    Highcharts.chart('"""+identificant_div+"""', {
        series: [{
            type: 'wordcloud',
            data: """+data_name+""",
            name: '"""+serie_name+"""'
        }],
        title: {
            text: '"""+plot_titre+"""'
        }
    });

          for (var i=0;i<=$('#"""+identificant_div+""" text').length;i++){
          $("#"""+identificant_div+""" text:eq("+i+")").on("click",function(e){console.log(e.target.innerHTML)});
          };

    </script>
    """
    return javascript+output_htm

def pie3D_drill():
    identificant_div="container"
    plot_titre="Wordcloud of Lorem Ipsum"
    data=""
    drilldown=""    
    output_html="""<script type="text/javascript">
        Highcharts.chart('"""+identificant_div+"""', {
            chart: {
                type: 'pie'
            },
            title: {
                text: '"""+plot_titre+"""'
            },
            subtitle: {
                text: 'Click the slices to view versions. Source: <a href="http://statcounter.com" target="_blank">statcounter.com</a>'
            },
            plotOptions: {
                series: {
                    dataLabels: {
                        enabled: true,
                        format: '{point.name}: {point.y:.1f}%'
                    }
                }
            },
        
            tooltip: {
                headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
                pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y:.2f}%</b> of total<br/>'
            },
            """+data+"""
            """+drilldown+"""
    
        });
          
        		</script>"""
    return output_html 


def pie3D_graph():
    output_html="""
    <script type="text/javascript">
    
    Highcharts.chart('container', {
        chart: {
            type: 'pie',
            options3d: {
                enabled: true,
                alpha: 33,
                beta: 2
            }
        },
        title: {
            text: "Répartition des projects présents dans la Base d 'extraction des données CATDB, 2019-03-31"
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                depth: 35,
    	    showInlegend:true,	
                dataLabels: {
                    enabled: true,
    		formatter:function(){
    		return this.y>1 ? '<b>'+ this.point.name+':</b>'+this.y+'%':null;
    		}
                    //format: '{point.name}'
                }
    	   
            }
        },
        series: [{
            type: 'pie',
            name: 'Repartition des projects presents dans CATDB',
            data: [
                {
                    name: 'Public',
                    y: 84.7,
                    sliced: true,
                    selected: true
                },['Privé', 15.3]        ]
        }]
    });
    		</script>
    """
    return output_html


