
/*   */

function remplissage_project_add(data){
		
		
		try{
			;
		//var text="<div class='tablea_prod'>";
		var text="<table class='table-sort'><thead><tr><th class='table_left'>Project name</th><th class='table_midlle'>Project Title</th><th class='table_left'>Public Date </th></tr></thead><tbody>"
				//Object.keys(data).length
		for (var i=1;i<10;i++){
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


$('#contenu_list_project .adapteur .panel_left').append('<div><div class="header_panel_left"><i class="fa fa-list-ul" style="float: left;font-size: 20px;margin-right: 4%;"></i><h4 class="h4">Filter</h4></div><button id="bt_couliss" style="position: relative;z-index: 1;"><i class="sidebar-arrow fa fa-angle-right"></i></button></div>');

$('#contenu_list_project .adapteur .panel_right').append('<button id="bt_couliss_right" style="position: relative;z-index: 1;"><i class="sidebar-arrow fa fa-angle-left"></i></button>');

$('#bt_couliss_right').hide();

//console.log('-----'+$('.panel_left').position().top+'------'+$('.panel_left').position().left)
$('#bt_couliss').css("top",($('.panel_left').position().left));
$('#bt_couliss').css("left",$('.panel_left').position().top+14);


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
var text='<div class="sidebar-list"><li class="sidebar-list-item"><a class="sidebar-link" aria-expanded="false">Organ</a> </li><ul></ul></div>';
var text=text+'<div class="sidebar-list"><li class="sidebar-list-item"><a class="sidebar-link" aria-expanded="true">Game</a> </li><ul class="sidebar-sublist"><li><div><imput class="_loop_primary_checkbox" type="checkbox"></imput>ASS</div></li>  </ul></div>';
//<div class="sidebar-list"><li class="sidebar-list-item"><a class="sidebar-link" aria-expanded="true">Organ</a> </li><ul><li>1 </li><li>2 </li><li>3 </li> </ul></div>

$('#contenu_list_project .adapteur .panel_left').append(text);
};

append_filtre_option();
//$('#conteneur').css('background','#ffffff');
$('#contenu_list_project .adapteur .panel_right').append('<div class="contenu_row"style="padding-left: 3%;"><div id="info_list_project">Showing 1 - 20 of <compt id="total_prod">--<compt> projects matching the search criteria - </div></div>');


//$('#contenu_list_project .adapteur .panel_right .contenu_row').append();

var Data_list_project=[];
try{Data_list_project=DG_execQuery('projet_all','','');//get data
}catch(error){console.log("verifier la requete projetc_add_new requete is false")};

try{remplissage_project_add(Data_list_project);}catch(error){};

var element='<li class="ligne_p"><a>1</a></li><li class="ligne_p"><a>2</a></li><li class="ligne_p"><a>3</a></li><li class="ligne_p"><a>4</a></li><li class="ligne_p"><a>5</a></li><li class="ligne_p"><a>6</a></li><li class="ligne_p"><a>7</a></li><li class="ligne_p"><a>8</a></li><li class="ligne_p"><a>9</a></li><li class="ligne_p"><a>10</a></li>'


$('#contenu_list_project .adapteur .panel_right .contenu_row').append('<div><ul><li class="ligne_p"><i class="fa fa-angle-left" aria-hidden="true"></i><i class="fa fa-angle-left" aria-hidden="true"></i></li><li class="ligne_p"><i class="fa fa-angle-left" aria-hidden="true"></i></li>'+element+'<li class="ligne_p"><i class="fa fa-angle-right" aria-hidden="true"></i></li><li class="ligne_p"><i class="fa fa-angle-right" aria-hidden="true"></i><i class="fa fa-angle-right" aria-hidden="true"></i></li></ul></div>');



