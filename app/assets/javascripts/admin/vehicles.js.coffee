$ ->

  # center of Novosibirsk
  defaultMapCenter = [55.00, 82.93]

  createMap = ->
    map = new ymaps.Map('map-canvas', {
      center: defaultMapCenter,
      zoom: 12,
      type: 'yandex#publicMap'
    })
    map.controls.add('typeSelector')
    map.controls.add('mapTools')
    map.controls.add('zoomControl')
    map.controls.add(new ymaps.control.SearchControl({
      provider: 'yandex#map',  useMapBounds: true
    }))

    if $('body.vehicles.overview_map').length > 0
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
      lastPointPlacemark = null

      if $('a.ico-last-point').length > 0
        pointLink = $('a.ico-last-point').first()
        lastPoint = pointLink.data('info')
        geoPoint = [lastPoint.latitude, lastPoint.longitude]
        map.setCenter(geoPoint, 12)

        if !pointLink.hasClass('ico-hidden')
          lastPointPlacemark = getPlacemark({
            map: map, title: lastPoint.title, description: lastPoint.description,
            geoPoint: geoPoint, bigIcon: vehicleIcon, moveMap: true
          })
          lastPointPlacemark.balloon.open()

      $('.movements-list a.movement-info').each (index, element) ->
        $(element).on 'click', ->
          showMovement(map, this)

      $('a.ico-show-all').first().on 'click', ->
        $('.movements-list a.movement-info').each (index, element) ->
          showMovement(map, element, 'show', false)

      $('a.ico-hide-all').first().on 'click', ->
        $('.movements-list a.movement-info').each (index, element) ->
          showMovement(map, element, 'hide')

      $('a.ico-last-point').first().on 'click', ->
        lastPoint = $(this).data('info')
        map.setCenter([lastPoint.latitude, lastPoint.longitude])
        lastPointPlacemark.balloon.open()

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
              map.geoObjects.remove(overlay)
            $('a.ico-last-point').first().data('overlays', null)

      selectedMovementId = window.location.hash.substr(1)
      if selectedMovementId
        $('a[data-id="' + selectedMovementId + '"]').click()

  resizeControls = ->
    mapHeight = if ($(window).width() < 768) then $(window).height() else ($(window).height() - $('#map-canvas').offset().top - 25)
    $('#map-canvas').height(mapHeight)
    if ($(window).width() > 768)
      menuHeight = $(window).height() - $('.sidebar-nav').offset().top - 45
      if $('.movements-list').length
        adjustSidebarHeight($('.movements-list'))
      if $('.vehicles-list').length
        adjustSidebarHeight($('.vehicles-list'))

  adjustSidebarHeight = (element) ->
    originalHeight = element.height()
    newHeight = $(window).height() - $(element).offset().top - 105
    if originalHeight > newHeight
      element.height(newHeight)

  getRouteLineStyle = ->
    {
      strokeColor: "0000FFA5",
      strokeWidth: 4
    }

  getIconStyle = (image) ->
    {
      iconImageHref: image_path(image),
      iconImageSize: [16, 16],
      iconImageOffset: [0, -16],
      hideIconOnBalloonOpen: false
    }

  getBigIconStyle = (image) ->
    {
      iconImageHref: image_path(image),
      iconImageSize: [48, 48],
      iconImageOffset: [-24, -24],
      hideIconOnBalloonOpen: false
    }

  getPlacemark = (config) ->
    if config.bigIcon
      icon = config.bigIcon
      iconStyle = getBigIconStyle('icons/' + icon + '.png')
    else
      icon = config.icon
      iconStyle = getIconStyle('icons/' + icon + '.png')

    content = {}
    content.balloonContent = config.title || ''
    content.balloonContent = '<b>' + content.balloonContent + '</b>' if content.balloonContent
    if content.balloonContent and config.link
      content.balloonContent = '<a href="' + config.link + '">' + content.balloonContent + '</a>'
    if config.description
      content.balloonContent += '<br>' + config.description

    placemark = new ymaps.Placemark(config.geoPoint, content, iconStyle)
    config.map.geoObjects.add(placemark)
    config.map.setCenter(config.geoPoint, 18) if config.moveMap
    placemark

  if $('body.vehicles.overview_map').length > 0

    renderPlacemark = (map, pointLink, lastPoint, geoPoint, vehicleIcon, options) ->
      lastPlacemark = getPlacemark({
        map: map, title: lastPoint.title, description: lastPoint.description,
        geoPoint: geoPoint, bigIcon: vehicleIcon, moveMap: options.moveMap, link: lastPoint.link
      })
      pointLink.data('placemark', lastPlacemark)
      lastPlacemark.balloon.open() if options.moveMap

    showLastPoint = (element, map, options) ->
      pointLink = $(element).first()
      lastPoint = pointLink.data('info')
      geoPoint = [lastPoint.latitude, lastPoint.longitude]
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
            map.geoObjects.remove(lastPlacemark)

          lastPoint.longitude = data.longitude
          lastPoint.latitude = data.latitude
          geoPoint = [lastPoint.latitude, lastPoint.longitude]

          renderPlacemark(map, pointLink, lastPoint, geoPoint, vehicleIcon, options)
      else
        renderPlacemark(map, pointLink, lastPoint, geoPoint, vehicleIcon, options)

    resizeControls()
    $(window).resize(resizeControls)
    ymaps.ready(createMap)

  if $('body.vehicles.map').length > 0

    loadMovementPoints = (map, element, move, moveMap) ->
      $(element).parent('li').append('<img src="' + image_path('icons/loading.gif') + '" class="inline-icon" width="16" height="16">')
      $.ajax({
        url: '/admin/vehicles/' + move.vehicle_id + '/get_movement_points?movement_id=' + move.movement_id,
        async: true
      }).done (data) ->
        $(element).parent('li').find('img:last-child').remove()
        move.points = data
        renderMovementPoints(map, element, move, moveMap)

    renderMovementPoints = (map, element, move, moveMap) ->
      overlays = []

      firstPointDescription = lastPointDescription = move.from_time + "<br/>" + move.to_time + "<br/>" + move.duration
      if move.from_location
        firstPointDescription += "<br/>" + move.from_location
      if move.to_location
        lastPointDescription += "<br/>" + move.to_location

      firstGeoPoint = [move.first_point.latitude, move.first_point.longitude]
      placemark = getPlacemark({
        map: map, title: move.title, description: firstPointDescription,
        geoPoint: firstGeoPoint, icon: 'flag_green', moveMap: false
      })
      overlays.push(placemark)

      lastGeoPoint = [move.last_point.latitude, move.last_point.longitude]
      placemark = getPlacemark({
        map: map, title: move.title, description: lastPointDescription,
        geoPoint: lastGeoPoint, icon: 'flag_finish', moveMap: false
      })
      overlays.push(placemark)

      mapPoints = []
      $(move.points).each (index, point) ->
        geoPoint = [point[0], point[1]]
        geoPoint.description = jsLocaleKeys.time.replace('%time%', point[2]) + '<br>' + jsLocaleKeys.speed.replace('%speed%', point[3])
        mapPoints.push(geoPoint)

      balloonContent = '<b>' + move.title + '</b><br/>'
      balloonContent += move.from_time + "<br/>" + move.to_time + "<br/>" + move.duration + "<br/>" + move.distance

      if move.from_location
        balloonContent += "<br/>" + move.from_location + "<br/>" + move.to_location

      polyline = new ymaps.Polyline(mapPoints, { balloonContent: balloonContent }, getRouteLineStyle())

      map.geoObjects.add(polyline)
      if moveMap
        if move.from_location
          bounds = getAreaBounds([firstGeoPoint, lastGeoPoint])
          map.setBounds(bounds)
        else
          map.setCenter(firstGeoPoint)
        polyline.balloon.open()
      overlays.push(polyline)

      $(element).data('overlays', overlays)

    getAreaBounds = (points) ->
      south = points[0][0]
      west = points[0][1]
      north = points[0][0]
      east = points[0][1]

      for index, point of points
        if south < point[0]
          south = point[0]
        if north > point[0]
          north = point[0]
        if west > point[1]
          west = point[1]
        if east < point[1]
          east = point[1]

      [[south, west], [north, east]]

    showMovement = (map, element, state, moveMap = true) ->
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
          map.geoObjects.remove(overlay)
        $(element).data('overlays', null)
        return

      return if 'hide' == state

      move = $(element).data('info')

      if !move.parking && 0 == move.points.length
        $(element).data('overlays', null)
        loadMovementPoints(map, element, move, moveMap)
        return

      if move.parking
        point = move.first_point
        geoPoint = [point.latitude, point.longitude]
        description = move.from_time + "<br/>" + move.to_time + "<br/>" + move.duration + '<br/>' + move.from_location

        placemark = getPlacemark({
          map: map, title: move.title, description: description,
          geoPoint: geoPoint, icon: 'parking', moveMap: moveMap
        })
        placemark.balloon.open() if moveMap
        overlays.push(placemark)
        $(element).data('overlays', overlays)
      else
        renderMovementPoints(map, element, move, moveMap)

    updatePosition = (map, vehicleId) ->
      pointLink = $('a.ico-last-point').first()
      lastPoint = pointLink.data('info')
      lastPlacemark = pointLink.data('placemark')
      oldGeoPoint = [lastPoint.latitude, lastPoint.longitude]

      overlays = pointLink.data('overlays')
      overlays = [] unless overlays

      if lastPlacemark
        map.geoObjects.remove(lastPlacemark)

      $.ajax({
        url: '/admin/vehicles/' + vehicleId + '/get_last_point'
      }).done (data) ->
        lastPoint.longitude = data.longitude
        lastPoint.latitude = data.latitude
        newGeoPoint = [lastPoint.latitude, lastPoint.longitude]

        lastPlacemark = getPlacemark({
          map: map, title: lastPoint.title, description: lastPoint.description,
          geoPoint: newGeoPoint, bigIcon: vehicleIcon, moveMap: true
        })
        pointLink.data('placemark', lastPlacemark)

        polyline = new PolylineWithArrows([oldGeoPoint, newGeoPoint], { style: 'user#routeLine' })
        map.geoObjects.add(polyline)
        overlays.push(polyline)
        pointLink.data('overlays', overlays)

    resizeControls()
    $(window).resize(resizeControls)
    ymaps.ready(createMap)


  if $.grep(['waybill', 'map', 'day_report'], (item) ->
    return $('body.vehicles.' + item).length > 0;
  ).length > 0

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
