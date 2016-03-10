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
  var remember = $('#input_remember_me').is(":checked");
  params = {
    "email": $('#input_email').val(),
    "password": $('#input_password').val(),
  }

  $.post("/auth", params)
    .done(function(data) {
      console.log(data);
    })
    .fail(function(data) {
      alert("error"+data.responseText);
    })
    .always(function(data) {
      alert("finished");
    });
  console.log("remember=" + remember);

}
