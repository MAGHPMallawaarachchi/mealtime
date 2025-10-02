# Mealtime Recipe Upload Guide

This guide shows you how to upload your localized recipes to Firebase Firestore.

## Quick Start

### 1. Navigate to tools directory
```bash
cd tools
```

### 2. Install dependencies (if not already done)
```bash
npm install
```

### 3. Set up Firebase authentication
Download your service account key from Firebase Console and save it as `service-account-key.json` in the tools directory.

### 4. Validate your recipes first
```bash
npm run validate
```

### 5. Upload to Firebase
```bash
npm run import
```

## Features of the Updated Import Script

✅ **Full Localization Support**: Handles both English and Sinhala content
✅ **Backward Compatibility**: Works with old string-based recipes
✅ **Comprehensive Validation**: Checks all fields including localized content
✅ **Safe Uploads**: Validates everything before uploading
✅ **Detailed Error Messages**: Shows exactly what needs to be fixed

## Localized Recipe Structure

Your `sample_recipes.json` now supports this structure:

```json
{
  "title": {
    "en": "English Title",
    "si": "සිංහල මාතෘකාව"
  },
  "description": {
    "en": "English description...",
    "si": "සිංහල විස්තරය..."
  },
  "ingredientSections": [
    {
      "ingredients": [
        {
          "name": {
            "en": "ingredient name",
            "si": "ද්‍රව්‍ය නම"
          }
        }
      ]
    }
  ],
  "instructionSections": [
    {
      "steps": [
        {
          "en": "English instruction step",
          "si": "සිංහල උපදෙස් පියවර"
        }
      ]
    }
  ]
}
```

## Example Usage

### Validate Only (Recommended First Step)
```bash
# This will check your recipes without uploading
node import_recipes.js ../data/sample_recipes.json --validate-only
```

### Upload After Validation
```bash
# This uploads to Firebase Firestore
node import_recipes.js ../data/sample_recipes.json
```

### Using npm scripts
```bash
# Validate default sample_recipes.json
npm run validate

# Import default sample_recipes.json
npm run import
```

## What Happens During Upload

1. **File Reading**: Reads your JSON file
2. **JSON Parsing**: Validates JSON syntax
3. **Recipe Validation**: Checks each recipe structure
4. **Localization Check**: Validates multilingual content
5. **Firestore Upload**: Batch uploads all valid recipes
6. **Timestamp Addition**: Adds `createdAt` and `updatedAt` fields

## Expected Output

### Successful Upload
```
🍽️  Mealtime Recipe Importer
================================
📖 Reading recipes from: ../data/sample_recipes.json
📝 Found 11 recipes to process

🔍 Validating recipes...

✅ Valid recipes: 11
❌ Invalid recipes: 0

📤 Starting import to Firestore...
✅ Successfully imported 11 recipes to Firestore!

👋 Done!
```

### Validation Issues
```
❌ Recipe "අග්ගලා" (index 0) has errors:
   - Missing required field: imageUrl

✅ Valid recipes: 10
❌ Invalid recipes: 1

⚠️  Some recipes have validation errors. Fix them before importing.
💡 Run with --validate-only to see all errors without importing
```

## Firebase Setup Requirements

1. **Project**: Make sure you're using project ID `mealtime-191ca` (or update the script)
2. **Service Account**: Download from Firebase Console → Project Settings → Service Accounts
3. **Permissions**: Service account needs Firestore write access
4. **Collection**: Recipes will be stored in the `recipes` collection

## Troubleshooting

### "Service account key not found"
- Download service account key from Firebase Console
- Save as `tools/service-account-key.json`
- Make sure the file is not in `.gitignore`

### "Permission denied"
- Check your service account has Firestore write permissions
- Verify you're using the correct project ID

### "Invalid JSON file"
- Use an online JSON validator to check syntax
- Common issues: trailing commas, missing quotes, mismatched brackets

### Validation errors
- Read error messages carefully - they tell you exactly what's wrong
- Use `--validate-only` flag to see all errors without uploading
- Check that localized objects have both `en` and `si` keys where expected

## Safety Features

- **Validation First**: All recipes are validated before any upload starts
- **Batch Operations**: Uses Firestore batch writes for consistency
- **Error Prevention**: Won't upload if any recipe has validation errors
- **Dry Run Mode**: `--validate-only` flag lets you check without uploading
- **Detailed Logging**: Shows progress and any issues during the process