import UIKit
import SnapKit

final class LoginViewController: UIViewController {

    private let viewModel = LoginViewModel()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "QuickBite"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .systemOrange
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover delicious meals"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()

    private let emailTextField: CustomTextField = {
        let textField = CustomTextField(
            icon: UIImage(systemName: "envelope"),
            placeholder: "Email"
        )
        textField.keyboardType = .emailAddress
        return textField
    }()

    private let passwordTextField: CustomTextField = {
        let textField = CustomTextField(
            icon: UIImage(systemName: "lock"),
            placeholder: "Password",
            isSecure: true
        )
        return textField
    }()

    private let loginButton: PrimaryButton = {
        let button = PrimaryButton(title: "Login")
        button.isEnabled = false
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        setupActions()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(stackView)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(errorLabel)
        view.addSubview(loginButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(60)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        emailTextField.snp.makeConstraints {
            $0.height.equalTo(50)
        }

        passwordTextField.snp.makeConstraints {
            $0.height.equalTo(50)
        }

        loginButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
    }

    private func setupBindings() {
        viewModel.state.bind { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .idle:
                self.loginButton.hideLoading()
                self.errorLabel.isHidden = true
            case .loading:
                self.loginButton.showLoading()
                self.errorLabel.isHidden = true
            case .success:
                self.loginButton.hideLoading()
                self.navigateToMain()
            case .error(let message):
                self.loginButton.hideLoading()
                self.errorLabel.text = message
                self.errorLabel.isHidden = false
                self.loginButton.setErrorState()
            }
        }

        viewModel.isValid.bind { [weak self] isValid in
            self?.loginButton.isEnabled = isValid
        }
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)

        emailTextField.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: nil)
        )
        passwordTextField.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: nil)
        )
    }

    @objc private func loginButtonTapped() {
        viewModel.updateEmail(emailTextField.text ?? "")
        viewModel.updatePassword(passwordTextField.text ?? "")
        viewModel.login()
    }

    private func navigateToMain() {
        let tabBarController = MainTabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
}