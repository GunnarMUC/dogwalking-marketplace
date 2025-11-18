#!/bin/bash

# Script to update DATABASE_URL in .env file
# Usage: ./update-database-url.sh "your-connection-string"

if [ -z "$1" ]; then
  echo "❌ Error: Please provide your Neon connection string"
  echo ""
  echo "Usage: ./update-database-url.sh \"postgresql://user:pass@host/db\""
  echo ""
  echo "Example:"
  echo "./update-database-url.sh \"postgresql://username:password@ep-cool-name-123456.us-east-2.aws.neon.tech/neondb\""
  exit 1
fi

DATABASE_URL="$1"

# Update web .env file
if [ -f "apps/web/.env" ]; then
  # Backup current .env
  cp apps/web/.env apps/web/.env.backup
  
  # Update DATABASE_URL
  if grep -q "^DATABASE_URL=" apps/web/.env; then
    # Replace existing DATABASE_URL
    sed -i '' "s|^DATABASE_URL=.*|DATABASE_URL=${DATABASE_URL}|" apps/web/.env
    echo "✅ Updated DATABASE_URL in apps/web/.env"
  else
    # Add DATABASE_URL if it doesn't exist
    echo "DATABASE_URL=${DATABASE_URL}" >> apps/web/.env
    echo "✅ Added DATABASE_URL to apps/web/.env"
  fi
  
  echo "✅ Backup saved to apps/web/.env.backup"
else
  echo "❌ Error: apps/web/.env not found"
  exit 1
fi

echo ""
echo "🎉 Database URL updated successfully!"
echo ""
echo "Next steps:"
echo "1. Go to Neon SQL Editor: https://console.neon.tech"
echo "2. Copy the contents of database-schema.sql"
echo "3. Paste into SQL Editor and click 'Run'"
echo "4. You're ready to start the app!"

