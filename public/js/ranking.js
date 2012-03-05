$(function(){
  var datatable = $('#ranking_table');
  $('#ranking_chart').height(datatable.height());
  var chart = initChart(getJSON(datatable));
});

function getJSON(datatable) {
  var json = {'values': []}
  datatable.find('tbody tr').each(function(){
    var tr = $(this);
    var label = $(tr.find('td.ranking_coder a')[0]).attr('title');
    var value = tr.find('td.ranking_data')[0].innerHTML;
    json.values.push({'label':label,'values':[parseInt(value)]});
  });
  return json;
}

function initChart(json) {
  var barChart = new $jit.BarChart({
    //id of the visualization container
    injectInto: 'ranking_chart',
    animate: true,
    orientation: 'horizontal',
    barsOffset: 10,
    showLabels:true,
    Label: {
      type: 'HTML',
      size: 13,
      family: 'Arial',
      color: 'black'
    }
  });
  barChart.loadJSON(json);
  return barChart;
}
