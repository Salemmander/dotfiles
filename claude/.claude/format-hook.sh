#!/bin/bash

# Add Mason bin to PATH for formatters installed via neovim
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

# Read hook input from stdin
input=$(cat)

# Extract file path and session ID using jq
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
session_id=$(echo "$input" | jq -r '.session_id // "default"')

if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
	exit 0
fi

has_local_stylua_config() {
	local dir
	dir=$(dirname "$1")
	while [ "$dir" != "/" ] && [ "$dir" != "." ]; do
		if [ -f "$dir/stylua.toml" ] || [ -f "$dir/.stylua.toml" ]; then
			return 0
		fi
		dir=$(dirname "$dir")
	done
	return 1
}

# Format based on file extension (matching LazyVim/conform.nvim defaults)
case "$file_path" in
*.py)
	command -v ruff &>/dev/null && ruff format "$file_path"
	echo "$file_path" >>"/tmp/claude-ruff-${session_id}.txt"
	;;
*.lua)
	# Use nvim stylua.toml config if no local config exists
	if command -v stylua &>/dev/null; then
		if [ -f "$HOME/.config/nvim/stylua.toml" ] && ! has_local_stylua_config "$file_path"; then
			stylua --config-path "$HOME/.config/nvim/stylua.toml" "$file_path"
		else
			stylua "$file_path"
		fi
	fi
	;;
*.json)
	# LazyVim uses jsonls LSP; jq produces matching multi-line output
	# Copy back in place so symlinks (e.g. stowed dotfiles) and permissions are preserved
	if command -v jq &>/dev/null; then
		tmp=$(mktemp)
		if jq . "$file_path" >"$tmp" 2>/dev/null; then
			cp "$tmp" "$file_path"
		fi
		rm -f "$tmp"
	fi
	;;
*.md)
	# LazyVim runs: prettier, markdownlint-cli2 (if issues), markdown-toc (if markers)
	command -v prettier &>/dev/null && prettier --write "$file_path" 2>/dev/null
	command -v markdownlint-cli2 &>/dev/null && markdownlint-cli2 --fix "$file_path" 2>/dev/null
	if grep -q '<!-- toc -->' "$file_path" 2>/dev/null; then
		command -v markdown-toc &>/dev/null && markdown-toc -i "$file_path" 2>/dev/null
	fi
	;;
*.sh | *.bash)
	command -v shfmt &>/dev/null && shfmt -w "$file_path"
	;;
*.tf | *.tfvars)
	# LazyVim also handles terraform-vars
	command -v terraform &>/dev/null && terraform fmt "$file_path"
	;;
*.hcl)
	# LazyVim uses packer_fmt for HCL
	command -v packer &>/dev/null && packer fmt "$file_path"
	;;
*.toml)
	command -v taplo &>/dev/null && taplo fmt "$file_path"
	;;
*.rs)
	command -v rustfmt &>/dev/null && rustfmt "$file_path"
	;;
*.ts | *.tsx | *.js | *.jsx | *.mjs | *.cjs)
	command -v prettier &>/dev/null && prettier --write "$file_path" 2>/dev/null
	;;
*.c | *.h | *.cpp | *.hpp | *.cc | *.cxx | *.cu | *.cuh)
	# LazyVim uses clangd LSP with --fallback-style=llvm
	command -v clang-format &>/dev/null && clang-format -i --fallback-style=llvm "$file_path"
	;;
esac

exit 0
