import MapboxMaps
import SwiftUI

class MapBoxMapCoordinator: NSObject, ObservableObject {
    
}

struct MapboxMapBasedViewRepresentable: UIViewRepresentable {
    
    let mapView: MapboxMaps.MapView
    @Binding var selectedMapType: MapTypeSelection
    @EnvironmentObject var dataStore: DataStore

    func makeUIView(context: Context) -> MapboxMaps.MapView {
//        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MapboxMaps.MapView, context: Context) {
//        context.coordinator.updateMapType(selection: selectedMapType)
    }

    func makeCoordinator() -> MapBoxMapCoordinator {
        return MapBoxMapCoordinator()
//        return Coordinator(self, mapView: mapView, dataStore: dataStore)
    }
    
}
