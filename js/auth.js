
/*
  auth cookies
  email: store email address
  persist: true/false
  token: ...

*/

function isAuth() {
  var token = $.cookie('token');
  var email = $.cookie('email');
  return (token != undefined && email.length != 0);
}

function setup_auth_menu() {
  var authd = isAuth();

  var ltext = authd ? "Logout" : "Login ...";
  $('#logio').text(ltext);

  return authd;
}

function setup_auth_dialog() {
    var authd = setup_auth_menu();

    var persist = $.cookie('persist');
    var email = $.cookie('email');

    var btext = authd ? "Sign out" : "Sign in";

    $('#signin').text(btext);
    $('#input_email').prop('disabled', authd);
    $('#input_password').prop('disabled', authd);

    if (!authd) {
	if (!persist) {
		email = "";
	}
	$('#input_email').val(email);
	$('#input_remember_me').attr('checked', persist);
    }
}

function logio() {
	var token = $.cookie('token');
	var email = $.cookie('email');
	if (token && email) {
		logout(email, token);
	} else {
		login();
	}
}

function logout(email, token) {
	var persist = $.cookie('persist');
	if (!persist) {
		$.removeCookie('email');
		$.removeCookie('persist');
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
			$.removeCookie('token');
			setup_auth_dialog();
		});
}

function login() {
	var params = {
		"email": $('#input_email').val(),
		"password": $('#input_password').val(),
		"persist": $('#input_remember_me').is(":checked")
	}

	$.post("/login", params)
		.done(function(data) {
			console.log(data);
			var res=JSON.parse(data);
			$.cookie('email', params.email)
			$.cookie('persist', params.persist)
			$.cookie('token', res.token)
		})
		.fail(function(data) {
			alert(data.responseText);
		})
		.always(function(data) {
			setup_auth_dialog();
		});

}
