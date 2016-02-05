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
