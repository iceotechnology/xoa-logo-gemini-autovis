#!/bin/bash

# ============================================
# Deploy - xoa-logo-gemini-autovis (PM2)
# Chỉ cần chạy: ./deploy.sh
# ============================================

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_NAME="xoa-logo-gemini-autovis"
APP_DIR="/opt/ai/xoa-logo-gemini-autovis"
APP_PORT=3007

echo ""
echo -e "${BLUE}🚀 Deploying ${APP_NAME}...${NC}"
echo ""

# 1. Fix permissions
echo -e "${BLUE}🔧 Fixing permissions...${NC}"
git config --global --add safe.directory ${APP_DIR}
sudo chown -R $(whoami):$(whoami) ${APP_DIR}
echo -e "${GREEN}✅ Permissions fixed${NC}"

# 2. Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
if command -v pnpm &> /dev/null; then
  pnpm install
else
  npm install
fi
echo -e "${GREEN}✅ Dependencies installed${NC}"

# 3. Build production
echo -e "${BLUE}🔨 Building production...${NC}"
if [ -d "dist" ]; then
  rm -rf dist
fi

if command -v pnpm &> /dev/null; then
  NODE_ENV=production pnpm build
else
  NODE_ENV=production npm run build
fi
echo -e "${GREEN}✅ Build complete${NC}"

# 4. Create logs dir
mkdir -p logs

# 5. Start PM2
echo -e "${BLUE}🔄 Starting PM2...${NC}"
pm2 delete ${APP_NAME} 2>/dev/null || true
pm2 start server.cjs --name ${APP_NAME}
echo -e "${GREEN}✅ PM2 started${NC}"

# 6. Save PM2 process list
pm2 save

echo ""
echo -e "${GREEN}🎉 Done! App running on port ${APP_PORT}${NC}"
echo ""
