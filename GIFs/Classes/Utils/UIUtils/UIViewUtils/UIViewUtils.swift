import UIKit

extension UIView {

    private var sideConstraint: CGFloat {
        return 16
    }

    private var expandedViewCornerRadius: CGFloat {
        return 10
    }

    private var collapsedViewCornerRadius: CGFloat {
        return 5
    }

    private var imageContainerFreeSpace: CGFloat {
        return 148
    }

    private func getHeight(windowFrame: CGRect, aspectRatio: Double) -> CGFloat {
        let width = windowFrame.width - sideConstraint * 2
        return CGFloat(aspectRatio) * (width - 16)
    }
}
