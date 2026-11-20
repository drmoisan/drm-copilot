# Remediation Closure Check — Issue #286 (Remediation Cycle 2)

- Timestamp: 2026-07-03T20-00
- Cycle: 2 (post-PR CI-failure handling)
- CI run under remediation: https://github.com/drmoisan/drm-copilot/actions/runs/28685430030 (PR #295)
- Findings addressed: CI-1 (Blocking), CI-2 (Blocking)

## Finding-to-Verification Map

### CI-1 — `context: fork` literal trips `claude-runtime-structure` guard

- Remediation: reworded the fork caveat in `.claude/skills/orchestrate/SKILL.md` and `.claude/skills/epic-orchestrate/SKILL.md` (and both bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`) so the text no longer matches `context:\s*fork`. Meaning preserved: a fork-routed skill inherits the parent model and ignores a model override.
- Verification:
  - P3-T1 — Pester `claude-runtime-structure.Tests.ps1` passes (EXIT_CODE 0); see `pester-final.2026-07-03T20-00.md`.
  - P3-T2 — zero `context:\s*fork` matches across all four files, repo-root and bundled (EXIT_CODE 0, `NO MATCHES`); see `fork-pattern-final.2026-07-03T20-00.md`.
  - Byte-identity between each repo-root file and its bundled mirror confirmed by P1-T6 (`IDENTICAL`, full-file hash equality for both orchestrate and epic-orchestrate).
- Status: satisfied locally.

### CI-2 — new agents missing from pack manifest

- Remediation: added `.claude/agents/commit-message.md` and `.claude/agents/human-exception-runbook.md` to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` at their alphabetical positions. `pr-author.md` was not added (documented pre-existing exception). No language-specific pack manifest or Codex manifest was edited.
- Governance finding: the pack manifests are bundle-only; they are outside the `.claude/**` root-to-bundle parity scope (`SCOPED_ROOTS == (Path(".claude"),)`), so no lockstep repo-root copy or parity contract requires a mirrored update. The Codex manifest set uses a separate `.agents/`/`.codex/` namespace and is unaffected.
- Verification:
  - P2-T2 — core.json is well-formed JSON, contains both new entries, and excludes `pr-author.md` (EXIT_CODE 0, `OK`).
  - P3-T3 — deterministic completeness check reports an empty missing set (EXIT_CODE 0, `MISSING: (none)`); see `pack-manifest-final.2026-07-03T20-00.md`.
- Residual dependency: the authoritative verifier is the CI Jest run of `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`, which executes on the next push against the new head SHA. The TypeScript suite is not runnable in this local environment (no npm/node/node_modules).
- Status: satisfied locally; CI-Jest confirmation pending on next push.

## Scope Confirmation

All changes are additive/textual only. No Python logic, validators, `model_policy`/`model_budget` config, or acceptance criteria were altered. No file exceeds 500 lines. Evidence resides only under `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/<kind>/`. No SCOPE-CHANGE items were identified.
