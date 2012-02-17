$ ->
  if $('body.vehicles.map').length > 0

    createMap = ->
      map = new YMaps.Map($("#map-canvas")[0])
      map.addControl(new YMaps.TypeControl())
      map.addControl(new YMaps.Zoom())
      map.addControl(new YMaps.ScaleLine())
      map.addControl(new YMaps.ToolBar())
      map.enableScrollZoom()
      map

    createLineStyle = ->
      lineStyle = new YMaps.Style()
      lineStyle.lineStyle = new YMaps.LineStyle()
      lineStyle.lineStyle.strokeColor = '0000FFA5'
      lineStyle.lineStyle.strokeWidth = '5'
      YMaps.Styles.add("map-canvas#custom-line", lineStyle)

    resizeMap = ->
      $('#map-canvas').height($(window).height() - $('#map-canvas').offset().top - 20)

    resizeMap()
    $(window).resize(resizeMap)

    map = createMap()
    map.setCenter(new YMaps.GeoPoint(82.933957,55.007224), 12)
    createLineStyle()

    placemark = null
    polyline = null

    $('.movements-list a').each (index, element) ->
      $(element).on 'click', ->
        move = $(this).data('info')

        map.removeOverlay(placemark) if placemark
        map.removeOverlay(polyline) if polyline

        if move.parking
          point = move.first_point
          geoPoint = new YMaps.GeoPoint(point.longitude, point.latitude)
          placemark = new YMaps.Placemark(geoPoint)
          placemark.name = "Стоянка"
          placemark.description = "Данные по стоянке..."
          bounds = new YMaps.GeoBounds(geoPoint, geoPoint)
          placemark.setBounds(bounds)
          map.addOverlay(placemark)
          map.setBounds(placemark.getBounds())
        else
          firstGeoPoint = new YMaps.GeoPoint(move.first_point.longitude, move.first_point.latitude)
          lastGeoPoint = new YMaps.GeoPoint(move.last_point.longitude, move.last_point.latitude)
          mapPoints = []
          $(move.points).each (index, point) ->
            mapPoints.push(new YMaps.GeoPoint(point.longitude, point.latitude))
          polyline = new YMaps.Polyline(mapPoints)
          polyline.setStyle('map-canvas#custom-line')
          map.addOverlay(polyline)
          bounds = new YMaps.GeoCollectionBounds(mapPoints)
          map.setBounds(bounds)
