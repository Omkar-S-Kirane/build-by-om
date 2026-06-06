#!/usr/bin/env bash
set -euo pipefail

# ─── UTF-8 locale (required for CocoaPods) ──────────────────
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# ─── Colours ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { printf "${GREEN}✔${NC}  %s\n" "$1"; }
warn() { printf "${YELLOW}⚠${NC}  %s\n" "$1"; }
fail() { printf "${RED}✖${NC}  %s\n" "$1"; }
info() { printf "${CYAN}→${NC}  %s\n" "$1"; }
header() { printf "\n${BOLD}── %s ──${NC}\n" "$1"; }

REQUIRED_NODE_MAJOR=18
REQUIRED_NPM_MAJOR=9
ERRORS=0

# ─── 1. System checks ──────────────────────────────────────
header "Environment checks"

# Node.js
if ! command -v node &>/dev/null; then
  fail "Node.js is not installed. Install v${REQUIRED_NODE_MAJOR}+ from https://nodejs.org"
  ERRORS=$((ERRORS + 1))
else
  NODE_VERSION=$(node -v | sed 's/v//')
  NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
  if [ "$NODE_MAJOR" -lt "$REQUIRED_NODE_MAJOR" ]; then
    fail "Node.js v${NODE_VERSION} found — v${REQUIRED_NODE_MAJOR}+ required"
    ERRORS=$((ERRORS + 1))
  else
    ok "Node.js v${NODE_VERSION}"
  fi
fi

# npm
if ! command -v npm &>/dev/null; then
  fail "npm is not installed"
  ERRORS=$((ERRORS + 1))
else
  NPM_VERSION=$(npm -v)
  NPM_MAJOR=$(echo "$NPM_VERSION" | cut -d. -f1)
  if [ "$NPM_MAJOR" -lt "$REQUIRED_NPM_MAJOR" ]; then
    fail "npm v${NPM_VERSION} found — v${REQUIRED_NPM_MAJOR}+ required"
    ERRORS=$((ERRORS + 1))
  else
    ok "npm v${NPM_VERSION}"
  fi
fi

# Git
if command -v git &>/dev/null; then
  ok "Git $(git --version | awk '{print $3}')"
else
  warn "Git not found — version control won't work"
fi

# Watchman (optional, speeds up Metro)
if command -v watchman &>/dev/null; then
  ok "Watchman $(watchman --version 2>/dev/null || echo 'installed')"
else
  warn "Watchman not found — optional but improves Metro performance"
  info "Install: brew install watchman"
fi

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  fail "Fix the ${ERRORS} error(s) above before continuing."
  exit 1
fi

# ─── 2. Install dependencies ───────────────────────────────
header "Installing npm dependencies"
npm install
ok "npm packages installed"

# ─── 3. Expo doctor ────────────────────────────────────────
header "Running Expo doctor"
if npx expo-doctor 2>/dev/null; then
  ok "Expo doctor passed"
else
  warn "Expo doctor reported issues — check output above"
fi

# ─── 4. Platform-specific setup ────────────────────────────
OS="$(uname -s)"

if [ "$OS" = "Darwin" ]; then
  header "macOS platform setup"

  # Xcode CLI tools
  if xcode-select -p &>/dev/null; then
    ok "Xcode Command Line Tools installed"
  else
    warn "Xcode CLI tools missing — run: xcode-select --install"
  fi

  # CocoaPods
  if command -v pod &>/dev/null; then
    ok "CocoaPods $(LANG=en_US.UTF-8 pod --version 2>/dev/null || echo 'installed')"
  else
    warn "CocoaPods not found — required for iOS builds"
    info "Install: sudo gem install cocoapods"
  fi

  # Xcode license
  if xcodebuild -checkFirstLaunchStatus 2>/dev/null; then
    ok "Xcode license accepted"
  else
    warn "Xcode license not accepted — run: sudo xcodebuild -license accept"
  fi

  # iOS pods
  if [ -d "ios" ]; then
    header "Installing iOS pods"
    (cd ios && LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install)
    ok "iOS pods installed"
  else
    info "No ios/ directory yet — run 'npx expo prebuild --platform ios' to generate it, then re-run setup"
  fi

  # Android SDK check
  if [ -n "${ANDROID_HOME:-}" ] || [ -n "${ANDROID_SDK_ROOT:-}" ]; then
    ok "Android SDK found at ${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
  else
    warn "ANDROID_HOME not set — needed for Android builds"
    info "Install Android Studio: https://developer.android.com/studio"
  fi

  # Java
  if command -v java &>/dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -1 | awk -F '"' '{print $2}')
    ok "Java ${JAVA_VERSION}"
  else
    warn "Java not found — required for Android builds"
    info "Install: brew install --cask zulu@17"
  fi

elif [ "$OS" = "Linux" ]; then
  header "Linux platform setup"

  if [ -n "${ANDROID_HOME:-}" ] || [ -n "${ANDROID_SDK_ROOT:-}" ]; then
    ok "Android SDK found at ${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
  else
    warn "ANDROID_HOME not set — needed for Android builds"
  fi

  if command -v java &>/dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -1 | awk -F '"' '{print $2}')
    ok "Java ${JAVA_VERSION}"
  else
    warn "Java not found — required for Android builds"
  fi

  info "iOS builds require macOS"
fi

# ─── 5. Generate native projects (optional) ────────────────
header "Native project generation"
if [ -d "ios" ] || [ -d "android" ]; then
  ok "Native directories already exist"
else
  info "Native directories not found — this is normal for Expo managed workflow"
  info "To generate them, run: npx expo prebuild"
  info "Then re-run: npm run setup"
fi

# ─── 6. TypeScript check ───────────────────────────────────
header "TypeScript validation"
if npx tsc --noEmit 2>/dev/null; then
  ok "TypeScript compiles cleanly"
else
  warn "TypeScript errors found — check output above"
fi

# ─── Done ───────────────────────────────────────────────────
echo ""
printf "${GREEN}${BOLD}Setup complete!${NC}\n"
echo ""
info "Start commands:"
echo "   npm run web         → browser"
echo "   npm run ios         → iOS Simulator"
echo "   npm run android     → Android Emulator"
echo "   npm start           → Expo dev server (pick platform)"
echo ""
