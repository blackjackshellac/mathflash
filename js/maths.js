// +-÷×

var OPERATION_TABLE = {
  "addition": "+",
  "subtraction": "-",
  "multiplication": "×",
  "division": "÷"
}

var g_number_max = 0;
var g_number_cur = 0;
var g_number_correct = 0;

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
  var text = "" + g_number_correct + " out of " + g_number_cur + " : " + pcc + "% (max="+g_number_max+")";
  $("#progress-number").attr('aria-valuenow', g_number_cur).attr('aria-valuemax', g_number_max).attr('style', width).html(text);
}

function setNumbers(sym) {
  var nums = getNumbers(sym);

  $("#left_val").text(nums.left);
  $("#right_val").text(nums.right);
  $("#answer").val("");
}

function getNumbers(sym) {
  var name = getOption("name");
  var options = getOptions();
  var option = options[name];

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
  return {
    left: left,
    right: right
  }
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

function createProgress(div) {
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

function goClick() {
  var answer = $("#answer").val().trim();
  if (answer == "") {
    return;
  }
  if (g_number_cur == g_number_max) {
    var pc = Math.floor(g_number_correct / g_number_cur * 100);
    var check = pc > 60 ? "images/star10correct.gif" : "images/stop10wrong.gif";
    $("#checkmark").attr('src', check);
    return;
  }
  answer = parseInt(answer);
  var left = parseInt($("#left_val").text());
  var right = parseInt($("#right_val").text());
  var sym = $("#operation").text();

  var correct = false;
  if (sym == '+') {
    correct = doAddition(left, right, answer);
  } else if (sym == '-') {
    correct = doSubtraction(left, right, answer);
  } else if (sym == '×') {
    correct = doMultiplication(left, right, answer);
  } else if (sym == '÷') {
    correct = doDivision(left, right, answer);
  }
  setStar(correct);
  setProgress();
  setNumbers(sym);
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
      $(id).attr('src', 'images/start10empty.gif');
    }
  }
}

function setStar(correct) {
  var star = "images/star1";
  var count = incCounters(correct);

  var n = (count % 10);
  n = n == 0 ? 9 : n - 1;
  var m = Math.floor(count / 10) * 10;

  var id = "#star" + n;
  if (n == 0 && m > 0) {
    id = "#star" + m;
    star = "images/star10.gif";
    $(id).attr('src', star);
    clearStars(true);
  }
  id = "#star" + n;
  star = correct ? "images/star1.gif" : "images/star1red.png";
  $(id).attr('src', star);
  var check = correct ? "images/check_green.png" : "images/check_red.png";
  $("#checkmark").attr('src', check);
}

function doAddition(left, right, answer) {
  var result = left + right;
  return answer == result;
}

function doSubtraction(left, right, answer) {
  var result = left - right;
  return answer == result;
}

function doMultiplication(left, right, answer) {
  var result = left * right;
  return answer == result;
}

function doDivision(left, right, answer) {
  var result = left / right;
  return answer == result;
}

function resetResponseCounter() {
  g_number_cur = 0;
  g_number_correct = 0;
  g_number_max = getIntegerOption("number_max");
}

function incCounters(correct) {
  g_number_cur++;
  if (correct) {
    g_number_correct++;
  }
  if (g_number_cur > g_number_max) {
    g_number_max = g_number_cur;
  }
  return g_number_cur;
}
