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

    resizeMap = ->
      $('#map-canvas').height($(window).height() - $('#map-canvas').offset().top - 20)

    createLineStyle = ->
      style = new YMaps.Style()
      style.polygonStyle = new YMaps.PolygonStyle()
      style.polygonStyle.strokeColor = '0000FFA5'
      style.polygonStyle.fillColor = '0000FFA5'
      style.lineStyle = new YMaps.LineStyle()
      style.lineStyle.strokeColor = '0000FFA5'
      style.lineStyle.strokeWidth = 4
      YMaps.Styles.add("user#routeLine", style)

    getIconStyle = (image) ->
      iconStyle = new YMaps.Style();
      iconStyle.iconStyle = new YMaps.IconStyle();
      iconStyle.iconStyle.size = new YMaps.Point(16, 16);
      iconStyle.iconStyle.offset = new YMaps.Point(0, -16);
      iconStyle.iconStyle.href = image_path(image)
      iconStyle

    getPlacemark = (config) ->
      placemark = new YMaps.Placemark(config.geoPoint, { style: "user#" + config.icon, hideIcon: false })
      YMaps.Styles.add("user#" + config.icon, getIconStyle('icons/' + config.icon + '.png'))
      placemark.name = config.title || ''
      placemark.description = config.description || ''
      bounds = new YMaps.GeoBounds(config.geoPoint, config.geoPoint)
      placemark.setBounds(bounds)
      config.map.addOverlay(placemark)
      config.map.setBounds(placemark.getBounds())
      placemark

    showMovement = (element, state) ->
      $(element).parent('li').toggleClass('ico-watch')
      $(element).parent('li').addClass('ico-watch') if 'show' == state
      $(element).parent('li').removeClass('ico-watch') if 'hide' == state

      overlays = $(element).data('overlays')
      overlays = [] unless overlays

      return if overlays.length > 0 && 'show' == state

      if overlays.length && !$(element).parent('li').hasClass('ico-watch')
        for overlay in overlays
          map.removeOverlay(overlay)
        $(element).data('overlays', null)
        return

      return if 'hide' == state

      move = $(element).data('info')

      if move.parking
        point = move.first_point
        geoPoint = new YMaps.GeoPoint(point.longitude, point.latitude)

        placemark = getPlacemark({
          map: map, title: move.title, description: move.timeframe + "<br/>" + move.duration,
          geoPoint: geoPoint, icon: 'parking'
        })
        placemark.openBalloon()
        overlays.push(placemark)
      else
        firstGeoPoint = new YMaps.GeoPoint(move.first_point.longitude, move.first_point.latitude)
        placemark = getPlacemark({
          map: map, title: move.title, description: move.timeframe + "<br/>" + move.duration,
          geoPoint: firstGeoPoint, icon: 'flag_green'
        })
        overlays.push(placemark)

        lastGeoPoint = new YMaps.GeoPoint(move.last_point.longitude, move.last_point.latitude)
        placemark = getPlacemark({
          map: map, title: move.title, description: move.timeframe + "<br/>" + move.duration,
          geoPoint: lastGeoPoint, icon: 'flag_finish'
        })
        overlays.push(placemark)

        mapPoints = []
        $(move.points).each (index, point) ->
          geoPoint = new YMaps.GeoPoint(point.longitude, point.latitude)
          geoPoint.description = point.time + '<br>' + point.speed
          mapPoints.push(geoPoint)

        polyline = new PolylineWithArrows(mapPoints, { style: 'user#routeLine' })
        polyline.name = move.title
        polyline.description = move.timeframe + "<br/>"
        polyline.description += move.duration
        map.addOverlay(polyline)
        bounds = new YMaps.GeoCollectionBounds(mapPoints)
        map.setBounds(bounds)
        polyline.openBalloon()
        overlays.push(polyline)

      $(element).data('overlays', overlays)

    resizeMap()
    $(window).resize(resizeMap)

    map = createMap()
    map.setCenter(new YMaps.GeoPoint(82.933957,55.007224), 12)
    createLineStyle()

    $('.movements-list a.movement-info').each (index, element) ->
      $(element).on 'click', ->
        showMovement(this)

    $('a.ico-show-all').first().on 'click', ->
      $('.movements-list a.movement-info').each (index, element) ->
        showMovement(element, 'show')

    $('a.ico-hide-all').first().on 'click', ->
      $('.movements-list a.movement-info').each (index, element) ->
        showMovement(element, 'hide')
