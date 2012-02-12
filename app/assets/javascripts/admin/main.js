var map;

function initMap() {
  $(function() {
    var resizeMap = function() {
      $('#map-canvas').height($(window).height() - $('#map-canvas').offset().top - 20);
    }

    resizeMap();
    $(window).resize(resizeMap);

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

    var mapPoints = [];

    $.each(wayPoints, function(index, point) {
      mapPoints.push(new YMaps.GeoPoint(point[0], point[1]));
    });

    var pl = new YMaps.Polyline(mapPoints);

    pl.setStyle('map-canvas#CustomLine');

    map.addOverlay(pl);
  });
});
