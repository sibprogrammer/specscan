$(function() {

  function extend(child, parent) {
    var c = function () {};
    c.prototype = parent.prototype;
    c.prototype.constructor = parent;
    return child.prototype = new c();
  };

  window.PolylineWithArrows = function(points, options) {
    YMaps.Polyline.call(this, points, options);
    this._origPoints = points;

    var arrows = new YMaps.GeoObjectCollection(this.getComputedStyle());
    var listener;

    this.onAddToMap = function(map, mapContainer) {
      YMaps.Polyline.prototype.onAddToMap.call(this, map);

      listener = YMaps.Events.observe(this, this.Events.PositionChange, function () {
        this.updateArrows();
      }, this);

      map.addOverlay(arrows);
      this.updateArrows();
    }

    this.onRemoveFromMap = function() {
      this.getMap().removeOverlay(arrows);
      YMaps.Polyline.prototype.onRemoveFromMap.call(this);
      listener.cleanup();
    }

    this.onMapUpdate = function() {
      YMaps.Polyline.prototype.onMapUpdate.call(this);
      this.updateArrows();
    }

    this.updateArrows = function() {
      var lineWidth = this.getComputedStyle().lineStyle.strokeWidth;
      var arrowWidth = lineWidth * 10;

      arrows.removeAll();

      for (var i = 0, prev, current, points = this.getPoints(); i < points.length; i++) {
          current = this.getMap().converter.coordinatesToLocalPixels(points[i]);
          if (prev) {
              var vector = current.diff(prev);
              var length = Math.sqrt(vector.getX() * vector.getX() + vector.getY() * vector.getY());
              var normal = vector.scale(1 / length);

              if (length > arrowWidth) {
                  var middle = current.diff(prev.neg()).neg().scale(1/2);
                  var offsetMiddle = normal.scale(-arrowWidth / 2);
                  var arrowPart1 = new YMaps.Point(0 - offsetMiddle.getY(), offsetMiddle.getX()).scale(0.4);
                  var arrowPart2 = new YMaps.Point(offsetMiddle.getY(), 0 - offsetMiddle.getX()).scale(0.4);
                  var arrowPoint1 = middle.diff(offsetMiddle).diff(arrowPart1.neg());
                  var arrowPoint2 = middle.diff(offsetMiddle).diff(arrowPart2.neg());

                  var polygon = new YMaps.Polygon([
                      this.getMap().converter.localPixelsToCoordinates(middle),
                      this.getMap().converter.localPixelsToCoordinates(arrowPoint1),
                      this.getMap().converter.localPixelsToCoordinates(arrowPoint2)
                  ]);

                  polygon.description = this._origPoints[i].description;
                  arrows.add(polygon);
              }
          }
          prev = current;
      }
    };
  }

  var ptp = extend(PolylineWithArrows, YMaps.Polyline);
});