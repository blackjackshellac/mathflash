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
        set_alert("alert", statusTxt, content + " loaded successfully!");
        var name = loadName();
        var stats = loadStats();

        stats = stats[name]["+"];

        var dates = [];
        for (var i = 0; i < stats.x.length; i++) {
          var d = new Date(stats.x[i] * 1000);
          dates.push(d.toLocaleString());
        }

        var barChartData = {
          labels: dates,
          datasets: [{
            label: "Percent",

            // The properties below allow an array to be specified to change the value of the item at the given index
            // String  or array - the bar color
            backgroundColor: "rgba(220,220,220,0.2)",

            // String or array - bar stroke color
            borderColor: "rgba(220,220,220,1)",

            // Number or array - bar border width
            borderWidth: 1,

            // String or array - fill color when hovered
            hoverBackgroundColor: "rgba(220,220,220,0.2)",

            // String or array - border color when hovered
            hoverBorderColor: "rgba(220,220,220,1)",

            // The actual data
            data: stats.y0,

            // String - If specified, binds the dataset to a certain y-axis. If not specified, the first y-axis is used.
            //yAxisID: "y-axis-1",
          }, {
            label: "Time",
            backgroundColor: "rgba(220,220,220,0.2)",
            borderColor: "rgba(220,220,220,1)",
            borderWidth: 1,
            hoverBackgroundColor: "rgba(220,220,220,0.2)",
            hoverBorderColor: "rgba(220,220,220,1)",
            //yAxisID: "y-axis-2",
            data: stats.y1
          }]
        };

        var ctx = $("#canvas")[0].getContext("2d");
        window.myBarChart = new Chart(ctx, {
          type: 'bar',
          data: barChartData,
          options: {}
        });

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
