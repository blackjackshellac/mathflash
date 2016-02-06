// +-÷×

OPERATION_TABLE = {
  "addition": "+",
  "subtraction": "-",
  "multiplication": "×",
  "division": "÷"
}

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
  dpp.addClass("progress-bar progress-bar-success progress-bar-striped");
  dpp.attr('role', "progressbar").attr('aria-valuenow', "0").attr('aria-valuemin', "0").attr('aria-valuemax', "100");

  dp.append(dpp);
  ptd.append(dp);
  ptr.append(ptd);
  tprogress.append(ptr);

  div.append(tprogress);
}

function goClick() {
  var left = parseInt($("#left_val").text());
  var right = parseInt($("#right_val").text());
  var sym = $("#operation").text();
  var answer = parseInt($("#answer").val());

  var correct = false;
  if (sym == '+') {
    correct = doAddition(left, right, answer);
  } else if (sym == '×') {
    correct = doMultiplication(left, right, answer);
  }
  setStar(correct);
  setNumbers(sym);
}

function clearStars(little) {
  if (little) {
    for (var i = 0; i < 10; i++) {
      // <img id="star0" src="images/star1empty.gif">
      var id="#star"+i;
      $(id).attr('src', 'images/star1empty.gif');
    }
  } else {
    for (var i = 10; i <= 50; i += 10) {
      var id="#star"+i;
      $(id).attr('src', 'images/start10empty.gif');
    }
  }
}

function setStar(correct) {
  var star = "images/star1";
  var count = incResponseCounter();

  var n = (count % 10);
  n = n == 0 ? 9 : n - 1;
  var m = Math.floor(count / 10) * 10;

  var id;
  if (n == 0 && m > 0) {
    id = "#star" + m;
    star = "images/star10.gif";
    clearStars(true);
  } else {
    id = "#star" + n;
    star = correct ? "images/star1.gif" : "images/star1red.png";
  }
  $(id).attr('src', star);
}

function doMultiplication(left, right, answer) {
  var result = left * right;
  return answer == result;
}

function doAddition(left, right, answer) {
  var result = left + right;
  return answer == result;
}

function resetResponseCounter() {
  response_counter = 0;
}

function incResponseCounter() {
  response_counter++;
  return response_counter;
}
