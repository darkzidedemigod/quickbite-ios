import Foundation

struct Ingredient: Sendable {
    let name: String
    let measure: String
}

struct Meal: Codable, Equatable, Sendable {
    let id: String
    let name: String
    let thumbnailURL: String
    let instructions: String?
    let ingredients: [Ingredient]?
    var isFavorite: Bool = false

    enum CodingKeys: String, CodingKey {
        case idMeal
        case strMeal
        case strMealThumb
        case strInstructions
        case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5
        case strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10
        case strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15
        case strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5
        case strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10
        case strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15
        case strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .idMeal)
        name = try container.decode(String.self, forKey: .strMeal)
        thumbnailURL = try container.decode(String.self, forKey: .strMealThumb)
        instructions = try container.decodeIfPresent(String.self, forKey: .strInstructions)

        var ingredientsArray: [Ingredient] = []
        let ingredientKeys: [CodingKeys] = [
            .strIngredient1, .strIngredient2, .strIngredient3, .strIngredient4, .strIngredient5,
            .strIngredient6, .strIngredient7, .strIngredient8, .strIngredient9, .strIngredient10,
            .strIngredient11, .strIngredient12, .strIngredient13, .strIngredient14, .strIngredient15,
            .strIngredient16, .strIngredient17, .strIngredient18, .strIngredient19, .strIngredient20
        ]
        let measureKeys: [CodingKeys] = [
            .strMeasure1, .strMeasure2, .strMeasure3, .strMeasure4, .strMeasure5,
            .strMeasure6, .strMeasure7, .strMeasure8, .strMeasure9, .strMeasure10,
            .strMeasure11, .strMeasure12, .strMeasure13, .strMeasure14, .strMeasure15,
            .strMeasure16, .strMeasure17, .strMeasure18, .strMeasure19, .strMeasure20
        ]

        for (index, ingredientKey) in ingredientKeys.enumerated() {
            let ingredientName = try container.decodeIfPresent(String.self, forKey: ingredientKey)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let measure = try container.decodeIfPresent(String.self, forKey: measureKeys[index])?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            if !ingredientName.isEmpty {
                ingredientsArray.append(Ingredient(name: ingredientName, measure: measure))
            }
        }
        ingredients = ingredientsArray.isEmpty ? nil : ingredientsArray
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .idMeal)
        try container.encode(name, forKey: .strMeal)
        try container.encode(thumbnailURL, forKey: .strMealThumb)
        try container.encodeIfPresent(instructions, forKey: .strInstructions)

        if let ingredients = ingredients {
            let ingredientKeys: [CodingKeys] = [
                .strIngredient1, .strIngredient2, .strIngredient3, .strIngredient4, .strIngredient5,
                .strIngredient6, .strIngredient7, .strIngredient8, .strIngredient9, .strIngredient10,
                .strIngredient11, .strIngredient12, .strIngredient13, .strIngredient14, .strIngredient15,
                .strIngredient16, .strIngredient17, .strIngredient18, .strIngredient19, .strIngredient20
            ]
            let measureKeys: [CodingKeys] = [
                .strMeasure1, .strMeasure2, .strMeasure3, .strMeasure4, .strMeasure5,
                .strMeasure6, .strMeasure7, .strMeasure8, .strMeasure9, .strMeasure10,
                .strMeasure11, .strMeasure12, .strMeasure13, .strMeasure14, .strMeasure15,
                .strMeasure16, .strMeasure17, .strMeasure18, .strMeasure19, .strMeasure20
            ]

            for (index, ingredient) in ingredients.prefix(20).enumerated() {
                try container.encode(ingredient.name, forKey: ingredientKeys[index])
                try container.encode(ingredient.measure, forKey: measureKeys[index])
            }
        }
    }

    static func == (lhs: Meal, rhs: Meal) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - API Response Wrappers

struct MealSearchResponse: Decodable, Sendable {
    let meals: [Meal]?

    enum CodingKeys: String, CodingKey {
        case meals
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        meals = try container.decodeIfPresent([Meal].self, forKey: .meals)
    }
}

struct MealCategoriesResponse: Decodable, Sendable {
    let categories: [MealCategory]

    enum CodingKeys: String, CodingKey {
        case categories
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        categories = try container.decode([MealCategory].self, forKey: .categories)
    }
}

struct MealCategory: Codable, Sendable {
    let idCategory: String
    let strCategory: String
    let strCategoryThumb: String
    let strCategoryDescription: String

    enum CodingKeys: String, CodingKey {
        case idCategory
        case strCategory
        case strCategoryThumb
        case strCategoryDescription
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        idCategory = try container.decode(String.self, forKey: .idCategory)
        strCategory = try container.decode(String.self, forKey: .strCategory)
        strCategoryThumb = try container.decode(String.self, forKey: .strCategoryThumb)
        strCategoryDescription = try container.decode(String.self, forKey: .strCategoryDescription)
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(idCategory, forKey: .idCategory)
        try container.encode(strCategory, forKey: .strCategory)
        try container.encode(strCategoryThumb, forKey: .strCategoryThumb)
        try container.encode(strCategoryDescription, forKey: .strCategoryDescription)
    }
}
