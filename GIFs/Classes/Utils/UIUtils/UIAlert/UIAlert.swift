import Kingfisher

extension UIViewController {
    public func showError(_ error: Error) {
        let alert = UIAlertController(title: "error_title".localized(),
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok_button".localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
