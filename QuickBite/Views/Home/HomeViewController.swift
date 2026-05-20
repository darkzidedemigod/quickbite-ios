import UIKit
import SnapKit

final class HomeViewController: UIViewController {

    private let viewModel = HomeViewModel()

    private let searchBarView: SearchBarView = {
        let searchBar = SearchBarView()
        return searchBar
    }()

    private let loadingView: LoadingView = {
        let view = LoadingView()
        return view
    }()

    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.configure(
            image: UIImage(systemName: "magnifyingglass"),
            title: "No meals found",
            subtitle: "Try searching for a different meal"
        )
        return view
    }()

    private let categoriesLabel: UILabel = {
        let label = UILabel()
        label.text = "Categories"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()

    private let categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 180)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(HomeCategoryCell.self, forCellWithReuseIdentifier: HomeCategoryCell.identifier)
        return collectionView
    }()

    private let featuredLabel: UILabel = {
        let label = UILabel()
        label.text = "Featured Meals"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()

    private let mealsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 250)
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(HomeMealCell.self, forCellWithReuseIdentifier: HomeMealCell.identifier)
        return collectionView
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

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private var categories: [MealCategory] = []
    private var meals: [Meal] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        setupDelegates()
        viewModel.fetchCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        view.addSubview(searchBarView)
        view.addSubview(contentStackView)
        contentStackView.addArrangedSubview(categoriesLabel)
        contentStackView.addArrangedSubview(categoriesCollectionView)
        contentStackView.addArrangedSubview(featuredLabel)
        contentStackView.addArrangedSubview(mealsCollectionView)

        view.addSubview(loadingView)
        view.addSubview(emptyStateView)
        view.addSubview(errorLabel)

        searchBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        contentStackView.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        categoriesCollectionView.snp.makeConstraints {
            $0.height.equalTo(180)
        }

        mealsCollectionView.snp.makeConstraints {
            $0.height.equalTo(250)
        }

        loadingView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(100)
        }

        emptyStateView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.height.equalTo(200)
        }

        errorLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
        }

        contentStackView.isHidden = true
        emptyStateView.isHidden = true
    }

    private func setupBindings() {
        viewModel.state.bind { [weak self] state in
            guard let self = self else { return }

            self.loadingView.stopLoading()
            self.contentStackView.isHidden = true
            self.emptyStateView.isHidden = true
            self.errorLabel.isHidden = true

            switch state {
            case .loading:
                self.loadingView.startLoading()
            case .success(let categories, let meals):
                self.categories = categories
                self.meals = meals
                self.categoriesCollectionView.reloadData()
                self.mealsCollectionView.reloadData()
                self.contentStackView.isHidden = false
            case .error(let message):
                self.errorLabel.text = message
                self.errorLabel.isHidden = false
            case .empty:
                self.emptyStateView.isHidden = false
            }
        }
    }

    private func setupDelegates() {
        searchBarView.delegate = self
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        mealsCollectionView.dataSource = self
        mealsCollectionView.delegate = self
    }
}

// MARK: - SearchBarViewDelegate
extension HomeViewController: SearchBarViewDelegate {
    func searchBarDidChange(query: String) {
        viewModel.updateSearchQuery(query)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            return categories.count
        }
        return meals.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeCategoryCell.identifier,
                for: indexPath
            ) as? HomeCategoryCell else {
                return UICollectionViewCell()
            }
            let category = categories[indexPath.item]
            cell.configure(with: category)
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeMealCell.identifier,
            for: indexPath
        ) as? HomeMealCell else {
            return UICollectionViewCell()
        }
        let meal = meals[indexPath.item]
        cell.configure(with: meal)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoriesCollectionView {
            let category = categories[indexPath.item]
            viewModel.updateSearchQuery(category.strCategory)
        } else {
            let meal = meals[indexPath.item]
            let detailVC = MealDetailViewController(meal: meal)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - HomeCategoryCell
final class HomeCategoryCell: UICollectionViewCell {
    static let identifier = "HomeCategoryCell"

    private let cardView = MealCardView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with category: MealCategory) {
        cardView.configureCategory(with: category)
    }
}

// MARK: - HomeMealCell
final class HomeMealCell: UICollectionViewCell {
    static let identifier = "HomeMealCell"

    private let cardView = MealCardView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with meal: Meal) {
        cardView.configure(with: meal, isFavorite: meal.isFavorite)
    }
}