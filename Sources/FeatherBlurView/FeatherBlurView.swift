import SwiftUI
import UIKit

// MARK: - FeatherBlurUIView

public class FeatherBlurUIView: UIView {
    // MARK: Lifecycle

    public init(radius: CGFloat = 4, startPoint: UnitPoint = .top, endPoint: UnitPoint = .bottom) {
        super.init(frame: .zero)

        let selectorString = ["filter", "With", "Type", ":"].joined()
        let selector = Selector(selectorString)
        guard let filterClass = NSClassFromString(["CA", "Filter"].joined()) as? NSObject.Type,
              filterClass.responds(to: selector),
              let variableBlur = filterClass.perform(selector, with: "variableBlur").takeUnretainedValue() as? NSObject
        else {
            return
        }

        guard let mask = ImageRenderer(
            content: Rectangle()
                .fill(LinearGradient(colors: [.clear, .black], startPoint: startPoint, endPoint: endPoint))
                .frame(width: 100, height: 100)
        ).cgImage else { return }

        variableBlur.setValue(radius, forKey: "inputRadius")
        variableBlur.setValue(mask, forKey: "inputMaskImage")
        variableBlur.setValue(true, forKey: "inputNormalizeEdges")

        layer.filters = [variableBlur]
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    override public class var layerClass: AnyClass {
        NSClassFromString(["CA", "Backdrop", "Layer"].joined()) ?? CALayer.self
    }
}

// MARK: - FeatherBlurView

public struct FeatherBlurView: UIViewRepresentable {
    // MARK: Lifecycle

    public init(radius: CGFloat = 4, startPoint: UnitPoint = .top, endPoint: UnitPoint = .bottom) {
        self.radius = radius
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    // MARK: Public

    public typealias UIViewType = FeatherBlurUIView

    public func makeUIView(context _: Context) -> FeatherBlurUIView {
        FeatherBlurUIView(radius: radius, startPoint: startPoint, endPoint: endPoint)
    }

    public func updateUIView(_: FeatherBlurUIView, context _: Context) {}

    // MARK: Internal

    let radius: CGFloat
    let startPoint: UnitPoint
    let endPoint: UnitPoint
}

#Preview {
    ZStack {
        AsyncImage(url: URL(string: "https://w.wiki/6opG")) { image in
            image.resizable().aspectRatio(1, contentMode: .fill)
        } placeholder: { ProgressView() }
        FeatherBlurView()
    }.ignoresSafeArea()
}
