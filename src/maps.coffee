map = null

class CustomOverlay
    constructor: (@json_script, @color) ->
        @features = []

    add: (obj) ->
        if obj.type == 'Point'
            @features.push new google.maps.Marker
                position: new google.maps.LatLng(obj.coords...)
                title: obj.name
        else if obj.type == 'Polygon'
            @features.push new google.maps.Polygon
                paths: [new google.maps.LatLng(ll...) for ll in obj.coords[0]]
                title: obj.name
                strokeColor: @color
                fillColor: @color
                strokeOpacity: 0.1            if obj.weight?
                fillOpacity: obj.weight / 400 if obj.weight? # TODO
                zIndex: if obj.weight? then 1 else 2

    load: ->
        self = @
        $.getJSON @json_script, (json_data) ->
            self.add(obj) for obj in json_data
            self.show()

    show: ->
        feature.setMap(map) for feature in @features

    hide: ->
        feature.setMap(null) for feature in @features

    toggle: (bool) ->
        if bool then @show() else @hide()


overlays =
    restaurants:  new CustomOverlay('src/restaurants.php')
    obstacles:    new CustomOverlay('src/obstacles.php', '#333')
    universities: new CustomOverlay('src/universities.php', '#009')
    heatmap:      new CustomOverlay('src/heatmap.php', '#090')


google.maps.event.addDomListener window, 'load', ->
    map = new google.maps.Map document.getElementById('map-canvas'),
        center: new google.maps.LatLng(18.7896457, 98.9939156)
        zoom: 13
        minZoom: 12
        maxZoom: 17
        mapTypeId: google.maps.MapTypeId.ROADMAP
        streetViewControl: false
    overlay.load() for _, overlay of overlays


$(document).ready ->
    $('.prehide').hide()

    $('#search').click ->
        # TODO do searching and fill result
        $('#search-result').show()

    $('#advance').click ->
        # TODO do searching and fill result
        $('#advance-search').show()

    $('#layers').click ->
        $('#layer-selector').show()

    $('#layer-selector input[type=checkbox]').click ->
        overlays[this.value].toggle(this.checked)

    $('.close').click ->
        $(this).parent().hide()
