import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var gifKeyboardHeight: NSLayoutConstraint!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var gifKeyboardView: UIView!
    @IBOutlet weak var resultImage: UIImageView!

    private var listConfig: GIFFrame!
    private var keyboardConfig: GIFFrame!
    private let _gifKeyboardHeight: CGFloat = 350

    override func viewDidLoad() {
        super.viewDidLoad()
        listConfig = GIFFrame(apiKey: "")
        keyboardConfig = GIFFrame(apiKey: "")

        textfield.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @IBAction func presentFramework(_ sender: UIButton) {
        present(fullGifList, animated: true, completion: nil)
    }

    @IBAction func gifKeyboard(_ sender: UIButton) {
        guard gifKeyboardHeight.constant <= 0 else {
            hideGifKeyboard()
            return
        }
        showGifKeyboard()
    }

    private lazy var fullGifList: UINavigationController = {
        let vc = listConfig.controller()
        listConfig.onCellSelect = { [weak self] gif in
            guard let url = URL.init(string: gif) else { return }
            self?.resultImage.kf.setImage(with: url)
            self?.dismiss(animated: true, completion: nil)
        }
        return vc
    }()

    private lazy var gifKB: UINavigationController = {
        var fullScreen = false
        let vc = keyboardConfig.controller()
        keyboardConfig.onCellSelect = { [weak self] gif in
            self?.hideGifKeyboard()
            guard let url = URL.init(string: gif) else { return }
            self?.resultImage.kf.setImage(with: url)
        }
        keyboardConfig.onSearchBarTouch = { [weak self] in
            guard self?.presentingViewController == nil, let listVC = self?.fullGifList else { return }
            self?.view.endEditing(true)
            self?.hideGifKeyboard()
            self?.present(listVC, animated: true, completion: nil)
        }
        return vc
    }()

    private func showGifKeyboard() {
        view.endEditing(true)
        gifKB.view.frame = CGRect(x: 0, y: 0, width: gifKeyboardView.frame.width, height: _gifKeyboardHeight)
        addChild(gifKB)
        gifKeyboardView.addSubview(gifKB.view)
        didMove(toParent: self)
        gifKeyboardHeight.constant = _gifKeyboardHeight
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
        }
    }

    private func hideGifKeyboard() {
        for view in gifKeyboardView.subviews{
            view.removeFromSuperview()
        }
        gifKeyboardHeight.constant = 0
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillChange(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            bottomConstraint.constant = -keyboardHeight
            if (gifKeyboardHeight.constant > 0) {
                hideGifKeyboard()
            }
            view.layoutSubviews()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
