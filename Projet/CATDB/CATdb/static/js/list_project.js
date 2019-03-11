
/*################################################*/
/*               fonction needed to affichage      */
/*################################################*/


function put_answer_list(data,id_put){
/* prendre en entree un dictionnaire de données json retourne un text */
var keys=Object.keys(data);
var text='<list>';
for (var i=0;i<keys.length;i++){
	var text=text+'<element><titre>'+keys[i]+'</titre> :'+data[keys[i]]+'</element>';	
};
var text=text+'</list>';
$('#'+id_put).append(text);
};


function print_towcomparaison_array(data_A,titre_A,data_B,titre_B,contenu_commun){
	var text='<article class="details card1 projects"><h2></h2><section class="minicard-area location"><div class="featured-indicators"><ul class="chart-list"><li class="location-detail-item"><a href=""><span class="name"></span><nav class="tabs"><div class="tab-item"><b class="indicator-title">';
	var text=text+titre_A['name']+'</b></div><div class="buttons"><button class="button secondary openinnew"><span>Details</span></button></div></nav><div class="chart" id="'+titre_A['variable']+'_project"></div></a></li><li class="location-detail-item"><a href=""><span class="name"></span><nav class="tabs"><div class="tab-item"><b class="indicator-title">'+titre_B['name']+'</b></div><div class="buttons"><button class="button secondary openinnew"><span>Details</span></button></div></nav><div class="chart" id="'+titre_B['variable']+'_project"></div></a></li></ul></div></section><aside class="sidebar">'+contenu_commun+'</aside></article>'; 
	$('#conteneur .contenu_pro').append(text);
	/*comparaison de deux Cy5 vs Cy3*/
		put_answer_list(data_A,titre_A['variable']+'_project');
		put_answer_list(data_B,titre_B['variable']+'_project');
};

function put_list_down(data_1,titre_1,data_2,titre_2,_name_astride,contenu_commun){
	print_towcomparaison_array(data_1,titre_1,data_2,titre_2,contenu_commun);
	$('#goto').append('<a href="#'+_name_astride+'"><li>'+_name_astride+'</li></a>');
	};


	

	/*   */
	function affichage_project_add(data){
		
		
		try{
			;
		//var text="<div class='tablea_prod'>";
		var text="<table><thead><tr><th class='table_name_left'>Project name</th><th class='table_name_midlle'>Project Title</th><th class='table_name_left'>Public Date </th></tr></thead><tbody>"
				
		for (var i=1;i<Object.keys(data).length;i++){
			var key=Object.keys(data[1]._value);
			//var size='style="width: '+100/(key.length-1)+'%;float: left;"';
			//var text=text+'<div class="row_table" id="'+key[0]+data[i]._value[key[0]]+'" >'; //style="display: inline-flex;"
			var text=text+'<tr>'
			var text=text+'<td class="table_name_left">'+__get_url({"key":"consult_project","value":data[i]._value['project_id'],"affichage":data[i]._value['project_name']})+'</td>';
			var text=text+'<td class="table_name_middle">'+data[i]._value['title']+'</td>';
			var text=text+'<td class="table_name_right">'+data[i]._value['public_date']+'</td>';
			var text=text+'</tr>';
			//var text=text+'</div>';
		};
		
		var text=text+'</tbody> <tfoot><tr><th>Lasts Projects Publics</th></tr></tfoot></table>';
		if (Object.keys(data).length===0){var text="";};
		$('#contenu_pro ._loop_card_main_section').append(text);
		}catch{};
	}
	
	
	

/*################################################*/
/*               Description       */
/*################################################*/

$('#conteneur').append("<div class='url_search'>.. </div>");
$('#conteneur').append("<div class='bar'>.</div>");
$('#conteneur').append('<div id="recherche_aera"></div>');





$('#recherche_aera').append('<div class="cont1"><h1 style="margin-left: 50%;">Project</h1></div><div class="cont2"><input type="textarea" id="recher_element" placeholder="Search.."><input type="image" id="image_loop" alt="bl"       src="https://img.icons8.com/metro/26/000000/search.png"></div>');

$('#conteneur').append('<nav class="_loop_page_nav" id="wrap"><ul class="tab_prim" id="dropdown-tab"><li class="_loop_nav_list_item"><a class="active disabled">summary</a></li><li class="_loop_nav_list_item"><a class="disabled">project list</a></li></ul></nav>');



$('#conteneur').append('<div id="contenu_pro" style="position: relative;top: 7em;"></div>');

/*  affichage de la liste des projects  */
$('#conteneur').append('<div id="contenu_list_project" style="position: relative;top: 7em;display: none;"></div>');
/**********/

$('#contenu_pro').append('<div class="summary"></div>');

$('#contenu_pro .summary').append('<div class="_loop_card_header_main_footer"><div class="_loop_card_header"><h3>RECENTLY ADDED PROJECTS</h3></div><div class="_loop_card_main_section"></div><div class="_loop_card_footer"><a id="list_btn" class="btn btn-default btn-lg primary-orange-btn">Project list</a></div></div>');



$('#contenu_pro').append('<article class="details card1 card2" ><h2></h2><section class="minicard-area location card-area"><div class="featured-indicators"><ul class="chart-list"><li class="location-detail-item"><a href=""><span class="name"></span><nav class="tabs"><div class="tab-item"><b class="indicator-title">Organism</b></div><div class="buttons"><button class="button secondary openinnew"><span>Details</span></button></div></nav><div class="chart" id="info_project"></div></a><div id="legenda_project"></div></li><li class="location-detail-item"><a href=""><span class="name"></span><nav class="tabs"><div class="tab-item"><b class="indicator-title">Treatments Types</b></div><div class="buttons"><button class="button secondary openinnew"><span>Details</span></button></div></nav><div class="chart" id="contact_project"></div></a><div id="legend1_project"></div></li></ul></div></section></article>');



//Changer le contenu de programme

$('#dropdown-tab a:eq(0)').on('click',function(){

if ($(this).attr('class')==='active disabled'){$(this).attr('class','disabled');
$('#dropdown-tab a:eq(1)').attr('class','active disabled');
$('#contenu_pro').css('display','none');
$('#contenu_list_project').css('display','block');

$('#conteneur').css('background','#ffffff');

}else{ $(this).attr('class','active disabled');
$('#dropdown-tab a:eq(1)').attr('class','disabled');
$('#contenu_pro').css('display','block');
$('#contenu_list_project').css('display','none');
$('#conteneur').css('background','#f6f7f4');
};
});


$('#dropdown-tab a:eq(1)').on('click',function(){

if ($(this).attr('class')==='active disabled'){$(this).attr('class','disabled');
$('#dropdown-tab a:eq(0)').attr('class','active disabled');
$('#contenu_pro').css('display','block');
$('#contenu_list_project').css('display','none');
$('#conteneur').css('background','#f6f7f4');
}else{ $(this).attr('class','active disabled');
$('#dropdown-tab a:eq(0)').attr('class','disabled');
$('#contenu_pro').css('display','none');
$('#contenu_list_project').css('display','block');
$('#conteneur').css('background','#ffffff');


};
});	

/* evenement 2*/
$('#list_btn').on("click",function(){
$('#dropdown-tab a:eq(1)').click();
});

// gestion de la affichage du tableau des projects publics
var Dataload=[];


try{Dataload=DG_execQuery('projet_add_new','','');//get data
}catch(error){console.log("verifier la requete projetc_add_new requete is false")};

try{
	 affichage_project_add(Dataload);


}catch(error){};

/* designe de la page des projects */

//$('#contenu_list_project').append('<div> </div>');


// $('#contact_project').append('<div id="iframe_trea"><iframe src = "/CATdb/graph/treatment_1.html" width = "100%" height = "100%" allowfullscreen scrolling="no" style="overflow:hidden;border: aliceblue;" ></iframe></div>');


//$('#legend1_project').append('<svg width="100%" height="100%"><circle cx="7" cy="5" r="3" fill="green"/><text x="11" y="8" font-//family="sans-serif" font-size="10px" fill="black">Hello!</text></svg>');

var data=[{'experiment_type': 'environmental treatment', 'count': 162,'color':'#004D40'},
 {'experiment_type': 'pathogen', 'count': 37,'color':'#00695C'},
 {'experiment_type': 'compound based treatment', 'count': 194,'color':'#00796B'},
 {'experiment_type': 'control buffer', 'count': 20,'color':'#00897B'},
 {'experiment_type': 'growth conditions', 'count': 35,'color':'#009688'},
 {'experiment_type': 'biotic stress', 'count': 27,'color':'#00838F'},
 {'experiment_type': 'time course study', 'count': 42,'color':'#0097A7'},
 {'experiment_type': 'hormone treatment', 'count': 3,'color':'#00ACC1'},
 {'experiment_type': 'technical', 'count': 1,'color':'#00BCD4'},
 {'experiment_type': 'genetic treatment', 'count': 4,'color':'#01579B'},
 {'experiment_type': 'compound+pathogen', 'count': 2,'color':'#0277BD'},
 {'experiment_type': 'abiotic stress', 'count': 40,'color':'#0288D1'},
 {'experiment_type': 'gene induction', 'count': 2,'color':'#039BE5'},
 {'experiment_type': 'limited nitrogen supply', 'count': 2,'color':'#2962FF'},
 {'experiment_type': 'sufficient nitrogen supply', 'count': 2,'color':'#6200EA'},
 {'experiment_type': 'syringe-inoculation', 'count': 4,'color':'#651FFF'},
 {'experiment_type': 'induction', 'count': 4,'color':'#7C4DFF'},
 {'experiment_type': 'control', 'count': 5,'color':'#B388FF'},
 {'experiment_type': 'nothing', 'count': 4,'color':'#AA00FF'},
 {'experiment_type': 'nematode inoculation', 'count': 1,'color':'#D500F9'},
 {'experiment_type': 'inoculation', 'count': 6,'color':'#E040FB'},
 {'experiment_type': 'with euteiches', 'count': 1,'color':'#EA80FC'},
 {'experiment_type': 'inoculation with a. euteiches', 'count': 2,'color':'#4A148C'},
 {'experiment_type': 'other inoculation ', 'count': 2,'color':'#C51162'},
 {'experiment_type': 'storage -20°c', 'count': 3,'color':'#F50057'},
 {'experiment_type': 'storage +20°c 2 mois', 'count': 3,'color':'#FF4081'},
 {'experiment_type': 'infection', 'count': 1,'color':'#FF80AB'},
 {'experiment_type': 'no treatment', 'count': 1,'color':'#880E4F'},
 {'experiment_type': 'wounding', 'count': 7,'color':'#CE93D8'},
 {'experiment_type': 'iron deficiency', 'count': 1,'color':'#BA68C8'},
 {'experiment_type': 'iron sufficiency', 'count': 1,'color':'#FFEA00'}];

console.log(data[1]['experiment_type']);
var text='<svg width="100%" height="100%">';
for (var j=0 ;j<4;j++){
for (var i=0 ;i<10;i++){
try{
var text=text+'<circle cx="'+(5+100*(j))+'" cy="'+(7*i*2+7)+'" r="5" fill="'+data[i+j*10]["color"]+'"/><text x="'+(11+100*(j))+'" y="'+(7*i*2+7)+'" font-family="sans-serif" font-size="8px" fill="black">'+data[i+j*10]["experiment_type"]+'</text>';
}catch{};
};
};
var text=text+'</svg>';
$('#legend1_project').append(text);

function donutChart() {
    var width,
        height,
        margin = {top: 10, right: 10, bottom: 10, left: 10},
        colour = d3.scaleOrdinal(d3.schemeCategory20c), // colour scheme
        variable, // value in data that will dictate proportions on chart
        category, // compare data by
        padAngle, // effectively dictates the gap between slices
        floatFormat = d3.format('.4r'),
        cornerRadius, // sets how rounded the corners are on each slice
        percentFormat = d3.format(',.2%');

    function chart(selection){
        selection.each(function(data) {
            // generate chart

            // ===========================================================================================
            // Set up constructors for making donut. See https://github.com/d3/d3-shape/blob/master/README.md
            var radius = Math.min(width, height) / 2;

            // creates a new pie generator
            var pie = d3.pie()
                .value(function(d) { return floatFormat(d[variable]); })
                .sort(null);

            // contructs and arc generator. This will be used for the donut. The difference between outer and inner
            // radius will dictate the thickness of the donut
            var arc = d3.arc()
                .outerRadius(radius * 0.8)
                .innerRadius(radius * 0.6)
                .cornerRadius(cornerRadius)
                .padAngle(padAngle);

            // this arc is used for aligning the text labels
            var outerArc = d3.arc()
                .outerRadius(radius * 0.9)
                .innerRadius(radius * 0.9);
            // ===========================================================================================

            // ===========================================================================================
            // append the svg object to the selection
            var svg = selection.append('svg')
                .attr('width', width + margin.left + margin.right)
                .attr('height', height + margin.top + margin.bottom)
              .append('g')
                .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')');
            // ===========================================================================================

            // ===========================================================================================
            // g elements to keep elements within svg modular
            svg.append('g').attr('class', 'slices');
            svg.append('g').attr('class', 'labelName');
            svg.append('g').attr('class', 'lines');
            // ===========================================================================================

            // ===========================================================================================
            // add and colour the donut slices
            var path = svg.select('.slices')
                .datum(data).selectAll('path')
                .data(pie)
              .enter().append('path')
                .attr('fill', function(d) { return d.data['color']; }) //colour(d.data['color']);
                .attr('d', arc);
            // ===========================================================================================

            // ===========================================================================================
            // add text labels
            //var label = svg.select('.labelName').selectAll('text')
            //    .data(pie)
            //  .enter().append('text')
            //    .attr('dy', '.35em')
            //    .html(function(d) {
                    // add "key: value" for given category. Number inside tspan is bolded in stylesheet.
            //        return d.data[category] + ': <tspan>' + percentFormat(d.data[variable]) + '</tspan>';
            //    })
            //    .attr('transform', function(d) {

                    // effectively computes the centre of the slice.
                    // see https://github.com/d3/d3-shape/blob/master/README.md#arc_centroid
           //         var pos = outerArc.centroid(d);

                    // changes the point to be on left or right depending on where label is.
           //         pos[0] = radius * 0.95 * (midAngle(d) < Math.PI ? 1 : -1);
           //         return 'translate(' + pos + ')';
           //     })
           //     .style('text-anchor', function(d) {
                    // if slice centre is on the left, anchor text to start, otherwise anchor to end
           //         return (midAngle(d)) < Math.PI ? 'start' : 'end';
           //     });
            // ===========================================================================================

            // ===========================================================================================
            // add lines connecting labels to slice. A polyline creates straight lines connecting several points
            //var polyline = svg.select('.lines')
            //    .selectAll('polyline')
            //    .data(pie)
            //  .enter().append('polyline')
            //    .attr('points', function(d) {

                    // see label transform function for explanations of these three lines.
            //        var pos = outerArc.centroid(d);
            //        pos[0] = radius * 0.95 * (midAngle(d) < Math.PI ? 1 : -1);
            //        return [arc.centroid(d), outerArc.centroid(d), pos]
            //    });
            // ===========================================================================================

            // ===========================================================================================
            // add tooltip to mouse events on slices and labels
            d3.selectAll('.labelName text, .slices path').call(toolTip);
            // ===========================================================================================

            // ===========================================================================================
            // Functions

            // calculates the angle for the middle of a slice
            function midAngle(d) { return d.startAngle + (d.endAngle - d.startAngle) / 2; }

            // function that creates and adds the tool tip to a selected element
            function toolTip(selection) {

                // add tooltip (svg circle element) when mouse enters label or slice
                selection.on('mouseenter', function (data) {

                    svg.append('text')
                        .attr('class', 'toolCircle')
                        .attr('dy', -15) // hard-coded. can adjust this to adjust text vertical alignment in tooltip
                        .html(toolTipHTML(data)) // add text to the circle.
                        .style('font-size', '.9em')
                        .style('text-anchor', 'middle'); // centres text in tooltip

                    svg.append('circle')
                        .attr('class', 'toolCircle')
                        .attr('r', radius * 0.55) // radius of tooltip circle
                        .style('fill', data.data['color']) //colour(data.data['color']) colour based on category mouse is over
                        .style('fill-opacity', 0.35);

                });

                // remove the tooltip when mouse leaves the slice/label
                selection.on('mouseout', function () {
                    d3.selectAll('.toolCircle').remove();
                });
            }

            // function to create the HTML string for the tool tip. Loops through each key in data object
            // and returns the html string key: value
            function toolTipHTML(data) {

                var tip = '',
                    i   = 0;

                for (var key in data.data) {

                    // if value is a number, format it as a percentage
                    var value = (!isNaN(parseFloat(data.data[key]))) ? percentFormat(data.data[key]) : data.data[key];

                    // leave off 'dy' attr for first tspan so the 'dy' attr on text element works. The 'dy' attr on
                    // tspan effectively imitates a line break.
                    if (i === 0) tip += '<tspan x="0">' + key + ': ' + value + '</tspan>';
                    else tip += '<tspan x="0" dy="1.2em">' + key + ': ' + value + '</tspan>';
                    i++;
                }

                return tip;
            }
            // ===========================================================================================

        });
    }

    // getter and setter functions. See Mike Bostocks post "Towards Reusable Charts" for a tutorial on how this works.
    chart.width = function(value) {
        if (!arguments.length) return width;
        width = value;
        return chart;
    };

    chart.height = function(value) {
        if (!arguments.length) return height;
        height = value;
        return chart;
    };

    chart.margin = function(value) {
        if (!arguments.length) return margin;
        margin = value;
        return chart;
    };

    chart.radius = function(value) {
        if (!arguments.length) return radius;
        radius = value;
        return chart;
    };

    chart.padAngle = function(value) {
        if (!arguments.length) return padAngle;
        padAngle = value;
        return chart;
    };

    chart.cornerRadius = function(value) {
        if (!arguments.length) return cornerRadius;
        cornerRadius = value;
        return chart;
    };

    chart.colour = function(value) {
        if (!arguments.length) return colour;
        colour = value;
        return chart;
    };

    chart.variable = function(value) {
        if (!arguments.length) return variable;
        variable = value;
        return chart;
    };

    chart.category = function(value) {
        if (!arguments.length) return category;
        category = value;
        return chart;
    };

    return chart;
}

    var donut = donutChart()
        .width(360)
        .height(300)
        .cornerRadius(3) // sets how rounded the corners are on each slice
        //.padAngle(0.015) // effectively dictates the gap between slices
        .variable('count')
        .category('experiment_type');

    
        d3.select('#contact_project')
            .datum(data) // bind data to the div
            .call(donut); // draw chart in div


    var donut = donutChart()
        .width(360)
        .height(300)
        .cornerRadius(3) // sets how rounded the corners are on each slice
        //.padAngle(0.015) // effectively dictates the gap between slices
        .variable('count')
        .category('experiment_type');

    
        d3.select('#info_project')
            .datum(data) // bind data to the div
            .call(donut); // draw chart in div


var text='<svg width="100%" height="100%">';
for (var j=0 ;j<4;j++){
for (var i=0 ;i<10;i++){
try{
var text=text+'<circle cx="'+(5+100*(j))+'" cy="'+(7*i*2+7)+'" r="5" fill="'+data[i+j*10]["color"]+'"/><text x="'+(11+100*(j))+'" y="'+(7*i*2+7)+'" font-family="sans-serif" font-size="8px" fill="black">'+data[i+j*10]["experiment_type"]+'</text>';
}catch{};
};
};
var text=text+'</svg>';
$('#legenda_project').append(text);
