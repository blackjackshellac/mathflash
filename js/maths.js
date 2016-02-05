// +-÷×

OPERATION_TABLE = {
  "addition" : "+",
  "subtraction" : "-",
  "multiplication" : "×",
  "division" : "÷"
}
function setOperation(oper) {
  var sym=OPERATION_TABLE[oper];
  if (!sym) {
      set_alert("alert", "error", "using addition for unknown operation="+oper);
      sym = OPERATION_TABLE["addition"];
  }
  $("#operation").text(sym);
}

function createStars(div) {
  div.append("<br>");
  var tstars = $("<table></table>").addClass("math");

  // little stars
  var tr=$('<tr></tr>');
  for (var i=0; i < 10; i++) {
    // <img id="star0" src="images/star1empty.gif">
    var simg=$('<img>').attr('id', "star"+i).attr('src', 'images/star1empty.gif');
    var td = $('<td></td>').addClass('stars').html(simg);
    tr.append(td);
  }
  tstars.append(tr);

  // big stars
  tr=$('<tr></tr>');
  for (var i=10; i <= 50; i+=10) {
    var simg=$('<img>').attr('id', "star"+i).attr('src', 'images/star10empty.gif');
    var td = $('<td></td>').addClass('stars').attr('colspan', '2').html(simg);
    tr.append(td);
  }
  tstars.append(tr);
  div.append(tstars);
}

function createProgress(div) {
  div.append("<br>");
  var tprogress = $("<table></table>").addClass("math");
  var ptr=$('<tr></tr>');
  var ptd=$('<td></td>');

  var dp = $('<div></div>').addClass("progress");
  var dpp = $('<div></div>');

  //<div class="progress-bar progress-bar-success progress-bar-striped" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width:40%">
  dpp.addClass("progress-bar progress-bar-success progress-bar-striped");
  dpp.attr('role', "progressbar").attr('aria-valuenow', "0").attr('aria-valuemin',"0").attr('aria-valuemax',"100");

  dp.append(dpp);
  ptd.append(dp);
  ptr.append(ptd);
  tprogress.append(ptr);

  div.append(tprogress);
}
