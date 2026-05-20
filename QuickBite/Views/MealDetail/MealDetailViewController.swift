import UIKit
import SnapKit

final class MealDetailViewController: UIViewController {

    private let viewModel = MealDetailViewModel()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    private let mealImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        return imageView
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .systemRed
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private let ingredientsLabel: UILabel = {
        let label = UILabel()
        label.text = "Ingredients"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    private let ingredientsTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .systemGray
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        return textView
    }()

    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Instructions"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    private let instructionsTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .systemGray
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        return textView
    }()

    private let loadingView = LoadingView()

    init(meal: Meal) {
        super.init(nibName: nil, bundle: nil)
        viewModel.configure(with: meal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        setupActions()
        populateData()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Meal Details"

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(mealImageView)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ingredientsLabel)
        contentView.addSubview(ingredientsTextView)
        contentView.addSubview(instructionsLabel)
        contentView.addSubview(instructionsTextView)
        view.addSubview(loadingView)

        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        mealImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }

        favoriteButton.snp.makeConstraints {
            $0.trailing.equalTo(mealImageView).offset(-20)
            $0.bottom.equalTo(mealImageView).offset(25)
            $0.width.height.equalTo(50)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(mealImageView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        ingredientsLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        ingredientsTextView.snp.makeConstraints {
            $0.top.equalTo(ingredientsLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        instructionsLabel.snp.makeConstraints {
            $0.top.equalTo(ingredientsTextView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        instructionsTextView.snp.makeConstraints {
            $0.top.equalTo(instructionsLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }

        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupBindings() {
        viewModel.isFavorite.bind { [weak self] isFavorite in
            self?.favoriteButton.isSelected = isFavorite
        }
    }

    private func setupActions() {
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }

    private func populateData() {
        guard let meal = viewModel.meal.value else { return }

        titleLabel.text = meal.name

        // Load image
        if let url = URL(string: meal.thumbnailURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let self = self,
                      let data = data,
                      let image = UIImage(data: data),
                      error == nil else { return }

                DispatchQueue.main.async {
                    self.mealImageView.image = image
                }
            }.resume()
        }

        // Populate ingredients
        if let ingredients = meal.ingredients, !ingredients.isEmpty {
            let ingredientsText = ingredients.map { "• \($0.name) - \($0.measure)" }.joined(separator: "\n")
            ingredientsTextView.text = ingredientsText
        } else {
            ingredientsTextView.text = "No ingredients available."
        }

        // Populate instructions
        if let instructions = meal.instructions, !instructions.isEmpty {
            instructionsTextView.text = instructions
        } else {
            instructionsTextView.text = "No instructions available."
        }
    }

    @objc private func favoriteButtonTapped() {
        viewModel.toggleFavorite()
    }
}