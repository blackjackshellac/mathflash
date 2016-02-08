var g_options = initializeOptions();
var g_name = NAME_DEF;

var LEFT_MAX = "10";
var RIGHT_MAX = "10";
var NUMBER_MAX = "50";
var TIMEOUT_MAX = "0"; // no timeout
var NAME_DEF = "default";
var OPTION_DEF = {
  left_max: LEFT_MAX,
  right_max: RIGHT_MAX,
  number_max: NUMBER_MAX,
  timeout_max: TIMEOUT_MAX
};

function initializeOptions() {
  var options = {};
  var option = OPTION_DEF;
  options[NAME_DEF] = option;
  return options;
}

function setOptionsControls(name) {
  var option = g_options[name];
  if (!option) {
    g_name = NAME_DEF;
    option = OPTION_DEF;
    set_alert("alert", "error", "options not found for name: "+name);
  } else {
    g_name = name;
  }
  $("#name").val(g_name);
  $("#left_max").val(option.left_max);
  $("#right_max").val(option.right_max);
  $("#number_max").val(option.number_max);
  $("#timeout_max").val(option.timeout_max);
}

function getOptionsControls() {
  var options = initializeOptions();
  options.left_max = $("#left_max").val();
  options.right_max = $("#right_max").val();
  options.number_max = $("#number_max").val();
  options.timeout_max = $("#timeout_max").val();
  return options;
}

function loadName() {
  var name = localStorage["name"];
  if (!name) {
    name = NAME_DEF;
    saveName(name);
  }
  g_name = name;
  return name;
}

function saveName(name) {
  localStorage["name"] = name;
  g_name = name;
}

function saveOptions(options) {
  localStorage["options"] = JSON.stringify(options);
}

function getOption(value, def) {
  var option = localStorage[value];
  return !option ? def : option;
}

function loadOptions() {
  var options = localStorage["options"];
  try {
    if (options) {
      options = JSON.parse(options);
    }
  } catch (e) {
    alert("Unable to parse options from localStorage: " + e);
    options = undefined;
  }
  if (!options) {
    options = initializeOptions();
    saveOptions(options);
    saveName(NAME_DEF);
  }

  g_options = options;

  return options;
}

function getIntegerOption(key) {
  var option = g_options[g_name];
  if (!option) {
    g_options = initializeOptions();
    g_name = NAME_DEF;
    option = g_options[g_name];
  }
  return parseInt(option[key]);
}

function goOptionsDefaults() {
  var name = NAME_DEF;
  var options = initializeOptions();
  saveName(name);
  saveOptions(options);
  setOptionsControls(name, options);
  set_alert("alert", "success", "using defaults for name="+name);
}

function goOptionsSave() {
  var name = $('#name').val();
  if (name == NAME_DEF) {
    set_alert("alert", "error", "Refusing to save over defaults, choose a different name");
    return;
  }
  saveName(name);
  var options = getOptionsControls();
  saveOptions(options);
  set_alert("alert", "success", "Saved options for name="+name);
}
