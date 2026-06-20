# Remediation Inputs — Issue #207 (CI failure, pass 1)

- Timestamp: 2026-06-19T19-15
- Base branch: main
- Branch head: f686ef480804634febc04f619683966dbd2cf4cf
- Work Mode: minor-audit
- Source: S9 CI green gate failure on PR #208

## CI Failure (synthetic Blocking finding)

- Failing check: `Code Quality & Tests (3.11)` (3.10/3.12/3.13 cancelled by fail-fast matrix)
- Run: https://github.com/drmoisan/drm-copilot/actions/runs/27852413622
- Failing test: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
- Error: `AssertionError: Repo file missing from bundle: .claude/hooks/enforce-completion-consistency.ps1`

## Root Cause

The repository enforces a byte-identical mirror contract: every non-memory `.claude/**` file
must also exist, byte-identical, in the bundled extension payload at
`extensions/drm-copilot/resources/claude-customizations/.claude/`. This change added a new
`.claude` hook and modified `.claude/settings.json` without updating the bundled copies.

Two bundle files are out of sync:
1. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1` — missing entirely.
2. `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` — does not contain the new hook registration (differs from the repo copy).

## Blocking Findings

### B1 (Blocking) — New hook not mirrored into bundled payload

- Required action: copy `.claude/hooks/enforce-completion-consistency.ps1` to
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`, byte-identical.

### B2 (Blocking) — Bundled settings.json out of sync

- Required action: update
  `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` so it is
  byte-identical to the repo `.claude/settings.json` (add the new hook registration).

## Acceptance / Verification Commands

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
poetry run black --check .
poetry run ruff check .
poetry run pyright
```

All bundle-contract tests must pass; toolchain clean.
