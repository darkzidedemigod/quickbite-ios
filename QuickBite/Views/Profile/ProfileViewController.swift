import UIKit
import SnapKit

final class ProfileViewController: UIViewController {

    private let viewModel = ProfileViewModel()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()

    private let themeLabel: UILabel = {
        let label = UILabel()
        label.text = "Theme Settings"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    private let themeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Theme customization coming soon."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray2
        return label
    }()

    private let logoutButton: PrimaryButton = {
        let button = PrimaryButton(title: "Logout")
        button.backgroundColor = .systemRed
        return button
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        setupActions()
        viewModel.checkUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        viewModel.checkUser()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Profile"

        view.addSubview(stackView)
        stackView.addArrangedSubview(avatarImageView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(themeLabel)
        stackView.addArrangedSubview(themeDescriptionLabel)
        stackView.addArrangedSubview(logoutButton)

        avatarImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        logoutButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
    }

    private func setupBindings() {
        viewModel.state.bind { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .loggedIn(let user):
                self.nameLabel.text = user.name
                self.emailLabel.text = user.email
            case .loggedOut:
                self.dismissToLogin()
            }
        }
    }

    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }

    @objc private func logoutButtonTapped() {
        let alertController = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.viewModel.logout()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        present(alertController, animated: true)
    }

    private func dismissToLogin() {
        dismiss(animated: true) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            let loginVC = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginVC)
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
}