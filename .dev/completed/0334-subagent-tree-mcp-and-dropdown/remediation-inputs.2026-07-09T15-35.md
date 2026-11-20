# Remediation Inputs — CI Failure (Issue #334)

- Cycle: 1
- Entry timestamp: 2026-07-09T15-35
- Source: Step S9 CI Green Gate — failed required check on PR #339 head SHA 0058c6305d86e8d3eb236577f530db2ce4446e98

## Synthetic Blocking Finding (from CI)

- Severity: Blocking
- Failing required check: `quality-checks7 / Code Quality & Tests (3.10)` (CI workflow)
- Failing job URL: https://github.com/drmoisan/drm-copilot/actions/runs/29029673540/job/86158748226
- Pipeline run: https://github.com/drmoisan/drm-copilot/actions/runs/29029673540

## Root Cause (reproduced locally)

`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails:

> AssertionError: Repo file missing from bundle: .claude/hooks/persist-session-id.ps1

The repository `.claude/**` runtime tree must be mirrored byte-identically into the bundled Claude
customization payload at `extensions/drm-copilot/resources/claude-customizations/.claude/` (the test
enumerates every repo `.claude/**` file, excluding `settings.local.json` and `agent-memory/**`, and
asserts each is present in the bundle with byte-identical content).

The feature added new `.claude/**` files and modified `.claude/settings.json` without mirroring them
into the bundled payload.

## Required Changes (mirror into the bundle, byte-identical)

- `.claude/hooks/persist-session-id.ps1` (MISSING in bundle)
- `.claude/skills/identify-session-id/SKILL.md` (MISSING in bundle)
- `.claude/skills/show-my-agent-tree/SKILL.md` (MISSING in bundle)
- `.claude/settings.json` (DIVERGENT — bundle copy must match the repo copy byte-for-byte)

Destination root: `extensions/drm-copilot/resources/claude-customizations/.claude/`

## Verification

- `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` passes.
- Full Python toolchain (Black -> Ruff -> Pyright -> Pytest) clean.
- Re-run S9 CI gate against the new PR head SHA: all required checks green.
