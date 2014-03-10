map = null

init_map = ->
    map = new google.maps.Map document.getElementById('map-canvas'),
        center: new google.maps.LatLng(18.7896457, 98.9939156)
        zoom: 13
        minZoom: 10
        maxZoom: 15
        mapTypeId: google.maps.MapTypeId.ROADMAP
        streetViewControl: false

google.maps.event.addDomListener(window, 'load', init_map)
