# DevContainer Setup

This directory contains the development container configuration for the Replysis project.

## Automated Version Management

### Current Setup
- **Dockerfile**: Uses `elixir:1.18-otp-27` (official image)
- **Fallback**: `Dockerfile.fallback` if issues arise
- **Automation**: Scripts for version management

### Available Scripts

#### `version-check.sh`
Shows all installed versions and tools:
```bash
./.devcontainer/version-check.sh
```

#### `update-base-image.sh`
Updates Dockerfile with latest stable Elixir version:
```bash
# Dry run to see what would be updated
./.devcontainer/update-base-image.sh --dry-run

# Actually update the Dockerfile
./.devcontainer/update-base-image.sh
```

## Manual Version Updates

If you need to manually update versions:

1. **Check available Elixir tags**: https://hub.docker.com/_/elixir/tags
2. **Check available hexpm tags**: https://hub.docker.com/r/hexpm/elixir/tags
3. **Update Dockerfile FROM line**
4. **Rebuild container**

## Troubleshooting

### Image Not Found Errors
If you get "image not found" errors:

1. Try the fallback Dockerfile:
   ```bash
   cp .devcontainer/Dockerfile.fallback .devcontainer/Dockerfile
   ```

2. Or use a known working tag:
   ```dockerfile
   FROM elixir:1.17-otp-26
   ```

### Language Server Issues
Run the version check to verify all tools are installed:
```bash
./.devcontainer/version-check.sh
```

### MCP Server Configuration
The post-create script automatically configures MCP servers for:
- Go (gopls)
- Python (pyright)
- Elixir (ElixirLS)
- Rust (rust-analyzer)

## Development Tools Included

### Languages & Runtimes
- Elixir 1.18+ with OTP 27
- Go (latest stable)
- Python 3 with pip
- Rust with Cargo
- Node.js with npm

### Language Servers
- ElixirLS for Elixir
- gopls for Go
- Pyright for Python  
- rust-analyzer for Rust
- mcp-language-server (bridge)

### AI Tools
- Claude Code
- Gemini CLI

### Development Utilities
- Git, curl, wget, jq
- Build tools (gcc, make, etc.)
- Text editors (vim, nano)

## Container Rebuild

After updating the Dockerfile:
1. **Rebuild**: Command Palette → "Dev Containers: Rebuild Container"
2. **Clean rebuild**: Command Palette → "Dev Containers: Rebuild Container Without Cache"

## Port Forwarding

The container forwards these ports:
- 3000: General web development
- 4000: Phoenix development server
- 8000: Additional web services