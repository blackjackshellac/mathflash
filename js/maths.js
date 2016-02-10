// +-÷×

var HAPPY_CHECK = "images/supermario/Yoshi_Star_Icon_96.png";
var SAD_CHECK = "images/supermario/Yoshi_Icon_96.png";
var RIGHT_CHECK = "images/supermario/Mushroom_1UP_Icon_96.png";
var WRONG_CHECK = "images/supermario/Mushroom_Life_Icon_96.png"

var OPERATION_TABLE = {
  "addition": "+",
  "subtraction": "-",
  "multiplication": "×",
  "division": "÷"
}

var g_done = false;
var g_incorrect = [];
var g_number_max = 0;
var g_number_cur = 0;
var g_number_correct = 0;
var g_timeout = 0;
var g_timeout_id = undefined;
var g_timeout_cur = 0;
var G_TIMEOUT_INC = 500;

function getSymbol(oper) {
  var sym = OPERATION_TABLE[oper];
  if (!sym) {
    set_alert("alert", "error", "using addition for unknown operation=" + oper);
    sym = OPERATION_TABLE["addition"];
  }
  return sym;
}

function setOperation(oper) {
  var sym = getSymbol(oper);
  $("#operation").text(sym);
  return sym;
}

function getRandom(min, max) {
  //var random_number = Math.round(Math.random()*(upper_bound - lower_bound) + lower_bound);
  return Math.round(Math.random() * (max - min) + min);
}

function setProgress() {
  // "progress-number"
  // attr('aria-valuenow', "0").attr('aria-valuemin', "0").attr('aria-valuemax', g_number_max)
  var pc = Math.floor(g_number_cur * 100 / g_number_max);
  var pcc = Math.floor(g_number_correct * 100 / g_number_cur);
  var width = "width: " + pc + "%";
  var text = "" + g_number_correct + " out of " + g_number_cur + " : " + pcc + "% (max=" + g_number_max + ")";
  $("#progress-number").attr('aria-valuenow', g_number_cur).attr('aria-valuemax', g_number_max).attr('style', width).html(text);
}

function setTimeoutProgress() {
  if (g_timeout_cur > g_timeout) {
    g_timeout_cur = g_timeout;
  }
  var pc = Math.floor(g_timeout_cur * 100 / g_timeout);
  var width = "width: " + pc + "%";
  //var text = String.format("{0} of {1} seconds", g_timeout_cur, g_timeout);
  $("#timeout-progress").attr('aria-valuenow', g_timeout_cur).attr('aria-valuemax', g_timeout).attr('style', width); //.html(text);
}

function clearTimeoutProgress() {
  if (g_timeout_id != undefined) {
    clearInterval(g_timeout_id);
    g_timeout_id = undefined;
  }
  g_timeout_cur = 0;
  setTimeoutProgress();
}

function setNumbers(sym) {
  var nums = getNumbers(sym);

  $("#left_val").text(nums[0]);
  $("#right_val").text(nums[1]);
  $("#answer").val("");
}

function getNumbers(sym) {
  var option = g_options[g_name];

  if (g_number_cur == g_number_max) {
    if (g_incorrect.length > 0) {
      $("#go").text("Retry!");
      return g_incorrect.pop();
    }
    g_done = true;
  }
  var left = getRandom(0, option.left_max);
  var right = getRandom(0, option.right_max);

  if (sym == '÷') {
    // prevent div0
    right = getRandom(1, option.right_max);
    var res = left * right;
    left = res;
  } else if (sym == '-') {
    var res = left + right;
    left = res;
  }

  g_timeout_id = undefined;
  if (g_timeout > 0) {
    g_timeout_id = setInterval(function() {
      g_timeout_cur += G_TIMEOUT_INC;
      if (g_timeout_cur <= g_timeout) {
        setTimeoutProgress();
      } else {
        set_alert("alert", "error", "Doh! Too slow!");
        clearTimeoutProgress();
        $("#answer").val("0");
        goClick();
      }
    }, G_TIMEOUT_INC);
  }
  return [left, right];
}

function createStars() {
  var div = $("#content");

  div.append("<br>");
  var tstars = $("<table></table>").addClass("math");

  // little stars
  var tr = $('<tr></tr>');
  for (var i = 0; i < 10; i++) {
    // <img id="star0" src="images/star1empty.gif">
    var simg = $('<img>').attr('id', "star" + i).attr('src', 'images/star1empty.gif');
    var td = $('<td></td>').addClass('stars').html(simg);
    tr.append(td);
  }
  tstars.append(tr);

  // big stars
  tr = $('<tr></tr>');
  for (var i = 10; i <= 50; i += 10) {
    var simg = $('<img>').attr('id', "star" + i).attr('src', 'images/star10empty.gif');
    var td = $('<td></td>').addClass('stars').attr('colspan', '2').html(simg);
    tr.append(td);
  }
  tstars.append(tr);
  div.append(tstars);
}

function createProgress() {
  var div = $("#content");
  div.append("<br>");
  var tprogress = $("<table></table>").addClass("math");
  var ptr = $('<tr></tr>');
  var ptd = $('<td></td>');

  var dp = $('<div></div>').addClass("progress");
  var dpp = $('<div></div>');

  //<div class="progress-bar progress-bar-success progress-bar-striped" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width:40%">
  dpp.addClass("progress-bar progress-bar-success");
  dpp.attr('id', "progress-number").attr('role', "progressbar").attr('aria-valuenow', "0").attr('aria-valuemin', "0").attr('aria-valuemax', g_number_max);

  dp.append(dpp);
  ptd.append(dp);
  ptr.append(ptd);
  tprogress.append(ptr);

  div.append(tprogress);
}

function createTimeoutProgress() {
  if (g_timeout == 0) {
    return;
  }
  var div = $("#content");
  div.append("<br>");
  var tprogress = $("<table></table>").addClass("math");
  var ptr = $('<tr></tr>');
  var ptd = $('<td></td>');

  var dp = $('<div></div>').addClass("progress");
  var dpp = $('<div></div>');

  //<div class="progress-bar progress-bar-success progress-bar-striped" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width:40%">
  dpp.addClass("progress-bar progress-bar-success");
  dpp.attr('id', "timeout-progress").attr('role', "progressbar").attr('aria-valuenow', "0").attr('aria-valuemin', "0").attr('aria-valuemax', g_timeout);

  dp.append(dpp);
  ptd.append(dp);
  ptr.append(ptd);
  tprogress.append(ptr);

  div.append(tprogress);
}

function getInt(sval) {
  var ival = parseInt(sval.trim());
  if (isNaN(ival)) {
    throw ("Value is not an integer: " + sval);
  }
  return ival;
}

function getIntVal(sid) {
  return getInt($(sid).val());
}

function getIntText(sid) {
  return getInt($(sid).text());
}

function goClick() {
  var answer, left, right, sym;

  if (g_done) {
    resetResponseCounter();
    clearStars(true);
    clearStars(false);
    setProgress();
    return;
  }

  try {
    answer = getIntVal("#answer");
    left = getIntText("#left_val");
    right = getIntText("#right_val");
    sym = $("#operation").text();
  } catch (e) {
    set_alert("alert", "error", e);
    $("#answer").val("");
    return;
  }

  var res = doOperation(sym, left, right);
  var correct = res == answer;
  var text_result = "";
  if (!correct) {
    text_result = String.format("{0} {1} {2} = {3}", left, sym, right, res);
    $("#result").css('color', 'darkred');
    g_incorrect.push([left, right]);
  }
  $("#result").text(text_result);

  setStar(correct);
  setProgress();
  setNumbers(sym);
  if (g_done) {
    var pc = Math.floor(g_number_correct / g_number_cur * 100);
    var check = pc > 60 ? HAPPY_CHECK : SAD_CHECK;
    $("#checkmark").attr('src', check);
    $("#answer").attr('disabled', 'disabled');
    $("#go").text("Restart!").focus();
  }
}

function clearStars(little) {
  if (little) {
    for (var i = 0; i < 10; i++) {
      // <img id="star0" src="images/star1empty.gif">
      var id = "#star" + i;
      $(id).attr('src', 'images/star1empty.gif');
    }
  } else {
    for (var i = 10; i <= 50; i += 10) {
      var id = "#star" + i;
      $(id).attr('src', 'images/star10empty.gif');
    }
  }
}

function setStar(correct) {
  var check;
  var star_id;
  var star;
  var count = incCounters(correct);

  var m = (count % 10);
  var n = m == 0 ? 9 : m - 1;

  if (n == 9 && m == 0) {
    star_id = "#star" + (count / 10) * 10;
    star = "images/star10.gif";
    $(star_id).attr('src', star);
  } else if (n == 0 && m == 1) {
    clearStars(true);
  }

  star_id = "#star" + n;
  if (correct) {
    star = "images/star1.gif";
    check = RIGHT_CHECK;
  } else {
    star = "images/star1red.png";
    check = WRONG_CHECK;
  }
  $(star_id).attr('src', star);
  $("#checkmark").attr('src', check);
}

function doOperation(sym, left, right) {
  if (sym == '+') return left + right;
  if (sym == '-') return left - right;
  if (sym == '×') return left * right;
  if (sym == '÷') return left / right;
  throw "Unknown operation symbol: " + sym
}

function resetResponseCounter() {
  g_done = false;
  g_incorrect = [];
  g_number_cur = 0;
  g_number_correct = 0;
  g_number_max = getIntegerOption("number_max");
  $("#answer").removeAttr('disabled').focus();
  $("#checkmark").attr('src', HAPPY_CHECK);
  $("#go").text("Go!");

  g_timeout = getIntegerOption("timeout_max") * 2000;
  g_timeout_cur = 0;
}

function incCounters(correct) {
  if (g_number_cur == g_number_max) {
    return g_number_cur;
  }
  g_number_cur++;
  if (correct) {
    g_number_correct++;
  }
  return g_number_cur;
}
