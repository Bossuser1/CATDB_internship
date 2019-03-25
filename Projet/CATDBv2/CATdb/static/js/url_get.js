
/*  function qui retourne les urls   */


function __get_url(data){
/*   */
var url={'consult_project':'http://urgv.evry.inra.fr/cgi-bin/projects/CATdb/consult_project.pl?project_id='


};

//var url='http://urgv.evry.inra.fr/cgi-bin/projects/CATdb/consult_project.pl?project_id=';
//console.log(Object.keys(url));
var resultat='<a href="'+url[data['key']]+data['value']+'">'+data['affichage']+'</a>';
var key=Object.keys(data);
if ('url' in key){resultat='<a href="">'+key+'</a>';};


return resultat;
}
