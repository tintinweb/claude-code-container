# Claude Code Container

A Docker container for running Claude Code with Claude 4 Sonnet in "dangerously allow all executions" mode.

## Quick Start

### Prerequisites

1. **Claude Code License**: Ensure you have a valid Claude Code license
2. **API Key**: Set your Anthropic API key
3. **Docker**: Docker must be installed and running

### Build the Container

```bash
# Clone this repository
git clone <repository-url>
cd container-claude

# Build the container
./build.sh
```

### Running Claude in the Container

#### Interactive Mode

```bash
# Start interactive session with current directory
./interactive-shell.sh

# With specific input directory
./interactive-shell.sh /path/to/your/code

# With input and reference data directories
./interactive-shell.sh /path/to/your/code /path/to/reference-data

# Pass additional Claude options
./interactive-shell.sh /path/to/your/code --model claude-3.5-sonnet --debug
```

## Environment Variables

- `CLAUDE_API_KEY`: Your Anthropic API key (required)

## Security Features

### Container Security
- **Non-root execution**: Runs as user `claude` (UID 1001)
- **Capability dropping**: Minimal Linux capabilities
- **Process limits**: Resource constraints for safety (max 100 PIDs)
- **Tmpfs mounts**: Isolated temporary storage for /tmp and /workspace/temp
- **Network isolation**: Bridge network with no host access
- **Security options**: No new privileges allowed

### Analysis Settings
- **Dangerous executions allowed**: Pre-configured for automation
- **Trusted workspace**: No trust prompts during analysis
- **Comprehensive tool permissions**: Access to all tools via wildcard allowlist


## Example: MCP Server Integration

The container includes the Chonky MCP Server for advanced security analysis:

**Chonky MCP Server**: Advanced security analysis tools
- Smart contract analysis (Solidity metrics, structure analysis)
- Vulnerability database search
- Semgrep custom rules
- Access control analysis
- Reentrancy detection
- Oracle dependency analysis
- And 50+ security analysis tools

### Available Chonky Tools

Key security analysis tools available:
- `chonky-solidity-metrics`: Comprehensive Solidity codebase metrics
- `chonky-solidity-contract-structure`: Contract analysis and dependencies
- `chonky-vulnerability-database-search`: Security vulnerability lookup
- `chonky-semgrep`: Custom security rules and static analysis
- `chonky-solidity-reentrancy`: Reentrancy vulnerability detection
- `chonky-solidity-access-control`: Access control pattern analysis
- `chonky-solidity-oracle-dependency`: Oracle security analysis
- And 40+ additional security analysis tools

## Add your own MCP

**Preparation**:
- copy your mcp to ./mcp/<your mcp> to be included in the Docker build, or
- npm install it with the **Dockerfile**
- add any additional tools to the **Dockerfile**

**Dockerfile**:
- go to `Configure MCP Providers`
- add a `COPY` line if the MCP source is in the ./mcp/<your mcp> folder and `RUN` compilation if needed. Else skip (make sure you `npm install -g` your server, though)


```Dockerfile
################ Configure MCP Providers  --->

# Copy pre-built MCP server into container (from mcp/chonky)
COPY --chown=${USER_NAME}:${USER_NAME} mcp/chonky /workspace/mcp-servers/chonky-mcp-server

# Install MCP server runtime dependencies only (using package-lock.json for exact versions)
RUN cd /workspace/mcp-servers/chonky-mcp-server && npm ci --production

# Don't forget to configure the MCP in claude-config.json

################# <--- Configure MCP Providers 
```

**Claude-config.json**:
- pre configure the mcp server under `"mcpServers":`. Follow the template.

```json
"mcpServers": {
   "chonky-stdio": {
      "type": "stdio",
      "command": "node",
      "args": ["/workspace/mcp-servers/chonky-mcp-server/build/index.js", "stdio"],
      "env": {},
      "trusted": true,
      "autoStart": true
   }
},
```

**Build**:
- run the `build.sh` script
- run the `interactive-shell.sh` script

## Architecture

```
┌─────────────────────────────────────────────┐
│                Container                    │
├─────────────────────────────────────────────┤
│ Claude Code + Security Tools                │
│ ├── Semgrep (SAST)                         │
│ ├── Solhint (Solidity linting)             │
│ ├── Foundry (Smart contract toolkit)       │
│ └── Node.js ecosystem                      │
├─────────────────────────────────────────────┤
│ MCP Server                                  │
│ └── Chonky MCP (Security analysis)         │
├─────────────────────────────────────────────┤
│ Security Layer                              │
│ ├── Non-root user (claude:1001)            │
│ ├── Dropped capabilities                   │
│ ├── Process limits (100 PIDs)              │
│ └── Tmpfs mounts                            │
└─────────────────────────────────────────────┘
```

## Directory Structure

```
/workspace/
├── input/          # Input files (read-only mount from host)
├── output/         # Analysis results (writable mount to host ./reports)
├── data/           # Reference data (optional read-only mount)
├── temp/           # Temporary files (tmpfs)
└── mcp-servers/    # MCP server installations
    └── chonky-mcp-server/
```

## Configuration Files

### Claude Configuration (`~/.claude.json`)
```json
{
  "workspaceFolders": {
    "/workspace": {
      "allowedTools": ["*"],
      "permissions": {
        "allow": [
          "Bash(*)", "Edit(*)", "Read(*)", "Write(*)",
          "List(*)", "Glob(*)", "Grep(*)", "Task(*)",
          "WebFetch(*)", "WebSearch(*)", "NotebookRead(*)",
          "NotebookWrite(*)", "mcp__*"
        ],
        "defaultMode": "acceptEdits",
        "additionalDirectories": ["/workspace/input", "/workspace/output", "/workspace/data", "/workspace/temp"]
      },
      "autoAcceptAllTools": true,
      "autoAcceptMcpTools": true,
      "dangerouslyAllowAllExecutions": true
    }
  },
  "mcpServers": {
    "chonky-stdio": {
      "command": "node",
      "args": ["/workspace/mcp-servers/chonky-mcp-server/build/index.js", "stdio"],
      "trusted": true,
      "autoStart": true
    }
  },
  "modelPreferences": {
  },
  "automationSettings": {
    "allowWebSearch": true,
    "allowWebFetch": true,
    "allowFileOperations": true,
    "allowBashExecution": true,
    "suppressTrustPrompts": true,
    "autoAcceptPermissions": true
  }
}
```

## Troubleshooting

### "No MCP servers configured" or MCP server not starting
The container includes pre-configured MCP server setup. If issues persist:
1. Rebuild the container with `./build.sh`
2. Check that the Chonky MCP server is properly installed in the container
3. Verify the API key is set correctly

### Permission Errors
Ensure your mounted directories have appropriate permissions for UID 1001:
```bash
sudo chown -R 1001:1001 /path/to/your/workspace
```

### API Key Issues
Verify your API key is set correctly:
```bash
export CLAUDE_API_KEY="your-api-key-here"
./interactive-shell.sh /path/to/code
```

## Advanced Usage

### Docker Run Options
The `interactive-shell.sh` script includes comprehensive security settings:
- Capability dropping (`--cap-drop=ALL`)
- No new privileges (`--security-opt=no-new-privileges:true`)
- Process limits (`--pids-limit=100`)
- Tmpfs mounts for temporary storage
- Network isolation

### Custom Analysis
Pass additional options to Claude Code:
```bash
./interactive-shell.sh /path/to/code --model claude-3.5-sonnet --debug --mcp-debug
```

## Security Considerations

- **API Key Security**: Never commit API keys. Use environment variables.
- **Container Isolation**: The container runs with minimal privileges and dropped capabilities.
- **Network Security**: Bridge network isolation prevents host network access.
- **File System**: Tmpfs mounts for temporary data, read-only input mounts.
- **Process Limits**: Maximum 100 processes to prevent resource exhaustion.

## Usage Examples

### Basic Security Analysis
```bash
export CLAUDE_API_KEY="your-api-key"
./interactive-shell.sh /path/to/smart-contracts
```

### With Reference Documentation
```bash
./interactive-shell.sh /path/to/contracts /path/to/docs
```

### Debug Mode
```bash
./interactive-shell.sh /path/to/contracts --debug --mcp-debug
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Test with both batch and interactive modes
4. Submit a pull request

## License

This project is provided under the terms consistent with Claude Code's licensing requirements.
