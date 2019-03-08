var url_media='http://tools.ips2.u-psud.fr/'



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



/*################################################*/
/*               Description       */
/*################################################*/
$('#conteneur').append("<div class='url_search'>.. </div>");
$('#conteneur').append("<div class='bar'>.</div>");

$('#conteneur').append("<section id='list_project_element'> <!--<div class='titre_pro'>Projects:<span>ADT03-02_Leaf_Flower-Bud</span><a class='info-b'></a> </div>--> <div class='contenu_pro'> </div></section>");

//$('#conteneur .contenu_pro').append('<div class="article"> <h2 class="title">Titre</h2></div><div class="article"> Col2</div> <div class="article"> Col3</div>');


$('#conteneur .contenu_pro').append('<div class="cardheader"><h1>ADT03-02_Leaf_Flower-Bud &nbsp; <a class="info-b"></a></h1><div class="jump-to"><button id="bt_show" class="buttonspecial"><span>Jump to</span> </button><ul id="goto" style="display:none;"></ul></div></div>');

$('#conteneur .contenu_pro #goto').append('<li><span>Projects &amp; Operations</span></li>');

$('#bt_show').click(function() {
  $('#goto').css("display",'block');
});


$('#goto').click(function(){
  $('#goto').css("display",'none');
});

//$('#conteneur .contenu_pro').append('<article><h2>Projects &amp; Operations</h2><section class="minicard-area"> </section> <aside class="assidebar"> Test</aside> </article>');


$('#conteneur .contenu_pro').append('<article class="details card1 projects" id="projects"><h2></h2><section class="minicard-area location"><div class="featured-indicators"><ul class="chart-list"><li class="location-detail-item"><a href=""><span class="name"></span><nav class="tabs"><div class="tab-item"><b class="indicator-title">Project Information</b></div><div class="buttons"><button class="button secondary openinnew"><span>Details</span></button></div></nav><div class="chart" id="info_project"></div></a></li><li class="location-detail-item"><a href=""><span class="name"></span><nav class="tabs"><div class="tab-item"><b class="indicator-title">Contact Information</b></div><div class="buttons"><button class="button secondary openinnew"><span>Details</span></button></div></nav><div class="chart" id="contact_project"></div></a></li></ul></div></section><aside class="sidebar">test </aside></article>');


$('#info_project').append('<list><element>Project name :</element><element>Project title:</element><element>Biological interest:<span>Identification of genes differentially expressed between flowers and leaves</span></element></list>');

$('#contact_project').append('<list><element>Contributor:1</element><element>Contributor:2</element><element>Contributor:3</element></list>');

//correction coordonne

/*Swap*/

var data_A={'Swap name':'Flower-buds / Leaves',
'Array type':'CATMA_2',
'Channel':'Cy5',
'Sample name':'Flower-buds',
'organism':'Arabidopsis thaliana (columbia)',
'organ':'flower',
'characteristics':"ecotype  columbia genotype - dev.stage (Boyes et al. Plant Cell 2001): boyes: 6.00",
'mutation':'none',
'treatment protocol':'no treatment',
'growth protocol':"flower - Arabidopsis thaliana Col-0 grown on soil at 22Â°C, 50% humidity to growth stage 6.0 (Boyes scale). Cool white light at 100 uEm-2s-1, 16 hour photoperiod. Harvested between 5-7h into the 9th day. The flower buds were harvested and immediately frozen in liquid nitrogen.",
'molecule type':"total RNA",
'extract protocol':'Flower-buds: 120 ug -',
'labelling protocol':'labelling Cy3 and Cy5 direct, amplificate=yes, aRNA 5 ug'};

var data_B={'Swap name':'Flower-buds / Leaves',
'Array type':'CATMA_2',
'Channel':'Cy5',
'Sample name':'Flower-buds',
'organism':'Arabidopsis thaliana (columbia)',
'organ':'flower',
'characteristics':"ecotype  columbia genotype - dev.stage (Boyes et al. Plant Cell 2001): boyes: 6.00",
'mutation':'none',
'treatment protocol':'no treatment',
'growth protocol':"flower - Arabidopsis thaliana Col-0 grown on soil at 22Â°C, 50% humidity to growth stage 6.0 (Boyes scale). Cool white light at 100 uEm-2s-1, 16 hour photoperiod. Harvested between 5-7h into the 9th day. The flower buds were harvested and immediately frozen in liquid nitrogen.",
'molecule type':"total RNA",
'extract protocol':'Flower-buds: 120 ug -',
'labelling protocol':'labelling Cy3 and Cy5 direct, amplificate=yes, aRNA 5 ug'};


var data_C={'Swap name':'Flower-buds / Leaves',
'Array type':'CATMA_2',
'Channel':'Cy5',
'Sample name':'Flower-buds',
'organism':'Arabidopsis thaliana (columbia)',
'organ':'flower',
'characteristics':"ecotype  columbia genotype - dev.stage (Boyes et al. Plant Cell 2001): boyes: 6.00",
'mutation':'none',
'treatment protocol':'no treatment'};

var data_D={'Swap name':'Flower-buds / Leaves',
'Array type':'CATMA_2',
'Channel':'Cy5',
'Sample name':'Flower-buds',
'organism':'Arabidopsis thaliana (columbia)',
'organ':'flower',
'characteristics':"ecotype  columbia genotype - dev.stage (Boyes et al. Plant Cell 2001): boyes: 6.00",
'mutation':'none',
'treatment protocol':'no treatment',
'growth protocol':"flower - Arabidopsis thaliana Col-0 grown on soil at 22Â°C, 50% humidity to growth stage 6.0 (Boyes scale). Cool white light at 100 uEm-2s-1, 16 hour photoperiod. Harvested between 5-7h into the 9th day. The flower buds were harvested and immediately frozen in liquid nitrogen.",
'molecule type':"total RNA",
'extract protocol':'Flower-buds: 120 ug -',
'labelling protocol':'labelling Cy3 and Cy5 direct, amplificate=yes, aRNA 5 ug'};


var titre_A={'name':'Swap Cy5','variable':'Swap1_Cy5'};
var titre_B={'name':'Swap Cy3','variable':'Swap1_Cy3'};
var titre_C={'name':'Swap Cy2','variable':'Swap1_Cy2'};
var titre_D={'name':'Swap Cy5','variable':'Swap2_Cy5'};


var text='<p id="Sawp1"><span>Swap1, .</span></p><div><ul class="meta"><li class="in come-level"><em><span>Income level</span><!-- react-text: 490 -->:&nbsp;</em><a class="toggle"><strong>Lower middle income</strong></a></li><li class="region"><em><span>Region</span><!-- react-text: 496 -->:&nbsp;<!-- /react-text --></em><a class="toggle"><strong> T</strong></a></li></ul><div class="buttonGroup"><div class="btn-item download"><h4><span>Download</span></h4><p><a href="">EXCEL</a></p></div><a class="btn-item databank" href="" target="_blank"><h4><span>..</span></h4><p><span>..</span></p></a></div></div>';

var data_K={"Extract protocol":"Extraction_ARN_Trizol.doc",
"Labelled protocol":"Labelling protocol: 5 µg of aRNA (8µl) mixed with 2 µl of random nonamers 1µg/µl and 0.5 µl of RNAse Out 40 U/µl, denatured 10 min at 70 °C and chilled on ice. The followig components were added to the sample 4 µl of first strand buffer 5 X, 1 µl of 10 mM dNTP/2mM dCTP, 2 µl of 0.1 M DTT, 1.5 µl of Cy3-dCTP or Cy5-dCTP (Amersham Pharmacia Biotech, 25nmol tube, PA5502), 1 µl of SuperScript II RT 200U/µl. Then it was incubated at 42°C for 2.5 hours and chilled on ice. The sample was denaturated by adding 2 µl of NaOH 2.5M and incubated at 37 °C for exactly 15 min, then was added 10 µl of 2M MOPS and put on ice. The dyes were purified with the QIAquick PCR Purification Kit (QIAGEN).",
"Hybridization protocol":"Hybridization Protocol: CATMA slides (Corning Microarray Technology, CORNING) are pretreated in the prehybridisation solution (1 % BSA, 0.1 SDS, 5X SSC ) at 42°C for 60 min. They are dipped a couple of times in distilled water at room temperature, then in isopropanol and dried immediately by compressed nitrogen stream. Slides were placed in Corning hybridization chambers with a 25x60 lifterslip and 10ul of distilled water for each groove. The target was diluted to a final volume of 60 µL as follows 15µl of purified, labeled cDNA, 15 µl of 4X Hybridization Buffer ( 20X SDS, 0.4 % SDS), 30 µL formamide. The target mixture is heated for 3 min at 95°C, put on ice for 30 sec and centrifuged to remove dust for 1 min. The target mixture was put on the chip as quickly as possible. The microarray is sealed in a chamber and submerged in a 42°C water bath for approximately 16 h. The microarray is washed for 4 min in 1xSSC, 0.2% SDS (42°C); 4 min in 0.1x SSC, 0.2% SDS (RT); 4 min in 0.1x SSC, 0.2% SDS (RT); 4 min in 0.1x SSC (RT); dipped a few times in distilled water and dried immediately by compressed nitrogen stream.",
"Data processing":"The statistical analysis was based on one dye-swap, i.e. two arrays containing the GSTs and 384 controls. The raw data comprised the logarithm of median feature pixel intensity at wavelength 635 nm (red) and 532 nm (green). No background was subtracted. An array-by-array normalization was performed to remove systematic biases. First, we excluded spots that were considered badly formed features by the experimenter (Flags=-100). Then we performed a global intensity-dependent normalization using the loess procedure (see Yang et al., 2002) to correct the dye bias. Finally, on each block, the log-ratio median is subtracted from each value of the log-ratio of the block to correct a print-tip effect on each metablock. To determine differentially expressed genes, we performed a paired t-test on the log-ratios. The raw P-values were adjusted by the Bonferroni method, which controls the Family Wise Error Rate (FWER) (Ge et al., 2003)."}
var data_I={"Extract protocol":"Extraction_ARN_Trizol.doc"};
var titre_K={'name':'Details on protocols used','variable':'protocol'};
var titre_I={'name':' ','variable':'protocol1'};


put_list_down(data_A,titre_A,data_B,titre_B,'Sawp1',text);
put_list_down(data_C,titre_C,data_D,titre_D,'Sawp2','<div> Sawp2</div>');
put_list_down(data_K,titre_K,data_I,titre_I,'Protocol','');

for (var i=0;i<$('.location-detail-item').length;i++){ 
var n=parseInt(i/2);
try{
var k1=2*n+1;var k2=2*n;var key1='location-detail-item:eq('+k1+')';var key2='location-detail-item:eq('+k2+')';
if ($('.'+key1).height()>$('.'+key2).height()){ $('.'+key2).css("height",$('.'+key1).height()+50+'px');
}else if($('.'+key1).height()<$('.'+key2).height()){$('.'+key1).css("height",$('.'+key2).height()+50+'px'); };
}catch(error){};
};

//Details on protocols used for this project

//for (var k in Objects.keys(Data_K)){console.log(k)};