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

    getBigIconStyle = (image) ->
      iconStyle = new YMaps.Style();
      iconStyle.iconStyle = new YMaps.IconStyle();
      iconStyle.iconStyle.size = new YMaps.Point(32, 32);
      iconStyle.iconStyle.offset = new YMaps.Point(-16, -16);
      iconStyle.iconStyle.href = image_path(image)
      iconStyle

    getPlacemark = (config) ->
      if config.bigIcon
        icon = config.bigIcon
        iconStyle = getBigIconStyle('icons/' + icon + '.png')
      else
        icon = config.icon
        iconStyle = getIconStyle('icons/' + icon + '.png')

      placemark = new YMaps.Placemark(config.geoPoint, { style: "user#" + icon, hideIcon: false })
      YMaps.Styles.add("user#" + icon, iconStyle)
      placemark.name = config.title || ''
      placemark.description = config.description || ''
      bounds = new YMaps.GeoBounds(config.geoPoint, config.geoPoint)
      placemark.setBounds(bounds)
      config.map.addOverlay(placemark)
      config.map.setBounds(placemark.getBounds()) if config.moveMap
      placemark

    loadMovementPoints = (element, move, moveMap) ->
      $(element).parent('li').append('<img src="' + image_path('icons/loading.gif') + '" class="inline-icon" width="16" height="16">')
      $.ajax({
        url: '/admin/vehicles/' + move.vehicle_id + '/get_movement_points?movement_id=' + move.movement_id,
        async: true
      }).done (data) ->
        $(element).parent('li').find('img:last-child').remove()
        move.points = data
        renderMovementPoints(element, move, moveMap)

    renderMovementPoints = (element, move, moveMap) ->
      overlays = []

      firstGeoPoint = new YMaps.GeoPoint(move.first_point.longitude, move.first_point.latitude)
      placemark = getPlacemark({
        map: map, title: move.title, description: move.from_time + "<br/>" + move.to_time + "<br/>" + move.duration,
        geoPoint: firstGeoPoint, icon: 'flag_green', moveMap: false
      })
      overlays.push(placemark)

      lastGeoPoint = new YMaps.GeoPoint(move.last_point.longitude, move.last_point.latitude)
      placemark = getPlacemark({
        map: map, title: move.title, description: move.from_time + "<br/>" + move.to_time + "<br/>" + move.duration,
        geoPoint: lastGeoPoint, icon: 'flag_finish', moveMap: false
      })
      overlays.push(placemark)

      mapPoints = []
      $(move.points).each (index, point) ->
        geoPoint = new YMaps.GeoPoint(point[1], point[0])
        geoPoint.description = jsLocaleKeys.time.replace('%time%', point[2]) + '<br>' + jsLocaleKeys.speed.replace('%speed%', point[3])
        mapPoints.push(geoPoint)

      polyline = new PolylineWithArrows(mapPoints, { style: 'user#routeLine' })
      polyline.name = move.title
      polyline.description = move.from_time + "<br/>" + move.to_time + "<br/>" + move.duration + "<br/>" + move.distance
      map.addOverlay(polyline)
      if moveMap
        bounds = new YMaps.GeoCollectionBounds(mapPoints)
        map.setBounds(bounds)
        polyline.openBalloon()
      overlays.push(polyline)

      $(element).data('overlays', overlays)

    showMovement = (element, state, moveMap = true) ->
      $(element).parent('li').toggleClass('ico-watch')
      $(element).parent('li').addClass('ico-watch') if 'show' == state
      $(element).parent('li').removeClass('ico-watch') if 'hide' == state

      if typeof state is "undefined"
        state = if $(element).parent('li').hasClass('ico-watch') then 'show' else 'hide'

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

      if !move.parking && 0 == move.points.length
        $(element).data('overlays', null)
        loadMovementPoints(element, move, moveMap)
        return

      if move.parking
        point = move.first_point
        geoPoint = new YMaps.GeoPoint(point.longitude, point.latitude)

        placemark = getPlacemark({
          map: map, title: move.title, description: move.from_time + "<br/>" + move.to_time + "<br/>" + move.duration,
          geoPoint: geoPoint, icon: 'parking', moveMap: moveMap
        })
        placemark.openBalloon() if moveMap
        overlays.push(placemark)
        $(element).data('overlays', overlays)
      else
        renderMovementPoints(element, move, moveMap)

    resizeMap()
    $(window).resize(resizeMap)

    map = createMap()

    lastPointPlacemark = null

    if $('a.ico-last-point').length > 0
      lastPoint = $('a.ico-last-point').first().data('info')
      geoPoint = new YMaps.GeoPoint(lastPoint.longitude, lastPoint.latitude)
      map.setCenter(geoPoint, 12)
      lastPointPlacemark = getPlacemark({
        map: map, title: lastPoint.title, description: lastPoint.description,
        geoPoint: geoPoint, bigIcon: 'truck', moveMap: true
      })
      lastPointPlacemark.openBalloon()
    else
      # center of Novosibirsk
      map.setCenter(new YMaps.GeoPoint(82.933957,55.007224), 12)

    createLineStyle()

    $('.movements-list a.movement-info').each (index, element) ->
      $(element).on 'click', ->
        showMovement(this)

    $('a.ico-show-all').first().on 'click', ->
      $('.movements-list a.movement-info').each (index, element) ->
        showMovement(element, 'show', false)

    $('a.ico-hide-all').first().on 'click', ->
      $('.movements-list a.movement-info').each (index, element) ->
        showMovement(element, 'hide')

    $('a.ico-last-point').first().on 'click', ->
      lastPoint = $(this).data('info')
      map.setCenter(new YMaps.GeoPoint(lastPoint.longitude, lastPoint.latitude))
      lastPointPlacemark.openBalloon()

    $('#selectedDate').on 'custom:dateChanged', ->
      url = document.location.pathname
      url += '?date=' + $('#selectedDate').text()
      document.location = url
