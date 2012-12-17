$ ->
  createMap = ->
    map = new YMaps.Map($("#map-canvas")[0])
    map.addControl(new YMaps.TypeControl())
    map.addControl(new YMaps.Zoom())
    map.addControl(new YMaps.ScaleLine())
    map.addControl(new YMaps.ToolBar())
    map.addControl(new YMaps.SearchControl())
    map.enableScrollZoom()
    map

  resizeMap = ->
    mapHeight = if ($(window).width() < 768) then $(window).height() else ($(window).height() - $('#map-canvas').offset().top - 20)
    $('#map-canvas').height(mapHeight)

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
    iconStyle.iconStyle.size = new YMaps.Point(48, 48);
    iconStyle.iconStyle.offset = new YMaps.Point(-24, -24);
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
    if placemark.name and config.link
      placemark.name = '<a href="' + config.link + '">' + placemark.name + '</a>'
    placemark.description = config.description || ''
    bounds = new YMaps.GeoBounds(config.geoPoint, config.geoPoint)
    placemark.setBounds(bounds)
    config.map.addOverlay(placemark)
    config.map.setBounds(placemark.getBounds()) if config.moveMap
    placemark

  if $('body.vehicles.overview_map').length > 0

    renderPlacemark = (map, pointLink, lastPoint, geoPoint, vehicleIcon, options) ->
      lastPlacemark = getPlacemark({
        map: map, title: lastPoint.title, description: lastPoint.description,
        geoPoint: geoPoint, bigIcon: vehicleIcon, moveMap: options.moveMap, link: lastPoint.link
      })
      pointLink.data('placemark', lastPlacemark)
      lastPlacemark.openBalloon() if options.moveMap

    showLastPoint = (element, map, options) ->
      pointLink = $(element).first()
      lastPoint = pointLink.data('info')
      geoPoint = new YMaps.GeoPoint(lastPoint.longitude, lastPoint.latitude)
      vehicleIcon = pointLink.data('icon')
      vehicleId = pointLink.data('id')

      lastPlacemark = pointLink.data('placemark')

      if lastPlacemark
        $(element).parent('li').append('<img src="' + image_path('icons/loading.gif') + '" class="inline-icon" width="16" height="16">')
        $.ajax({
          url: '/admin/vehicles/' + vehicleId + '/get_last_point',
          async: true
        }).done (data) ->
          $(element).parent('li').find('img:last-child').remove()

          if lastPlacemark
            map.removeOverlay(lastPlacemark)

          lastPoint.longitude = data.longitude
          lastPoint.latitude = data.latitude
          geoPoint = new YMaps.GeoPoint(lastPoint.longitude, lastPoint.latitude)

          renderPlacemark(map, pointLink, lastPoint, geoPoint, vehicleIcon, options)
      else
        renderPlacemark(map, pointLink, lastPoint, geoPoint, vehicleIcon, options)

    resizeMap()
    $(window).resize(resizeMap)
    map = createMap()
    map.setCenter(new YMaps.GeoPoint(82.933957, 55.007224), 12)

    $('.vehicles-list a.ico-vehicle').each (index, element) ->
      showLastPoint(this, map, { moveMap: false })
      $(element).on 'click', ->
        showLastPoint(this, map, { moveMap: true })

    $('a.ico-monitor').first().on 'click', ->
      onlineMonitoring = $(this).data('onlineMonitoring')
      onlineMonitoring = !onlineMonitoring
      $(this).data('onlineMonitoring', onlineMonitoring)
      if onlineMonitoring
        $(this).parent('li').append('<img src="' + image_path('icons/monitor.gif') + '" class="inline-icon" width="16" height="16">')
        timerId = setInterval ->
          $('.vehicles-list a.ico-vehicle').each (index, element) ->
            showLastPoint(this, map, { moveMap: false })
        , 10000
        $(this).data('timerId', timerId)
      else
        $(this).parent('li').find('img:last-child').remove()
        clearInterval($(this).data('timerId'))

  if $('body.vehicles.map').length > 0

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

      firstPointDescription = lastPointDescription = move.from_time + "<br/>" + move.to_time + "<br/>" + move.duration
      if move.from_location
        firstPointDescription += "<br/>" + move.from_location
      if move.to_location
        lastPointDescription += "<br/>" + move.to_location

      firstGeoPoint = new YMaps.GeoPoint(move.first_point.longitude, move.first_point.latitude)
      placemark = getPlacemark({
        map: map, title: move.title, description: firstPointDescription,
        geoPoint: firstGeoPoint, icon: 'flag_green', moveMap: false
      })
      overlays.push(placemark)

      lastGeoPoint = new YMaps.GeoPoint(move.last_point.longitude, move.last_point.latitude)
      placemark = getPlacemark({
        map: map, title: move.title, description: lastPointDescription,
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

      if move.from_location
        polyline.description += "<br/>" + move.from_location + "<br/>" + move.to_location

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
        description = move.from_time + "<br/>" + move.to_time + "<br/>" + move.duration + '<br/>' + move.from_location

        placemark = getPlacemark({
          map: map, title: move.title, description: description,
          geoPoint: geoPoint, icon: 'parking', moveMap: moveMap
        })
        placemark.openBalloon() if moveMap
        overlays.push(placemark)
        $(element).data('overlays', overlays)
      else
        renderMovementPoints(element, move, moveMap)

    updatePosition = (map, vehicleId) ->
      pointLink = $('a.ico-last-point').first()
      lastPoint = pointLink.data('info')
      lastPlacemark = pointLink.data('placemark')
      oldGeoPoint = new YMaps.GeoPoint(lastPoint.longitude, lastPoint.latitude)

      overlays = pointLink.data('overlays')
      overlays = [] unless overlays

      if lastPlacemark
        map.removeOverlay(lastPlacemark)

      $.ajax({
        url: '/admin/vehicles/' + vehicleId + '/get_last_point'
      }).done (data) ->
        lastPoint.longitude = data.longitude
        lastPoint.latitude = data.latitude
        newGeoPoint = new YMaps.GeoPoint(lastPoint.longitude, lastPoint.latitude)

        lastPlacemark = getPlacemark({
          map: map, title: lastPoint.title, description: lastPoint.description,
          geoPoint: newGeoPoint, bigIcon: vehicleIcon, moveMap: true
        })
        pointLink.data('placemark', lastPlacemark)

        polyline = new PolylineWithArrows([oldGeoPoint, newGeoPoint], { style: 'user#routeLine' })
        map.addOverlay(polyline)
        overlays.push(polyline)
        pointLink.data('overlays', overlays)

    resizeMap()
    $(window).resize(resizeMap)

    map = createMap()

    lastPointPlacemark = null

    if $('a.ico-last-point').length > 0
      pointLink = $('a.ico-last-point').first()
      lastPoint = pointLink.data('info')
      geoPoint = new YMaps.GeoPoint(lastPoint.longitude, lastPoint.latitude)
      map.setCenter(geoPoint, 12)

      if !pointLink.hasClass('ico-hidden')
        lastPointPlacemark = getPlacemark({
          map: map, title: lastPoint.title, description: lastPoint.description,
          geoPoint: geoPoint, bigIcon: vehicleIcon, moveMap: true
        })
        lastPointPlacemark.openBalloon()
    else
      # center of Novosibirsk
      map.setCenter(new YMaps.GeoPoint(82.933957, 55.007224), 12)

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

    $('a.ico-monitor').first().on 'click', ->
      onlineMonitoring = $(this).data('onlineMonitoring')
      onlineMonitoring = !onlineMonitoring
      $(this).data('onlineMonitoring', onlineMonitoring)
      if onlineMonitoring
        $(this).parent('li').append('<img src="' + image_path('icons/monitor.gif') + '" class="inline-icon" width="16" height="16">')
        map.setZoom(12)
        updatePosition(map, vehicleId)
        timerId = setInterval ->
          updatePosition(map, vehicleId)
        , 10000
        $(this).data('timerId', timerId)
      else
        $(this).parent('li').find('img:last-child').remove()
        clearInterval($(this).data('timerId'))
        overlays = $('a.ico-last-point').first().data('overlays')
        if overlays && overlays.length
          for overlay in overlays
            map.removeOverlay(overlay)
          $('a.ico-last-point').first().data('overlays', null)

    selectedMovementId = window.location.hash.substr(1)
    if selectedMovementId
      $('a[data-id="' + selectedMovementId + '"]').click()

  if $('body.vehicles.map').length > 0 or $('body.vehicles.day_report').length > 0

    $('#selectedDate').on 'custom:dateChanged', ->
      url = document.location.pathname
      url += '?date=' + $('#selectedDate').text()
      document.location = url

  if $('body.vehicles.reports').length > 0

    $('#reports-list').tablesorter({
      sortList: [[0, 1]],
      headers: {
        0: {
          sorter: 'text'
        }
      }
    })

  if $('body.vehicles.day_report').length > 0
    movementsChartData = []
    movementIdsMap = []
    activitiesChartData = []

    for index, range of movementRanges
      for i in [range[0]..range[1]]
        if (1 == range[2]) then movementsChartData[i] = 9 else movementsChartData[i] = 1
        movementIdsMap[i] = range[3]

    for i in [0...movementsChartData.length]
      movementsChartData[i] = 1 if 'undefined' == typeof movementsChartData[i]

    for index, range of activityRanges
      for i in [range[0]..range[1]]
        if (1 == range[2]) then activitiesChartData[i] = 4 else activitiesChartData[i] = 0

    for i in [0...activitiesChartData.length]
      activitiesChartData[i] = 0 if 'undefined' == typeof activitiesChartData[i]

    activityTitle = if activityRanges.length then jsLocaleKeys.activity_title else ''

    showMovementsChart = ->
      chart = new Highcharts.Chart({
        chart: {
          renderTo: 'movementsChart',
          type: 'area',
          zoomType: 'x',
          marginBottom: 25,
          marginLeft: 100
        },
        title: {
          text: ''
        },
        yAxis: {
          title: {
            text: null
          },
          max: 10,
          gridLineWidth: 0
          categories: ['', jsLocaleKeys.parking_title, '', '', '', activityTitle, '', '', '', jsLocaleKeys.movement_title, '']
        },
        xAxis: {
          labels: {
            formatter: ->
              this.value / 60
          },
          min: 0,
          max: 1440,
          tickInterval: 60,
          gridLineWidth: 1
        },
        plotOptions: {
          area: {
            lineWidth: 2,
            shadow: false,
            fillColor: {
              linearGradient: [0, 0, 0, 400],
              stops: [
                [0, 'rgba(240,240,240,0)'],
                [1, Highcharts.getOptions().colors[0]]
              ]
            },
            marker: {
              enabled: false,
              symbol: 'circle',
              states: {
                hover: {
                  enabled: true,
                  radius: 4,
                }
              }
            },
            states: {
              hover: {
                lineWidth: 2
              }
            }
          }
        }
        tooltip: {
          crosshairs: true,
          shared: true,
          formatter: ->
            hours = parseInt(this.x / 60)
            hours = if hours >= 10 then hours else ('0' + hours)
            minutes = this.x % 60
            minutes = if minutes >= 10 then minutes else ('0' + minutes)
            hours + ':' + minutes
        },
        legend: {
          enabled: false
        },
        credits: {
          enabled: false
        },
        series: [{
          data: movementsChartData,
          cursor: 'pointer',
          events: {
            click: (event) ->
              selectedMinute = event.point.category
              movementId = movementIdsMap[selectedMinute]
              document.location = document.location.href.replace('/day_report', '/map') + '#' + movementId
          }
        }, {
          data: activitiesChartData
        }]
      })

    showFuelChangesChart = ->
      chartData = fuelChartData

      chart = new Highcharts.Chart({
        chart: {
          renderTo: 'fuelChangesChart',
          type: 'area',
          zoomType: 'x',
          marginBottom: 25,
          marginLeft: 100
        },
        title: {
          text: ''
        },
        yAxis: {
          title: {
            text: null
          },
          min: 0,
          max: tankSize,
          startOnTick: false,
        },
        xAxis: {
          labels: {
            formatter: ->
              this.value / 60
          },
          min: 0,
          max: 1440,
          tickInterval: 60,
          gridLineWidth: 1,
          offset: 1
        },
        plotOptions: {
          area: {
            lineWidth: 2,
            shadow: false,
            fillColor: {
              linearGradient: [0, 0, 0, 400],
              stops: [
                [0, 'rgba(240,240,240,0)'],
                [1, Highcharts.getOptions().colors[0]],
              ]
            },
            marker: {
              enabled: false,
              symbol: 'circle',
              states: {
                hover: {
                  enabled: true,
                  radius: 4,
                }
              }
            },
            states: {
              hover: {
                lineWidth: 2
              }
            }
          }
        }
        tooltip: {
          crosshairs: true,
          shared: true,
          formatter: ->
            point = this.points[0]
            hours = parseInt(point.x / 60)
            hours = if hours >= 10 then hours else ('0' + hours)
            minutes = point.x % 60
            minutes = if minutes >= 10 then minutes else ('0' + minutes)
            hours + ':' + minutes + ' - ' + point.y
        },
        legend: {
          enabled: false
        },
        credits: {
          enabled: false
        },
        series: [{
          data: chartData
          cursor: 'pointer',
          events: {
            click: (event) ->
              selectedMinute = event.point.category
              movementId = movementIdsMap[selectedMinute]
              document.location = document.location.href.replace('/day_report', '/map') + '#' + movementId
          }
        }]
      })

    Highcharts.setOptions({
      lang: {
        resetZoom: jsLocaleKeys.reset_zoom,
        resetZoomTitle: jsLocaleKeys.reset_zoom_title
      }
    })

    showMovementsChart() if $('#movementsChart').length > 0
    showFuelChangesChart() if $('#fuelChangesChart').length > 0

    $('#movements-list').tablesorter({
      sortList: [[1, 0]]
    })
