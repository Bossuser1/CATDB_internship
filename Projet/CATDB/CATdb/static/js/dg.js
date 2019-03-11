
function DG_execQuery($Tablename,$QueryType,$ListDataCond){
	console.log($Tablename+'----------'+$QueryType+'-'+$ListDataCond.length);
	var Data=[];
	if ($ListDataCond!=''){var instruction={'data_requete_element':$Tablename,'value_search':$ListDataCond}}
	else{var instruction={'data_requete_element':$Tablename}};
	
	$.ajax({
	    type:"GET",
	    data:instruction,
	    dataType: "json",
	    async: false,
	    url:"/CATdb/ajax/chekEmail",
	    success: function(data) {
		Data=data;
				
	    },
	error:function(err) { console.clear();console.log('error'+$Tablename);}
	    
	});
	return Data;
};

var func1 = function() {}
  
var object = {
  func2: function() {}
}


function LoadGrid(Dataload,id_div,zone,max_row,option){
	var col_name=Object.keys(Dataload[1]._value);
	var coldef="";
	var ligndef="";
	//Object.keys(Dataload)
	var select=Array.from(Array(max_row).keys());	
	
	// gestion de l'option option du nom
	try{
	var name_opt="col_odrer";	
	if(Object.keys(option).includes(name_opt)){console.log("tot");
	
		
	var col_name=option["col_odrer"];
	}else{ };
	
	}catch{};
		
	//if (Object.keys(Dataload).length<select.length){var select=Object.keys(Dataload)};
	
	//console.log('-----zone de taille--'+$('.'+zone).width()+'-----col length---:'+col_name.length);
	
	var add=($('.'+zone).width()/col_name.length)-0.005;
	var add_1=$('.'+zone).width()-add*(col_name.length-1)+30;
	for (var i = 0; i < col_name.length-1; i++){ var coldef=coldef+" "+add+"px";};
	var coldef=coldef+" "+add_1+"px";
	var max_height=parseInt($('.'+zone).attr("style").split(":")[1].split("p")[0]);
	for (var i in select){var ligndef=ligndef+" "+((max_height/select.length)-0.09)+"px";};
	var ligndef=ligndef+" "+((max_height/select.length)-0.09)+"px";
	$('#'+id_div).attr("style","grid-template-columns: "+coldef+";grid-template-rows:"+ligndef+";");
	//add head
	var colrefere=id_div.replace('e','_');
	for (var j in col_name){
		try{
			$('#'+id_div).append("<div class='head_cell' id='"+colrefere+"ligne"+(-1)+"colonne"+(j)+"'>"+col_name[j]+"<i class='fas fa-sort-up' style='color:#4d5bff;cursor:pointer;' onclick='actionclick(\""+id_div+'#'+zone+"\");'></i> <i class='fas fa-sort-down' style='color: #800075;cursor: pointer;'  onclick='actionclick(\""+id_div+'#'+zone+"\");'></i> </div>");//
		}catch{};
	};
	//
	for (var i in select ){
		for (var j in col_name){
		try{
			$('#'+id_div).append("<div class='insider_cell' id='"+colrefere+"ligne"+id_div+(i)+"colonne"+(j)+"'>"+Dataload[i]._value[col_name[j]]+"</div>");//
		}catch{};
		};
	}
	//foot
	
	//for (var j in col_name){
	//	try{
	//		$('#'+id_div).append("<div class='foot_cell' id='ligne"+(10000)+"colonne"+(j)+"'>"+" "+"</div>");//
	//	}catch{};
	//};
	for (var i = 0; i < col_name.length-1; i++){
		try{
			$('#'+id_div).append("<div class='foot_cell1' id='"+colrefere+"ligne"+(10001)+"colonne"+(j)+"'>"+" "+"</div>");//
		}catch{};
	}
	var j=col_name.length;
	try{
		$('#'+id_div).append("<div class='foot_cell1' id='"+colrefere+"ligne"+(10001)+"colonne"+(j)+"'> "+select.length+"/"+(Object.keys(Dataload).length)+"</div>");//
	}catch{};
	;
	
}

function LoadGridevent(id_div,zone){
	$('.'+zone).ready(function(){
	$('#'+id_div).on("mousemove",'div',function(event){
		var id=$(this).attr('id');
		var classe=$(this).attr('class');
		if (classe=='head_cell'){$('#'+id_div).css('cursor','e-resize')};
		if (classe=='insider_cell'){$('#'+id_div).css('cursor','pointer')};
		if (classe=='foot_cell1'){$('#'+id_div).css('cursor','context-menu')};
	});
	
	var currentMousePos_x1=0;
	var currentMousePos_x2=0;
	//console.log('#'+id_div+' .head_cell');
	$('#'+id_div+' .head_cell').mousedown(function(e){
		currentMousePos_x1 = e.pageX;

		
		return currentMousePos_x1;
	});
	$('#'+id_div+' .head_cell').mouseup(function(e) {
		currentMousePos_x2=e.pageX;
	    var calc=currentMousePos_x2-currentMousePos_x1;

		var text=$('#'+id_div).css("grid-template-columns");
		var idcol=$(this).attr('id');
		var position_resize=idcol.split('e')[2];
		var text1=text.split('x');
		var grid_col='';

	    
		for (var i = 0; i < text1.length-1; i++){
			if (i!=parseInt(position_resize)){ grid_col=grid_col+text1[i]+'x '}else{grid_col=grid_col+(parseInt(text1[i].split('p')[0])+calc)+'px ';}
		}

	    $('#'+id_div).css("grid-template-columns",grid_col);
		
	});
});
};


