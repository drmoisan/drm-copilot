# @danmoisan/drm-copilot-mcp

Stdio MCP server exposing drm-copilot repo-automation tools. Intended for use with MCP-compatible AI clients such as Claude Desktop, GitHub Copilot, and Codex CLI.

## Installation

### npx (recommended, no install required)

```bash
npx -y @danmoisan/drm-copilot-mcp
```

### Global install

```bash
npm install -g @danmoisan/drm-copilot-mcp
drm-copilot-mcp
```

## MCP Client Configuration

Add the following to your MCP client configuration file (e.g., `claude_desktop_config.json` or equivalent):

```json
{
  "mcpServers": {
    "drm-copilot": {
      "command": "npx",
      "args": ["-y", "@danmoisan/drm-copilot-mcp"],
      "cwd": "/absolute/path/to/your/workspace"
    }
  }
}
```

Set `cwd` to the absolute path of the workspace root that the MCP server tools should operate on.

## Runtime Prerequisites

- Node >=18 required to run the MCP server process.
- Python 3 and PowerShell 7+ required for script-backed tools (repo automation scripts).
- The MCP server must be run from within the drm-copilot repository workspace.

## Available Tools

The server exposes the drm-copilot repo-automation MCP tools defined in the `extensions/drm-copilot` source. See the extension README for the full tool listing.

## Validator and Remediation Contract

`validate_orchestration_artifacts` validates the review fields `REVIEW_VERDICT`, `REMEDIATION_ACTION`, `BLOCKER_FINGERPRINT`, `REMEDIATION_INPUTS`, and `REMEDIATION_PLAN`. Version 2 of `remediation_loop` requires `status`, `max_completed_cycles`, `attempt_count`, `completed_cycle_count`, `last_blocker_fingerprint`, `attempts`, and `cycles`. Attempts start only after clear preflight and R3 delegation. A completed cycle is recorded only after a candidate is applied, committed, and re-audited in R4.

The transition order is PASS/`NONE` to PR readiness; non-actionable results to a pre-R1 terminal or wait state; `candidate_applied: false` to a terminal attempt without commit, R4, or cycle consumption; and a completed candidate through commit and R4 before cycle accounting. An unchanged post-R4 fingerprint stops as `blocked_stagnation` unless an exact unused exception applies. The third unresolved completed cycle stops only as `blocked_remediation_loop_limit`. `blocked_cycle_limit` is rejected legacy input and is not an executable status.

Validation uses stable `ORCH_*` diagnostics for remediation schema, sequence, count, transition, stagnation, exception binding, routing gates, validator capability/version, and routing-policy digest failures. Selected routing gates remain independent, and identical diagnostics are de-duplicated only by their documented identity.

Tracked research output belongs in the active feature's `research/` folder or in `docs/research/`; `artifacts/research/` is retired. `require_pr_creation_ready` is independent of `require_complete`: readiness excludes `pr_gate`, `ci_gate`, and pr-author receipt requirements, while completion retains route-appropriate final PR/CI, phase-completeness, preparation, and routing gates.

The release boundary requires matching local source, built, and packed validator capabilities, routing-policy digest, package version, and bundle identity before publication. An incompatible published runtime, including immutable version 1.0.24 when it lacks this contract, is negative `EXTERNAL_RUNTIME` evidence rather than a local parity target. Repository validation does not publish packages, create release tags, query a registry, or authorize consumer package-pin changes.

## License

MIT
