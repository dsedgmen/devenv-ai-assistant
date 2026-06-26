# Tree-sitter Language Support

Complete guide to adding languages to tree-sitter in Neovim.

## Quick Start

```bash
cd ~/vim-ai-assistant
./install-treesitter-languages.sh
```

Interactive menu lets you:
1. Install ALL languages
2. Select specific languages
3. View currently installed parsers

---

## Available Languages in Fedora Repos

### Currently Configured (15 languages)
These are already set up in your `treesitter-config.lua`:

**Core Development:**
- Python
- Bash
- C
- C++
- Go
- Rust
- Java

**Web Development:**
- JavaScript
- TypeScript
- HTML
- CSS
- JSON

**Configuration:**
- YAML
- Lua
- Ruby

### Available to Add (8 more languages)

Install with the script or manually:

| Language | Package | Use Case |
|----------|---------|----------|
| **C#** | `tree-sitter-c-sharp` | .NET development |
| **Elixir** | `tree-sitter-elixir` | Functional programming |
| **HEEx** | `tree-sitter-heex` | Elixir Phoenix templates |
| **PHP** | `tree-sitter-php` | Web backend |
| **PHPDoc** | `tree-sitter-phpdoc` | PHP documentation |
| **JSDom** | `tree-sitter-jsdoc` | JavaScript documentation |
| **CMake** | `tree-sitter-cmake` | Build system |
| **TOML** | `tree-sitter-toml` | Config files |

---

## Manual Installation

### Install All Languages

```bash
sudo dnf install -y \
    tree-sitter-bash \
    tree-sitter-c \
    tree-sitter-cmake \
    tree-sitter-cpp \
    tree-sitter-c-sharp \
    tree-sitter-css \
    tree-sitter-elixir \
    tree-sitter-go \
    tree-sitter-heex \
    tree-sitter-html \
    tree-sitter-java \
    tree-sitter-javascript \
    tree-sitter-jsdoc \
    tree-sitter-json \
    tree-sitter-lua \
    tree-sitter-php \
    tree-sitter-phpdoc \
    tree-sitter-python \
    tree-sitter-ruby \
    tree-sitter-rust \
    tree-sitter-toml \
    tree-sitter-typescript \
    tree-sitter-yaml
```

### Install Specific Languages

**C# Development:**
```bash
sudo dnf install tree-sitter-c-sharp
```

**Elixir Development:**
```bash
sudo dnf install tree-sitter-elixir tree-sitter-heex
```

**PHP Development:**
```bash
sudo dnf install tree-sitter-php tree-sitter-phpdoc
```

**CMake Projects:**
```bash
sudo dnf install tree-sitter-cmake
```

**TOML Configs:**
```bash
sudo dnf install tree-sitter-toml
```

---

## Configuration

After installing new parsers, update `~/.config/nvim/lua/treesitter-config.lua`:

### Add Language to Config

```lua
local treesitter_langs = {
    "python",
    "bash",
    -- ... existing languages ...
    
    -- Add new languages here:
    "c_sharp",      -- For C# (tree-sitter-c-sharp)
    "php",          -- For PHP (tree-sitter-php)
    "toml",         -- For TOML (tree-sitter-toml)
    -- etc.
}
```

**Note:** Language names in config may differ from package names:
- Package: `tree-sitter-c-sharp` → Config: `c_sharp`
- Package: `tree-sitter-javascript` → Config: `javascript`

### Reload Configuration

```vim
:source ~/.config/nvim/init.lua
```

Or restart neovim.

---

## What Tree-sitter Provides

### 1. Advanced Syntax Highlighting

**Regular vim syntax:**
```python
def calculate(a, b):  # All one color
    return a + b       # Limited highlighting
```

**Tree-sitter syntax:**
```python
def calculate(a, b):  # Keywords, functions, params all different colors
    return a + b       # Operators, variables, return values highlighted
```

Tree-sitter understands **semantic meaning**, not just regex patterns.

### 2. Code Folding

```vim
za    " Toggle fold at cursor
zc    " Close fold
zo    " Open fold
zR    " Open all folds
zM    " Close all folds
```

Folds based on code structure (functions, classes, blocks).

### 3. Better Text Objects

Tree-sitter enables semantic text objects:
- Whole functions
- Class definitions
- Code blocks
- Parameter lists

(Requires additional plugins, but foundation is there)

### 4. Incremental Parsing

Tree-sitter re-parses **only changed parts** of the file:
- Fast even on large files
- Syntax highlighting doesn't lag
- Real-time feedback

---

## Language-Specific Features

### Python
```python
# Tree-sitter understands:
class MyClass:           # Class definition
    def __init__(self):  # Special method
        self.value = 10  # Attribute
        
async def fetch():       # Async function
    await something()    # Await keyword
```

### JavaScript/TypeScript
```javascript
// Tree-sitter understands:
const MyComponent = () => {  // Arrow function
    const [state, setState] = useState();  // Destructuring
    return <div>JSX</div>;   // JSX syntax
};
```

### Rust
```rust
// Tree-sitter understands:
pub struct Config {      // Visibility + struct
    value: Option<T>,    // Generic types
}

impl<T> Config<T> {     // Generic impl
    fn new() -> Self {}  // Self type
}
```

### Go
```go
// Tree-sitter understands:
type Server struct {     // Type definition
    port int `json:"port"`  // Tags
}

func (s *Server) Start() error {  // Method
    // ...
}
```

---

## Verification

### Check Installed Parsers

```bash
rpm -qa | grep tree-sitter
```

Example output:
```
tree-sitter-python-0.23.8-1.fc44.x86_64
tree-sitter-rust-0.23.6-1.fc44.x86_64
tree-sitter-go-0.23.5-1.fc44.x86_64
...
```

### Test in Neovim

```bash
# Open a file
nvim test.py

# Check tree-sitter status
:TSPlaygroundToggle    # If nvim-treesitter plugin installed
# Or just observe syntax highlighting
```

### View Active Highlights

```vim
:Inspect    " Show highlight group under cursor
```

If tree-sitter is active, you'll see groups like:
- `@function.python`
- `@keyword.python`
- `@variable.python`

---

## Troubleshooting

### Parser Not Loading

**Check if installed:**
```bash
rpm -qa | grep tree-sitter-python
```

**Check if configured:**
```bash
grep -i python ~/.config/nvim/lua/treesitter-config.lua
```

**Reload config:**
```vim
:source ~/.config/nvim/init.lua
```

### Syntax Highlighting Not Working

**Enable tree-sitter manually:**
```vim
:TSBufEnable highlight
```

**Check tree-sitter is running:**
```vim
:lua print(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()])
```

Should print `table: 0x...` if active, `nil` if not.

### Wrong Colors

Tree-sitter uses your color scheme. Some color schemes don't support tree-sitter highlights.

**Test with a tree-sitter-aware theme:**
```vim
:colorscheme jellybeans   " vim-jellybeans package
```

Or stick with default neovim theme (already tree-sitter aware).

---

## Comparison: With vs Without Tree-sitter

### Without Tree-sitter (Regular Vim Syntax)

**Pros:**
- Works in regular vim
- Fast on old hardware
- Simple configuration

**Cons:**
- Basic highlighting (regex-based)
- Doesn't understand semantics
- Can break on complex syntax
- No incremental parsing

### With Tree-sitter (Neovim)

**Pros:**
- Semantic highlighting
- Understands code structure
- Incremental parsing (fast)
- Better text objects
- Accurate folding

**Cons:**
- Neovim only (not regular vim)
- Requires parser packages
- Slightly more memory

**Verdict:** Tree-sitter is worth it for Neovim users!

---

## Adding Custom Languages

If a language isn't in Fedora repos, you have two options:

### Option 1: Request in Fedora (Preferred)

File a package request:
```bash
# Example for a new language "zig"
# Search if it exists first:
dnf search tree-sitter-zig

# If not found, request it on Fedora Bugzilla
# https://bugzilla.redhat.com/
```

Maintains your "repos only" constraint!

### Option 2: Manual Install (Breaks Constraint)

⚠️ **This violates your "repos only" constraint!**

But for reference:
```bash
# Clone parser
git clone https://github.com/tree-sitter/tree-sitter-zig

# Build (requires compiler)
cd tree-sitter-zig
cc -shared src/parser.c -o zig.so -fPIC

# Install to system
sudo cp zig.so /usr/lib64/tree-sitter/
```

**Not recommended** - stick to Fedora repos!

---

## Language Coverage

### Excellent Coverage (23 languages in Fedora repos)

✅ **System Programming:** C, C++, Rust, Go
✅ **Scripting:** Python, Bash, Ruby, Lua, PHP, Elixir
✅ **Web:** JavaScript, TypeScript, HTML, CSS, JSDoc
✅ **Data:** JSON, YAML, TOML
✅ **Enterprise:** Java, C#
✅ **Build:** CMake
✅ **Templates:** HEEx, PHPDoc

### Missing from Fedora Repos

Languages you'd need to build manually (violates constraint):
- ❌ Zig
- ❌ Kotlin
- ❌ Swift
- ❌ Haskell
- ❌ OCaml
- ❌ Scala

For these, you can:
1. Request packaging in Fedora
2. Use regular vim syntax (still works!)
3. Build manually (not recommended)

---

## Best Practices

### 1. Install What You Use

Don't install all 23 parsers if you only code in Python and Go.

```bash
# Example: Python + Web dev
sudo dnf install \
    tree-sitter-python \
    tree-sitter-javascript \
    tree-sitter-typescript \
    tree-sitter-html \
    tree-sitter-css \
    tree-sitter-json
```

### 2. Keep Config Updated

When you install new parsers, update `treesitter-config.lua`:

```lua
local treesitter_langs = {
    "python",   -- If tree-sitter-python installed
    "rust",     -- If tree-sitter-rust installed
    -- etc.
}
```

### 3. Test After Installation

```bash
nvim test.py
# Check syntax highlighting
# Try code folding (za)
```

### 4. Update Regularly

```bash
sudo dnf update tree-sitter-*
```

Parsers get bug fixes and new features.

---

## Summary

**Quick Install:**
```bash
./install-treesitter-languages.sh
```

**Manual Install (all languages):**
```bash
sudo dnf install tree-sitter-*
```

**Check Installed:**
```bash
rpm -qa | grep tree-sitter
```

**Test:**
```bash
nvim test.py
```

**All from Fedora repos - maintains your security constraint!** 🌳

---

## What You Have Now

### Complete Language Support

**Editor Features:**
- ✅ Semantic syntax highlighting (tree-sitter)
- ✅ LSP (definitions, hover, completion)
- ✅ AI assistance (code generation, review)
- ✅ Git integration (fugitive, gitgutter)
- ✅ Fast navigation (CtrlP, NERDTree)

**Language Coverage:**
- ✅ 15+ languages with tree-sitter
- ✅ 8+ more available to add
- ✅ LSP for Python, Go, Bash
- ✅ All from system repos

Your neovim is now a **complete polyglot IDE**! 🚀
