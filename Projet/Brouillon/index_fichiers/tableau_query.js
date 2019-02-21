    function afficher_table(data,id_table,query){
    	//permet d'afficher le resultat sous forme de tableau
        afficheur='';  
        $.each(data, function(index, value) {
        if (index == 1){
        afficheur=afficheur+"<div class='theader'>"; 
        $.each(value._value,function(index,resp1) {
        afficheur=afficheur+"<div class='table_header'><div class='table_conteneur' elem_val='"+index+"'>"+index+"<div class='table_conteneur_up' id='table_up' onclick='up_click(\""+index+"\,"+id_table+"\,"+query+"\");'> <i class='fas fa-sort-up' style=''></i> </div> <div id='table_down' onclick='down_click(\""+index+","+id_table+","+query+"\");'> <i class='fas fa-sort-down'></i> </div> </div></div>";
        });
        afficheur=afficheur+"</div>";
        }
        afficheur=afficheur+"<div class='table_row'>";
        $.each(value._value,function(index,resp) {
        afficheur=afficheur+"<div class='table_small'><div class='table_cell'>"+index+"</div><div class='table_cell'>"+resp+"</div></div>";        
        });
        afficheur=afficheur+"</div>";
        });
        $('#'+id_table).append(afficheur); 
        };

	function down_click(element){
		var elem = element.split(',');
		var id_tab=elem[1];
		var element =elem[0];
		console.log('down :'+'#'+id_tab);
		$('#'+id_tab).empty();
		readorder(element,'ASC',id_tab,elem[2]);
	}
	
	function up_click(element){
		var elem = element.split(',');
		var id_tab=elem[1];
		var element =elem[0];
		$('#'+id_tab).empty();
		readorder(element,'DESC',id_tab,elem[2]);
	}
  
    
    
	
    function readorder(element,key,id_table,query){
    $.ajax({
        type:"GET",
        data:{'data_requete_element':query,'order_by':element+" "+key},
        dataType: "json",
        async: true,
        url:"/CATdb/ajax/chekEmail",
        success: function(data) {
        	//$.each(data, function(index, value){console.log(value);});
        	afficher_table(data,id_table,query);
        }
    });  
    };
    

