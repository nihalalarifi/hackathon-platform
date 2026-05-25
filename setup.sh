#!/bin/bash

echo "=================================="
echo "HACKATHON PLATFORM - SETUP SCRIPT"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Python
echo -e "${YELLOW}Checking Python installation...${NC}"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓ Python found: $PYTHON_VERSION${NC}"
else
    echo -e "${RED}✗ Python not found. Please install Python 3.8+${NC}"
    exit 1
fi

# Check pip
echo -e "${YELLOW}Checking pip installation...${NC}"
if command -v pip3 &> /dev/null; then
    PIP_VERSION=$(pip3 --version)
    echo -e "${GREEN}✓ pip found: $PIP_VERSION${NC}"
else
    echo -e "${RED}✗ pip not found. Please install pip${NC}"
    exit 1
fi

# Install Python dependencies
echo ""
echo -e "${YELLOW}Installing Python dependencies...${NC}"
pip3 install -r requirements.txt
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Python dependencies installed successfully${NC}"
else
    echo -e "${RED}✗ Failed to install Python dependencies${NC}"
    exit 1
fi

# Check Flutter
echo ""
echo -e "${YELLOW}Checking Flutter installation...${NC}"
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo -e "${GREEN}✓ Flutter found: $FLUTTER_VERSION${NC}"
else
    echo -e "${YELLOW}! Flutter not found. Please install Flutter SDK from https://flutter.dev${NC}"
    echo -e "${YELLOW}  Backend setup completed. Frontend requires Flutter.${NC}"
fi

echo ""
echo -e "${GREEN}=================================="
echo "SETUP COMPLETED SUCCESSFULLY!"
echo "==================================${NC}"
echo ""
echo "To start the backend:"
echo -e "${YELLOW}  python3 backend_app.py${NC}"
echo ""
echo "To setup Flutter frontend:"
echo -e "${YELLOW}  1. flutter create hackathon_platform${NC}"
echo -e "${YELLOW}  2. Copy hackathon_app.dart to lib/main.dart${NC}"
echo -e "${YELLOW}  3. Copy pubspec.yaml${NC}"
echo -e "${YELLOW}  4. flutter pub get${NC}"
echo -e "${YELLOW}  5. flutter run${NC}"
echo ""
echo "For detailed instructions, see README.md"
