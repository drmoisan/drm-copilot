# Final forbidden-token scan: workflow

Timestamp: 2026-10-01T17-22
Command: git grep -n -E "NPM_TOKEN|NODE_AUTH_TOKEN" -- .github/workflows/publish-mcp-npm.yml
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: No match (git grep exit code 1, empty output). The workflow contains neither secret-name string.
