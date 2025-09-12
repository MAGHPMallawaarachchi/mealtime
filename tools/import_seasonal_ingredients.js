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
const seasonalIngredientsCollection = db.collection('seasonal_ingredients');

// Validation functions
function validateSeasonalIngredient(ingredient) {
  const errors = [];

  // Required fields
  if (!ingredient.id) errors.push('Missing required field: id');
  if (!ingredient.imageUrl) errors.push('Missing required field: imageUrl');
  if (!ingredient.peakSeason) errors.push('Missing required field: peakSeason');
  
  // If name field exists, validate it; if not, it will be derived from localizedNames.en
  if (ingredient.name && typeof ingredient.name !== 'string') {
    errors.push('name must be a string');
  }

  // Validate seasonalMonths
  if (!Array.isArray(ingredient.seasonalMonths)) {
    errors.push('seasonalMonths must be an array');
  } else {
    // Check that all months are valid numbers between 1-12
    const invalidMonths = ingredient.seasonalMonths.filter(month => 
      typeof month !== 'number' || month < 1 || month > 12
    );
    if (invalidMonths.length > 0) {
      errors.push(`seasonalMonths contains invalid month numbers: ${invalidMonths.join(', ')}`);
    }
  }

  // Validate localizedNames
  if (!ingredient.localizedNames || typeof ingredient.localizedNames !== 'object') {
    errors.push('localizedNames must be an object');
  } else {
    if (!ingredient.localizedNames.en) errors.push('localizedNames.en is required');
    if (!ingredient.localizedNames.si) errors.push('localizedNames.si is required');
  }

  // Validate localizedDescriptions
  if (!ingredient.localizedDescriptions || typeof ingredient.localizedDescriptions !== 'object') {
    errors.push('localizedDescriptions must be an object');
  } else {
    if (!ingredient.localizedDescriptions.en) errors.push('localizedDescriptions.en is required');
    if (!ingredient.localizedDescriptions.si) errors.push('localizedDescriptions.si is required');
  }

  return errors;
}

async function importSeasonalIngredients(filePath, validateOnly = false) {
  try {
    console.log(`📖 Reading seasonal ingredients from: ${filePath}`);
    
    if (!fs.existsSync(filePath)) {
      console.error(`❌ File not found: ${filePath}`);
      return;
    }

    const fileContent = fs.readFileSync(filePath, 'utf8');
    let ingredients;
    
    try {
      ingredients = JSON.parse(fileContent);
    } catch (error) {
      console.error('❌ Invalid JSON file:', error.message);
      return;
    }

    if (!Array.isArray(ingredients)) {
      console.error('❌ JSON file must contain an array of seasonal ingredients');
      return;
    }

    console.log(`📝 Found ${ingredients.length} seasonal ingredients to process`);

    let validCount = 0;
    let errorCount = 0;

    // Validate all ingredients first
    console.log('\n🔍 Validating seasonal ingredients...');
    for (let i = 0; i < ingredients.length; i++) {
      const ingredient = ingredients[i];
      const errors = validateSeasonalIngredient(ingredient);
      
      if (errors.length > 0) {
        console.error(`❌ Ingredient "${ingredient.localizedNames?.en || ingredient.id}" (index ${i}) has errors:`);
        errors.forEach(error => console.error(`   - ${error}`));
        errorCount++;
      } else {
        validCount++;
      }
    }

    console.log(`\n✅ Valid ingredients: ${validCount}`);
    console.log(`❌ Invalid ingredients: ${errorCount}`);

    if (validateOnly) {
      console.log('\n🔍 Validation complete (no data was imported)');
      return;
    }

    if (errorCount > 0) {
      console.log('\n⚠️  Some ingredients have validation errors. Fix them before importing.');
      console.log('💡 Run with --validate-only to see all errors without importing');
      return;
    }

    // Import valid ingredients
    console.log('\n📤 Starting import to Firestore...');
    const batch = db.batch();

    for (const ingredient of ingredients) {
      const docRef = seasonalIngredientsCollection.doc(ingredient.id);
      
      // Add name field if it doesn't exist, using English localized name as fallback
      const ingredientData = {
        ...ingredient,
        name: ingredient.name || ingredient.localizedNames?.en || ingredient.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      };
      
      batch.set(docRef, ingredientData);
    }

    await batch.commit();
    console.log(`✅ Successfully imported ${ingredients.length} seasonal ingredients to Firestore!`);

    // Display summary of imported ingredients by season
    console.log('\n📊 Import Summary:');
    const seasonCounts = {};
    ingredients.forEach(ingredient => {
      ingredient.seasonalMonths.forEach(month => {
        const season = getSeasonName(month);
        seasonCounts[season] = (seasonCounts[season] || 0) + 1;
      });
    });

    Object.entries(seasonCounts).forEach(([season, count]) => {
      console.log(`   ${season}: ${count} ingredients`);
    });

  } catch (error) {
    console.error('❌ Import failed:', error.message);
    if (error.code) {
      console.error('Error code:', error.code);
    }
  }
}

// Helper function to get season name from month number
function getSeasonName(month) {
  if (month >= 12 || month <= 2) return 'Winter';
  if (month >= 3 && month <= 5) return 'Spring';
  if (month >= 6 && month <= 8) return 'Summer';
  if (month >= 9 && month <= 11) return 'Autumn';
}

// Main execution
async function main() {
  const args = process.argv.slice(2);
  const validateOnly = args.includes('--validate-only');
  
  // Default to seasonal ingredient sample if no file specified
  let filePath = path.join(__dirname, '..', 'data', 'seasonal_ingredient_sample.json');
  
  // Check for custom file path
  const fileArg = args.find(arg => arg.endsWith('.json') && !arg.startsWith('--'));
  if (fileArg) {
    filePath = path.resolve(fileArg);
  }

  console.log('🌱 Mealtime Seasonal Ingredients Importer');
  console.log('=========================================');
  
  if (validateOnly) {
    console.log('🔍 Validation mode (no data will be imported)');
  }
  
  await importSeasonalIngredients(filePath, validateOnly);
  
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