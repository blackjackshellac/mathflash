function getChartDataset(xyy) {
  if (g_stats_dataset == 0) {
    return [{
      label: "Percent - " + g_stats_sym,
      fillColor: "rgba(220,220,220,0.5)",
      strokeColor: "rgba(220,220,220,0.8)",
      highlightFill: "rgba(220,220,220,0.75)",
      highlightStroke: "rgba(220,220,220,1)",
      data: xyy.y0
    }];
  } else {
    return [{
      label: "My Second dataset",
      fillColor: "rgba(151,187,205,0.5)",
      strokeColor: "rgba(151,187,205,0.8)",
      highlightFill: "rgba(151,187,205,0.75)",
      highlightStroke: "rgba(151,187,205,1)",
      data: xyy.y1
    }];

  }
}

function getChart2BetaDataset(xyy) {
  if (g_stats_dataset == 0) {
    return [{
      label: "Percent - " + g_stats_sym,

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
      data: xyy.y0,

      // String - If specified, binds the dataset to a certain y-axis. If not specified, the first y-axis is used.
      //yAxisID: "y-axis-1",
    }];
  } else {
    return [{
      label: "Ave time - " + g_stats_sym,
      backgroundColor: "rgba(220,220,220,0.2)",
      borderColor: "rgba(220,220,220,1)",
      borderWidth: 1,
      hoverBackgroundColor: "rgba(220,220,220,0.2)",
      hoverBorderColor: "rgba(220,220,220,1)",
      //yAxisID: "y-axis-2",
      data: xyy.y1
    }];
  }
}

function getDates(xyy) {
  var dates = [];
  for (var i = 0; i < xyy.x.length; i++) {
    var d = new Date(xyy.x[i] * 1000);
    dates.push(d.toLocaleString());
  }
  return dates;
}

/*
 * extract xyy data for (x) time, (y0) percent and (y1) ave time
 */
function getXYY(stats) {
	var xyy = {
		x: [],
		y0: [],
		y1: []
	}
	for (var i=0; i < stats.length; i++) {
		stat=stats[i];
		xyy.x.push(stat.stimestamp);
		xyy.y0.push(stat.percent);
		var ave_time=Math.round((stat.etimestamp-stat.stimestamp)/stat.count);
		xyy.y1.push(ave_time);
	}
	return xyy;
}

function loadChart(stats_sym, stats_dataset) {

  g_stats_sym = stats_sym;
  g_stats_dataset = stats_dataset;

  var name = loadName();
  var stats = loadStats();

  var xyy = getXYY(stats);

  var dates = getDates(xyy);
  var barChartData = {
    labels: dates,
    datasets: getChartDataset(xyy)
  };
  var options = {

  };

  if (window.myBarChart !== undefined) {
    window.myBarChart.destroy();
  }
  var ctx = $("#canvas")[0].getContext("2d");
  var myBarChart = new Chart(ctx).Bar(barChartData, options);
  window.myBarChart = myBarChart;
  /*
  chartjs 2.0 beta
  window.myBarChart = new Chart(ctx, {
    type: 'bar',
    data: barChartData,
    options: {}
  });
  */
}
