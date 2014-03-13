map = null


google.maps.Polygon::getPosition = ->
    bounds = new google.maps.LatLngBounds()
    @getPath().forEach (points, _) -> bounds.extend(points)
    bounds.getCenter()


class CustomOverlay
    constructor: (@get_data, @color, @neg_color) ->
        @features = []

    add: (obj) ->
        if obj.type == 'Point'
            @features.push new google.maps.Marker
                gid: obj.gid
                title: obj.name
                position: new google.maps.LatLng(obj.coords...)
        else if obj.type == 'Polygon'
            @features.push new google.maps.Polygon
                gid: obj.gid
                title: obj.name
                paths: [new google.maps.LatLng(ll...) for ll in obj.coords[0]]
                strokeColor: if obj?.weight < 0 then @neg_color else @color
                fillColor:   if obj?.weight < 0 then @neg_color else @color
                strokeOpacity: 0.1                        if obj.weight?
                fillOpacity:   Math.abs(obj.weight / 100) if obj.weight?
                zIndex: if obj.weight? then 1 else 2

    load: (just_load=null, after=null) ->
        return unless @get_data?
        self = @
        $.getJSON 'overlay.php', @get_data, (json_data) ->
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
    search:       new CustomOverlay(null, '#a0a', '#00a') # TODO repick color

heatmaps =
    rates:        new CustomOverlay({t: 'sample_heat'}, '#0a0', '#aa0')
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
        $('#search-result ol').append $('<li>').html [
            $('<b>').addClass('find-me')
                    .data('latlng', [lat, lng])
                    .html(feature.title or "Block ID #{feature.gid}")
            $('<br>')
            $('<span>').addClass('unimportant')
                       .html("@ #{lat}, #{lng}")
        ]
    $('.find-me').click ->
        map.panTo(new google.maps.LatLng($(@).data('latlng')...))
        map.setZoom(17)
    $('#search-dialog').show()


$(document).ready ->
    $('.prehide').hide()
    $('#search-box').focus()

    $('#search-box').keydown (event) ->
        $('#search').click() if event.keyCode == 13

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
