
/*   */

window.FontAwesomeConfig = {
      searchPseudoElements: true
   }


function putmore(element){
	
	//var a=this.className;
	console.log(element);
	$('#collapse_info').show();
	
};


function formatatge(data,key){
	var text1="";
	var text2="";

for (var i=0;i<Object.keys(data).length;i++){
	try{
		if (i<6){
	var text1=text1+'<li><div class="aff"><input class="_loop_primary_checkbox" type="checkbox"></input><span class="sidebar-sublist-item">'+data[i]['_value'][key]+'</span><span>('+data[i]['_value']['count']+')</span></div></li>';
	
		} else{
			var text2=text2+'<li><div class="aff"><input class="_loop_primary_checkbox" type="checkbox"></input><span class="sidebar-sublist-item">'+data[i]['_value'][key]+'</span><span>('+data[i]['_value']['count']+')</span></div></li>';
		}
		if (i==5){var text1=text1+'<li><div class="aff_more" onclick="putmore(\'aff_more\');">See More++</div></li>';}'this'
		
		}catch{};
	
};
return text1+'#'+text2;
}

function remplissage_project_add(data){
		
		
		try{
			;
		//var text="<div class='tablea_prod'>";
		var text="<table class='table-sort'><thead><tr><th class='table_left'>Project name</th><th class='table_midlle'>Project Title</th><th class='table_left'>Public Date </th></tr></thead><tbody>"
				//Object.keys(data).length
		for (var i=1;i<20;i++){
			var key=Object.keys(data[1]._value);
			//var size='style="width: '+100/(key.length-1)+'%;float: left;"';
			//var text=text+'<div class="row_table" id="'+key[0]+data[i]._value[key[0]]+'" >'; //style="display: inline-flex;"
			var text=text+'<tr>'
			var text=text+'<td class="table_left">'+__get_url({"key":"consult_project","value":data[i]._value['project_id'],"affichage":data[i]._value['project_name']})+'</td>';
			var text=text+'<td class="table_middle">'+data[i]._value['title']+'</td>';
			var text=text+'<td class="table_right">'+data[i]._value['public_date']+'</td>';
			var text=text+'</tr>';
			//var text=text+'</div>';
		};
		
		//var text=text+'</tbody> <tfoot><tr><th>Lasts Projects Publics</th></tr></tfoot></table>';
		var text=text+'</table';
		if (Object.keys(data).length===0){var text="";};
		$('#contenu_list_project .adapteur .panel_right .contenu_row').append(text);
		$('#total_prod').text(Object.keys(data).length+' projects matching the search criteria-');
		}catch{};
	}
	





$('#list_btn').click();

$('#contenu_list_project').append('<div class="adapteur"><div class="panel_left"></div><div class="panel_right"> </div></div>');


$('#contenu_list_project .adapteur .panel_left').append('<div><div class="header_panel_left"><i class="fa fa-list-ul" style="float: left;font-size: 20px;margin-right: 4%;"></i><h4 class="h4">Filter</h4></div><button id="bt_couliss" style="position: relative;z-index: 1;"><i class="sidebar-arrow fa fa-angle-left"></i></button></div>');

$('#contenu_list_project .adapteur .panel_right').append('<button id="bt_couliss_right" style="position: relative;z-index: 1;"><i class="sidebar-arrow fa fa-angle-right"></i></button>');

$('#bt_couliss_right').hide();

//console.log('-----'+$('.panel_left').position().top+'------'+$('.panel_left').position().left)
$('#bt_couliss').css("top",0);//($('.panel_left').position().left)
$('#bt_couliss').css("left",0);//$('.panel_left').position().top+14


/* effet du bouton de click pour le filtre*/
$('#bt_couliss').on("click",function(){
$('#contenu_list_project .adapteur .panel_left').hide( 1000 );
$('#bt_couliss_right').show();
});


$('#bt_couliss_right').on("click",function(){
$('#bt_couliss_right').hide();
$('#contenu_list_project .adapteur .panel_left').show( "slow" );
//$('#contenu_list_project .adapteur .panel_left').css("display","block");
//console.log("entrer");
//$('#bt_couliss_right').css("display","none");
});


function append_filtre_option(){
	
	var organism_list=DG_execQuery('Tag2','','');
	var organism_text=formatatge(organism_list,"organism_name");
	
	/*
	for (var i=0;i<Object.keys(organism_list).length;i++){
		try{
		var organism_text=organism_text+'<li><div class="aff"><input class="_loop_primary_checkbox" type="checkbox"></input><span class="sidebar-sublist-item">'+organism_list[i]['_value']['organism_name']+'</span><span>('+organism_list[i]['_value']['count']+')</span></div></li>';
		}catch{};
	};
	*/
	var organ=DG_execQuery('Tag2','','');
	var organ_text="";
	
	
	
	for (var i=0;i<Object.keys(organ).length;i++){
		try{
		var organ_text=organ_text+'<li><div class="aff"><input class="_loop_primary_checkbox" type="checkbox"></input><span class="sidebar-sublist-item">'+organ[i]['_value']['organism_name']+'</span><span>('+organ[i]['_value']['count']+')</span></div></li>';
		}catch{};
	};
	

	var analysis_type=DG_execQuery('TagRNas_vs_analys','','');
	
	var analysis_type_text="";
	var analysis_type_text1=""
	for (var i=0;i<Object.keys(analysis_type).length;i++){
		
		try{
			if (i<5){
		var analysis_type_text=analysis_type_text+'<li><div class="aff"><input class="_loop_primary_checkbox" type="checkbox"></input><span class="sidebar-sublist-item">'+analysis_type[i]['_value']['analysis_type']+'</span><span>('+analysis_type[i]['_value']['count']+')</span></div></li>';
		
			} else{
				var analysis_type_text1=analysis_type_text1+'<li><div class="aff"><input class="_loop_primary_checkbox" type="checkbox"></input><span class="sidebar-sublist-item">'+analysis_type[i]['_value']['analysis_type']+'</span><span>('+analysis_type[i]['_value']['count']+')</span></div></li>';
			}
			if (i==5){var analysis_type_text=analysis_type_text+'<li><div class="aff">See More++</div></li>';}
			
			}catch{};
		
	};
	//console.log(analysis_type);
	
var text='<div class="sidebar-list"><li class="sidebar-list-item"><a class="sidebar-link" aria-expanded="true" onclick="close_file(\'.sidebar-link:eq(0)\');">Analysis Type</a> </li><ul class="sidebar-sublist">'+analysis_type_text+'</ul></div>';	
var text=text+'<div class="sidebar-list"><li class="sidebar-list-item"><a class="sidebar-link" aria-expanded="true" onclick="close_file(\'.sidebar-link:eq(1)\');">Organ</a> </li><ul class="sidebar-sublist" >'+organ_text+'</ul></div>';
var text=text+'<div class="sidebar-list"><li class="sidebar-list-item"><a class="sidebar-link" aria-expanded="true" onclick="close_file(\'.sidebar-link:eq(2)\');">Organism</a> </li><ul class="sidebar-sublist" >'+organism_text.split('#')[0]+'</ul></div>';
//<div class="sidebar-list"><li class="sidebar-list-item"><a class="sidebar-link" aria-expanded="true">Organ</a> </li><ul><li>1 </li><li>2 </li><li>3 </li> </ul></div>

$('#contenu_list_project .adapteur .panel_left').append(text);
};

append_filtre_option();
//$('#conteneur').css('background','#ffffff');
$('#contenu_list_project .adapteur .panel_right').append('<div class="contenu_row"style="padding-left: 3%;"><div id="info_list_project">Showing 1 - 20 of <compt id="total_prod">--<compt> projects matching the search criteria - </div></div>');


//$('#contenu_list_project .adapteur .panel_right .contenu_row').append();




var Data_list_project=[];
console.clear();
console.log("text");
try{Data_list_project=DG_execQuery('projet_all','',''); console.log(Data_list_project);//get data projet_all
}catch(error){console.log("verifier la requete projetc_add_new requete is false")};

try{remplissage_project_add(Data_list_project);}catch(error){};

var element='<li class="ligne_p"><a>1</a></li><li class="ligne_p"><a>2</a></li><li class="ligne_p"><a>3</a></li><li class="ligne_p"><a>4</a></li><li class="ligne_p"><a>5</a></li><li class="ligne_p"><a>6</a></li><li class="ligne_p"><a>7</a></li><li class="ligne_p"><a>8</a></li><li class="ligne_p"><a>9</a></li><li class="ligne_p"><a>10</a></li>'


$('#contenu_list_project .adapteur .panel_right .contenu_row').append('<div><ul><li class="ligne_p"><i class="fa fa-angle-left" aria-hidden="true"></i><i class="fa fa-angle-left" aria-hidden="true"></i></li><li class="ligne_p"><i class="fa fa-angle-left" aria-hidden="true"></i></li>'+element+'<li class="ligne_p"><i class="fa fa-angle-right" aria-hidden="true"></i></li><li class="ligne_p"><i class="fa fa-angle-right" aria-hidden="true"></i><i class="fa fa-angle-right" aria-hidden="true"></i></li></ul></div>');

/* action clik sur boutton*/

for (var i=0;i<$('.sidebar-link').length;i++){$('.sidebar-link:eq('+i+')').click();};


function close_file(element){
	if ($(element).attr("aria-expanded")=='true'){
    $(element).attr("aria-expanded",'false');
    $(element).parent().parent().find('ul').hide()
	}else{
	    $(element).attr("aria-expanded",'true');
	    $(element).parent().parent().find('ul').show()
	};
};


$('body').append('<div id="collapse_info" class="modal"></div>');
var sizew=$( window ).width();

//$('#collapse_info').attr("style","height:"+$(document).height()+"px;width:"+$(document).width()+"px;top:0;left: 0;position: absolute;z-index: 1000;opacity: 0.75;background: black;display:none");

$('#collapse_info').append('<div class="modal-content">	<i class="fa fa-window-close" aria-hidden="true" id="closecol" value="close" style="background: red;z-index: 10000;position: absolute;top: 0;left: 0;"></i><iframe src="graph/treatment_1.html" style="position:fixed; top:2%; left:0; bottom:0; right:0; width:80%; height:80%; border:none; margin:0; padding:0; overflow:hidden;"></iframe></div>');
//<input type="button"
$('#closecol').on("click",function(){
	$('#collapse_info').hide();
});
