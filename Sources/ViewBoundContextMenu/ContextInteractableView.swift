import UIKit
import SwiftUI
import SwiftUIX

public class ContextInteractableView: UIView {
    
    var actions = [ContextAction]()
    
    var content: (() -> any View)? {
        didSet {
            configureHostingView()
        }
    }
    
    var preview: (() -> any View)?
    
    var previewShape: PreviewShape = .roundedRectangle(cornerRadius: 10)
    
    private var hostingView: UIHostingView<AnyView>?
    
    init() {
        super.init(frame: .zero)
        addInteraction(UIContextMenuInteraction(delegate: self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        hostingView?.intrinsicContentSize ?? .zero
    }
    
    public override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        hostingView?.sizeThatFits(targetSize) ?? .zero
    }
    
    public override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        hostingView?.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority) ?? .zero
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        hostingView?.sizeThatFits(size) ?? .zero
    }
}

private extension ContextInteractableView {
    func configureHostingView() {
        if let content = content?() {
            if hostingView == nil {
                hostingView = UIHostingView(rootView: AnyView(content))
                
                addSubview(hostingView!)
                
                hostingView!.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    hostingView!.leadingAnchor.constraint(equalTo: leadingAnchor),
                    hostingView!.trailingAnchor.constraint(equalTo: trailingAnchor),
                    hostingView!.topAnchor.constraint(equalTo: topAnchor),
                    hostingView!.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
            } else {
                hostingView?.rootView = AnyView(content)
            }
        } else {
            hostingView?.removeFromSuperview()
            hostingView = nil
        }
    }
}

extension ContextInteractableView: UIContextMenuInteractionDelegate {
    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(
            identifier: nil,
            previewProvider: {
                guard let preview = self.preview else { return nil }
                
                // 1. host your SwiftUI preview
                let host = UIHostingController(rootView: AnyView(preview()))
                host.view.backgroundColor = .clear
                
                // 2. force a layout pass so Auto‑Layout & SwiftUI have a chance to size everything
                host.view.setNeedsLayout()
                host.view.layoutIfNeeded()
                
                // 3. measure the “compressed” fitting size
                let targetSize = host.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                host.preferredContentSize = targetSize
                
                return host
            },
            actionProvider: { [weak self] _ in
                guard let self = self else { return nil }
                return UIMenu(
                    title: "",
                    children: self.actions.map(\.asMenuElement)
                )
            }
        )
    }
    
    // when the menu is about to appear, tell it to use a circle
    public func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration config: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        let params = UIPreviewParameters()
        // ovalIn: the hostingView’s bounds → perfect circle
        switch previewShape {
        case .circle:
            params.visiblePath = UIBezierPath(ovalIn: hostingView!.bounds)
        case .roundedRectangle(let radius):
            params.visiblePath = UIBezierPath(
                roundedRect: hostingView!.bounds,
                cornerRadius: radius
            )
        }
        return UITargetedPreview(view: hostingView!, parameters: params)
    }
    
    // same for the dismiss‑preview if you want consistency
    public func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForDismissingMenuWithConfiguration config: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        let params = UIPreviewParameters()
        switch previewShape {
        case .circle:
            params.visiblePath = UIBezierPath(ovalIn: hostingView!.bounds)
        case .roundedRectangle(let radius):
            params.visiblePath = UIBezierPath(
                roundedRect: hostingView!.bounds,
                cornerRadius: radius
            )
        }
        return UITargetedPreview(view: hostingView!, parameters: params)
    }
}

public enum PreviewShape {
    case circle
    case roundedRectangle(cornerRadius: CGFloat)
}

private extension ContextAction {
    var asMenuElement: UIMenuElement {
        if children.isEmpty {
            return UIAction(
                title: title,
                image: image,
                identifier: .init(identifier)
            ) { _ in
                action?()
            }
        } else {
            return UIMenu(
                title: title,
                image: image,
                identifier: .init(identifier),
                children: children.map(\.asMenuElement)
            )
        }
    }
}
