import UIKit
import SnapKit

final class RegisterViewController: UIViewController {

    private let viewModel = RegisterViewModel()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .systemOrange
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Save favorites and meal ideas"
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

    private let firstNameTextField = CustomTextField(
        icon: UIImage(systemName: "person"),
        placeholder: "First Name"
    )

    private let lastNameTextField = CustomTextField(
        icon: UIImage(systemName: "person"),
        placeholder: "Last Name"
    )

    private let passwordTextField = CustomTextField(
        icon: UIImage(systemName: "lock"),
        placeholder: "Password",
        isSecure: true
    )

    private let registerButton: PrimaryButton = {
        let button = PrimaryButton(title: "Register")
        button.isEnabled = false
        return button
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Already have an account? Login", for: .normal)
        button.setTitleColor(.systemOrange, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
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
        title = "Register"

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(stackView)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(firstNameTextField)
        stackView.addArrangedSubview(lastNameTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(errorLabel)
        view.addSubview(registerButton)
        view.addSubview(loginButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        [emailTextField, firstNameTextField, lastNameTextField, passwordTextField].forEach { textField in
            textField.snp.makeConstraints {
                $0.height.equalTo(50)
            }
        }

        registerButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }

        loginButton.snp.makeConstraints {
            $0.top.equalTo(registerButton.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }

    private func setupBindings() {
        viewModel.state.bind { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .idle:
                self.registerButton.hideLoading()
                self.errorLabel.isHidden = true
            case .loading:
                self.registerButton.showLoading()
                self.errorLabel.isHidden = true
            case .success:
                self.registerButton.hideLoading()
                self.navigateToMain()
            case .error(let message):
                self.registerButton.hideLoading()
                self.errorLabel.text = message
                self.errorLabel.isHidden = false
                self.registerButton.setErrorState()
            }
        }

        viewModel.isValid.bind { [weak self] isValid in
            self?.registerButton.isEnabled = isValid
        }
    }

    private func setupActions() {
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)

        [emailTextField, firstNameTextField, lastNameTextField, passwordTextField].forEach { textField in
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }

    @objc private func textFieldDidChange() {
        updateViewModelFields()
    }

    @objc private func registerButtonTapped() {
        updateViewModelFields()
        viewModel.register()
    }

    private func updateViewModelFields() {
        viewModel.updateEmail(emailTextField.text ?? "")
        viewModel.updateFirstName(firstNameTextField.text ?? "")
        viewModel.updateLastName(lastNameTextField.text ?? "")
        viewModel.updatePassword(passwordTextField.text ?? "")
    }

    @objc private func loginButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func navigateToMain() {
        let tabBarController = MainTabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
}
