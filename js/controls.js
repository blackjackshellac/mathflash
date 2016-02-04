function init_controls() {
  $(".nav li").click(function() {
    $(".nav").find(".active").removeClass("active");
    $(this).addClass("active");
  });

  $("#options").click(function(e) {
    var div = title_from(e);
    var content = "content/" + div + ".html";
    $("#content").load(content, function(responseTxt, statusTxt, xhr) {
      if (statusTxt == "success")
        set_alert("alert", statusTxt, content + " loaded successfully!");
      if (statusTxt == "error")
        set_alert("alert", statusTxt, "Error: " + xhr.status + ": " + xhr.statusText);
    });
    var options = getOptions();
  });

  $("#addition").click(function(e) {
    var div = title_from(e);
    var content = "content/maths.html";
    $("#content").load(content, function(responseTxt, statusTxt, xhr) {
      if (statusTxt == "success")
        set_alert("alert", statusTxt, content + " loaded successfully!");
      if (statusTxt == "error")
        set_alert("alert", statusTxt, "Error: " + xhr.status + ": " + xhr.statusText);
    });
    localStorage.setItem("operation", div);
  });

  $("#subtraction").click(function(e) {
    var div = title_from(e);
    var content = "content/maths.html";
    $("#content").load(content, function(responseTxt, statusTxt, xhr) {
      if (statusTxt == "success")
        set_alert("alert", statusTxt, content + " loaded successfully!");
      if (statusTxt == "error")
        set_alert("alert", statusTxt, "Error: " + xhr.status + ": " + xhr.statusText);
    });
    localStorage.setItem("operation", div);
  });

  $("#multiplication").click(function(e) {
    var div = title_from(e);
    var content = "content/maths.html";
    $("#content").load(content, function(responseTxt, statusTxt, xhr) {
      if (statusTxt == "success")
        set_alert("alert", statusTxt, content + " loaded successfully!");
      if (statusTxt == "error")
        set_alert("alert", statusTxt, "Error: " + xhr.status + ": " + xhr.statusText);
    });
    localStorage.setItem("operation", div);
  });

  $("#division").click(function(e) {
    var div = title_from(e);
    var content = "content/maths.html";
    $("#content").load(content, function(responseTxt, statusTxt, xhr) {
      if (statusTxt == "success")
        set_alert("alert", statusTxt, content + " loaded successfully!");
      if (statusTxt == "error")
        set_alert("alert", statusTxt, "Error: " + xhr.status + ": " + xhr.statusText);
    });
    localStorage.setItem("operation", div);
  });
};

function getOptionsDefault() {
  var options = {};
  options.default = {
    left_max: "12",
    right_max: "12",
    number_max: "50",
    timeout_max: "0"
  }
  return options;
}

function setOptions(options) {
  localStorage["options"]=JSON.stringify(options);
}

function getOptions() {
  var options = localStorage["options"];
  try {
    options = options === undefined ? getOptionsDefault() : JSON.parse(options);
  } catch (e) {
    alert("Unable to parse options from localStorage: "+e);
    options = getOptionsDefault();
  }
  return options;
}

function set_alert(id, type, txt) {
  if (type == "error") {
    type = "danger";
  }
  $("#" + id).attr('class', "alert alert-" + type);
  $("#" + id).text(txt);
};

function capitalize(txt) {
  var ctext = txt.charAt(0).toUpperCase() + txt.substring(1).toLowerCase();
  return ctext;
};

function title_from(e) {
  var div = e.target.id;
  var title = "" + div;
  title = capitalize(title);
  $('#h1_action').text(title);
  return div;
};
