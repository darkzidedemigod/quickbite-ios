import UIKit
import SnapKit

final class FavoritesViewController: UIViewController {

    private let viewModel = FavoritesViewModel()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FavoriteMealCell.self, forCellWithReuseIdentifier: FavoriteMealCell.identifier)
        return collectionView
    }()

    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.configure(
            image: UIImage(systemName: "heart.slash"),
            title: "No favorites yet",
            subtitle: "Start adding meals to your favorites!"
        )
        return view
    }()

    private var meals: [Meal] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        viewModel.fetchFavorites()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Favorites"

        view.addSubview(collectionView)
        view.addSubview(emptyStateView)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        emptyStateView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.height.equalTo(200)
        }
    }

    private func setupBindings() {
        viewModel.state.bind { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .loading:
                break
            case .success(let meals):
                self.meals = meals
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
                self.emptyStateView.isHidden = true
            case .empty:
                self.meals = []
                self.collectionView.reloadData()
                self.collectionView.isHidden = true
                self.emptyStateView.isHidden = false
            }
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return meals.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavoriteMealCell.identifier,
            for: indexPath
        ) as? FavoriteMealCell else {
            return UICollectionViewCell()
        }

        let meal = meals[indexPath.item]
        cell.configure(with: meal)
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let meal = meals[indexPath.item]
        let detailVC = MealDetailViewController(meal: meal)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.frame.width - 56) / 2
        return CGSize(width: width, height: 250)
    }
}

// MARK: - FavoriteMealCellDelegate
extension FavoritesViewController: FavoriteMealCellDelegate {
    func favoriteMealCellDidTapRemove(for mealID: String) {
        viewModel.removeFavorite(mealID: mealID)
    }
}

// MARK: - FavoriteMealCell
protocol FavoriteMealCellDelegate: AnyObject {
    func favoriteMealCellDidTapRemove(for mealID: String)
}

final class FavoriteMealCell: UICollectionViewCell {
    static let identifier = "FavoriteMealCell"

    weak var delegate: FavoriteMealCellDelegate?

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
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private let removeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 15
        return button
    }()

    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        gradient.locations = [0.4, 1.0]
        return gradient
    }()

    private var mealID: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private func setupView() {
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        contentView.addSubview(mealImageView)
        mealImageView.layer.addSublayer(gradientLayer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(removeButton)

        mealImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().offset(-12)
        }

        removeButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(8)
            $0.width.height.equalTo(30)
        }

        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
    }

    func configure(with meal: Meal) {
        mealID = meal.id
        titleLabel.text = meal.name

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
    }

    @objc private func removeButtonTapped() {
        delegate?.favoriteMealCellDidTapRemove(for: mealID)
    }
}