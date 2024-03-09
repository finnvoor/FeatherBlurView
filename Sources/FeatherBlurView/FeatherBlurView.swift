import CoreImage.CIFilterBuiltins
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

        let gradient = CIFilter.smoothLinearGradient()
        gradient.color0 = .clear
        gradient.color1 = .black
        gradient.point0 = CGPoint(
            x: endPoint.x * 100,
            y: endPoint.y * 100
        )
        gradient.point1 = CGPoint(
            x: startPoint.x * 100,
            y: startPoint.y * 100
        )

        let mask = Self.context.createCGImage(
            startPoint == endPoint ? .black : gradient.outputImage!.clampedToExtent(),
            from: CGRect(
                origin: .zero,
                size: CGSize(width: 100, height: 100)
            )
        )

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

    // MARK: Private

    private static let context = CIContext()
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
