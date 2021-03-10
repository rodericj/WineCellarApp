import Combine
import MapboxMaps
import OSLog
import Turf // for FeatureCollection

extension MapboxMapView: CameraViewDelegate {
    func cameraViewManipulated(for cameraView: CameraView) {
        dataStore.mapZoom = cameraView.zoom
    }
}

class MapboxMapView: MapboxMaps.MapView, ObservableObject {
    
    // We need to use WineMapType
    public enum MapStyle: Hashable {
        public enum TerrainExaggeration: String, CustomStringConvertible {
            public var description: String {
                switch self {
                case .realistic:
                    return ""
                case .doubled:
                    return "2x"
                }
            }
            
            case realistic
            case doubled
            
        }
        case topo(TerrainExaggeration)
        case hillShader(TerrainExaggeration)
        case satellite(TerrainExaggeration)

        var url: URL {
            let urlString: String
            switch self {
            case .satellite(let exaggeration):
                switch exaggeration {
                case .realistic:
                    urlString = "mapbox://styles/roderic/cklt2u3s921wd17r1kbb0sa7g"
                case .doubled:
                    urlString = "mapbox://styles/roderic/cklt354jn00sy17qhn3b7srzd"
                }
            case .hillShader(let exaggeration):
                switch exaggeration {
                case .realistic:
                    urlString = "mapbox://styles/roderic/cklt0q3fv1zp418p72ci8fd2n"
                case .doubled:
                    urlString = "mapbox://styles/roderic/ckkz10f4v0aos17jtqk3gnqpw"
                }
            case .topo(let exaggeration):
                switch exaggeration {
                case .realistic:
                    urlString = "mapbox://styles/roderic/cklt1452v206317o2py1tbby0"
                case .doubled:
                    urlString = "mapbox://styles/roderic/ckkuobvtp14p117rxa87f2b32"
                }
            }
            return URL(string: urlString)!
        }
    }
    
    var dataStore: WineRegionProviding
    var cancellables: [AnyCancellable] = []
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MapboxMapView")

    init(dataStore: DataStore) {
        
        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1Ijoicm9kZXJpYyIsImEiOiJja2t2ajNtMXMxZjdjMm9wNmYyZHR1ZWN3In0.mM6CghYW2Uil53LD5uQrGw")
        self.dataStore = dataStore
        super.init(with: .zero, resourceOptions: myResourceOptions)
        
        self.cameraView.delegate = self
        style.styleURL = StyleURL.custom(url: MapStyle.hillShader(.realistic).url)
        
        dataStore.$selectedMapType
            .combineLatest(dataStore.$selectedExaggerationLevel)
            .map {style, exaggeration -> MapStyle in
                switch style {
                case .topo(_):
                    return MapStyle.topo(exaggeration)
                case .hillShader(_):
                    return MapStyle.hillShader(exaggeration)
                case .satellite(_):
                    return MapStyle.satellite(exaggeration)
                }
            }.map { $0.url }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.logger.debug("completed")
        } receiveValue: { [weak self] url in
            self?.style.styleURL = StyleURL.custom(url: url)
        }.store(in: &cancellables)
        
        dataStore.wineRegionLib.$regionMapsData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.logger.debug("completed")
        } receiveValue: { [weak self] mapMappingData in
            switch mapMappingData {

            case .regions(let mapArrayOfData):
                self?.addRegion(mapArrayOfData: mapArrayOfData)
            default:
                break

            }
        }.store(in: &cancellables)

        on(.sourceChanged) { [weak self] event in
            self?.cameraView.zoom = dataStore.mapZoom
        }
        
        on(.styleLoadingFinished) { [weak self] style in
            // The below line is used for internal testing purposes only.
            self?.logger.debug("done loading style \(style)")
            switch dataStore.wineRegionLib.regionMapsData {
            case .regions(let mapArrayOfData):
                self?.addRegion(mapArrayOfData: mapArrayOfData)
            default:
                break
            }
        }
    }
    
    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MapboxMapView {
    private func addRegion(mapArrayOfData: [Data]) {
        mapArrayOfData.forEach { [weak self] data in
            var geoJSONSource = GeoJSONSource()
            do {
                let parsedFeature = try GeoJSON.parse(FeatureCollection.self, from: data)
                geoJSONSource.data = .featureCollection(parsedFeature)
                self?.showRegion(featurecollection: parsedFeature)
            } catch {
                self?.logger.error("unable to get the feature \(error as NSObject).")
                return
            }

            let geoJSONDataSourceIdentifier = "geoJSON-data-source"
            self?.removeStyleLayer(layerID: "fill-layer")
            self?.removeSource(sourceID: geoJSONDataSourceIdentifier)
          
            // Add the source and style layers to the map style.
            self?.addSource(source: geoJSONSource, sourceIdentifier: geoJSONDataSourceIdentifier)
            self?.addLayer(sourceIdentifier: geoJSONDataSourceIdentifier)
        }
    }
    private func removeSource(sourceID: String) {
        let removeSourceResult = style.removeSource(for: sourceID)
        switch removeSourceResult {
        case .success(let successBool):
            logger.debug("Did succeed removing source \(successBool)")
        case .failure(let error):
            logger.error("Error removing source \(error as NSObject)")
        }
    }
    
    private func removeStyleLayer(layerID: String) {
        let removeStyleLayerResult = style.removeStyleLayer(forLayerId: layerID)
        switch removeStyleLayerResult {
        case .success(let successBool):
            logger.debug("Did succeed removing layer \(successBool)")
        case .failure(let error):
            logger.error("Error removing style layer \(error as NSObject)")
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
                let cam = self.cameraManager.camera(for: unionBounds)
                cameraManager.setCamera(to: cam,
                                        animated: true,
                                        duration: 2.0) { completed in
                    let finalCamera = self.cameraManager.camera(for: newBounds)
                    self.cameraManager.setCamera(to: finalCamera, animated: true, duration: 2, completion: nil)
                }
            
            default:
                logger.debug("not a polygon or multipolygon")
                break
            }
        }
    }
    
    private func addSource(source: GeoJSONSource, sourceIdentifier: String) {
        let addSourceResult = self.style.addSource(source: source, identifier: sourceIdentifier)
        switch addSourceResult {
        case .success(let successBool):
            logger.debug("Did succeed adding source \(successBool)")
        case .failure(let error):
            logger.error("Error adding source \(error as NSObject)")
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
            logger.debug("Did succeed adding layer \(successBool)")
        case .failure(let error):
            logger.error("Error adding layer \(error as NSObject)")
        }
    }
}
