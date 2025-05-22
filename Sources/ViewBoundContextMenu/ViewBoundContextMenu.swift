import SwiftUI
import UIKit

public struct ViewBoundContextMenu: UIViewRepresentable {
    
    var actions: [ContextAction]
    var content: () -> any View
    var preview: (() -> any View)?
    var previewShape: PreviewShape
    
    init(
        actions: [ContextAction] = [],
        content: @escaping () -> any View,
        preview: (() -> any View)? = nil,
        previewShape: PreviewShape
    ) {
        self.actions = actions
        self.content = content
        self.preview = preview
        self.previewShape = previewShape
    }
    
    public func makeUIView(context: Context) -> ContextInteractableView {
        let view = ContextInteractableView()
        view.actions = actions
        view.content = content
        view.preview = preview
        view.previewShape = previewShape
        
        return view
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.actions = actions
        uiView.content = content
        uiView.preview = preview
        uiView.previewShape = previewShape
    }
}

#Preview {
    Text("Hello")
        .viewBoundContextMenu(
            actions: [
                .init(identifier: "Hi", title: "Hello")
            ],
            preview: {
                Text("hey!")
                    .frame(height: 40)
            }
        )
}
