//add header div
$('body').append('<div id="header"></div>');
$('body').append('<div id="menu_button"></div>');
$('body').append('<div id="conteneur"></div>');

$('body').append('<div class="footer"></div>');
$('body').append('<div class="copyright"><span>&copy; 2019 IPS2 Inc. All rights reserved.</span><a href="#">Terms of Use</a><a href="#">EULA</a><a href="#">Privacy Policy</a></div>');
//initialisation du header

$('#header').append('<i class="fas fa-bars"></i><a href="#" class="logo"> </a><a href="#" class="logo_gem2net"> </a><a href="#" class="logIPS2"></a>');

$('#conteneur').css('font-size','10px')



//$('body').append('<div id="menu_show">Text</div>');

$('body').append('<div id="menu_show" style="height:'+$(document).height()+'px;top: 70px;position: absolute;background: white;border: solid 1px teal;width: 15%;z-index: 150;left: 0;display:none">Text</div>');
