# Keybinds & Workflow Reference

## Launching a Dev Session

```bash
dev --agy [dir]      # tmux: agy (left pane) + shell/nvim (right pane)
dev --claude [dir]   # same layout with Claude Code
```

Set `export DEV_AGENT=agy` in `~/.zshrc.local` to make `dev` default to `agy`.

---

## Neovim → Agent Bridge (`<leader>a`)

Leader is `Space`. All bridge keys paste into the adjacent agent pane and focus it.

| Key | Mode | Action |
| :--- | :--- | :--- |
| `<leader>as` | Visual | Send `@file:start-end` |
| `<leader>af` | Normal | Send `@file` |
| `<leader>al` | Normal | Send `@file:line` |
| `<leader>ad` | Normal | Send LSP diagnostics on current line (or whole buffer) |

## Reviewing Agent Edits in Neovim

Open buffers reload automatically when you switch back from the agent pane (`focus-events` + `checktime`).

| Key | Context | Action |
| :--- | :--- | :--- |
| `<leader>av` | Normal | Toggle **Diffview** (side-by-side multi-file diff of all edits) |
| `<leader>ah` | Normal | Toggle **Diffview File History** for current file |
| `q` | Inside Diffview | Close Diffview |
| `]h` / `[h` | Normal | Next / previous git hunk (`gitsigns`) |
| `<leader>ghp` | Normal | Inline preview of hunk diff |
| `<leader>ghd` | Normal | Side-by-side diff of current buffer vs `HEAD` |
| `<leader>ghr` | Normal | Revert current hunk (`<leader>ghR` reverts whole file) |

## Neovim CMake (`<leader>m`)

| Key | Action |
| :--- | :--- |
| `<leader>mg` / `<leader>mb` / `<leader>mr` | CMake Generate / Build / Run |
| `<leader>md` / `<leader>mf` | Debug / Debug Current File |
| `<leader>mt` / `<leader>mT` | Select Launch / Build Target |
| `<leader>my` / `<leader>ma` / `<leader>mo` | Build Type / Launch Args / Open Output |

---

## Tmux

Press `Alt+/` inside tmux anytime to open the built-in quick reference popup.

| Key | Action |
| :--- | :--- |
| `Alt+h/j/k/l` | Navigate panes |
| `Ctrl+h/j/k/l` | Resize panes (repeatable) |
| `Alt+d` / `Alt+Shift+d` | Split vertical / horizontal |
| `Alt+f` | Toggle pane zoom (fullscreen) |
| `Alt+e` | Send last ~50 lines of active pane to agent pane |
| `Alt+Shift+h/l` | Previous / next window |
| `Alt+n` / `Alt+w` | New window / close pane |
| `Alt+/` | Open tmux reference popup |
| `Ctrl+a s` / `Ctrl+a d` | Switch session / detach |

---

## Antigravity CLI (`agy`)

### Built-in Slash Commands

- `/plan` — step-by-step plan before editing
- `/grill-me` — interview you to nail down design decisions before coding
- `/teamwork` — multi-agent team for larger projects
- `/goal` — run autonomously until verified
- `/compact` — summarize context to free window space
- `/learn` — save a correction/setup into persistent rules/skills
- `/schedule` — cron jobs & one-shot timers
- `/browser` — browser automation (requires Chrome v144+ remote debugging)
- `/model` / `/effort` / `/permissions` — change model, reasoning depth, or rules

### Custom Skills (`~/.gemini/config/skills/`)

- `/commit [path]` — stage, commit, push (never pushes to `main`/`master`)
- `/github-issue <n> [path]` — branch, implement, test, commit, draft PR
- `/gitlab-issue <n> [path]` — branch + draft MR, implement, test, commit
- `/weekly-update` / `/resume` — work weekly summary & resume bullets
- **Socratic Tutor:** say *"teach me \<topic\>"*, *"quiz me..."*, or *"drill me..."*
  - Mid-session commands: `show progress`, `harder`, `easier`, `just tell me`, `save state`, `resume from:`
