import MapboxMaps
import Combine
import MapKit // for MKGeoJSONDecoder()
import Turf // for FeatureCollection


extension MapboxMapView: CameraViewDelegate {
    func cameraViewManipulated(for cameraView: CameraView) {
        print("the camera view changed \(cameraView.visibleCoordinateBounds)")
        
        let bounds = cameraView.visibleCoordinateBounds
        let latDelta = bounds.northeast.latitude - bounds.southwest.latitude
        let lonDelta = bounds.northeast.longitude - bounds.southwest.longitude
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        dataStore.region = MKCoordinateRegion(center: cameraView.centerCoordinate, span: span)
        dataStore.mapZoom = cameraView.zoom
    }
}

class MapboxMapView: MapboxMaps.MapView, ObservableObject {
    
    // We need to use WineMapType
    public enum MapStyle: Hashable {
        public enum TerrainExaggeration: Int {
            case realistic
            case doubled
            case quadrupled
        }
        case topo(TerrainExaggeration)
        case hillShader(TerrainExaggeration)
        
        var url: URL {
            let urlString: String
            switch self {
            case .hillShader(let exaggeration):
                switch exaggeration {
                case .realistic:
                    urlString = "mapbox://styles/roderic/cklt0q3fv1zp418p72ci8fd2n"
                case .doubled:
                    urlString = "mapbox://styles/roderic/ckkz10f4v0aos17jtqk3gnqpw"
                case .quadrupled:
                    urlString = "mapbox://styles/roderic/cklt0gs331zo417ozobmeh4i1"
                }
            case .topo(let exaggeration):
                switch exaggeration {
                
                case .realistic:
                    urlString = "mapbox://styles/roderic/cklt1452v206317o2py1tbby0"
                case .doubled:
                    urlString = "mapbox://styles/roderic/ckkuobvtp14p117rxa87f2b32"
                case .quadrupled:
                    urlString = "mapbox://styles/roderic/cklt16pgx0sxz17o1hjzs1fmi"
                }
            }
            return URL(string: urlString)!

        }
    }
    
    var dataStore: WineRegionProviding
    var cancellables: [AnyCancellable] = []
    
    init(dataStore: DataStore) {
        
        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1Ijoicm9kZXJpYyIsImEiOiJja2t2ajNtMXMxZjdjMm9wNmYyZHR1ZWN3In0.mM6CghYW2Uil53LD5uQrGw")
        self.dataStore = dataStore
        super.init(with: .zero, resourceOptions: myResourceOptions)
        
        self.cameraView.delegate = self
        style.styleURL = StyleURL.custom(url: MapStyle.hillShader(.realistic).url)
        
        dataStore.$selectedMapType
            .receive(on: DispatchQueue.main)
            .sink { _ in
            debugPrint("completed")
        } receiveValue: { [weak self] mapType in
            switch mapType {
            
            case .MapBox(let mapBoxType):
                self?.style.styleURL = StyleURL.custom(url: mapBoxType.url)
            default:
                break
            }
        }.store(in: &cancellables)
        
        dataStore.wineRegionLib.$regionMapsData
            .receive(on: DispatchQueue.main)
            .sink { _ in
            debugPrint("completed")
        } receiveValue: { mapMappingData in
            switch mapMappingData {

            case .regions(let mapArrayOfData):
                mapArrayOfData.forEach { [weak self] data in
                    var geoJSONSource = GeoJSONSource()
                    do {
                        let parsedFeature = try GeoJSON.parse(FeatureCollection.self, from: data)
                        geoJSONSource.data = .featureCollection(parsedFeature)
                        self?.showRegion(featurecollection: parsedFeature)
                    } catch {
                        print("unable to get the feature \(error).")
                        return
                    }

                    let geoJSONDataSourceIdentifier = "geoJSON-data-source"
                    self?.removeStyleLayer(layerID: "fill-layer")
                    self?.removeSource(sourceID: geoJSONDataSourceIdentifier)
                  
                    // Add the source and style layers to the map style.
                    self?.addSource(source: geoJSONSource, sourceIdentifier: geoJSONDataSourceIdentifier)
                    self?.addLayer(sourceIdentifier: geoJSONDataSourceIdentifier)
                }
            default:
                break

            }
        }.store(in: &cancellables)
        
        on(.cameraDidChange) { event in
            print("camera changed \(event)")
            print(self.cameraView.camera)
        }
        
        on(.sourceChanged) { [weak self] event in
            print("the source changed. update the camera?")
            self?.cameraView.zoom = dataStore.mapZoom
        }
        
        on(.styleLoadingFinished) { style in
            // The below line is used for internal testing purposes only.
            print("done loading style \(style)")
        }
    }
    
    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


private extension MapboxMapView {
    private func removeSource(sourceID: String) {
        let removeSourceResult = style.removeSource(for: sourceID)
        switch removeSourceResult {
        case .success(let successBool):
            print("Did succeed removing source \(successBool)")
        case .failure(let error):
            print("Error removing source \(error)")
        }
    }
    
    private func removeStyleLayer(layerID: String) {
        let removeStyleLayerResult = style.removeStyleLayer(forLayerId: layerID)
        switch removeStyleLayerResult {
        case .success(let successBool):
            print("Did succeed removing layer \(successBool)")
        case .failure(let error):
            print("Error removing style layer \(error)")
        }

    }
    private func showRegion(featurecollection: FeatureCollection) {
        if let geometry = featurecollection.features.first?.geometry {
            switch geometry {
            case .multiPolygon, .polygon:
                let cameraShowingPolygon = self.cameraManager.camera(fitting: geometry)
                let newBounds = self.cameraManager.coordinateBounds(for: cameraShowingPolygon)
                let currentBounds = cameraView.visibleCoordinateBounds
                
                let unionNorthEastLat = currentBounds.northeast.latitude > newBounds.northeast.latitude ? currentBounds.northeast.latitude : newBounds.northeast.latitude
                let unionNorthEastLon = currentBounds.northeast.longitude < newBounds.northeast.longitude ? currentBounds.northeast.longitude : newBounds.northeast.longitude
                let unionSouthWestLat = currentBounds.southwest.latitude < newBounds.southwest.latitude ? currentBounds.southwest.latitude : newBounds.southwest.latitude
                let unionSouthWestLon = currentBounds.southwest.longitude > newBounds.southwest.longitude ? currentBounds.southwest.longitude : newBounds.southwest.longitude
                
                
                let unionBounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: unionSouthWestLat, longitude: unionSouthWestLon),
                                                   northeast: CLLocationCoordinate2D(latitude: unionNorthEastLat, longitude: unionNorthEastLon))
                // Animate to unionBounds first
                // Animate to newBounds second

                print("animate to \(unionBounds)")
                let cam = self.cameraManager.camera(for: unionBounds)
                cameraManager.setCamera(to: cam,
                                        animated: true,
                                        duration: 2.0) { completed in
                    let finalCamera = self.cameraManager.camera(for: newBounds)
                    print("now animate to \(finalCamera)")
                    self.cameraManager.setCamera(to: finalCamera, animated: true, duration: 2, completion: nil)
                }
            
            default:
                print("not a polygon or multipolygon")
                break
            }
        }
    }
    
    private func addSource(source: GeoJSONSource, sourceIdentifier: String) {
        let addSourceResult = self.style.addSource(source: source, identifier: sourceIdentifier)
        switch addSourceResult {
        case .success(let successBool):
            print("Did succeed adding source \(successBool)")
        case .failure(let error):
            print("Error adding source \(error)")
        }
    }
    
    private func addLayer(sourceIdentifier: String) {
        var polygonLayer = FillLayer(id: "fill-layer")
        polygonLayer.filter = Exp(.eq) {
            "$type"
            "Polygon"
        }
        polygonLayer.source = sourceIdentifier
        polygonLayer.paint?.fillColor = .constant(ColorRepresentable(color: UIColor.green))
        polygonLayer.paint?.fillOpacity = .constant(0.3)
        polygonLayer.paint?.fillOutlineColor = .constant(ColorRepresentable(color: UIColor.purple))
        let addLayerResponse = style.addLayer(layer: polygonLayer, layerPosition: nil)
        switch addLayerResponse {
        case .success(let successBool):
            print("Did succeed adding layer \(successBool)")
        case .failure(let error):
            print("Error adding layer \(error)")
        }
    }
}
