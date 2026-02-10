#!/bin/bash

echo "🔒 Security Verification Script"
echo "================================"
echo ""

# Check if .env is ignored
echo "1. Checking .env file..."
if git check-ignore .env > /dev/null 2>&1; then
    echo "   ✅ .env is properly ignored by git"
else
    echo "   ❌ WARNING: .env is NOT ignored by git!"
    exit 1
fi

# Check if .env exists
if [ -f .env ]; then
    echo "   ✅ .env file exists"
else
    echo "   ⚠️  .env file not found"
fi

# Check if .env is tracked by git
if git ls-files --error-unmatch .env > /dev/null 2>&1; then
    echo "   ❌ CRITICAL: .env is tracked by git! Run: git rm --cached .env"
    exit 1
else
    echo "   ✅ .env is not tracked by git"
fi

# Check for any sensitive files in staging
echo ""
echo "2. Checking for sensitive files in git..."
SENSITIVE_FILES=$(git status --porcelain | grep -E "\.env$|\.key$|\.pem$|credentials\.json$" || true)
if [ -z "$SENSITIVE_FILES" ]; then
    echo "   ✅ No sensitive files in git staging"
else
    echo "   ❌ WARNING: Sensitive files found in staging:"
    echo "$SENSITIVE_FILES"
    exit 1
fi

# Check if credentials are in .env
echo ""
echo "3. Checking .env file contents..."
if [ -f .env ]; then
    if grep -q "GOOGLE_PRIVATE_KEY" .env; then
        echo "   ✅ GOOGLE_PRIVATE_KEY found in .env"
    else
        echo "   ⚠️  GOOGLE_PRIVATE_KEY not found in .env"
    fi
    
    if grep -q "GOOGLE_SERVICE_ACCOUNT_EMAIL" .env; then
        echo "   ✅ GOOGLE_SERVICE_ACCOUNT_EMAIL found in .env"
    else
        echo "   ⚠️  GOOGLE_SERVICE_ACCOUNT_EMAIL not found in .env"
    fi
    
    if grep -q "GA4_PROPERTY_ID" .env; then
        echo "   ✅ GA4_PROPERTY_ID found in .env"
    else
        echo "   ⚠️  GA4_PROPERTY_ID not found in .env"
    fi
fi

# Check git history for leaked credentials
echo ""
echo "4. Checking git history for leaked credentials..."
if git log --all --full-history --source --pretty=format: --name-only | grep -q "^\.env$"; then
    echo "   ⚠️  WARNING: .env was committed in the past"
    echo "   Consider using: git filter-branch or BFG Repo-Cleaner"
else
    echo "   ✅ No .env file found in git history"
fi

echo ""
echo "================================"
echo "✅ Security verification complete!"
echo ""
echo "📝 Remember:"
echo "   - Never commit .env file"
echo "   - Use .env.example for documentation"
echo "   - Rotate keys if accidentally committed"
