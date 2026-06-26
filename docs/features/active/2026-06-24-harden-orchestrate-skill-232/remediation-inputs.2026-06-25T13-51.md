# Remediation Inputs: Issue #232 Harden Orchestrate Skill

Timestamp: 2026-06-25T13-51
Source Review Artifacts:
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/policy-audit.2026-06-25T13-51.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/code-review.2026-06-25T13-51.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/feature-audit.2026-06-25T13-51.md`

Primary Requirements Source:
- This remediation-inputs artifact is authoritative for the remediation planning pass.

## Required Fix List

1. Register the Claude pre-implementation gate.
   - Files: `.claude/settings.json`, any tracked customization source that owns Claude runtime settings if applicable.
   - Expected behavior: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` runs before the configured operation surfaces and blocks pre-readiness implementation operations for Issue #232.
   - Verification commands:
     - `Select-String -Path .claude/settings.json -Pattern 'enforce-orchestration-preimplementation-gate'`
     - Pester test proving the configured hook is present and executes for the expected matcher.

2. Cover required non-edit operation surfaces.
   - Files: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`, `.codex/config.toml` if repository runtime config is intentionally tracked for this enforcement, hook tests under `tests/scripts/claude-hooks/`.
   - Expected behavior: implementation edits, formatters, tests, staging, commits, and implementation delegation are blocked until Issue #232 route metadata, lifecycle readiness, and checkpoint state are present.
   - Verification commands:
     - `Select-String -Path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml -Pattern 'enforce-orchestration-preimplementation-gate' -Context 1,1`
     - `mcp__drm_copilot.run_poshqc_test scan_folders=tests/scripts/claude-hooks,tests/scripts/orchestration`

3. Remove or safely scope Issue #232 hardcoding in reusable gates.
   - Files: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, corresponding tests.
   - Expected behavior: future non-232 feature workflows are not blocked solely because checkpoint state is not Issue #232; Issue #232 still receives the required readiness protection.
   - Verification commands:
     - Pester test with a non-232 ready checkpoint that verifies intended behavior.
     - Pester test with Issue #232 not-ready checkpoint that verifies blocking behavior.

4. Clean branch whitespace failures.
   - Files: paths reported by `git diff --check`, including prior Issue #232 review artifacts and `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`.
   - Expected behavior: diff whitespace validation exits 0.
   - Verification command:
     - `git diff --check 4a20713a4be32afa759915b3e7e24ac4f005eb35..HEAD`

5. Address PowerShell coverage threshold failure.
   - Files: changed PowerShell hooks and Pester tests.
   - Expected behavior: PowerShell coverage satisfies repository policy or a policy-compliant exception dossier is recorded under `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/regression-testing/`.
   - Verification command:
     - `mcp__drm_copilot.run_poshqc_test scan_folders=tests/scripts/claude-hooks,tests/scripts/orchestration`

6. Reconcile acceptance criteria checkboxes after remediation.
   - Files: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/spec.md`, `docs/features/active/2026-06-24-harden-orchestrate-skill-232/user-story.md`.
   - Expected behavior: criteria evaluated PASS remain checked; criteria still PARTIAL or FAIL are not represented as delivered.
   - Verification command:
     - Feature-audit re-review using `feature-review-workflow`.

## Do Not Do

- Do not weaken Issue #232 acceptance criteria to match the current implementation.
- Do not remove hook enforcement to make tests pass.
- Do not store review, baseline, QA, or remediation evidence outside `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/`.
- Do not bypass MCP template resolution for policy-audit artifacts.
- Do not mark Issue #232 ready while `git diff --check`, coverage thresholds, or artifact validators fail.

## Context Package

Required context for remediation planning:
- `artifacts/pr_context.summary.txt`
- `artifacts/pr_context.appendix.txt`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/plan.2026-06-24T15-45.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/remediation-plan.2026-06-25T07-45.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/spec.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/user-story.md`
- The three review artifacts listed above.
