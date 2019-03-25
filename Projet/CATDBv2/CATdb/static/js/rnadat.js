
$('#conteneur').append('<div id="table" style="padding: calc(10%);"> </div>');

$('#conteneur').append('<div id="form"> </div>');

let head=["rnaseqdata_id","rnaseqdata_name","project_file","mapping_type","stranded","seq_type","multihits","log_file","resume_file","project_id","experiment_id","user_id","submission_date","bankref_desc"];
var data=DG_execQuery('get_rnaseq_data','','');
var identifiant=["project_id","experiment_id","rnaseqdata_id"];
var order_affich=["rnaseqdata_id","rnaseqdata_name","project_file","mapping_type","stranded","seq_type","multihits","log_file","resume_file","project_id","experiment_id","user_id","submission_date","bankref_desc"]

var answer="<table><thead>";
var file_image_key=['project_file','log_file','resume_file','user_id'];

function defcurrent_id(data,i,identifiant){
  var ident="";
  for (let key in identifiant){
    var ident=ident+'|'+identifiant[key]+'#'+data[i]['_value'][identifiant[key]]+'|'
  }  
  return ident;
}

var answer=answer+'</td>'
let key=order_affich;//Object.keys(data[i]["_value"])
for (let j in order_affich){ if (file_image_key.includes(key[j]) || identifiant.includes(key[j])  ){}else{var answer=answer+"<td>"+key[j]+"</td>"}}
var answer=answer+'<td></thead><tbody>'

for (let cpt in Object.keys(data)){
 var i=Object.keys(data)[cpt]
 var answer=answer+'<tr id="'+defcurrent_id(data,i,identifiant)+'">' 
 let key=order_affich;//Object.keys(data[i]["_value"])
 for (let j in order_affich){ if (file_image_key.includes(key[j]) || identifiant.includes(key[j])  ){}else{var answer=answer+"<td>"+data[i]["_value"][key[j]]+"</td>"}}
 var answer=answer+'</tr>' 
}
var answer=answer+"</tbody></table>";

$('#table').append(answer);

var data1=DG_execQuery('get_rnaseq_library','','');
