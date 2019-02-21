


   //if(this.value=='\''\')this.value='Search...''
	
    //$('#database').append('<h5>All Databases</h5><ul><li>one</li><li>two</li><li>three</li><li>four</li></ul>');
    


	//$('#recherche_val').on( "click", function() {
	//	var messag=$('#recherche_text').val();
	//	var colname='chips.project';
	//	$.ajax({
    //        type:"GET",
    //        data:{'data_requete_element':'my_req_recherche_av','value_search':messag,'colname_search':colname},
    //        dataType: "json",
    //        async: true,
    //        url:"/CATdb/ajax/chekEmail",
    //        success: function(data) {
    //        	$.each(data, function(index, value){console.log(value);});
    //  		
    //        }
    //        });
		
		
		
	//	console.log(messag);
	//});
	
	
    
    function affichage1(){  
    function afficher_table(data){
    	//permet d'afficher le resultat sous forme de tableau
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
    
    
    

	var data_send ='my_req_special';
    

    
    
    
    }
	
    //affichage1();
    
    
    function affichage2(){  
    	var data_send ='my_querySpecies';//#my_querySpecies####my_req_recherche
        $.ajax({
            type:"GET",
            data:{'data_requete_element': data_send},
            dataType: "json",
            async: true,
            url:"/CATdb/ajax/chekEmail",
            success: function(data) {
            	$.each(data, function(index, value){console.log(value);});
      		
            }
            });
      	
    $('.row_element').toggleClass("row_element1");
    	
    };
    affichage1();

