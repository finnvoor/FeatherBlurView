import SwiftUI
import UIKit

public class FeatherBlurUIView: UIView {
    override public class var layerClass: AnyClass {
        NSClassFromString(["CA", "Backdrop", "Layer"].joined()) ?? CALayer.self
    }

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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public struct FeatherBlurView: UIViewRepresentable {
    public typealias UIViewType = FeatherBlurUIView

    let radius: CGFloat
    let startPoint: UnitPoint
    let endPoint: UnitPoint

    public init(radius: CGFloat = 4, startPoint: UnitPoint = .top, endPoint: UnitPoint = .bottom) {
        self.radius = radius
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    public func makeUIView(context _: Context) -> FeatherBlurUIView {
        FeatherBlurUIView(radius: radius, startPoint: startPoint, endPoint: endPoint)
    }

    public func updateUIView(_: FeatherBlurUIView, context _: Context) {}
}

#Preview {
    ZStack {
        AsyncImage(url: URL(string: "https://w.wiki/6opG")) { image in
            image.resizable().aspectRatio(1, contentMode: .fill)
        } placeholder: { ProgressView() }
        VStack {
            Spacer()
            FeatherBlurView().frame(height: 400)
        }
    }.ignoresSafeArea()
}
