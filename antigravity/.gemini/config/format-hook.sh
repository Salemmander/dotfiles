#!/bin/bash

# Add Mason bin to PATH for formatters installed via neovim
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

# Read hook input from stdin
input=$(cat)

# Extract file path and conversation ID (Antigravity uses camelCase protojson)
file_path=$(printf '%s' "$input" | jq -r '.toolCall.args.Path // .toolCall.args.TargetFile // .toolCall.args.path // empty')
session_id=$(printf '%s' "$input" | jq -r '.conversationId // "default"')

finish() {
	printf '{}\n'
	exit 0
}

if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
	finish
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
# Redirect all formatter output so hook stdout remains valid JSON.
case "$file_path" in
*.py)
	command -v ruff &>/dev/null && ruff format "$file_path" >/dev/null 2>&1
	echo "$file_path" >>"/tmp/agy-ruff-${session_id}.txt"
	;;
*.lua)
	if command -v stylua &>/dev/null; then
		if [ -f "$HOME/.config/nvim/stylua.toml" ] && ! has_local_stylua_config "$file_path"; then
			stylua --config-path "$HOME/.config/nvim/stylua.toml" "$file_path" >/dev/null 2>&1
		else
			stylua "$file_path" >/dev/null 2>&1
		fi
	fi
	;;
*.json)
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
	command -v prettier &>/dev/null && prettier --write "$file_path" >/dev/null 2>&1
	command -v markdownlint-cli2 &>/dev/null && markdownlint-cli2 --fix "$file_path" >/dev/null 2>&1
	if grep -q '<!-- toc -->' "$file_path" 2>/dev/null; then
		command -v markdown-toc &>/dev/null && markdown-toc -i "$file_path" >/dev/null 2>&1
	fi
	;;
*.sh | *.bash)
	command -v shfmt &>/dev/null && shfmt -w "$file_path" >/dev/null 2>&1
	;;
*.tf | *.tfvars)
	command -v terraform &>/dev/null && terraform fmt "$file_path" >/dev/null 2>&1
	;;
*.hcl)
	command -v packer &>/dev/null && packer fmt "$file_path" >/dev/null 2>&1
	;;
*.toml)
	command -v taplo &>/dev/null && taplo fmt "$file_path" >/dev/null 2>&1
	;;
*.rs)
	command -v rustfmt &>/dev/null && rustfmt "$file_path" >/dev/null 2>&1
	;;
*.ts | *.tsx | *.js | *.jsx | *.mjs | *.cjs)
	command -v prettier &>/dev/null && prettier --write "$file_path" >/dev/null 2>&1
	;;
*.c | *.h | *.cpp | *.hpp | *.cc | *.cxx | *.cu | *.cuh)
	command -v clang-format &>/dev/null && clang-format -i --fallback-style=llvm "$file_path" >/dev/null 2>&1
	;;
esac

finish
