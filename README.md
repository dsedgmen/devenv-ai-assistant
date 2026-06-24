# AI Coding Assistant for Vim/Neovim

Complete AI coding assistant supporting both **Ollama (local Granite Code model)** and **Claude API**.

Works with standard vim and neovim. All dependencies installable from Fedora system repositories.

## Features

- ✅ **Code Completion** - Inline or in split window
- ✅ **Code Explanation** - Understand complex code
- ✅ **Code Review** - Find bugs and improvements
- ✅ **Refactoring** - Automated code transformations
- ✅ **Code Generation** - Generate from descriptions
- ✅ **Chat/Q&A** - Ask questions about your code
- ✅ **Dual Backend** - Switch between local Ollama and Claude API
- ✅ **Privacy First** - Local-only option with Ollama

## Quick Start

### 1. Clone this repo

```bash
git clone https://github.com/yourusername/vim-ai-assistant.git
cd vim-ai-assistant
```

### 2. Install configuration files

```bash
./install.sh
```

### 3. Install packages and models

```bash
~/.config/vim-ai-setup.sh
```

This will:
1. Install Ollama, Python clients from system repos (Fedora)
2. Download Granite Code model
3. Set up environment variables

## Manual Installation

If you prefer manual setup:

### 1. Install packages

```bash
sudo dnf install -y ollama python3-ollama python3-openai
```

### 2. Enable Ollama service

```bash
sudo systemctl enable --now ollama
```

### 3. Download Granite Code model

```bash
ollama pull granite-code:latest
```

### 4. Configure environment

Add to your `~/.bashrc`:

```bash
export VIM_AI_BACKEND=ollama                    # ollama or claude
export VIM_AI_OLLAMA_MODEL=granite-code:latest
export PATH="$HOME/.local/bin:$PATH"

# For Claude API (optional):
# export ANTHROPIC_API_KEY=your-key-here
```

Then reload: `source ~/.bashrc`

## Usage

All commands use **Space** as the leader key.

### Normal Mode Commands

| Keybinding | Command | Description |
|------------|---------|-------------|
| `<Space>ac` | `:AIComplete` | Complete code from cursor |
| `<Space>ar` | `:AIReview` | Review entire file for bugs/improvements |
| `<Space>ag` | `:AIGenerate` | Generate code from description |
| `<Space>aq` | `:AIChat` | Ask AI a question |
| `<Space>ab` | `:AISwitchBackend` | Toggle Ollama ↔ Claude |

### Visual Mode Commands

Select text first, then:

| Keybinding | Command | Description |
|------------|---------|-------------|
| `<Space>ae` | `:AIExplain` | Explain selected code |
| `<Space>ar` | `:AIReview` | Review selected code |
| `<Space>af` | `:AIRefactor` | Refactor selection with prompt |
| `<Space>aq` | `:AIChat` | Ask about selected code |

## Example Workflows

### 1. Code Completion

```vim
def calculate_fibonacci(n):
    # cursor here
```

Press `<Space>ac` to complete the function.

### 2. Code Review

Select buggy code, press `<Space>ar` for review.

### 3. Explain Complex Code

Select confusing code, press `<Space>ae` for explanation.

### 4. Refactor

Select code, press `<Space>af`, type: "use list comprehension"

### 5. Generate New Code

Press `<Space>ag`, type: "function to parse JSON and handle errors"

### 6. Ask Questions

Select code, press `<Space>aq`, ask: "Why is this slow?"

## Backend Switching

### Use Ollama (Local Granite)

```bash
export VIM_AI_BACKEND=ollama
```

Or in vim: `<Space>ab`

**Pros:**
- Completely offline
- Free
- Privacy - code never leaves your machine
- Works in air-gapped environments

**Cons:**
- Slower than Claude
- Lower quality for complex tasks
- Requires GPU for best performance

### Use Claude API

```bash
export ANTHROPIC_API_KEY=sk-ant-...
export VIM_AI_BACKEND=claude
```

Or in vim: `<Space>ab`

**Pros:**
- Best code quality
- Faster responses
- Better at complex refactoring

**Cons:**
- Requires internet
- Costs money (per-use)
- Code sent to Anthropic

## Advanced Configuration

### Use Different Ollama Models

```bash
# List available models
ollama list

# Pull other models
ollama pull codellama
ollama pull deepseek-coder

# Switch model
export VIM_AI_OLLAMA_MODEL=codellama:latest
```

### Customize Keybindings

Edit `~/.vimrc` (vim) or `~/.config/nvim/init.lua` (neovim):

```vim
" Change leader from Space to comma
let mapleader = ","

" Or remap individual commands
nnoremap <Leader>cc :call <SID>AIComplete()<CR>
```

### Direct Script Usage

The helper script can be used outside vim:

```bash
# Complete code
echo "def hello():" > test.py
vim-ai-helper complete test.py python

# Explain code
vim-ai-helper explain test.py python

# Review code
vim-ai-helper review test.py python

# Generate code
vim-ai-helper generate "function to sort list" python

# Chat
vim-ai-helper chat "How do I use async in Python?"

# Force specific backend
vim-ai-helper complete test.py python claude
vim-ai-helper complete test.py python ollama
```

## Troubleshooting

### Ollama not starting

```bash
sudo systemctl status ollama
sudo systemctl start ollama
journalctl -u ollama -f
```

### Model not found

```bash
ollama list
ollama pull granite-code:latest
```

### Python import errors

```bash
# Check installations
rpm -q python3-ollama python3-openai

# Reinstall if needed
sudo dnf reinstall python3-ollama python3-openai
```

### Slow responses

Ollama performance depends on your hardware:
- CPU-only: Slow (10-30s)
- GPU (NVIDIA): Fast (1-3s)

Check GPU usage:
```bash
nvidia-smi
```

### Claude API errors

```bash
# Check API key is set
echo $ANTHROPIC_API_KEY

# Test with curl
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-5@20250929","max_tokens":100,"messages":[{"role":"user","content":"Hi"}]}'
```

## Status Line

Both vim and neovim show the current backend in the status line:

```
filename.py [+]                    ollama | 42,10 50%
```

Press `<Space>ab` to toggle between `ollama` and `claude`.

## Architecture

```
┌─────────────────────────────────────────────┐
│  Vim/Neovim                                 │
│  - Keybindings (init.lua / .vimrc)         │
│  - Commands (:AIComplete, etc.)             │
└────────────────┬────────────────────────────┘
                 │
                 v
┌─────────────────────────────────────────────┐
│  ~/.local/bin/vim-ai-helper                 │
│  - Python script                            │
│  - Routes to Ollama or Claude               │
│  - Handles prompts & context                │
└────────────┬───────────────────┬────────────┘
             │                   │
             v                   v
┌────────────────────┐  ┌───────────────────┐
│  Ollama            │  │  Claude API       │
│  - Local service   │  │  - Remote API     │
│  - Granite Code    │  │  - Sonnet 4.5     │
│  - Port 11434      │  │  - HTTPS          │
└────────────────────┘  └───────────────────┘
```

## File Locations

```
~/.vimrc                         # Vim config
~/.config/nvim/init.lua          # Neovim config
~/.local/bin/vim-ai-helper       # Python backend
~/.config/vim-ai-setup.sh        # Installation script
~/.config/vim-ai-README.md       # This file
```

## What Each Backend is Best For

### Ollama (Granite Code)

Best for:
- Quick completions
- Simple refactoring
- Learning/experimenting
- Offline work
- Privacy-sensitive code
- High-frequency usage (free)

### Claude API (Sonnet 4.5)

Best for:
- Complex refactoring
- Architecture questions
- Code review with context
- Generating complex algorithms
- Explaining intricate code
- Production-quality code

## Tips

1. **Start with Ollama** - Free and instant. Switch to Claude for hard problems.

2. **Visual selection** - Always select the relevant code before asking questions.

3. **Specific prompts** - "Refactor to use list comprehension" beats "improve this"

4. **Iterate** - Use `<Space>af` to refactor, review output, refine prompt.

5. **Context matters** - Select surrounding code when asking questions.

6. **Review before applying** - AI suggestions open in a split; review before copying.

## Security Notes

- **Ollama**: All processing is local. Code never leaves your machine.
- **Claude API**: Code is sent to Anthropic's servers. Don't use with sensitive/proprietary code unless your org approves.
- Set `VIM_AI_BACKEND=ollama` for sensitive projects.

## Repository Constraint

All components installed from system repositories only:
- `ollama` from Fedora repos
- `python3-ollama` from Fedora repos  
- `python3-openai` from Fedora repos
- No external packages or repos added

## Support

For issues with:
- **Vim/Neovim config**: Check ~/.vimrc or ~/.config/nvim/init.lua
- **Ollama**: `systemctl status ollama`, check logs
- **Models**: `ollama list`, try re-pulling
- **Python**: Check package installations with `rpm -q`

Enjoy your AI-powered coding experience!
