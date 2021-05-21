import Kingfisher

final class GIFCell: UICollectionViewCell {

    private var imageView: UIImageView!

    private let options: [KingfisherOptionsInfoItem] = [.scaleFactor(UIScreen.main.scale/2)]

    func configure(url: URL?) {
        imageView = UIImageView()
        addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true

        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url, options: options)
    }
}
