map = null


class CustomOverlay
    constructor: ->
        @features = []

    add: (obj) ->
        @features.push new google.maps.Marker
            position: new google.maps.LatLng(obj.coordinates.reverse()...)
            title: obj.name

    show: ->
        feature.setMap(map) for feature in @features

    hide: ->
        feature.setMap(null) for feature in @features


restaurants = new CustomOverlay()
load_restaurants = ->
    $.getJSON 'src/restaurants.php', (json_data) ->
        restaurants.add(obj) for obj in json_data
        restaurants.show()


init_map = ->
    map = new google.maps.Map document.getElementById('map-canvas'),
        center: new google.maps.LatLng(18.7896457, 98.9939156)
        zoom: 13
        minZoom: 10
        maxZoom: 15
        mapTypeId: google.maps.MapTypeId.ROADMAP
        streetViewControl: false
    load_restaurants()

google.maps.event.addDomListener(window, 'load', init_map)
