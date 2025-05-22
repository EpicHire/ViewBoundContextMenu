import SwiftUI

struct ContextualListItemViewModifier: ViewModifier {
    
    let actions: [ContextAction]
    var preview: (() -> any View)?
    var previewShape: PreviewShape
    
    func body(content: Content) -> some View {
        ViewBoundContextMenu(
            actions: actions,
            content: { AnyView(content) },
            preview: preview,
            previewShape: previewShape
        )
        .fixedSize()
    }
}

public extension View {
    func viewBoundContextMenu(
        actions: [ContextAction],
        preview: (() -> any View)? = nil,
        previewShape: PreviewShape = .roundedRectangle(cornerRadius: 10)
    ) -> some View {
        self.modifier(
            ContextualListItemViewModifier(
                actions: actions,
                preview: preview,
                previewShape: previewShape
            )
        )
    }
}
