import SwiftUI

struct ContextualListItemViewModifier: ViewModifier {
    
    let actions: [ContextAction]
    var preview: (() -> any View)?
    
    func body(content: Content) -> some View {
        ViewBoundContextMenu(
            actions: actions,
            content: { AnyView(content) },
            preview: preview
        )
        .fixedSize()
    }
}

public extension View {
    func viewBoundContextMenu(actions: [ContextAction], preview: (() -> any View)? = nil) -> some View {
        self.modifier(ContextualListItemViewModifier(actions: actions, preview: preview))
    }
}
