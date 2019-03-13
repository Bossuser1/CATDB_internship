$('#conteneur').append("<div class='url_search'>.. </div>");
$('#conteneur').append("<div class='bar'>.</div>");
$('#conteneur').append('<div id="recherche_aera"></div>');





$('#recherche_aera').append('<div class="cont1"><h1 style="margin-left: 50%;">Project</h1></div><div class="cont2"><input type="textarea" id="recher_element" placeholder="Search.."><input type="image" id="image_loop" alt="bl"       src="https://img.icons8.com/metro/26/000000/search.png"></div>');

$('#conteneur').append('<nav class="_loop_page_nav" id="wrap"><ul class="tab_prim" id="dropdown-tab"><li class="_loop_nav_list_item"><a class="active disabled">summary</a></li><li class="_loop_nav_list_item"><a class="disabled">project list</a></li></ul></nav>');



$('#conteneur').append('<div id="contenu_pro" style="position: relative;top: 7em;"></div>');


var data1=[{
	    '_key': 1,
	    'project_id': '363',
	    'project_name': 'AFFY_MED',
	    'experiment1': {
	        'experiment_id': '536',
	        'experiment_name': 'AFFY_MED_2013_05',
	        'experiment_type': 'gene knock out',
	        'array_type': 'Affymetrix',
	        'organism1': {
	            'organ': 'roots',
	            'organism_name': 'Medicago truncatula',
	            'organism_id': '13'
	        }
	    },'experiment2': {
	        'experiment_id': '539',
	        'experiment_name': '_MED_2013_05',
	        'experiment_type': 'gene knock out',
	        'array_type': 'Affymetrix',
	        'organism1': {
	            'organ': 'roots',
	            'organism_name': 'Medicago truncatula',
	            'organism_id': '13'
	        }
	 }   
	}, {
	    '_key': 2,
	    'project_id': '279',
	    'project_name': 'RA10-04_Roots',
	    'experiment1': {
	        'experiment_id': '448',
	        'experiment_name': 'WS vs Clca2/35A2/352.7',
	        'experiment_type': 'gene knock out,genotype comparaison,normal vs transgenic comparaison',
	        'array_type': 'CATMA',
	        'organism1': {
	            'organ': 'roots',
	            'organism_name': 'Arabidopsis thaliana',
	            'organism_id': '1'
	        }
	    }
	}, {
	    '_key': 3,
	    'project_id': '282',
	    'project_name': 'AU10-13_CellWall',
	    'experiment1': {
	        'experiment_id': '451',
	        'experiment_name': 'cell wall mutants ',
	        'experiment_type': 'gene knock in (transgenic),normal vs transgenic comparaison',
	        'array_type': 'CATMA',
	        'organism1': {
	            'organ': 'stem',
	            'organism_name': 'Arabidopsis thaliana',
	            'organism_id': '1'
	        },'organism2': {
	            'organ': 'stem',
	            'organism_name': 'Arabidopsis thaliana',
	            'organism_id': '1'
	        }
	    }
	}, {
	    '_key': 4,
	    'project_id': '311',
	    'project_name': 'RS11-10_URT1',
	    'experiment1': {
	        'experiment_id': '482',
	        'experiment_name': 'Leaf transcriptome comparison between wt and URT1 (SALK_087647) ',
	        'experiment_type': 'gene knock out',
	        'array_type': 'NimbleGen',
	        'organism1': {
	            'organ': 'rosette',
	            'organism_name': 'Arabidopsis thaliana',
	            'organism_id': '1'
	        }
	    }
	}, {
	    '_key': 5,
	    'project_id': '447',
	    'project_name': 'NGS2017_10_cpk5_6',
	    'experiment1': {
	        'experiment_id': '631',
	        'experiment_name': 'Treatment of Col0 and cpk',
	        'experiment_type': 'genotype comparaison,treated vs untreated comparison',
	        'array_type': 'Illumina',
	        'organism1': {
	            'organ': 'seedling',
	            'organism_name': 'Arabidopsis thaliana',
	            'organism_id': '1'
	        }
	    }
	}];




/*

var text='<table> <tbody>';

for (var i=0;i<data1.length;i++){
var key=Object.keys(data1[i]);



var text=text+'<tr><td>'+data1[i][key[1]]+'</td><td>'+data1[i][key[2]]+'</td><td>'
//console.log(key.length);
// key>4 on a 2 experiment au moins
for (var j=3;j<key.length;j++){
	var text2="<div>";
	var text3=data1[i][key[2]];
	var key2=Object.keys(data1[i][key[j]]);
	for (var k=4;k<key2.length;k++){
	var key3=Object.keys(data1[i][key[j]][key2[k]])	
	var text2=text2+data1[i][key[j]][key2[k]][key3[0]]+'</div>';
	var text3=text3+"<br>";	
	};
	var text2=text3+text2;
	console.log(text2);

};

var text=text+'</td></tr>';
};
*/
/*
for (var i=0;i<data1.length;i++){
 var key=Object.keys(data1[i]);
 var text2='';
console.log(key);
for (var j=3;j<key.length;j++){
var key2=Object.keys(data1[i][key[j]]);
console.log(key2)
var text2=text2+'<div class="experiment" id="project_id_'+data1[i][key[1]]+'_experiment_id_'+data1[i][key[j]][key2[0]]+'"><div class="exp_name">'+data1[i][key[j]][key2[1]]+'</div><div class="exp">'+data1[i][key[j]][key2[2]]+'</div></div>'; 
};
var text=text+'<div class="project" id="project_id_'+data1[i][key[1]]+'">'+data1[i][key[2]]+text2+'</div>';
}
*/

//var text='<table> <tbody><tr><td> AB</td><td>CD</td></tr><tr><td> AB2</td><td>CD2</td></tr> </tbody></table>';
/*
var text=text+'</tbody></table>';	
$('#contenu_pro').append(text);


var text='<table style="width:100%">'
console.clear();
var key=Object.keys(data1[1])
var cpt=0
var cpt2=[];
for (var i in key ){var fals=key[i].split('t')[0]==='experimen';if(fals){var cpt=cpt+1; 
var key2=Object.keys(data1[1][key[i]]);
var cpt1=0;
for (var j in key2 ){var fals1=key2[j].split('m')[0]==='organis';if(fals1){cpt1=cpt1+1};};

var text=""
for (var l=1;l<cpt1;l++){
var text=text+"<div>"+data1[1][key[i]]+"</div>"	
}

}};
var text=text+'<tr>'+data1[1][key[2]]+'<td>'+data1[1][key[3]]//+'</td><td>'+''+'</td><td>'+''+'</td>'+'</tr>':
console.log(text);

*/

var text="<div>A</div><div>B</div><div>C</div>"

$('#contenu_pro').append('<div id="put_table" style="width: 1280px;height: 1200px;background-color: white;display: -webkit-box;"></div>');
$('#contenu_pro #put_table').append(text);

