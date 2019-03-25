$('#contener').append("<div id='slider'>  <div>");
/*
 * add slide bar element
 * 
 */
$('#slider').append("<div id='Tableau_id'>Todo Tableau<div>");
$('#slider').append("<div id='Histogramme_id'>Todo Histogramme<div>");
$('#slider').append("<div id='Requete_id'>Todo Requete<div>");
$('#slider').append("<div id='welcomme_id'>Welcome<div>");
$('#slider').append("<div id='arab_projects'>Arabidopsis projects<div>");
$('#slider').append("<div id='GEM2Net_projects'>GEM2Net<div>");
$('#slider').append("<div id='Other_projects'>Other Species projects<div>");


$('#contener').append("<div id='conteneur_main'>  <div>");
$('#contener').css( "display","flex");
$('#contener').css( "justify-content","space-between");

/* ##################################### */
/* ###########Function ########## */
/* ##################################### */
function welcome_affiche() {
	/* Welcome */
	$('#conteneur_main').css("padding-left", "12px");
	$('#conteneur_main').append("<h2>Welcome</h2>");
	$('#conteneur_main').append("<div> </div>");
	/*information*/
	$('#conteneur_main').append("<div  class='class_div' style='background-color: #f2f3f0;'>From CATdb you can access all the details of transcriptome experiments from experiment design with a description of each sample (plant, growth conditions, treatments) to statistical analyses (normalized expression data and differential analyses).<div>");
	/* link*/
	$('#conteneur_main').append("<div  class='class_div' style='background-color: #f2f3f0; display: flex;'> <div id='info_explore' style='text-align: center;'> <p>More information to explore CATdb</p><img src='/static/icons/info-cirlce-solid.svg' style='width: 99px;height: 100px;' /> </div> <div id='info_CATdb_data' style='text-align: center;'> <p>More information on CATdb database</p> <img src='/static/icons/book-cover-svgrepo-com.svg' style='width: 99px;height: 100px;' /> </div></div>");
	$('#info_explore').click(function () {
		window.location = "http://tools.ips2.u-psud.fr/cgi-bin/projects/CATdb/catdb_help.pl?docInfo=CATdb_explore.txt&title=Consult";
	});
	$('#info_CATdb_data').click(function () {
		window.location = "http://tools.ips2.u-psud.fr/cgi-bin/projects/CATdb/catdb_help.pl?docInfo=CATdb_more.txt&title=Database";
	});
};

/* ####### */

function arab_affiche() {
	/* Welcome */
	$('#conteneur_main').css("padding-left", "12px");
	$('#conteneur_main').append("<h3>Explore  the 279 Arabidopsis projects in public access</h3>");
	/*information*/
	$('#conteneur_main').append("<div class='class_div' style='background-color: #f2f3f0;'>CATdb provides access to a large collection of trancriptomic data for Arabidopsis thaliana, mainly hybridized with the 2-colors CATMA (Complete Arabidopsis Transcriptome Micro-Array, Crow et al. NAR 2003). The CATMA design has been updated to include almost all the annotated genes in Arabidopsis (TAIR + EuGene predictions).<div>");

	var data=[["Tododooooo graph   =====>","Number of Arabidopsis microarrays per array type","Number of gene loci covered per array design "],["146","CATMA_2","22486"],["352","CATMA_2.1","22679"],["1384","CATMA_2.2","22702"],["868","CATMA_2.3","23001"],["1833","CATMA_5","28230"],["98","CATMAv6-HD12","35656"],["358","CATMAv6.2-HD12","35656"],["24","CATMAv6.1-HD12","35656"],["423","CATMAv7_4PLEX","35656"]];

	
	text_html="<div id='table_n'>";	/*data.length*/

	for (var i=0;i<6;i++){
		text="<div class='col_tabe'>";
		/* */
		text=text+"<div class='row_tabe'> <e class='info'>"+data[i][0]+" "+data[i][1]+"</e></div>";
		/* */
		text=text+"<div class='row_tabe'>"+data[i][2]+"</div>";
	text=text+"</div>";
	text_html=text_html+text;
	};	
	text_html=text_html+"</div>"
	$('#conteneur_main').append("<div>"+text_html+" </div>");

};



/* ######################    arab_projects                  ##################################****/


/* click de Arabopsis project */
$("#arab_projects").click(function() {
	$('#conteneur_main').html("");
	arab_affiche();
});

$("#welcomme_id").click(function() {
	$('#conteneur_main').html("");
	welcome_affiche();
});

$( "#GEM2Net_projects" ).click(function() {
	$('#conteneur_main').html("");  
	  alert( "Handler for .click() GEM2Net_projects" );
});


$( "#Other_projects" ).click(function() {
	$('#conteneur_main').html("");  
	  alert( "Handler for .click() Other_projects." );
});



$("#Tableau_id").click();

$( "#Tableau_id" ).click(function() {
	$('#conteneur_main').html("");  
	  alert( "D3js" );
});

/* function d'affichage de tableau
 * de façon générique
 *   
 *   */
function affichage_table()
{
	var data={"_id":0,"List":[{"_key":45,"_value":7},{"_key":45,"_value":7}]};

var i=Object.keys(data);
console.log("  _key:  _val:"+data._id);
var somme = 3;
var resultat = somme * 6.55957;
   return somme ;
}

/*
List[i]
for (var i = 0; i < List.length; i++) {
    $.each(List[i].List, function (index, data) {
        console.log("  _key:" + data._key.trim() + "  _val:" + data._val);
        $Response.push("  _key:" + data._key.trim() + "  _val:" + data._val);
});
*/    
    
    


/*$('#conteneur_main').append("<div> "+affichage_table()+"<div>");*/

