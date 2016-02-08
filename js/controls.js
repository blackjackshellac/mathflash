function init_controls() {
  $(".nav li").click(function() {
    $(".nav").find(".active").removeClass("active");
    $(this).addClass("active");
  });

  $("#options").click(function(e) {
    var div = title_from(e);
    var content = "content/" + div + ".html";
    $("#content").load(content, function(responseTxt, statusTxt, xhr) {
      if (statusTxt == "success") {
        set_alert("alert", statusTxt, content + " loaded successfully!");
        var options = loadOptions();
        var name = loadName();
        setOptionsControls(name);

        $("#options_defaults,#options_save").click(function(e) {
          var id = e.target.id;
          if (id == "options_defaults") {
            goOptionsDefaults();
          } else if (id == "options_save") {
            goOptionsSave();
          }
        });
        $('ul.dropdown-menu li a').click(function (e) {
          var id = e.target.id;
          var name = $("#"+id).text().toLowerCase();
          setOptionsControls(name);
          e.preventDefault();
        });
        var lis = $('ul.dropdown-menu li').length;
        console.log("num li = "+lis);
        fillNamesMenu($('ul.dropdown-menu'));
      } else if (statusTxt == "error") {
        set_alert("alert", statusTxt, "Error: " + xhr.status + ": " + xhr.statusText);
      }
    });
  });

  $("#addition,#subtraction,#multiplication,#division").click(function(e) {
    var oper = title_from(e);
    var content = "content/maths.html";
    $("#content").load(content, function(responseTxt, statusTxt, xhr) {
      if (statusTxt == "success") {
        set_alert("alert", statusTxt, oper + " loaded successfully!");
        localStorage.setItem("operation", oper);
        var sym = setOperation(oper);

        setNumbers(sym);

        createStars();
        createProgress();

        resetResponseCounter();

        $("#go").click(function(e) {
          goClick();
        });
        $('#answer').keypress(function(e) {
                if (e.keyCode == 13) {
                    goClick();
                    return false; // prevent the button click from happening
                }
        });
        $('#answer').focus();
      } else if (statusTxt == "error") {
        set_alert("alert", statusTxt, "Error: " + xhr.status + ": " + xhr.statusText);
      }
    });
  });
};

function title_from(e) {
  var div = e.target.id;
  var title = "" + div;
  title = capitalize(title);
  $('#h1_action').text(title);
  return div;
};
