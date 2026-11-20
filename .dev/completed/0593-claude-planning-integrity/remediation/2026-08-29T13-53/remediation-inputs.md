# Remediation Inputs: Claude Planning Integrity (#593), Re-review Pass 1

## Authoritative Finding

The audit at `docs/features/active/2026-08-29-claude-planning-integrity-593/audit/2026-08-29T13-53/` found that `.claude/hooks/validate-prd-feature-output.ps1` is implemented and unit-tested but not registered as a `SubagentStop` hook for `prd-feature` in `.claude/settings.json` or the corresponding published Claude bundle settings file. This leaves the AC1 lifecycle enforcement inactive.

## Required Fixes

1. Update `.claude/settings.json` to register `pwsh -NoProfile -File .claude/hooks/validate-prd-feature-output.ps1` under a dedicated `SubagentStop` entry matching `prd-feature`.
2. Apply the byte-identical registration to `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`.
3. Add focused regression coverage that fails when the canonical or bundle settings omit the `prd-feature` registration and verifies the command points to the canonical hook path.
4. Re-run the applicable PowerShell hook tests, bundle-parity contract test, focused planning-integrity Python contract test, and the full language-specific QA loop required by the approved remediation plan.

## Verification Requirements

- The registration must be in the runtime-consumed `SubagentStop` configuration, not only in documentation or agent front matter.
- Canonical and bundle settings must be byte-identical after the change.
- Tests must cover the registration, not merely direct invocation of the hook function.
- Preserve the resolved prior coverage evidence; rerun coverage when the approved plan requires it and compare against the 90.00% and 93.75% post-remediation hook baselines.

## Do Not Do

- Do not weaken numeric-provenance validation or remove rejection cases.
- Do not alter the existing issue #586 executor-owned preflight loop.
- Do not modify Codex runtime files, generic plan-progress counters, or unrelated settings entries.
- Do not stage, commit, push, publish, create a PR, or merge as part of this remediation planning step.
