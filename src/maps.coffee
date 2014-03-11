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


restaurants = new CustomOverlay('src/restaurants.php')
obstacles = new CustomOverlay('src/obstacles.php', '#333')
universities = new CustomOverlay('src/universities.php', '#009')


init_map = ->
    map = new google.maps.Map document.getElementById('map-canvas'),
        center: new google.maps.LatLng(18.7896457, 98.9939156)
        zoom: 13
        minZoom: 10
        maxZoom: 15
        mapTypeId: google.maps.MapTypeId.ROADMAP
        streetViewControl: false
    restaurants.load()
    obstacles.load()
    universities.load()

google.maps.event.addDomListener(window, 'load', init_map)


$(document).ready ->
    $('#layer-selector').hide()

    $('#layers').click ->
        $('#layer-selector').toggle()

    $('#layer-selector input[type=checkbox]').click ->
        mapper = {restaurants, obstacles, universities}
        mapper[this.value.split('-')[1]].toggle(this.checked)
