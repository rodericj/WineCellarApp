import MapboxMaps
import SwiftUI

class MapBoxMapCoordinator: NSObject, ObservableObject {
    
}

struct MapboxMapBasedViewRepresentable: UIViewRepresentable {
    
    let mapView: MapboxMaps.MapView
    @Binding var selectedMapType: MapTypeSelection
    
    @EnvironmentObject var dataStore: DataStore

    func makeUIView(context: Context) -> MapboxMaps.MapView {
        mapView.cameraManager.setCamera(centerCoordinate: dataStore.region.center,
                                        zoom: dataStore.mapZoom)
        return mapView
    }

    func updateUIView(_ mapView: MapboxMaps.MapView, context: Context) {
        print("update mapbox view for some reason")
    }

    func makeCoordinator() -> MapBoxMapCoordinator {
        return MapBoxMapCoordinator()
    }
    
}
