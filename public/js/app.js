$(function(){
  $('#ghuser').focus(function(){this.value='';});
});

//    <div class="row">
//      <div class="span3">
//        <header><h2>Public Activity</h2></header>
//        <div id="ghuser_feed"></div>
//      </div>
//    </div>
var Feed = {
  load: function() {
    // users public activity
    var url = 'https://github.com/' + $('#ghlogin').text() + '.atom';
    $.getScript('http://www.google.com/jsapi?key=AIzaSyB75IDBFMpF9DsLFbDVwVY0Kzn9CIBBQhY', function(data, textStatus){
      function initfeed() {
        var feed = new google.feeds.Feed(url);
        feed.load(function(result) {
          if (!result.error) {
            var container = document.getElementById('ghuser_feed');
            for (var i = 0; i < result.feed.entries.length; i++) {
              var entry = result.feed.entries[i];
              var div = document.createElement('div');
              div.appendChild(document.createTextNode(entry.title));
              container.appendChild(div);
            }
          }
        });
      }
      google.load('feeds', '1', initfeed);
    });
  }
};
