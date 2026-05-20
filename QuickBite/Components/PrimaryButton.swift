import UIKit
import SnapKit

final class PrimaryButton: UIButton {

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var originalTitle: String?

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }

    init(title: String) {
        super.init(frame: .zero)
        originalTitle = title
        setupView(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(title: String) {
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        backgroundColor = .systemOrange
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        layer.cornerRadius = 12
        clipsToBounds = true

        addSubview(loadingIndicator)

        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        snp.makeConstraints {
            $0.height.equalTo(50)
        }
    }

    func showLoading() {
        originalTitle = title(for: .normal)
        setTitle("", for: .normal)
        loadingIndicator.startAnimating()
        isEnabled = false
    }

    func hideLoading() {
        setTitle(originalTitle, for: .normal)
        loadingIndicator.stopAnimating()
        isEnabled = true
    }

    func setErrorState() {
        backgroundColor = .systemRed
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = .systemOrange
        }
    }
}