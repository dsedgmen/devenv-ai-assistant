# AI Activity Monitor

The AI assistant includes an optional monitoring panel that tracks all AI operations in real-time.

## Features

- **Real-time Activity Log** - See all AI commands as they execute
- **Timing Information** - Track how long each operation takes
- **Backend Tracking** - Know which backend (Ollama/Claude) was used
- **Persistent Log** - Activities saved to `~/.cache/vim-ai-activity.log`
- **Toggle On/Off** - Enable/disable logging without closing the panel

## Quick Start

```vim
:AILogging          " Enable logging
:AIMonitor          " Open monitor panel
<Space>ac           " Use AI features - watch them appear in monitor
```

## Commands

| Command | Keybinding | Description |
|---------|------------|-------------|
| `:AIMonitor` | `<Space>am` | Toggle monitor panel on/off |
| `:AILogging` | `<Space>al` | Toggle activity logging on/off |
| `:AIMonitorClear` | - | Clear all logged activity |

## Monitor Panel Layout

```
┌─────────────────────┬─────────────────────────────────┐
│                     │ === AI Activity Monitor ===     │
│                     │ Tracking all operations         │
│   Your Code         │                                 │
│   (Main Editor)     │ [14:23:45] AI Complete...       │
│                     │ [14:23:48] Completed in 3s      │
│                     │ [14:24:12] Executing: review... │
│                     │ [14:24:18] Completed in 6s      │
│                     │ [14:25:03] Backend switched...  │
│                     │                                 │
│                     │ (Auto-scrolls to latest)        │
└─────────────────────┴─────────────────────────────────┘
```

## Example Log Output

```
[2026-06-25 14:23:45] Logging enabled
[2026-06-25 14:23:45] AI Complete (inline): lang=python, backend=ollama
[2026-06-25 14:23:48] Completed in 3s, inserted 5 lines
[2026-06-25 14:24:12] Executing: review test.py python [backend=ollama]
[2026-06-25 14:24:18] Completed in 6s, output lines: 42
[2026-06-25 14:25:03] Backend switched: ollama -> claude
[2026-06-25 14:25:15] AI Complete (inline): lang=javascript, backend=claude
[2026-06-25 14:25:16] Completed in 1s, inserted 8 lines
```

## What Gets Logged

- AI Complete (inline and split) - with language and timing
- AI Review - with file/selection and duration  
- AI Explain - with context
- AI Refactor - with instructions
- AI Generate - code generation requests
- AI Chat - questions asked
- Backend Switches - Ollama ↔ Claude
- Errors and failures

## Use Cases

### 1. Debug Slow Responses

```vim
:AIMonitor          " Open monitor
:AILogging          " Enable logging
<Space>ac           " Test with current backend
" Check timing in monitor
<Space>ab           " Switch backend
<Space>ac           " Test again
" Compare timings between Ollama and Claude
```

### 2. Track Usage Patterns

```vim
:AIMonitor
:AILogging
" Work normally for your session
" Review monitor to see which features you use most
" Check which backend you use more often
```

### 3. Learn the Plugin

```vim
:AIMonitor
" Try different commands and see what they do
<Space>ac           " See: "AI Complete (inline)"
<Space>ar           " See: "Executing: review..."
<Space>ab           " See: "Backend switched"
```

### 4. Performance Comparison

```vim
:AILogging
" Do several operations with Ollama
" Switch to Claude with <Space>ab
" Do same operations with Claude
" Review ~/.cache/vim-ai-activity.log for timing comparison
```

## Log File

Activity is persisted to: `~/.cache/vim-ai-activity.log`

View outside vim:
```bash
# Watch real-time
tail -f ~/.cache/vim-ai-activity.log

# View all
cat ~/.cache/vim-ai-activity.log

# Last 50 entries
tail -50 ~/.cache/vim-ai-activity.log

# Search for specific operations
grep "Complete" ~/.cache/vim-ai-activity.log
grep "backend=claude" ~/.cache/vim-ai-activity.log
```

## Tips

1. **Keep monitor open while learning** - see what commands do in real-time
2. **Disable logging during normal use** - reduces overhead, panel still works
3. **Check timing** to compare Ollama vs Claude performance
4. **Clear periodically** - `AIMonitorClear` to prevent large log files
5. **Review patterns** - see which features you use most

## Performance

- **Logging disabled**: No performance impact
- **Logging enabled**: Minimal overhead (~1ms per operation)  
- **Monitor panel**: Real-time updates, auto-scrolls

## Privacy

- Logs stored locally in `~/.cache/`
- No data sent anywhere (except to your configured AI backend)
- Clear anytime with `:AIMonitorClear`
- Disable logging with `<Space>al` for sensitive work

## Troubleshooting

**Monitor doesn't open:**
- Check `:messages` for errors
- Ensure `~/.cache/` directory exists

**No logs appearing:**
- Enable logging with `:AILogging` or `<Space>al`
- Check if `log_enabled` is true

**Log file too large:**
- Run `:AIMonitorClear` to clear
- Or manually: `rm ~/.cache/vim-ai-activity.log`

**Monitor window too narrow/wide:**
- Resize with normal vim window commands: `Ctrl+w` `>` or `<`
- Default width is 60 columns
