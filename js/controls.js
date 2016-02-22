function init_controls() {
  $(".nav li").click(function() {
    $(".nav").find(".active").removeClass("active");
    $(this).addClass("active");
  });

  $("#charts").click(function(e) {
    var div = title_from(e);
    var content = "content/charts.html";
    $("#content").load(content, function(responseTxt, statusTxt, xhr) {
      if (statusTxt === "success") {

        $('#operations-slider').slider({
          formatter: function(value) {
            var sym = OPERATION_LOOKUP[value % 4];
            loadChart(sym, g_stats_dataset);
            return 'Operation: ' + sym;
          }
        });

        $('#dataset-slider').slider({
          formatter: function(value) {
            var dataset=["percent","ave time"][value%2];
            loadChart(g_stats_sym, value);
            return 'Dataset: ' + dataset;
          }
        });

        set_alert("alert", statusTxt, content + " loaded successfully!");

        /*
        window.myBar = new Chart(ctx).Bar(barChartData, {
          responsive: true
        });
        */

      } else if (statusTxt === "error") {
        set_alert("alert", statusTxt, "Failed to load " + content);
      }
    });
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
        clearTimeoutProgress();

        $("#options_defaults,#options_save").click(function(e) {
          var id = e.target.id;
          if (id == "options_defaults") {
            goOptionsDefaults();
          } else if (id == "options_save") {
            goOptionsSave();
          }
        });

        // fill the menu before setting the click events
        fillNamesMenu();
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

        clearTimeoutProgress();
        createStars();
        createProgress();
        createTimeoutProgress();
        resetResponseCounter();
        setNumbers(sym);

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
