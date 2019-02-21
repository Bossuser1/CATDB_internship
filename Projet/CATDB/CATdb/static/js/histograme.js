
$('#contener').append("<div id='informask' class='informask1'></div>");
$('#contener').append("<div id='informa' class='affichage_informask1'> <div style='border-color: white;width: 100%;height: 10%;margin-left: auto;margin-right: auto;width: 90%;height: 8%;border-radius: 12%;border: 2px solid;margin-left: auto;margin-right: auto;box-shadow: 2px 2px grey;border-color: white;'> header</div> <div style='border-color: white;width: 90%;height: 80%;border: 2px solid;margin-left: auto;margin-right: auto;box-shadow: 2px 3px grey;border-color: white;'> conteneur</div> <div style='border-color: white;width: 90%;height: 8%;border-radius: 12%;border: 2px solid;margin-left: auto;margin-right: auto;box-shadow: 2px 2px grey;border-color: white;'> footer</div> </div>");	
 	$("#informa").children()[0].innerHTML='<div style="width: 100%;height:100%; display:flex; justify-content:space-between;"><div id="entete_informa" style="font-weight: bold;"> </div><img src="https://img.icons8.com/color/48/000000/close-window.png" style="width: 10%;height: 100%;" onclick="clean_function();"></div>';
	
$("#informa").children()[2].innerHTML=' ';



function clean_function(){
    	$('#informa').css("z-index",-1);
    	$('#informa').css("top",'10000px');
    	$('#informask').toggleClass("informask2" );
};

function declenche(elemnt,elemnt1) {
    	  $('#informask').toggleClass("informask2");
    	  $('#informa').css("z-index",2);
    	  $('#informa').css("top",'20%');
    	  var res = elemnt.split("x");
    	  var message='';
    	  $.each(res, function(index, value) {
    		message=message+'<p>'+value+'</p>'+'<a href="https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?name='+value+'"> Lien NCBI de description </a>';  
    	  });
    	  
    	  $("#informa").children()[1].innerHTML=message;
    	  $("#entete_informa").html(elemnt1);
    };

    function histograme_inital(data_test,zone_affiche,name_eleme){  
        const margin = {top: 20, right: 20, bottom: 120, left: 100},
    	width = 450 - margin.left - margin.right,
    	height =500 - margin.top - margin.bottom;
        
    	const x = d3.scaleBand()
    	.range([0, width])
    	.padding(0.1);
    	
    	const y = d3.scaleLinear()
    		.range([height, 0]);
        
        const svg = d3.select("#"+zone_affiche).append("svg")
        .attr("id", "svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");    
        
    	const div = d3.select("body").append("div")
    	.attr("class", "tooltip")         
    	.style("opacity", 0);
       
    	// pour mettre les datas dans un format commun
       data_test.forEach(function(d) {
            d.Yvar = +d.Yvar;
        });

        // Mise en relation du scale avec les données de notre fichier
        // Pour l'axe X, c'est la liste des pays
        // Pour l'axe Y, c'est le max des Yvars
        x.domain(data_test.map(function(d) { return d.Xvar; }));
        if (name_eleme=='organism name'){y.domain([0,45]);}else{y.domain([d3.min(data_test, function(d){return d.Yvar;}), d3.max(data_test, function(d) { return d.Yvar; })+10]);};
        //y.domain([0,30,200, d3.max(data_test, function(d) { return d.Yvar; })+10]);
        //0, 20, 700,d3.min(data_test, function(d){return d.Yvar;})

        console.log(data_test);
        // Ajout de l'axe X au SVG
        // Déplacement de l'axe horizontal et du futur texte (via la fonction translate) au bas du SVG
        // Selection des noeuds text, positionnement puis rotation
        svg.append("g")
            .attr("transform", "translate(0," + height + ")")
            .call(d3.axisBottom(x).tickSize(0))
            .selectAll("text")	
                .style("text-anchor", "end")
                .attr("dx", "-.8em")
                .attr("dy", ".15em")
                .attr("transform", "rotate(-65)");
        
        
        svg.append("text")
        	.attr("x", (width / 2))             
        	.attr("y", 0 - (margin.top / 2)+3)
        	.attr("text-anchor", "middle")  
        	.style("font-size", "16px") 
        	.style("text-decoration", "underline")  
        	.text(name_eleme+" vs Value Graph");
        // Ajout de l'axe Y au SVG avec 6 éléments de légende en utilisant la fonction ticks (sinon D3JS en place autant qu'il peut).
        svg.append("g")
            .call(d3.axisLeft(y).ticks(6));

        // Ajout des bars en utilisant les données de notre fichier data.tsv
        // La largeur de la barre est déterminée par la fonction x
        // La hauteur par la fonction y en tenant compte de la Yvar
        // La gestion des events de la souris pour le popup
        svg.selectAll(".bar")
            .data(data_test)
        .enter().append("rect")
            .attr("class", "bar")
            .attr("x", function(d) { return x(d.Xvar); })
            .attr("width", x.bandwidth())
            .attr("element_name", function(d) { return d.Xvar; })
            .attr("y", function(d) { return y(d.Yvar); })
            .attr("fill", function(d) { return '#000'; })
            .attr("height", function(d) { return height - y(d.Yvar); })
            .on("click",function(d) { declenche(d.Xvar,name_eleme);})
            .on("mouseover", function(d) {
                div.transition()        
                    .duration(200)      
                    .style("opacity", .9);
                div.html("count:" + d.Yvar)
                    .style("left", (d3.event.pageX + 15) + "px")     
                    .style("top", (d3.event.pageY -30) + "px");
            })
            .on("mouseout", function(d) {
                div.transition()
                    .duration(500)
                    .style("opacity", 0);
            });
        
        if (name_eleme=='organism name'){
            var marginLeft=0;
            svg.append("rect")
            .attr("x", marginLeft - 5)
            .attr("y",180)
            .attr("height", 5)
            .attr("width", 20);

            svg.append("rect")
            .attr("x", marginLeft - 10)
            .attr("y", 185)
            .attr("height", 6)
            .attr("width",20)
            .style("fill", "white");
            
            svg.append("rect")
            .attr("x", marginLeft - 5)
            .attr("y", 190)
            .attr("height", 5)
            .attr("width", 20);
            
            };
      }

 function execucte_affichage(zone_affiche,name_eleme,name_eleme_var,query){
	//execucte_affichage('svg1','organism name','organism_name','my_req_special')	
	$.ajax({
        type:"GET",
        data:{'data_requete_element': query},
      dataType: "json",
      async: true,
      url:"/CATdb/ajax/chekEmail",
      success: function(data) {
        afficher_table(data);
		var x1=name_eleme_var;//"organism_name"
		var y1="count";
		var show_data=[];
        $.each(data, function(index, value) {
        	show_data.push({"Xvar":eval('value._value.'+x1),"Yvar":eval('value._value.'+y1)});
        });
		show_data.sort(function (a, b) {
		    	   return  b.Yvar-a.Yvar;
		});
		var show_data_final=[]
		$.each(show_data, function(index, value) {
			show_data_final.push({"position": parseInt(index, 10)+1,"Xvar":value.Xvar,"Yvar":parseInt(value.Yvar,10)});
        });
		// affichage histogramme
		histograme_inital(show_data_final,zone_affiche,name_eleme);//#histograme(show_data_final,'svg1','Organism Name');
    }
    
    });
};
