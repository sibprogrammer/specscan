$ ->

  searchActionDelay = 200
  timer = null
  enterPressed = false
  searchField = $('.navbar-search > input')

  scheduleSearch =  ->
    if (timer)
      clearTimeout(timer)
    timer = setTimeout(findTerm, searchActionDelay)

  findTerm = ->
    term = searchField.val()

    if '' == term
      resetSearch()
      return

    $.ajax({
      url: '/admin/search',
      data: { term: term }
    }).done (content) ->
      $('.search-results').show()
      $('.search-results').html(content)

  resetSearch = ->
    if (timer)
      clearTimeout(timer)
    $('.search-results').hide()

  # focus search on S key
  $(document.body).on 'keydown', (event) ->
    if 83 == event.which && !searchField.is(':focus')
      searchField.focus()
      event.preventDefault()

  searchField.on 'keyup', (event) ->
    if ([13, 37, 38, 39, 40].indexOf(event.which) != -1)
      return

    scheduleSearch()

  searchField.on 'keydown', (event) ->
    enterPressed = (13 == event.which)
    if enterPressed
      scheduleSearch()

  $(document.body).on 'click', (event) ->
    resetSearch()

  $('form.navbar-search').on 'submit', ->
    return false
