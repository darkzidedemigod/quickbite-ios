import UIKit
import SnapKit

protocol MealCardViewDelegate: AnyObject {
    func mealCardDidTapFavorite(mealID: String)
}

final class MealCardView: UIView {

    weak var delegate: MealCardViewDelegate?

    private let mealImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 12
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .white
        return button
    }()

    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        gradient.locations = [0.5, 1.0]
        return gradient
    }()

    private var mealID: String = ""
    private var currentImageURL: String = ""

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        layer.cornerRadius = 12
        clipsToBounds = true

        addSubview(mealImageView)
        mealImageView.layer.addSublayer(gradientLayer)
        addSubview(titleLabel)
        addSubview(favoriteButton)

        mealImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().offset(-16)
        }

        favoriteButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }

        snp.makeConstraints {
            $0.height.equalTo(200)
        }

        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }

    func configure(with meal: Meal, isFavorite: Bool) {
        mealID = meal.id
        titleLabel.text = meal.name
        favoriteButton.isSelected = isFavorite
        favoriteButton.tintColor = isFavorite ? .systemRed : .white

        if let url = URL(string: meal.thumbnailURL) {
            currentImageURL = meal.thumbnailURL
            loadImage(from: url)
        }
    }

    func configureCategory(with category: MealCategory) {
        mealID = category.idCategory
        titleLabel.text = category.strCategory
        favoriteButton.isHidden = true

        if let url = URL(string: category.strCategoryThumb) {
            currentImageURL = category.strCategoryThumb
            loadImage(from: url)
        }
    }

    private func loadImage(from url: URL) {
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

    @objc private func favoriteButtonTapped() {
        favoriteButton.isSelected.toggle()
        favoriteButton.tintColor = favoriteButton.isSelected ? .systemRed : .white
        delegate?.mealCardDidTapFavorite(mealID: mealID)
    }
}