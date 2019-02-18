from django.shortcuts import render

# Create your views here.
import json
from django.http import HttpResponse
from CATdb.connection import *


def index(request):
    answer="""
    <!DOCTYPE html>
    <meta charset="utf-8">
    <head>
    <link rel="stylesheet" type="text/css" href="http://www.knowstack.com/webtech/d3jsData/css/barchart.css">
    
    <style>
    body{
    background-color: #f1f1f1;
    }

    #contener{
    display: flex;
    flex-direction: row;
    }
    .row_element {
    box-shadow: 1px 0px 1px rgba(0, 0, 0, 0.25);
background-color: white;
padding: 12px;
        padding-top: 12px;
        padding-right: 12px;
        padding-bottom: 12px;
        padding-left: 12px;
    margin: 0px 13px 12px;
        margin-top: 0px;
        margin-right: 13px;
        margin-bottom: 12px;
        margin-left: 13px;
    width: 50%;
    text-align:center;

    }    
    #svg1{    
    
    /*height: 75px;*/
    padding: 12px;
        padding-top: 12px;
        padding-right: 12px;
        padding-bottom: 12px;
        padding-left: 12px;
    margin: 0px 13px 12px;
        margin-top: 0px;
        margin-right: 13px;
        margin-bottom: 12px;
        margin-left: 13px;

        }

        
        
    .table {
    box-shadow: 1px 0px 1px rgba(0, 0, 0, 0.25);
background-color: white;
    display: table;
    text-align: center;
    width: 100%;
    /*margin: 10% auto 0;*/
    border-collapse: separate;
    font-family: 'Roboto', sans-serif;
    font-weight: 400;
        margin-left: auto;
    margin-right: auto;
  }
  
  .table_row {
    display: table-row;
  }
  
  .theader {
    display: table-row;
  }
  
  .table_header {
    display: table-cell;
    border-bottom: #ccc 1px solid;
    border-top: #ccc 1px solid;
    background: #bdbdbd;
    color: #e5e5e5;
    padding-top: 10px;
    padding-bottom: 10px;
    font-weight: 700;
  }
  
  .table_header:first-child {
    border-left: #ccc 1px solid;
    border-top-left-radius: 5px;
  }
  
  .table_header:last-child {
    border-right: #ccc 1px solid;
    border-top-right-radius: 5px;
  }
  
  .table_small {
    display: table-cell;
  }
  
  .table_row > .table_small > .table_cell:nth-child(odd) {
    display: none;
    background: #bdbdbd;
    color: #e5e5e5;
    padding-top: 10px;
    padding-bottom: 10px;
  }
  
  .table_row > .table_small > .table_cell {
    padding-top: 3px;
    padding-bottom: 3px;
    color: #5b5b5b;
    border-bottom: #ccc 1px solid;
  }
  
  .table_row > .table_small:first-child > .table_cell {
    border-left: #ccc 1px solid;
  }
  
  .table_row > .table_small:last-child > .table_cell {
    border-right: #ccc 1px solid;
  }
  
  .table_row:last-child > .table_small:last-child > .table_cell:last-child {
    border-bottom-right-radius: 5px;
  }
  
  .table_row:last-child > .table_small:first-child > .table_cell:last-child {
    border-bottom-left-radius: 5px;
  }
  
  .table_row:nth-child(2n+3) {
    background: #e9e9e9;
  }
  
  @media screen and (max-width: 900px) {
    .table {
      width: 90%
    }
  }
  
  @media screen and (max-width: 650px) {
    .table {
      display: block;
    }
    .table_row:nth-child(2n+3) {
      background: none;
    }
    .theader {
      display: none;
    }
    .table_row > .table_small > .table_cell:nth-child(odd) {
      display: table-cell;
      width: 50%;
    }
    .table_cell {
      display: table-cell;
      width: 50%;
    }
    .table_row {
      display: table;
      width: 100%;
      border-collapse: separate;
      padding-bottom: 20px;
      margin: 5% auto 0;
      text-align: center;
    }
    .table_small {
      display: table-row;
    }
    .table_row > .table_small:first-child > .table_cell:last-child {
      border-left: none;
    }
    .table_row > .table_small > .table_cell:first-child {
      border-left: #ccc 1px solid;
    }
    .table_row > .table_small:first-child > .table_cell:first-child {
      border-top-left-radius: 5px;
      border-top: #ccc 1px solid;
    }
    .table_row > .table_small:first-child > .table_cell:last-child {
      border-top-right-radius: 5px;
      border-top: #ccc 1px solid;
    }
    .table_row > .table_small:last-child > .table_cell:first-child {
      border-right: none;
    }
    .table_row > .table_small > .table_cell:last-child {
      border-right: #ccc 1px solid;
    }
    .table_row > .table_small:last-child > .table_cell:first-child {
      border-bottom-left-radius: 5px;
    }
    .table_row > .table_small:last-child > .table_cell:last-child {
      border-bottom-right-radius: 5px;
    }
  }
    
    .navbar{
    border-color: transparent;
    background-color: #64DD17;
    color: #FFFFFF;
    padding: 12px;
    margin: 12px;
        }
    
    .nav-link {
    color: #f1fff6;
    text-transform: uppercase;
    padding-right: .5rem;
    padding-left: .5rem;
    font-family: robot;
    font-weight: bold;
    }    
        
    
        #headmain{

    border-color: transparent;
    background-color: #FFF;
    color: #FFFFFF;
    padding: 12px;
    margin: 12px;
    height: 40px;

}
        
    </style>


    </head>
    <body>
    <div id='headmain'>
    
    </div>
    <nav class="navbar">
	<a class="navbar_brand">
		<span class="fa fa-anchor" style="color: #1f8dd6;"></span>
	</a>
	<div class="element">
		<div class="row">
			<div class="col navbar-nav">
				<a class="nav-item nav-link active" href="index.php#d3js">D3JS</a>
				<a class="nav-item nav-link" href="index.php#maps">Maps</a>
				<a class="nav-item nav-link" href="index.php#playing">Playing</a>
				<a class="nav-item nav-link" href="index.php#tech">Tech</a>
				<a class="nav-item nav-link" href="index.php#contact">Contact</a>
			</div>
		</div>
	<div>
</div></div></nav>
    <div id='contener'>
    <div class='row_element'> <div class="table" id="results"> </div> </div>
    <div class='row_element'> <div id="svg1"></div> </div>
    </div>
    
    <script src="https://d3js.org/d3.v5.js"></script>    
    <script src="http://www.knowstack.com/webtech/d3jsData/js/d3.v3.min.js"></script>
    <script src="http://www.knowstack.com/webtech/d3jsData/js/d3.tip.v0.6.3.js"></script>
    <script src="https://code.jquery.com/jquery-1.10.2.js"></script>
    <script>
    
    var margin = {top: 40, right: 20, bottom: 30, left: 70},
        width = 460 - margin.left - margin.right,
        height = 500 - margin.top - margin.bottom;


    function afficher_table(data){
        afficheur='';  
        $.each(data, function(index, value) {
        if (index == 1){
        afficheur=afficheur+"<div class='theader'>"; 
        $.each(value._value,function(index,resp1) {
        afficheur=afficheur+"<div class='table_header'>"+index+"</div>";
        });
        afficheur=afficheur+"</div>";
        }
        afficheur=afficheur+"<div class='table_row'>";
        $.each(value._value,function(index,resp) {
        afficheur=afficheur+"<div class='table_small'><div class='table_cell'>"+index+"</div><div class='table_cell'>"+resp+"</div></div>";        
        });
        afficheur=afficheur+"</div>";
        });
        $('#results').append(afficheur);
          
        }


    $.ajax({
      type:"GET",
      dataType: "json",
      async: true,
      url:"/CATdb/ajax/chekEmail",
      success: function(data) {
        afficher_table(data);      


   for (var property1 in Object.keys(data)) {
      /****  read data   ***/
    /*  afficage */
    var x = d3.scale.ordinal()
        .rangeRoundBands([0, width], .1);
    
    var y = d3.scale.linear()
        .range([height, 0]);
    
    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");
    
    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")
        .ticks(10, "");
   



    }

    }       
    });
    
const data_test = [
        {"position":1, "country":"Chine", "population":1355045511},
        {"position":2, "country":"Inde", "population":1210193422},
        {"position":3, "country":"États-Unis", "population":315664478},
        {"position":4, "country":"Indonésie", "population":237641326},
        {"position":5, "country":"Brésil", "population":193946886},
        {"position":6, "country":"Pakistan", "population":182614855},	
        {"position":7, "country":"Nigeria", "population":174507539},
        {"position":8, "country":"Bangladesh", "population":152518015},	
        {"position":9, "country":"Russie", "population":143056383},
        {"position":10, "country":"Japon", "population":127650000}
    ];
    

    svg = d3.select("#svg1").append("svg");  
    var group = svg.append("g");
    group.selectAll(".node")
    .data(data_test) // 2
    .enter() // 3
        .append("rect") // 4
        .attr("x", function(d) {return d.position * 30}) // 5
        .attr("y", 0) //6
        .attr("width", 20) // 7
        .attr("height", function(d) {return d.population / 10000000}); // 8
    
    </script>"""



    return HttpResponse(answer)


def ajax_check_email_fields(request):
    requete='select * from users;'
    memory=read_data_sql(requete)
    return HttpResponse(json.dumps(memory), content_type="application/json")

