
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
		var text="<table><thead><tr><th class='table_name_left'>Project name</th><th class='table_name_midlle'>Title</th><th class='table_name_left'>Date</th></tr></thead><tbody>"
				
		for (var i=1;i<Object.keys(data).length;i++){
			var key=Object.keys(data[1]._value);
			//var size='style="width: '+100/(key.length-1)+'%;float: left;"';
			//var text=text+'<div class="row_table" id="'+key[0]+data[i]._value[key[0]]+'" >'; //style="display: inline-flex;"
			var text=text+'<tr>'
			//var text=text+'<div '+size+'>'+data[i]._value['project_name']+'</div>';
			//var text=text+'<div '+size+'>'+data[i]._value['title']+'</div>';
			//var text=text+'<div '+size+'>'+data[i]._value['public_date']+'</div>';
			var text=text+'<td class="table_name_left">'+data[i]._value['project_name']+'</td>';
			var text=text+'<td class="table_name_middle">'+data[i]._value['title']+'</td>';
			var text=text+'<td class="table_name_right">'+data[i]._value['public_date']+'</td>';
			
			
			
			//for (var j=0;j<key.length;j++){
			//	project_name,title,public_date
			//var text=text+'<div '+size+'>'+data[i]._value[key[j]]+'</div>';
			//}
			var text=text+'</tr>';
			//var text=text+'</div>';
		};
		//var text=text+'</div>';
		
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

$('#contenu_pro').append('<div class="summary"></div>');

$('#contenu_pro .summary').append('<div class="_loop_card_header_main_footer"><div class="_loop_card_header"><h3>RECENTLY ADDED PROJECTS</h3></div><div class="_loop_card_main_section"></div><div class="_loop_card_footer"><a class="btn btn-default btn-lg primary-orange-btn" href="#">project list</a></div></div>');




$('#contenu_pro').append('<article class="details card1 card2" ><h2></h2><section class="minicard-area location card-area"><div class="featured-indicators"><ul class="chart-list"><li class="location-detail-item"><a href=""><span class="name"></span><nav class="tabs"><div class="tab-item"><b class="indicator-title">Organism</b></div><div class="buttons"><button class="button secondary openinnew"><span>Details</span></button></div></nav><div class="chart" id="info_project"></div></a></li><li class="location-detail-item"><a href=""><span class="name"></span><nav class="tabs"><div class="tab-item"><b class="indicator-title">Treatments Types</b></div><div class="buttons"><button class="button secondary openinnew"><span>Details</span></button></div></nav><div class="chart" id="contact_project"></div></a></li></ul></div></section></article>');



//Changer le contenu de programme

$('#dropdown-tab a:eq(0)').on('click',function(){

if ($(this).attr('class')==='active disabled'){$(this).attr('class','disabled');
$('#dropdown-tab a:eq(1)').attr('class','active disabled');
$('#contenu_pro').css('display','none');

}else{ $(this).attr('class','active disabled');
$('#dropdown-tab a:eq(1)').attr('class','disabled');
$('#contenu_pro').css('display','block');
};
});




$('#dropdown-tab a:eq(1)').on('click',function(){

if ($(this).attr('class')==='active disabled'){$(this).attr('class','disabled');
$('#dropdown-tab a:eq(0)').attr('class','active disabled');
$('#contenu_pro').css('display','block');


}else{ $(this).attr('class','active disabled');
$('#dropdown-tab a:eq(0)').attr('class','disabled');
$('#contenu_pro').css('display','none');
};
});	

// gestion de la affichage du tableau des projects publics
var Dataload=[];


try{Dataload=DG_execQuery('projet_add_new','','');//get data
}catch(error){console.log("verifier la requete projetc_add_new requete is false")};

try{
	 affichage_project_add(Dataload);


}catch(error){};



 $('#contact_project').append('<div id="iframe_trea"><iframe src = "/CATdb/graph/treatment_1.html" width = "500" height = "500" allowfullscreen scrolling="no" style="overflow:hidden;border: aliceblue;" ></iframe></div>');
