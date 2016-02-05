NAME_DEF = "default";
LEFT_MAX = "10";
RIGHT_MAX = "10";
NUMBER_MAX = "50";
TIMEOUT_MAX = "0"; // no timeout

function getOptionsDefault() {
  var options = {
    left_max: LEFT_MAX,
    right_max: RIGHT_MAX,
    number_max: NUMBER_MAX,
    timeout_max: TIMEOUT_MAX
  }
  return options;
}

function setOptionsControls(name, option) {
  $("#name").val(name);
  $("#left_max").val(option.left_max);
  $("#right_max").val(option.right_max);
  $("#number_max").val(option.number_max);
  $("#timeout_max").val(option.timeout_max);
}

function setName(name) {
  localStorage["name"] = name;
}

function setOptions(options) {
  localStorage["options"] = JSON.stringify(options);
}

function getOption(value, def) {
  var option = localStorage[value];
  return !option ? def : option;
}

function getOptions() {
  var options = localStorage["options"];
  try {
    if (options !== undefined) {
      options = JSON.parse(options);
    }
  } catch (e) {
    alert("Unable to parse options from localStorage: " + e);
    options = undefined;
  }
  if (!options) {
    options = {};
    options[NAME_DEF] = getOptionsDefault();
    setOptions(options);
    setName(NAME_DEF);
  }

  return options;
}
