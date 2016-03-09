
function logio() {
  var ac = $.cookie('auth');
  if (ac) {
    logout($.cookie('hash'));
  } else {
    login();
  }
}

function logout(hash) {
  if (!$.cookie('persist')) {
    $.removeCookie('hash')
    $.removeCookie('user')
  }
  $.removeCookie('auth')
}

function login() {

}
