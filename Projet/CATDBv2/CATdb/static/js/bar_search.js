    $('#headmain_schear').append("<div>information </div><div style='display: flex;flex-direction: row;margin-top: 8px;'><div id='database' style='width: 100px;height: 15px;cursor:pointer; display: inline-block;padding: 5px 10px 6px;color: #fdf8f8;text-decoration: none;transition: all 40ms linear;box-shadow: 0 0 0 1px #ebebeb inset, 0 0 0 1px rgba(255, 255, 255, 0.15) inset, 0 1px 3px 1px rgba(108, 99, 99, 0.1);background-color: #337ab7;'></div><div style='background: #fff;display: flex;border-radius: 2px;border: none;box-shadow: 0 2px 2px 0 rgba(0,0,0,0.16),0 0 0 1px rgba(0,0,0,0.08);z-index: 1;width: 320px;'> <input type='text' id='recherche_text' value='Search...' onblur='if(this.value==\"\") this.value=\"Search...\";' onfocus='if(this.value==\"Search...\") this.value=\"\";' >  </div> <div id='recherche_val' style='display: inline-block;height: 15px;padding: 5px 10px 6px;color: #ffffff;text-decoration: none;transition: all 40ms linear;box-shadow: 0 0 0 1px #ebebeb inset, 0 0 0 1px rgba(255, 255, 255, 0.15) inset, 0 1px 3px 1px rgba(108, 99, 99, 0.1);background-color: #337ab7;'>Validate </div> </div>");
	$("#recherche_text").keyup(function() {
	 $('#suggestion_area').empty();
	  var res=$("#recherche_text").val();
	  var putsuggestion='<div id="suggestion_area"> '+res+' </div>';
	  console.log(putsuggestion);	
	});
    
    var list_object={'All Databases': {'_key': 1, '_value':['Organism','Experiment']},'Organism': {'_key': 1, '_value':['B','A','More']},'Experiment': {'_key':1, '_value':['C','A','More']}};	
    var message='';
    // add for All DataBases
    var i=0 
     var message=message+'<div>'+Object.keys(list_object)[i];
	for (var j in list_object[Object.keys(list_object)[i]]._value){
		var message=message+'<div>'+list_object[Object.keys(list_object)[i]]._value[j]+'</div>';	
	};
	var message=message+'</div>';
    $('#database').append(message);
    console.log(message);
