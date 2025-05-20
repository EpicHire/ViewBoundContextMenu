import UIKit

public struct ContextAction {
    
    let identifier: String
    let title: String
    let image: UIImage?
    let action: (() -> ())?
    let children: [ContextAction]
    
    public init(
        identifier: String,
        title: String,
        image: UIImage? = nil,
        children: [ContextAction] = [],
        action: (() -> ())? = nil
    ) {
        self.identifier = identifier
        self.title = title
        self.image = image
        self.action = action
        self.children = children
    }
}
