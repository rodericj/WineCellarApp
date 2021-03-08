import CoreSpotlight
import MobileCoreServices
import UIKit
import WineRegionLib


extension Array where Element == RegionJson {
    public func storeInCoreSpotlight() {
        var items: [CSSearchableItem] = []
        forEach { region in
            items.append(contentsOf: region.searchableItems())
        }
        CSSearchableIndex.default().indexSearchableItems(items) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                print("Items indexed \(items.count)")
            }
        }
    }
}

extension RegionJson {
    func findRegion(with id: UUID) -> RegionJson? {
        if self.id == id {
            return self
        }
        var iterator = children?.makeIterator()
        if let nextRegion = iterator?.next() {
            if let matchingChildRegion = nextRegion.findRegion(with: id) {
                return matchingChildRegion
            }
        }
        return nil
    }
}

private extension RegionJson {
    
    func searchableItems() -> [CSSearchableItem] {
        var ret: [CSSearchableItem?] = []
        let childrenSearchableItems = children?.map { $0.searchableItems() }.reduce([], +)
        ret.append(contentsOf: childrenSearchableItems ?? [])
        ret.append(individualSearchableItem())
        return ret.compactMap { $0 }
    }
    
    func individualSearchableItem() -> CSSearchableItem {
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributes.title = title
        attributes.contentDescription = String(format: LocalizedText.Region.Spotlight.contentDescrption, title)
        attributes.thumbnailData = UIImage(systemName: "map")?.pngData()
        return CSSearchableItem(uniqueIdentifier: id.uuidString, domainIdentifier: "io.thumbworks", attributeSet: attributes)
    }
}

struct LocalizedText {
    struct Region {
        struct Spotlight {
            static let contentDescrption = NSLocalizedString("The great wines of the %@ region.", comment: "The formatted string that appears in spotlight search for a specific region")
        }
    }
}
