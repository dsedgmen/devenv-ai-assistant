# Adding Gemini Support

Your vim AI assistant now supports **three backends**:
1. **Ollama** (Granite Code) - Local, free, offline
2. **Claude** (Anthropic) - Best quality, remote API
3. **Gemini** (Google) - Fast, cost-effective, remote API ✨ NEW

## Installation

### Step 1: Install Gemini Python Client

```bash
sudo dnf install python3-google-genai
```

This is Google's official Gemini SDK, from Fedora repos!

### Step 2: Get Gemini API Key

1. Go to: https://aistudio.google.com/app/apikey
2. Sign in with Google account
3. Click "Create API Key"
4. Copy your API key

### Step 3: Configure Environment

Add to your `~/.bashrc`:

```bash
# Gemini API configuration
export GEMINI_API_KEY="your-key-here"
export VIM_AI_GEMINI_MODEL="gemini-2.0-flash-exp"  # or other model
```

Then reload:
```bash
source ~/.bashrc
```

## Available Gemini Models

| Model | Best For | Speed | Cost |
|-------|----------|-------|------|
| `gemini-2.0-flash-exp` | General coding (default) | Very Fast | Free* |
| `gemini-1.5-pro` | Complex tasks | Fast | Paid |
| `gemini-1.5-flash` | Quick tasks | Very Fast | Paid |

*Free tier available with limits

## Usage

### Switch to Gemini

In neovim, press `<Space>ab` to cycle through backends:
```
ollama → claude → gemini → ollama → ...
```

Or set directly in environment:
```bash
export VIM_AI_BACKEND=gemini
```

### Test Gemini

```bash
# Command line test
vim-ai-helper chat "Hello from Gemini!" gemini

# In neovim
nvim test.py
<Space>ab  # Switch until you see "Switched to: gemini"
<Space>ac  # Generate completion with Gemini
```

## Backend Comparison

| Feature | Ollama | Claude | Gemini |
|---------|--------|--------|--------|
| **Speed** | Medium (local GPU) | Fast | Very Fast |
| **Quality** | Good | Excellent | Very Good |
| **Cost** | Free | $$$ | $ |
| **Offline** | ✅ Yes | ❌ No | ❌ No |
| **Privacy** | ✅ Local | ❌ Remote | ❌ Remote |
| **API Key** | None | Required | Required |
| **Rate Limits** | None | By tier | Generous free tier |

## When to Use Each

### Use Ollama (Granite):
- Offline work
- Privacy-sensitive code
- Learning/experimenting
- Free unlimited usage

### Use Claude (Sonnet):
- Best code quality needed
- Complex refactoring
- Production code
- Detailed explanations

### Use Gemini (Flash):
- Fast responses needed
- Cost-conscious usage
- Good balance of speed/quality
- Free tier exploration

## Configuration

### Custom Model

```bash
# Use a different Gemini model
export VIM_AI_GEMINI_MODEL="gemini-1.5-pro"
```

### Set as Default

```bash
# Make Gemini the default backend
export VIM_AI_BACKEND=gemini
```

## Commands

All AI commands work with Gemini:

```vim
<Space>ac   - Complete code (Gemini)
<Space>ax   - Fix bugs (Gemini)
<Space>aq   - Interactive chat (Gemini)
<Space>ar   - Review code (Gemini)
<Space>ab   - Switch backend
```

## Command Line Usage

```bash
# Complete code
vim-ai-helper complete test.py python gemini

# Chat
vim-ai-helper chat "Explain async in Python" gemini

# Review
vim-ai-helper review test.py python gemini
```

## Troubleshooting

### ImportError: No module named 'google.genai'

```bash
# Install the package
sudo dnf install python3-google-genai

# Verify
python3 -c "from google import genai; print('OK')"
```

### API Key Error

Check your key is set:
```bash
echo $GEMINI_API_KEY
```

Test directly:
```bash
python3 << EOF
from google import genai
client = genai.Client(api_key="$GEMINI_API_KEY")
response = client.models.generate_content(
    model="gemini-2.0-flash-exp",
    contents="Hello!"
)
print(response.text)
EOF
```

### Rate Limit Errors

Free tier limits:
- 15 requests per minute
- 1M tokens per day

Switch to another backend or wait a minute.

## System Repos Only

✅ `python3-google-genai` from Fedora repos
✅ No pip installs needed
✅ Signed RPM package
✅ System updates via dnf

## Cost Comparison

Example: 100K input tokens, 10K output tokens

| Backend | Cost | Notes |
|---------|------|-------|
| Ollama | $0 | Local, free |
| Claude Sonnet | ~$0.60 | High quality |
| Gemini Flash | ~$0.04 | Free tier available |

Gemini is ~15x cheaper than Claude for similar tasks!

## Example Workflow

```vim
" Working on sensitive code? Use Ollama
:let $VIM_AI_BACKEND='ollama'
<Space>ac

" Need best quality? Use Claude
:let $VIM_AI_BACKEND='claude'
<Space>ac

" Fast iteration? Use Gemini
:let $VIM_AI_BACKEND='gemini'
<Space>ac

" Or just cycle with <Space>ab
```

## Monitor Which Backend is Used

The activity monitor shows which backend handled each request:

```
<Space>am  # Open monitor
<Space>al  # Enable logging

[14:30:45] AI Complete: lang=python, backend=gemini
[14:30:46] Completed in 1s, generated 5 lines
```

## Next Steps

1. Install: `sudo dnf install python3-google-genai`
2. Get API key: https://aistudio.google.com/app/apikey
3. Set environment: `export GEMINI_API_KEY=...`
4. Test: `vim-ai-helper chat "test" gemini`
5. Use in nvim: `<Space>ab` to switch to Gemini

Now you have **three AI backends** to choose from!
