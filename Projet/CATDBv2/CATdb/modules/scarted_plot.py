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




def analyis_arra_type():
    palet=getcolor()
    requete="select CONCAT(ds.analysis_type,' ',ds.array_type) as col,ds.Year,ds.nb from(select df.analysis_type,df.array_type,df.Year,Count(*) as nb from (SELECT experiment.analysis_type, experiment.array_type, to_char(project.public_date,'YYYY') as Year FROM chips.experiment,chips.project WHERE project.project_id = experiment.project_id  ) as df group by df.Year,df.analysis_type,df.array_type order by df.array_type) as ds where year<>' ' order by year;"
    data_requete_label,data=getdata(requete)
    data=pd.DataFrame(data)
    data=data[data[1]!=None]
    res=data.pivot(index=1,columns=0,values=2).fillna(0)
    labelbael=list(sorted(res.keys()))
    name_label=list(map(lambda x: x.replace(' ','_').replace('-','_'), labelbael))#list(set(data_a))#
    #color=map(lambda x: '"'+x+'"', labelbael)
    #label1=""
    value_tampon=0.000005
    data_time=""
    for x in list(res.index.values):
        if str(x)!='nan':
            text="{year:'"+str(x)+"',"
            #print(labelbael)
            labelbael=''
            i=-1
            label1=''
            color=''
            for y in list(sorted(res.keys().values)):
                i+=1
                try:
                   if int(res[y][x])==0:
                       val=value_tampon
                   else:
                       val=int(res[y][x])
                   text+=y.replace(' ','_').replace('-','_')+":'"+str(val)+"',"
                except:
                    pass
                try:
                    labelbael+="case "+str(i)+": return '"+name_label[i]+"';"#"""case """+str(i)+""": return '"""+name_label[i]+"""' ;"""
                except:
                    pass
                try:
                    label1+='"'+name_label[i]+'"'+','
                    #print(name_label[i])
                except:
                    pass
                try:     
                    color+='"'+palet[i][random.randint(1,9)]+'"'+','
                except:
                    pass
            #print(labelbael)
            data_time+=text[:-1]+','+'None:"0"'+'},'
        
    data_time=data_time#[:-1]
    color+='"'+palet[i][random.randint(1,9)]+'"'+','
    #label1+=label1    
    return labelbael,color,data_time,value_tampon,label1#list(res.index.values)

labelbael,color,data_time,value_tampon,label=analyis_arra_type()

html_print="""
{% load staticfiles %}
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>d3.js learning</title>
  <script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
  <!--<script src="{% static "bibliotheque/d3/d3.js" %}"></script>-->
  <style type="text/css">
  svg {
    font: 10px sans-serif;
    shape-rendering: crispEdges;
  }

  .axis path,
  .axis line {
    fill: none;
    stroke: #000;
  }
 
  path.domain {
    stroke: none;
  }
 
  .y .tick line {
    stroke: #ddd;
  }
div.tooltip {	
    position: absolute;			
    text-align: center;			
    width: 60px;					
    height: 28px;					
    padding: 2px;				
    font: 12px sans-serif;		
    background: lightsteelblue;	
    border: 0px;		
    border-radius: 8px;			
    pointer-events: none;			
}      
      
      
  </style>

</head>
<body>

<div id="graph_h">

</div>
<script type="text/javascript">

function tooltip_parser(obj){
   var key=Object.keys(obj);
   var text="";
   for (var i=0;i<key.length-1;i++){
       if(obj[key[i]]==String({{value_tampon}})){var valuecurrent="0"}else{var valuecurrent=obj[key[i]]};
       var text=text+" "+key[i]+":"+valuecurrent+" ";    
   }
    return text;     
}
   


// Setup svg using Bostock's margin convention

var margin = {top: 20, right: 160, bottom: 35, left: 30};

var width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var svg = d3.select("#graph_h")
  .append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


/* Data in strings like it would be if imported from a csv */

var data = [{{data_time|safe}}];

var parse = d3.time.format("%Y").parse;

// Transpose the data into layers
var dat=[{{label1|safe}}];
var dataset = d3.layout.stack()([{{label1|safe}}'None'].map(function(type_data) {
  return data.map(function(d) {
    return {x: parse(d.year), y: +d[type_data],label:d};
  });
}));
//console.log(dataset)

// Set x, y and colors
var x = d3.scale.ordinal()
  .domain(dataset[0].map(function(d) { return d.x; }))
  .rangeRoundBands([10, width-10], 0.02);

var y = d3.scale.linear()
  .domain([0, d3.max(dataset, function(d) {  return d3.max(d, function(d) { return d.y0 + d.y; });  })])
  .range([height, 0]);
var colors = [{{color|safe}}];
console.log(colors);
// Define and draw axes
var yAxis = d3.svg.axis()
  .scale(y)
  .orient("left")
  .ticks(5)
  .tickSize(-width, 0, 0)
  .tickFormat( function(d) { return d } );

var xAxis = d3.svg.axis()
  .scale(x)
  .orient("bottom")
  .tickFormat(d3.time.format("%Y"));

svg.append("g")
  .attr("class", "y axis")
  .call(yAxis);

svg.append("g")
  .attr("class", "x axis")
  .attr("transform", "translate(0," + height + ")")
  .call(xAxis);


// Create groups for each series, rects for each segment 
var groups = svg.selectAll("g.cost")
  .data(dataset)
  .enter().append("g")
  .attr("class", "cost")
  
  .style("fill", function(d,i) { return colors[i]; });

var rect = groups.selectAll("rect")
  .data(function(d) { return d; })
  .enter()
  .append("rect")
  .attr("x", function(d) { return x(d.x); })
  .attr("y", function(d) { return y(d.y0 + d.y); })
  .attr("height", function(d) { return y(d.y0) - y(d.y0 + d.y); })
  .attr("width", x.rangeBand())
  .on("mouseover", function() { tooltip.style("display", null); })
  .on("mouseout", function() { setTimeout(function() {tooltip.style("display", "none");},18000); })
  .on("mousemove", function(d) {
    var xPosition = d3.mouse(this)[0] - 15;
    var yPosition = d3.mouse(this)[1] - 25;
    tooltip.attr("transform", "translate(" + xPosition + "," + yPosition + ")");
    tooltip.select("text").html(tooltip_parser(d.label));//d.y+
  });


// Draw legend
var legend = svg.selectAll(".legend")
  .data(colors)
  .enter().append("g")
  .attr("class", "legend")
  .attr("transform", function(d, i) { return "translate(30," + i * 19 + ")"; });
 
legend.append("rect")
  .attr("x", width - 18)
  .attr("width", 18)
  .attr("height", 18)
  .style("fill", function(d, i) {console.log(d),console.log(i); return colors[i];});
  //.slice().reverse()
 
legend.append("text")
  .attr("x", width + 5)
  .attr("y", 9)
  .attr("dy", ".35em")
  .style("text-anchor", "start")
  .text(function(d, i) { 
    switch (i) {
{{labelbael|safe}}    }
  });


// Prep the tooltip bits, initial display is hidden
var tooltip = svg.append("g")
  .attr("class", "tooltip1")
  .style("display", "none");
    
tooltip.append("rect")
  .attr("width", 200)
  .attr("height", 50)
  .attr("border", 'blue')
  .attr("fill", "white")
  .style("opacity", 1);

tooltip.append("text")
  .attr("x",50)
  .attr("dy", "2.2em")
  .style("text-anchor","middle")
  .attr("font-size", "12px")
  .attr("font-weight", "bold");

</script>
</body>
</html>
"""




try:
    
    html_print1="""
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <title>d3.js learning</title>
      <script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
      <style type="text/css">
      svg {
        font: 10px sans-serif;
        shape-rendering: crispEdges;
      }
    
      .axis path,
      .axis line {
        fill: none;
        stroke: #000;
      }
     
      path.domain {
        stroke: none;
      }
     
      .y .tick line {
        stroke: #ddd;
      }
    div.tooltip {	
        position: absolute;			
        text-align: center;			
        width: 60px;					
        height: 28px;					
        padding: 2px;				
        font: 12px sans-serif;		
        background: lightsteelblue;	
        border: 0px;		
        border-radius: 8px;			
        pointer-events: none;			
    }      
          
          
      </style>
    
    </head>
    <body>
    
    <div id="graph_h">
    
    </div>
    <script type="text/javascript">
    
    function tooltip_parser(obj){
       var key=Object.keys(obj);
       var text="";
       for (var i=0;i<key.length-1;i++){
           if(obj[key[i]]=="""+str(value_tampon)+"""){var valuecurrent="0"}else{var valuecurrent=obj[key[i]]};
           var text=text+" "+key[i]+":"+valuecurrent+" ";    
       }
        return text;     
    }
       
    
    
    // Setup svg using Bostock's margin convention
    
    var margin = {top: 20, right: 160, bottom: 35, left: 30};
    
    var width = 960 - margin.left - margin.right,
        height = 500 - margin.top - margin.bottom;
    
    var svg = d3.select("#graph_h")
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
    
    
    /* Data in strings like it would be if imported from a csv */
    
    var data = ["""+data_time+"""];
    
    var parse = d3.time.format("%Y").parse;
    
    // Transpose the data into layers
    var dataset = d3.layout.stack()(["""+label+"'None',"+"""].map(function(type_data) {
      return data.map(function(d) {
        return {x: parse(d.year), y: +d[type_data],label:d};
      });
    }));
    //console.log(dataset)
    
    // Set x, y and colors
    var x = d3.scale.ordinal()
      .domain(dataset[0].map(function(d) { return d.x; }))
      .rangeRoundBands([10, width-10], 0.02);
    
    var y = d3.scale.linear()
      .domain([0, d3.max(dataset, function(d) {  return d3.max(d, function(d) { return d.y0 + d.y; });  })])
      .range([height, 0]);
    var colors = ["""+color+"""];
    console.log(colors);
    // Define and draw axes
    var yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")
      .ticks(5)
      .tickSize(-width, 0, 0)
      .tickFormat( function(d) { return d } );
    
    var xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")
      .tickFormat(d3.time.format("%Y"));
    
    svg.append("g")
      .attr("class", "y axis")
      .call(yAxis);
    
    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);
    
    
    // Create groups for each series, rects for each segment 
    var groups = svg.selectAll("g.cost")
      .data(dataset)
      .enter().append("g")
      .attr("class", "cost")
      
      .style("fill", function(d,i) { return colors[i]; });
    
    var rect = groups.selectAll("rect")
      .data(function(d) { return d; })
      .enter()
      .append("rect")
      .attr("x", function(d) { return x(d.x); })
      .attr("y", function(d) { return y(d.y0 + d.y); })
      .attr("height", function(d) { return y(d.y0) - y(d.y0 + d.y); })
      .attr("width", x.rangeBand())
      .on("mouseover", function() { tooltip.style("display", null); })
      .on("mouseout", function() { setTimeout(function() {tooltip.style("display", "none");},18000); })
      .on("mousemove", function(d) {
        var xPosition = d3.mouse(this)[0] - 15;
        var yPosition = d3.mouse(this)[1] - 25;
        tooltip.attr("transform", "translate(" + xPosition + "," + yPosition + ")");
        tooltip.select("text").html(tooltip_parser(d.label));//d.y+
      });
    
    
    // Draw legend
    var legend = svg.selectAll(".legend")
      .data(colors)
      .enter().append("g")
      .attr("class", "legend")
      .attr("transform", function(d, i) { return "translate(30," + i * 19 + ")"; });
     
    legend.append("rect")
      .attr("x", width - 18)
      .attr("width", 18)
      .attr("height", 18)
      .style("fill", function(d, i) {console.log(d),console.log(i); return colors[i];});
      //.slice().reverse()
     
    legend.append("text")
      .attr("x", width + 5)
      .attr("y", 9)
      .attr("dy", ".35em")
      .style("text-anchor", "start")
      .text(function(d, i) { 
        switch (i) {
    """+labelbael+"""    }
      });
    
    
    // Prep the tooltip bits, initial display is hidden
    var tooltip = svg.append("g")
      .attr("class", "tooltip1")
      .style("display", "none");
        
    tooltip.append("rect")
      .attr("width", 200)
      .attr("height", 50)
      .attr("border", 'blue')
      .attr("fill", "white")
      .style("opacity", 1);
    
    tooltip.append("text")
      .attr("x",50)
      .attr("dy", "2.2em")
      .style("text-anchor","middle")
      .attr("font-size", "12px")
      .attr("font-weight", "bold");
    
    </script>
    </body>
    </html>
    """
except:
    pass  


with open("/home/traore/Bureau/Dossier_Stage/CATDB_internship/Projet/CATDBv2/CATdb/templates/CATdb/graph/graph.html",'w') as fi:
    fi.write(html_print)
    fi.close()
  