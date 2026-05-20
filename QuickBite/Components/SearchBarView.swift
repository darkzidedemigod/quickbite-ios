import UIKit
import SnapKit

protocol SearchBarViewDelegate: AnyObject {
    func searchBarDidChange(query: String)
}

final class SearchBarView: UIView {

    weak var delegate: SearchBarViewDelegate?

    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search meals..."
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .search
        textField.clearButtonMode = .whileEditing
        return textField
    }()

    private let searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        return imageView
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()

    private var searchWorkItem: DispatchWorkItem?

    init() {
        super.init(frame: .zero)
        setupView()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(searchIconImageView)
        containerView.addSubview(searchTextField)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(44)
        }

        searchIconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        searchTextField.snp.makeConstraints {
            $0.leading.equalTo(searchIconImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
        }
    }

    private func setupActions() {
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        searchTextField.delegate = self
    }

    @objc private func textFieldDidChange() {
        searchWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self, let query = self.searchTextField.text else { return }
            self.delegate?.searchBarDidChange(query: query)
        }

        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }

    func clear() {
        searchTextField.text = ""
        delegate?.searchBarDidChange(query: "")
    }
}

// MARK: - UITextFieldDelegate
extension SearchBarView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let query = textField.text else { return true }
        delegate?.searchBarDidChange(query: query)
        return true
    }
}