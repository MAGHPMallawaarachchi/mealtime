# Data Import Tools

This directory contains tools to bulk import data to your Firebase Firestore database for the Mealtime app.

## Available Tools
- `import_recipes.js` - Import recipes from JSON files
- `import_seasonal_ingredients.js` - Import seasonal ingredients data

## Setup

### 1. Install Dependencies
```bash
cd tools
npm install
```

### 2. Firebase Authentication

You have two options for authentication:

#### Option A: Service Account Key (Recommended for Development)
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (`mealtime-191ca`)
3. Go to Project Settings → Service Accounts
4. Click "Generate new private key"
5. Download the JSON file and save it as `tools/service-account-key.json`

#### Option B: Application Default Credentials
Set the environment variable:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-key.json"
```

## Usage

### Import Recipes
```bash
# Import the sample recipes
npm run import

# Import custom recipe file
node import_recipes.js /path/to/your/recipes.json

# Validate recipes without importing
npm run validate
node import_recipes.js --validate-only
```

### Import Seasonal Ingredients
```bash
# Import the seasonal ingredients sample
node import_seasonal_ingredients.js

# Import custom seasonal ingredients file
node import_seasonal_ingredients.js /path/to/your/seasonal_ingredients.json

# Validate seasonal ingredients without importing
node import_seasonal_ingredients.js --validate-only
```

## Recipe JSON Format

Each recipe must follow this structure:

```json
{
  "id": "unique_recipe_id",
  "title": "Recipe Name",
  "time": "30 min",
  "imageUrl": "https://example.com/image.jpg",
  "calories": 250,
  "macros": {
    "protein": 15.2,
    "carbs": 30.1,
    "fats": 8.5,
    "fiber": 4.2
  },
  "description": "Recipe description (optional)",
  "defaultServings": 4,
  "ingredients": [
    {
      "id": "ingredient_id",
      "name": "ingredient name",
      "quantity": 1.5,
      "unit": "cups",
      "metricQuantity": 360,
      "metricUnit": "milliliters"
    }
  ],
  "instructionSections": [
    {
      "id": "section_id",
      "title": "Section Title",
      "steps": [
        "Step 1 instructions",
        "Step 2 instructions"
      ]
    }
  ],
  "tags": ["sri-lankan", "vegetarian", "quick"],
  "source": "Recipe source (optional)"
}
```

### Valid Units
- **Volume**: `cups`, `teaspoons`, `tablespoons`, `milliliters`, `liters`
- **Weight**: `grams`, `kilograms`, `ounces`, `pounds`
- **Count**: `pieces`, `whole`
- **Other**: `pinch`, `dash`, `toTaste`

## Seasonal Ingredients JSON Format

Each seasonal ingredient must follow this structure:

```json
{
  "id": "SI001",
  "name": "Ingredient Name",
  "imageUrl": "https://example.com/image.jpg",
  "description": "Ingredient description in English",
  "seasonalMonths": [3, 4, 5, 6],
  "peakSeason": "April–June",
  "localizedNames": {
    "en": "Ingredient Name",
    "si": "සිංහල නම"
  },
  "localizedDescriptions": {
    "en": "English description",
    "si": "සිංහල විස්තරය"
  }
}
```

### Seasonal Data Requirements
- **seasonalMonths**: Array of month numbers (1-12) when ingredient is available
- **peakSeason**: Human-readable peak season description
- **Localization**: Both English (`en`) and Sinhala (`si`) names and descriptions are required

## Sample Data

### Recipes
The `data/sample_recipes.json` file contains 5 authentic Sri Lankan recipes:
1. Traditional Sri Lankan Chicken Curry
2. Parippu (Sri Lankan Lentil Curry)
3. Sri Lankan Hoppers (Appa)
4. Sri Lankan Fish Curry
5. Pol Sambol (Coconut Relish)

### Seasonal Ingredients
The `data/seasonal_ingredient_sample.json` file contains 20 Sri Lankan seasonal ingredients including:
- Tropical fruits (Rambutan, Mangosteen, Durian)
- Common vegetables (Okra, Bitter Gourd, Pumpkin)
- Seasonal specialties (Wood Apple, Cashew Apple, Rose Apple)

All sample data files are properly formatted and can be imported directly to get you started.

## Adding More Recipes

### Method 1: JSON Files
1. Create or edit JSON files in the `data/` directory
2. Follow the recipe format above
3. Run the import tool

### Method 2: Convert from Other Formats
If you have recipes in spreadsheet format:

1. Export as CSV with columns: id, title, time, imageUrl, etc.
2. Use a CSV to JSON converter
3. Manually format the ingredients and instructions arrays
4. Validate and import

### Method 3: Scrape Recipe Websites
You can create a scraper script to extract recipes from websites:
- Parse recipe JSON-LD structured data
- Convert to your format
- Validate and import

## Validation

The tool automatically validates:
- ✅ Required fields (id, title, time, imageUrl, calories, macros)
- ✅ Proper data types (numbers, arrays, objects)
- ✅ Valid ingredient units
- ✅ Instruction section structure
- ✅ Macro nutrition values

## Troubleshooting

### "Service account key not found"
- Download the service account key from Firebase Console
- Save it as `tools/service-account-key.json`

### "Permission denied"
- Check your Firebase project permissions
- Ensure the service account has Firestore write access

### "Invalid JSON file"
- Validate your JSON syntax using an online JSON validator
- Check for trailing commas or missing quotes

### "Recipe validation errors"
- Run with `--validate-only` to see all errors
- Fix each validation error before importing
- Check the required fields and data types

## Security Notes

⚠️ **Never commit your service account key to version control!**

The `service-account-key.json` file is already added to `.gitignore` to prevent accidental commits.

## Next Steps

After importing recipes:
1. Open your Flutter app
2. Navigate to the Explore screen
3. Your recipes should appear automatically
4. Test recipe details and functionality

For bulk operations or regular imports, consider setting up GitHub Actions or Cloud Functions to automate the process.