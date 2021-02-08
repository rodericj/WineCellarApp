import MapboxMaps

class MapboxMapView: MapboxMaps.MapView, ObservableObject {
    
    init() {
        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1Ijoicm9kZXJpYyIsImEiOiJja2t2ajNtMXMxZjdjMm9wNmYyZHR1ZWN3In0.mM6CghYW2Uil53LD5uQrGw")
        super.init(with: .zero, resourceOptions: myResourceOptions)
        style.styleURL = StyleURL.custom(url: URL(string: "mapbox://styles/roderic/ckkuobvtp14p117rxa87f2b32")!)
    }
    
    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

