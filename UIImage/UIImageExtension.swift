extension UIImage {
    /// 根据给定的大小和圆角半径，生成圆角图片。
    /// - Parameters:
    ///   - size: 当最终生成的图片大小
    ///   - radius: 最终生成的图片的圆角
    /// - Returns: 成功最返回生成的图片，失败则返回自身
    public func imageWithCornerRadius(size: CGSize, radius: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
        context?.addPath(path.cgPath)
        context?.clip()
        draw(in: rect)
        context?.drawPath(using: .fillStroke)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? self
    }
}
