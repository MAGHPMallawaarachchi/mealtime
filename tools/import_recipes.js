#!/usr/bin/env node

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
let serviceAccount;
try {
  // Try to load service account key from environment or local file
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    console.log('Using GOOGLE_APPLICATION_CREDENTIALS environment variable');
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: 'mealtime-191ca'
    });
  } else {
    // For development, you'll need to download service account key
    console.log('Looking for service account key...');
    const serviceAccountPath = path.join(__dirname, 'service-account-key.json');
    if (fs.existsSync(serviceAccountPath)) {
      serviceAccount = require(serviceAccountPath);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: 'mealtime-191ca'
      });
    } else {
      console.error('❌ Service account key not found.');
      console.log('Please download service account key from Firebase Console:');
      console.log('1. Go to Firebase Console > Project Settings > Service Accounts');
      console.log('2. Click "Generate new private key"');
      console.log('3. Save as tools/service-account-key.json');
      process.exit(1);
    }
  }
} catch (error) {
  console.error('❌ Failed to initialize Firebase:', error.message);
  process.exit(1);
}

const db = admin.firestore();
const recipesCollection = db.collection('recipes');

// Validation functions
function validateLocalizedString(value, fieldName) {
  if (typeof value === 'string') {
    // Legacy format - single string (treated as English)
    return true;
  }

  if (typeof value === 'object' && value !== null) {
    // New localized format - object with language keys
    const keys = Object.keys(value);
    if (keys.length === 0) {
      return false;
    }

    // Check if all values are strings
    return keys.every(key => typeof value[key] === 'string' && value[key].trim().length > 0);
  }

  return false;
}

function validateRecipeIngredient(ingredient) {
  const validUnits = [
    'cups', 'teaspoons', 'tablespoons', 'milliliters', 'liters',
    'grams', 'kilograms', 'ounces', 'pounds', 'pieces', 'whole',
    'pinch', 'dash', 'toTaste', 'centimeters',
    'large', 'medium', 'small', 'cloves', // Common descriptive units
    null
  ];

  if (!ingredient.id) {
    return false;
  }

  // Validate localized name (can be string or object)
  if (!validateLocalizedString(ingredient.name, 'ingredient name')) {
    return false;
  }

  // Allow null quantity for units that don't require precise measurement
  const unitsAllowingNullQuantity = ['toTaste', 'pinch', 'dash'];
  if (ingredient.quantity === null && !unitsAllowingNullQuantity.includes(ingredient.unit)) {
    return false;
  }

  // If quantity is not null, it must be a number
  if (ingredient.quantity !== null && typeof ingredient.quantity !== 'number') {
    return false;
  }

  // Allow null unit when quantity exists (for descriptive items like "3 large eggs")
  if (ingredient.unit === null && ingredient.quantity === null) {
    return false;
  }

  if (!validUnits.includes(ingredient.unit)) {
    console.warn(`⚠️  Unknown unit: ${ingredient.unit}`);
  }

  return true;
}

function validateIngredientSection(section) {
  if (!section.id || !Array.isArray(section.ingredients)) {
    return false;
  }

  // Title can be null (will default to "Ingredients" in Dart model) or localized string
  if (section.title !== null && !validateLocalizedString(section.title, 'section title')) {
    return false;
  }

  return section.ingredients.every(ingredient => validateRecipeIngredient(ingredient));
}

function validateInstructionSection(section) {
  if (!section.id || !Array.isArray(section.steps) || section.steps.length === 0) {
    return false;
  }

  // Title can be null or localized string
  if (section.title !== null && !validateLocalizedString(section.title, 'instruction section title')) {
    return false;
  }

  // Validate each step (can be string or localized object)
  return section.steps.every(step => validateLocalizedString(step, 'instruction step'));
}

function validateRecipe(recipe) {
  const errors = [];

  if (!recipe.id) errors.push('Missing required field: id');
  if (!validateLocalizedString(recipe.title, 'title')) errors.push('title must be a string or localized object');
  if (!recipe.time) errors.push('Missing required field: time');
  if (!recipe.imageUrl) errors.push('Missing required field: imageUrl');
  if (typeof recipe.calories !== 'number') errors.push('calories must be a number');

  // Validate description (optional but if present, must be localized string)
  if (recipe.description !== null && recipe.description !== undefined &&
      !validateLocalizedString(recipe.description, 'description')) {
    errors.push('description must be a string or localized object');
  }
  
  if (!recipe.macros || typeof recipe.macros.protein !== 'number' || 
      typeof recipe.macros.carbs !== 'number' || typeof recipe.macros.fats !== 'number' ||
      typeof recipe.macros.fiber !== 'number') {
    errors.push('macros must contain protein, carbs, fats, and fiber as numbers');
  }

  if (!Array.isArray(recipe.ingredientSections)) {
    errors.push('ingredientSections must be an array');
  } else {
    recipe.ingredientSections.forEach((section, index) => {
      if (!validateIngredientSection(section)) {
        errors.push(`Invalid ingredient section at index ${index}`);
      }
    });
  }

  if (!Array.isArray(recipe.instructionSections)) {
    errors.push('instructionSections must be an array');
  } else {
    recipe.instructionSections.forEach((section, index) => {
      if (!validateInstructionSection(section)) {
        errors.push(`Invalid instruction section at index ${index}`);
      }
    });
  }

  if (typeof recipe.defaultServings !== 'number') {
    errors.push('defaultServings must be a number');
  }

  if (recipe.tags && !Array.isArray(recipe.tags)) {
    errors.push('tags must be an array');
  }

  return errors;
}

async function importRecipes(filePath, validateOnly = false) {
  try {
    console.log(`📖 Reading recipes from: ${filePath}`);
    
    if (!fs.existsSync(filePath)) {
      console.error(`❌ File not found: ${filePath}`);
      return;
    }

    const fileContent = fs.readFileSync(filePath, 'utf8');
    let recipes;
    
    try {
      recipes = JSON.parse(fileContent);
    } catch (error) {
      console.error('❌ Invalid JSON file:', error.message);
      return;
    }

    if (!Array.isArray(recipes)) {
      console.error('❌ JSON file must contain an array of recipes');
      return;
    }

    console.log(`📝 Found ${recipes.length} recipes to process`);

    let validCount = 0;
    let errorCount = 0;

    // Validate all recipes first
    console.log('\n🔍 Validating recipes...');
    for (let i = 0; i < recipes.length; i++) {
      const recipe = recipes[i];
      const errors = validateRecipe(recipe);

      // Get title for display (handle both string and localized object)
      let displayTitle = 'Unknown';
      if (typeof recipe.title === 'string') {
        displayTitle = recipe.title;
      } else if (recipe.title && typeof recipe.title === 'object') {
        displayTitle = recipe.title.en || recipe.title.si || Object.values(recipe.title)[0] || 'Unknown';
      }

      if (errors.length > 0) {
        console.error(`❌ Recipe "${displayTitle}" (index ${i}) has errors:`);
        errors.forEach(error => console.error(`   - ${error}`));
        errorCount++;
      } else {
        validCount++;
      }
    }

    console.log(`\n✅ Valid recipes: ${validCount}`);
    console.log(`❌ Invalid recipes: ${errorCount}`);

    if (validateOnly) {
      console.log('\n🔍 Validation complete (no data was imported)');
      return;
    }

    if (errorCount > 0) {
      console.log('\n⚠️  Some recipes have validation errors. Fix them before importing.');
      console.log('💡 Run with --validate-only to see all errors without importing');
      return;
    }

    // Import valid recipes
    console.log('\n📤 Starting import to Firestore...');
    const batch = db.batch();

    for (const recipe of recipes) {
      const docRef = recipesCollection.doc(recipe.id);
      batch.set(docRef, {
        ...recipe,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    await batch.commit();
    console.log(`✅ Successfully imported ${recipes.length} recipes to Firestore!`);

  } catch (error) {
    console.error('❌ Import failed:', error.message);
    if (error.code) {
      console.error('Error code:', error.code);
    }
  }
}

// Main execution
async function main() {
  const args = process.argv.slice(2);
  const validateOnly = args.includes('--validate-only');
  
  // Default to sample recipes if no file specified
  let filePath = path.join(__dirname, '..', 'data', 'sample_recipes.json');
  
  // Check for custom file path
  const fileArg = args.find(arg => arg.endsWith('.json') && !arg.startsWith('--'));
  if (fileArg) {
    filePath = path.resolve(fileArg);
  }

  console.log('🍽️  Mealtime Recipe Importer');
  console.log('================================');
  
  if (validateOnly) {
    console.log('🔍 Validation mode (no data will be imported)');
  }
  
  await importRecipes(filePath, validateOnly);
  
  console.log('\n👋 Done!');
  process.exit(0);
}

// Handle errors
process.on('unhandledRejection', (error) => {
  console.error('❌ Unhandled error:', error);
  process.exit(1);
});

// Run the script
if (require.main === module) {
  main();
}