
/*
  auth cookies
  email: store email address
  persist: true/false
  token: ...

*/

function isAuth() {
  var token = $.cookie('token');
  var email = $.cookie('email');
  return (token && email);
}

function setup_auth_dialog() {
    var btext = "Sign out";
    var disabled = true;

    if (isAuth()) {
      btext = "Sign in";
      disabled = false;
    }

    $('#signin').text(btext);
    $('#input_email').prop('disabled', disabled);
    $('#input_password').prop('disabled', disabled);
}

function logio() {
  var token = $.cookie('token');
  var email = $.cookie('email');
  if (token && email) {
    logout(email, token);
  } else {
    login();
  }
  setup_auth_dialog();
}

function logout(email, token) {
  var persist = $.cookie('persist');
  if (!persist) {
    $.removeCookie('token')
  }
  var params = {
    "email": email,
    "token": token
  }
  $.post("/logout", params)
    .done(function(data) {
      console.log(data);
    })
    .fail(function(data) {
      alert("error" + data.responseText);
    })
    .always(function(data) {

    });
}

function login() {
  var remember = $('#input_remember_me').is(":checked");
  var params = {
    "email": $('#input_email').val(),
    "password": $('#input_password').val()
  }

  $.post("/login", params)
    .done(function(data) {
      console.log(data);
      var res=JSON.parse(data);
      $.cookie('email', params.email)
      $.cookie('token', res.token)
    })
    .fail(function(data) {
      alert(data.responseText);
    })
    .always(function(data) {

    });
  console.log("remember=" + remember);

}
