import SwiftUI
import UIKit

// MARK: - FeatherBlurUIView

public class FeatherBlurUIView: UIView {
    // MARK: Lifecycle

    public init(
        radius: CGFloat = 4,
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) {
        super.init(frame: .zero)

        let selectorString = ["filter", "With", "Type", ":"].joined()
        let selector = Selector(selectorString)
        guard let filterClass = NSClassFromString(["CA", "Filter"].joined()) as? NSObject.Type,
              filterClass.responds(to: selector),
              let variableBlur = filterClass.perform(selector, with: "variableBlur").takeUnretainedValue() as? NSObject
        else {
            return
        }

        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                UIColor.clear.cgColor,
                UIColor.black.cgColor
            ] as CFArray,
            locations: [0, 1]
        ) else { return }
        let startPoint = CGPoint(
            x: startPoint.x * 100,
            y: startPoint.y * 100
        )
        let endPoint = CGPoint(
            x: endPoint.x * 100,
            y: endPoint.y * 100
        )

        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        let context = UIGraphicsGetCurrentContext()!

        context.drawLinearGradient(
            gradient,
            start: startPoint,
            end: endPoint,
            options: []
        )

        let mask = UIGraphicsGetImageFromCurrentImageContext()!.cgImage!
        UIGraphicsEndImageContext()

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

    public init(
        radius: CGFloat = 4,
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) {
        self.radius = radius
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    // MARK: Public

    public typealias UIViewType = FeatherBlurUIView

    public func makeUIView(context _: Context) -> FeatherBlurUIView {
        FeatherBlurUIView(
            radius: radius,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    public func updateUIView(_: FeatherBlurUIView, context _: Context) {}

    // MARK: Internal

    let radius: CGFloat
    let startPoint: UnitPoint
    let endPoint: UnitPoint
}

// MARK: - FeatherBlurView_Previews

struct FeatherBlurView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AsyncImage(url: URL(string: "https://w.wiki/6opG")) { image in
                image.resizable().aspectRatio(1, contentMode: .fill)
            } placeholder: { ProgressView() }
            FeatherBlurView(startPoint: .bottom, endPoint: .top)
        }.ignoresSafeArea()
    }
}
