# Claude Code Container

A Docker container for running Claude Code in "dangerously skip permissions" mode.

https://github.com/user-attachments/assets/81c731d9-caeb-48cf-aa3e-65a48c55519e

Build the docker container and execute `run_claude.sh` to run an isolated version of claude code with access to the current working dir (`readOnly:/workspace/input`).

```
/workspace/
├── input/              # Host input files (read-only mount of $PWD)
├── output/             # Analysis results (writable mount to host)
├── data/               # Reference data (optional read-only mount)
├── temp/               # Temporary files (tmpfs mount)
├── .claude/            # Claude Code project settings
│   └── settings.local.json
└── mcp-servers/        # MCP server installations
```


## Variants

### 1. claude-standalone
Basic Claude Code container without any MCP servers configured. Clean, simple setup.

### 2. claude-with-mcp-example  
Claude Code container with MCP servers pre-configured (e.g., Chonky Security Tools). Shows how to add MCP servers, configure them, and auto-trust their execution.

## Quick Start

### Prerequisites

1. **Claude Code License**: Ensure you have a valid Claude Code license
2. **OAuth Token**: Set your Claude Code OAuth token
3. **Docker**: Docker must be installed and running

### Build and Run


```bash
# Clone this repository
git clone <repository-url>
cd claude-code-container

# For standalone version
cd claude-standalone
./build.sh
CLAUDE_CODE_OAUTH_TOKEN=sk-... ./run_claude.sh

# For MCP example version  
cd claude-with-mcp-example
./build.sh
CLAUDE_CODE_OAUTH_TOKEN=sk-... ./run_claude.sh

# Pass additional Claude options
CLAUDE_CODE_OAUTH_TOKEN=sk-... ./run_claude.sh --debug --mcp-debug
```

## Environment Variables

- `CLAUDE_CODE_OAUTH_TOKEN`: Your Claude Code OAuth token (required)

Run `claude setup-token`, login, save the resulting `sk-*` token.


## Security Features

### Container Security
- **Non-root execution**: Runs as user `claude` (UID 1001)
- **Capability dropping**: Minimal Linux capabilities
- **Process limits**: Resource constraints for safety (max 100 PIDs)
- **Tmpfs mounts**: Isolated temporary storage for /tmp and /workspace/temp
- **Network isolation**: Bridge network with no host access
- **Security options**: No new privileges allowed

### Jailfree Mode
- **Dangerous executions allowed**: Pre-configured for full automation
- **Auto-trusted workspace**: No trust prompts during analysis
- **Comprehensive tool permissions**: Access to all tools via wildcard allowlist

## MCP Server Integration (claude-with-mcp-example)

The MCP example shows how to integrate Model Context Protocol servers:

### Adding Your Own MCP Server

1. **Copy MCP to build context**: `./mcp/<your-mcp>/`
2. **Update Dockerfile**: Add COPY and build steps
3. **Configure in claude-config.json**: Add MCP server definition
4. **Build and run**: Use the build script

Example MCP configuration:
```json
"mcpServers": {
   "your-mcp": {
      "type": "stdio",
      "command": "node",
      "args": ["/workspace/mcp-servers/your-mcp/build/index.js", "stdio"],
      "env": {},
      "trusted": true,
      "autoStart": true
   }
}
```

## Usage Examples

### Basic Claude Session
```bash
export CLAUDE_CODE_OAUTH_TOKEN="sk-your-token"
./run_claude.sh
```

### With Debug Options
```bash
./run_claude.sh --debug --mcp-debug
```

## Troubleshooting

### OAuth Token Issues
Verify your OAuth token is set correctly:
```bash
export CLAUDE_CODE_OAUTH_TOKEN="sk-your-token-here"
./run_claude.sh
```

### Debug Container Access
```bash
./debug-shell.sh  # Access container shell for debugging
```

## License

This project is provided under the terms consistent with Claude Code's licensing requirements.
