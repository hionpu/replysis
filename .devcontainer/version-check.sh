#!/bin/bash
# Version checking and updating script for devcontainer

set -e

echo "=== Development Environment Version Report ==="
echo "Generated on: $(date)"
echo

# Elixir/Erlang versions
echo "--- Language Runtimes ---"
if command -v elixir >/dev/null 2>&1; then
    echo "Elixir: $(elixir --version | head -n1)"
    echo "Erlang: $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell 2>/dev/null)"
else
    echo "Elixir: Not installed"
fi

if command -v go >/dev/null 2>&1; then
    echo "Go: $(go version | cut -d' ' -f3-4)"
else
    echo "Go: Not installed"
fi

if command -v python3 >/dev/null 2>&1; then
    echo "Python: $(python3 --version)"
else
    echo "Python: Not installed"
fi

if command -v rustc >/dev/null 2>&1; then
    echo "Rust: $(rustc --version)"
else
    echo "Rust: Not installed"
fi

if command -v node >/dev/null 2>&1; then
    echo "Node.js: $(node --version)"
    echo "npm: $(npm --version)"
else
    echo "Node.js: Not installed"
fi

echo
echo "--- Language Servers ---"

# Check LSP servers
if [ -f "/home/vscode/go/bin/gopls" ]; then
    echo "gopls: $(/home/vscode/go/bin/gopls version)"
else
    echo "gopls: Not installed"
fi

if [ -f "/home/vscode/.local/bin/elixir-ls" ]; then
    echo "ElixirLS: Available at /home/vscode/.local/bin/elixir-ls"
else
    echo "ElixirLS: Not installed"
fi

if command -v pyright >/dev/null 2>&1; then
    echo "Pyright: $(pyright --version)"
else
    echo "Pyright: Not installed"
fi

if [ -f "/home/vscode/.cargo/bin/rust-analyzer" ]; then
    echo "rust-analyzer: Available"
else
    echo "rust-analyzer: Not installed"
fi

echo
echo "--- MCP Language Server ---"
if [ -f "/home/vscode/go/bin/mcp-language-server" ]; then
    echo "mcp-language-server: Available"
else
    echo "mcp-language-server: Not installed"
fi

echo
echo "--- AI Tools ---"
if command -v claude >/dev/null 2>&1; then
    echo "Claude Code: $(claude --version 2>/dev/null || echo 'Available')"
else
    echo "Claude Code: Not installed"
fi

if command -v gemini >/dev/null 2>&1; then
    echo "Gemini CLI: Available"
else
    echo "Gemini CLI: Not installed"
fi

echo
echo "=== End Report ==="