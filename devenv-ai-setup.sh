#!/bin/bash
# AI Coding Assistant Setup Script

echo "================================================"
echo "AI Coding Assistant Setup for Vim/Neovim"
echo "================================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Error: Do not run this script as root"
    exit 1
fi

# Step 1: Install packages
echo "Step 1: Installing packages from system repositories..."
echo "This will install: ollama, python3-ollama, python3-openai"
echo "(optional) python3-google-genai for Gemini backend"
echo ""

sudo dnf install -y ollama python3-ollama python3-openai

if [ $? -ne 0 ]; then
    echo "Error: Package installation failed"
    exit 1
fi

# Optional Gemini client (ignore failure if not in repos)
sudo dnf install -y python3-google-genai 2>/dev/null || echo "Note: python3-google-genai not available; Gemini backend optional."

echo ""
echo "✓ Packages installed successfully"
echo ""

# Step 2: Enable and start Ollama service
echo "Step 2: Enabling Ollama service..."
sudo systemctl enable --now ollama

if [ $? -ne 0 ]; then
    echo "Warning: Could not enable ollama service. You may need to start it manually."
else
    echo "✓ Ollama service enabled and started"
fi

echo ""

# Step 3: Wait for Ollama to be ready
echo "Step 3: Waiting for Ollama to be ready..."
sleep 3

# Check if Ollama is running
if ! systemctl is-active --quiet ollama; then
    echo "Warning: Ollama service is not running. Attempting to start..."
    sudo systemctl start ollama
    sleep 2
fi

echo "✓ Ollama is ready"
echo ""

# Step 4: Download Granite Code model
echo "Step 4: Downloading Granite Code model..."
echo "This may take several minutes depending on your connection..."
echo ""

ollama pull granite-code:latest

if [ $? -ne 0 ]; then
    echo "Error: Failed to download Granite Code model"
    echo "You can try again later with: ollama pull granite-code:latest"
    exit 1
fi

echo ""
echo "✓ Granite Code model downloaded successfully"
echo ""

# Step 5: Test Ollama
echo "Step 5: Testing Ollama with Granite Code..."
echo "Testing with a simple prompt..."
echo ""

echo "def hello():" | ollama run granite-code:latest "Complete this Python function" | head -10

echo ""
echo "✓ Ollama test completed"
echo ""

# Step 6: Setup environment variables
echo "Step 6: Setting up environment variables..."
echo ""

# Check if .bashrc already has the config
if ! grep -q "DEVENV_AI_BACKEND" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# AI Coding Assistant Configuration
export DEVENV_AI_BACKEND=ollama                    # ollama | claude | gemini
export DEVENV_AI_OLLAMA_MODEL=granite-code:latest
export DEVENV_AI_CLAUDE_MODEL=claude-sonnet-4-5@20250929
export DEVENV_AI_GEMINI_MODEL=gemini-2.0-flash
# export ANTHROPIC_API_KEY=your-key-here
# export GEMINI_API_KEY=your-key-here

# Add devenv-ai-helper to PATH
export PATH="$HOME/.local/bin:$PATH"
EOF
    echo "✓ Environment variables added to ~/.bashrc"
else
    echo "✓ Environment variables already configured in ~/.bashrc"
fi

echo ""

# Step 7: Test devenv-ai-helper
echo "Step 7: Testing devenv-ai-helper script..."
echo ""

# Source the new environment
export PATH="$HOME/.local/bin:$PATH"
export DEVENV_AI_BACKEND=ollama
export DEVENV_AI_OLLAMA_MODEL=granite-code:latest

if command -v devenv-ai-helper >/dev/null 2>&1; then
    echo "✓ devenv-ai-helper found at $(command -v devenv-ai-helper)"
elif [ -x ~/.local/bin/devenv-ai-helper ]; then
    echo "✓ devenv-ai-helper is executable at ~/.local/bin/devenv-ai-helper"
else
    echo "Warning: devenv-ai-helper not on PATH. Run ./install.sh or install the devenv-ai-helper RPM."
fi

echo ""

# Step 8: Summary
echo "================================================"
echo "Setup Complete!"
echo "================================================"
echo ""
echo "Installed components:"
echo "  ✓ Ollama service (running)"
echo "  ✓ Python AI clients (ollama, openai)"
echo "  ✓ Granite Code model"
echo "  ✓ Vim configuration (~/.vimrc)"
echo "  ✓ Neovim configuration (~/.config/nvim/init.lua)"
echo "  ✓ AI helper script (~/.local/bin/devenv-ai-helper)"
echo ""
echo "To use:"
echo "  1. Restart your shell or run: source ~/.bashrc"
echo "  2. Open vim or nvim"
echo "  3. Use <Space>a followed by:"
echo "     - c: Complete code"
echo "     - r: Review code"
echo "     - g: Generate code"
echo "     - q: Chat/Ask questions"
echo "     - b: Switch backend (Ollama ↔ Claude)"
echo ""
echo "  In visual mode (after selecting text):"
echo "     - e: Explain selection"
echo "     - f: Refactor selection"
echo ""
echo "Current backend: Ollama (Granite Code)"
echo ""
echo "To use Claude API instead:"
echo "  1. Get API key from: https://console.anthropic.com/"
echo "  2. Add to ~/.bashrc: export ANTHROPIC_API_KEY=your-key"
echo "  3. Set backend: export DEVENV_AI_BACKEND=claude"
echo "  4. Or switch in vim: <Space>ab"
echo ""
echo "Available models in Ollama:"
ollama list
echo ""
echo "Enjoy your AI-powered coding!"
echo ""
