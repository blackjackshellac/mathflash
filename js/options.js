var LEFT_MAX = "10";
var RIGHT_MAX = "10";
var COUNT = "50";
var TIMEOUT = "0"; // no timeout
var NAME_DEF = "default";
var OPTION_DEF = {
  left_max: LEFT_MAX,
  right_max: RIGHT_MAX,
  count: COUNT,
  timeout: TIMEOUT
};

var g_options = initializeOptions();
var g_name = NAME_DEF;

var g_jsonFile = null;

function makeJsonFile() {
  var data = {};
  data["name"] = g_name;
  data["options"] = loadOptions(g_name);
  data["stats"] = loadStats();
  var json = JSON.stringify(data, null, 4);

  if (g_jsonFile !== null) {
    window.URL.revokeObjectURL(g_jsonFile);
  }
  var blob = new Blob([json], {
    type: 'application/json'
  });
  g_jsonFile = window.URL.createObjectURL(blob);
  return g_jsonFile;
}

function initializeOptions() {
	return OPTION_DEF;
}

function setOptionsControls(name, options) {
	g_name = name;
	g_options = options;
	$("#name").val(name);
	$("#left_max").val(options.left_max);
	$("#right_max").val(options.right_max);
	setCount(options.count);
	setOptionsTimeout(options.timeout);
}

function getOptionsControls() {
  var options = {};
  options.left_max = $("#left_max").val();
  options.right_max = $("#right_max").val();
  options.count = $("#count").val();
  options.timeout = $("#timeout").val();
  return options;
}

function getName() {
	if (!g_name) {
		g_name = NAME_DEF;
	}
	return g_name;
}

function getParams() {
	var params = {
		"email": $.cookie('email'),
		"token": $.cookie('token')
	};
	return params;
}

function loadOptions(name) {
	var params=getParams();
	params["name"]=name
	$.get("/mathflash/options", params)
		.done(function(data) {
			console.log(data);
			res=JSON.parse(data);
			options=res["options"];
			msg=res["msg"];
			if (msg !== undefined) {
	    		set_alert("alert", "error", msg);
			}
		})
		.fail(function(data) {
			set_alert("alert", "error", "failed to load options, using defaults: "+data.responseText);
			options=OPTION_DEF;
		})
		.always(function(data) {
			setOptionsControls(name, options)
		});
}

function loadName(name) {
	if (name !== undefined) {
		loadOptions(name);
		return;
	}
	var params = getParams();
	$.get("/mathflash/global/name", params)
		.done(function(data) {
			res=JSON.parse(data);
			name=res["name"];
			console.log("name="+name);
		})
		.fail(function(data) {
			set_alert("alert", "error", "failed to load default name: "+data.responseText);
			name="default";
		})
		.always(function(data) {
			loadOptions(name);
		});
}

function saveName(name) {
	var params = getParams();
	params["name"]=name;
	$.post("/mathflash/global/name", params)
		.done(function(data) {
			res=JSON.parse(data);
			set_alert("alert", "info", "Saved default name: "+name);
		})
		.fail(function(data) {
			set_alert("alert", "error", "failed to save name: "+data.responseText);
			name="default";
		})
		.always(function(data) {
			loadOptions(name);
		});
}

function saveOptions(name, options) {
	var params=getParams();
	params["name"]=name
	params["options"]=JSON.stringify(options)
	$.post("/mathflash/options", params)
		.done(function(data) {
			res=JSON.parse(data);
			console.log("res="+res);
			saveName(name);
		})
		.fail(function(data) {
    		set_alert("alert", "error", data.responseText);
		})
		.always(function(data) {
		});
}

function getOption(value, def) {
  var option = localStorage[value];
  return !option ? def : option;
}

/*
  s
    user
      sym {
        d: [ date, date, date ]
        pc: [ pc, pc, pc ]
        ts: [ ts, ts, ts ]
      }
*/
function saveStats(stats) {
	var params = getParams();
	params["stats"]=JSON.stringify(stats);
    $.post("/mathflash/stats", params)
        .done(function(data) {
            res=JSON.parse(data);
        })
        .fail(function(data) {
            set_alert("alert", "error", data.responseText, 10000);
        })
        .always(function(data) {
        });
}

function loadStats() {
	var params = getParams();
	params.oldest=0;
	$.get("/mathflash/stats", params)
        .done(function(data) {
            res=JSON.parse(data);
        })
        .fail(function(data) {
            set_alert("alert", "error", data.responseText, 10000);
        })
        .always(function(data) {
        });
	return res
}

function getIntegerOption(key) {
  var option = g_options;
  if (!option) {
    g_options = initializeOptions();
    g_name = NAME_DEF;
  }
  return parseInt(option[key]);
}

function goOptionsDefaults() {
  var name = NAME_DEF;
  var options = initializeOptions();
  saveOptions(name, options);
  setOptionsControls(name, options);
  set_alert("alert", "success", "using defaults for name=" + name);
}

function goOptionsSave() {
  var name = $('#name').val();
  if (name == NAME_DEF) {
    set_alert("alert", "error", "Refusing to save over defaults, choose a different name");
    return;
  }
  saveName(name);
  g_options = getOptionsControls();
  saveOptions(name, g_options);
  fillNamesMenu();

  set_alert("alert", "success", "Saved options for name=" + name);
}

function fillNames(names) {
	var sul = $('ul#name_list.dropdown-menu');
	sul.empty();
	for (var i = 0; i < names.length; i++) {
		var id = 'name-list-' + i;
		var li = $('<li></li>')
			var a = $('<a></a>').attr('id', id).attr('href', '#').text(names[i]);
		li.append(a);
		sul.append(li);
	}
	$('ul#name_list.dropdown-menu li a').click(function(e) {
		var id = e.target.id;
		var name = $("#" + id).text();
		loadName(name);
		saveName(name);
		e.preventDefault();
	});
}

function fillNamesMenu() {
  getNames(fillNames);
}

function getNames(fillNamesCallback) {
	var params = getParams();
	var res=[];
	$.get("/mathflash/names", params)
		.done(function(data) {
			console.log(data);
			res=JSON.parse(data);
			fillNamesCallback(res);
		})
		.fail(function(data) {
    		set_alert("alert", "error", data.responseText);
		})
		.always(function(data) {
		});
}

