var map;

function initMap() {
  $(function() {
    map = new YMaps.Map(document.getElementById("map-canvas"));
    map.addControl(new YMaps.TypeControl());
    map.addControl(new YMaps.Zoom());
    map.addControl(new YMaps.ScaleLine());
    map.addControl(new YMaps.ToolBar());
    map.setCenter(new YMaps.GeoPoint(82.933957,55.007224), 12);
  });
}

$(function() {
  $('#show-track').on('click', function() {
    var s = new YMaps.Style();
    s.lineStyle = new YMaps.LineStyle();
    s.lineStyle.strokeColor = '0000FF55';
    s.lineStyle.strokeWidth = '5';
    YMaps.Styles.add("map-canvas#CustomLine", s);

    var pl = new YMaps.Polyline([ 
      new YMaps.GeoPoint(82.936641,55.008459),
      new YMaps.GeoPoint(82.901279,55.02503),
      new YMaps.GeoPoint(82.910892,55.031735),
      new YMaps.GeoPoint(82.919132,55.036862),
      new YMaps.GeoPoint(82.962734,55.041003)
    ]);

    pl.setStyle('map-canvas#CustomLine');

    map.addOverlay(pl);
  });
});
