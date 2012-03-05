$(function(){
  var activeid = $('#languagetabs').find('.tab-pane.active')[0].id;
  var chart = initChart(getJSON(activeid));
  // update when tab is clicked
  $('#languagetablinks a').each(function(){
    var href = this.href;
    var activeid = href.substring(href.indexOf('#')+1);
    var json = getJSON(activeid);
    var button = $jit.id(this.id);
    $jit.util.addEvent(button, 'click', function() {
      chart.loadJSON(json);
    });
  });
});

function getJSON(activeid) {
  var json = {'values': []}
  $('#'+activeid).find('tbody tr').each(function(){
    var tr = $(this);
    var label = tr.find('td')[1].innerHTML;
    var value = tr.find('td')[2].innerHTML;
    json.values.push({'label':label,'values':[parseInt(value)]});
  });
  return json;
}

function initChart(json) {
  var barChart = new $jit.BarChart({
    //id of the visualization container
    injectInto: 'infovis',
    animate: true,
    orientation: 'vertical',
    barsOffset: 2,
    Margin: {
      top: 5,
      left: 5,
      right: 5,
      bottom: 5
    },
    labelOffset:5,
    showLabels:true,
    Label: {
      type: labelType, //Native or HTML
      size: 14,
      family: 'Arial',
      color: 'black'
    }
  });
  barChart.loadJSON(json);
  return barChart;
}
