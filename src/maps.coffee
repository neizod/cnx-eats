map = null

class CustomOverlay
    constructor: (@json_script, @color, @neg_color) ->
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
                strokeColor: if obj?.weight < 0 then @neg_color else @color
                fillColor:   if obj?.weight < 0 then @neg_color else @color
                strokeOpacity: 0.1                        if obj.weight?
                fillOpacity:   Math.abs(obj.weight / 100) if obj.weight?
                zIndex: if obj.weight? then 1 else 2

    load: (just_load=null, after=null) ->
        return unless @json_script?
        self = @
        $.getJSON @json_script, (json_data) ->
            self.add(obj) for obj in json_data
            self.show() unless just_load?
            after?()

    reload: (@json_script=@json_script, after=null) ->
        @empty()
        @load(false, after)

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
    restaurants:  new CustomOverlay('overlay.php?t=restaurants')
    obstacles:    new CustomOverlay('overlay.php?t=obstacles', '#333')
    universities: new CustomOverlay('overlay.php?t=universities', '#009')
    search:       new CustomOverlay(null) # TODO pick color for it

heatmaps =
    rates:        new CustomOverlay('overlay.php?t=sample_heat', '#0a0', '#aa0')
    rest_density: new CustomOverlay('overlay.php?t=rest_density', '#900')
    univ_density: new CustomOverlay('overlay.php?t=univ_density', '#00a')


google.maps.event.addDomListener window, 'load', ->
    map = new google.maps.Map document.getElementById('map-canvas'),
        center: new google.maps.LatLng(18.7896457, 98.9939156)
        zoom: 13
        minZoom: 12
        maxZoom: 17
        mapTypeId: google.maps.MapTypeId.ROADMAP
    overlay.load() for key, overlay of overlays
    heatmap.load(key.match(/.*_density/)) for key, heatmap of heatmaps


$(document).ready ->
    $('.prehide').hide()
    $('#search-box').focus()

    $('#search-box').keydown (event) ->
        $('#search').click() if event.keyCode == 13

    $('#search').click ->
        name = encodeURIComponent($('#search-box').val())
        overlays.search.reload "overlay.php?t=restaurants&namelike=#{name}", ->
            $('#search-result ol').empty()
            for feature in overlays.search.features
                lat = feature.position.lat()
                lng = feature.position.lng()
                $('#search-result ol').append $('<li>').html [
                    $('<b>').addClass('find-me')
                            .data('latlng', [lat, lng])
                            .html(feature.title)
                    $('<br>')
                    $('<span>').addClass('unimportant')
                               .html("@ #{lat}, #{lng}")
                ]
            $('.find-me').click ->
                map.panTo(new google.maps.LatLng($(@).data('latlng')...))
                map.setZoom(17)
            $('#search-dialog').show()

    $('#advance').click ->
        # TODO do searching and fill result
        $('#advance-search').toggle()

    $('#layers').click ->
        $('#layer-selector').toggle()

    $('#layer-selector input:checkbox').click ->
        overlays[this.value].toggle(this.checked)

    $('#layer-selector input:radio').click ->
        heatmap.hide() for _, heatmap of heatmaps
        heatmaps[$('input:radio[name=heatmap]:checked').val()]?.show()

    $('.close').click ->
        $(this).parent().hide()
