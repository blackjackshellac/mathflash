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
        var options = getOptions();
        var name = getOption("name", NAME_DEF);
        var option = options[name];
        if (!option) {
          set_alert("alert", "warning", "using defaults for name="+name);
          option = getOptionsDefault();
          setOptions(options);
          setName(NAME_DEF);
        }
        setOptionsControls(name, option);
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
        set_alert("alert", statusTxt, content + " loaded successfully!");
        localStorage.setItem("operation", oper);
        setOperation(oper);

        var nums = getNumbers(oper);

        $("#left_val").text(nums.left);
        $("#right_val").text(nums.right);

        var cdiv = $("#content");
        createStars(cdiv);
        createProgress(cdiv);

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
