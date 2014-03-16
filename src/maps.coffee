map = null
info_window = new google.maps.InfoWindow()


google.maps.Polygon::getPosition = ->
    bounds = new google.maps.LatLngBounds()
    @getPath().forEach (points, _) -> bounds.extend(points)
    bounds.getCenter()


icon = (star=null) ->
    'https://chart.googleapis.com/chart?' +
        if star?
            'chst=d_map_xpin_icon&chld=pin_star|restaurant|0ff|ff0'
        else
            'chst=d_map_pin_icon&chld=restaurant|ac0'


class CustomOverlay
    constructor: (@get_data, @color, @neg_color, @star_icon) ->
        @features = []

    add: (obj) ->
        if obj.type == 'Point'
            marker = new google.maps.Marker
                gid: obj.gid
                title: obj.name
                url: "http://foursquare.com/v/#{obj.fsq_id}" if obj?.fsq_id
                chkins: obj?.chkins
                position: new google.maps.LatLng(obj.coords...)
                icon: icon(@star_icon)
                zIndex: if @star_icon? then 2 else 1
        else if obj.type == 'Polygon'
            marker = new google.maps.Polygon
                gid: obj.gid
                title: if obj?.name then obj.name else "Block ##{obj.gid}"
                paths: [new google.maps.LatLng(ll...) for ll in obj.coords[0]]
                people: obj?.people
                weight: obj?.weight
                strokeColor: if +obj?.weight < 0 then @neg_color else @color
                fillColor:   if +obj?.weight < 0 then @neg_color else @color
                strokeOpacity: 0.1                        if obj.weight?
                fillOpacity:   Math.abs(obj.weight / 1.1) if obj.weight?
                zIndex: if obj?.weight then 1 else 2
        @features.push(marker)
        google.maps.event.addListener marker, 'click', ->
            info_window.setContent $('<div>').html([
                $('<h3>').html(marker.title)
                $('<p>').html("weight: #{marker.weight}")    if marker.weight?
                $('<p>').html("check-ins: #{marker.chkins}") if marker.chkins?
                $('<p>').html("students: #{marker.people}")  if marker.people?
            ]).html()
            info_window.open(map, marker)

    load: (just_load=null, after=null) ->
        return unless @get_data?
        self = @
        $.getJSON 'overlay.php', @get_data, (json_data, _, meta_data) ->
            return if meta_data.status != 200
            self.add(obj) for obj in json_data
            self.show() unless just_load?
            after?()

    reload: (@get_data=@get_data, after=null) ->
        @empty()
        @load(null, after)

    empty: ->
        @hide()
        @features = []

    show: ->
        feature.setMap(map) for feature in @features

    hide: ->
        feature.setMap(null) for feature in @features

    toggle: (bool) ->
        if bool then @show() else @hide()


overlays =
    restaurants:  new CustomOverlay({t: 'restaurants'})
    obstacles:    new CustomOverlay({t: 'obstacles'}, '#333')
    universities: new CustomOverlay({t: 'universities'}, '#009')
    search:       new CustomOverlay(null, '#0aa', '#a0a', true)

heatmaps =
    land_rates:   new CustomOverlay({t: 'land_rates'}, '#0a0', '#aa0')
    rest_density: new CustomOverlay({t: 'rest_density'}, '#900')
    univ_density: new CustomOverlay({t: 'univ_density'}, '#00a')


google.maps.event.addDomListener window, 'load', ->
    map = new google.maps.Map document.getElementById('map-canvas'),
        center: new google.maps.LatLng(18.7896457, 98.9939156)
        zoom: 13
        minZoom: 12
        maxZoom: 17
        mapTypeId: google.maps.MapTypeId.ROADMAP
    overlay.load() for key, overlay of overlays
    heatmap.load(key.match(/.*_density/)) for key, heatmap of heatmaps


show_search_result = ->
    $('#search-result ol').empty()
    for feature in overlays.search.features
        lat = feature.getPosition().lat()
        lng = feature.getPosition().lng()
        search_item_title = feature.title
        search_item_title += ", weight #{feature.weight}" if feature?.weight
        $('#search-result ol').append $('<li>').html [
            $('<a>').attr('href', feature?.url)
                    .attr('target', '_blank')
                    .html($('<b>').html(search_item_title))
            $('<br>')
            $('<span>').addClass('unimportant')
                       .addClass('find-me')
                       .data('latlng', [lat, lng])
                       .html("@ #{lat.toFixed(8)}, #{lng.toFixed(8)}")
        ]
    $('.find-me').click ->
        map.panTo(new google.maps.LatLng($(@).data('latlng')...))
        map.setZoom(17)
    $('#search-dialog').show()


$(document).keydown (event) ->
    if event.which == 27 # esc
        if $('#search-box:focus').length
            $('#search-box').blur()
        else
            info_window.close()

$(document).keypress (event) ->
    unless $('#search-box:focus').length
        if event.which == 47 # /
            $('#search-box').focus()
            event.preventDefault()


$(document).ready ->
    $('.prehide').hide()
    $('#search-box').focus()

    $('#search-box').keydown (event) ->
        $('#search').click() if event.keyCode == 13 # enter

    $('#search').click ->
        get_data =
            t: 'restaurants'
            namelike: $('#search-box').val()
        overlays.search.reload(get_data, show_search_result)

    $('#advance').click ->
        $('#advance-search').toggle()

    $('#density-search').click ->
        get_data =
            t: $('input:radio[name=density-type]:checked').val()
            lower: $('#density-lower').val()
            upper: $('#density-upper').val()
        $('#layer-selector input:radio[value=none]').click()
        heatmap.hide() for _, heatmap of heatmaps
        overlays.search.reload(get_data, show_search_result)

    $('#layers').click ->
        $('#layer-selector').toggle()

    $('#layer-selector input:checkbox').click ->
        overlays[this.value].toggle(this.checked)

    $('#layer-selector input:radio').click ->
        heatmap.hide() for _, heatmap of heatmaps
        heatmaps[$('input:radio[name=heatmap]:checked').val()]?.show()

    $('.close').click ->
        $(this).parent().hide()

    $('#search-dialog .close').click ->
        overlays.search.hide()
