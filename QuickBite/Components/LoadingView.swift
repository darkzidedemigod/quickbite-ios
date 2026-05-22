import UIKit
import SnapKit

final class LoadingView: UIView {

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemOrange
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.text = "Loading..."
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .systemBackground.withAlphaComponent(0.8)
        isHidden = true

        addSubview(activityIndicator)
        addSubview(messageLabel)

        activityIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-20)
        }

        messageLabel.snp.makeConstraints {
            $0.top.equalTo(activityIndicator.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    func startLoading(message: String = "Loading...") {
        messageLabel.text = message
        activityIndicator.startAnimating()
        isHidden = false
    }

    func stopLoading() {
        activityIndicator.stopAnimating()
        isHidden = true
    }
}