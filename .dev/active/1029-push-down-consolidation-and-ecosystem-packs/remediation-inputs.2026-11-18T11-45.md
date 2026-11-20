# Remediation Inputs — Issue #1029 (feature review)

Timestamp: 2026-11-18T11-45
Source: feature review of `feature/push-down-consolidation-and-ecosystem-packs-1029` at head `9345046c3a64c95a56cec354fba3ed2fb9e04110` against `origin/epic/shared-agent-harness-layer-integration` (merge base `2d487f5b070b401a6d14271a039b1207a6e0383f`)
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: design

## Review artifacts

- `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/policy-audit.2026-11-18T11-45.md`
- `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/code-review.2026-11-18T11-45.md`
- `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/feature-audit.2026-11-18T11-45.md`

## Finding F-1 — Pester repository gate red on orchestrator-state rule generator drift

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: the generator source and the generated rule are both tracked in this repository; the fix is to port the hand-added section text into the #1028 rule source and regenerate, which needs no external service, owner decision, or CI result.
- Finding-Scope: contained
- Failing test: `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1`, case `reports no drift for any generated target in the working tree` (`evidence/qa-gates/final-pester.2026-11-18T11-34.md`; same failure in `evidence/baseline/baseline-pester.2026-11-18T08-22.md`).
- Cause (reproduced by the reviewer): commit `db46ac6ad` ("feat(1201): exclude the allowance file from push-down and document the leg") added a 10-line `## Release-Commit Allowance Scope` section by hand to `.claude/rules/orchestrator-state.md` (current lines 425-434, between the regeneration-path section's closing disclosure paragraph and `## Enforcement`) and to its byte-identical bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`. The #1028 rule source `scripts/harness-generation/sources/rules/orchestrator-state.md` has no section holding that text, and the Claude target in `scripts/harness-generation/sources/rules/orchestrator-state.json` lists none. Rendering the Claude target with the `HarnessRuleGeneration.psm1` algorithm (frontmatter, then the listed sections in order) and diffing it against the committed file yields one hunk, `424a425,434`. The Codex target `.agents/skills/orchestrator-state/SKILL.md` renders identically and is not affected.
- Impact: the CI PowerShell QC shard jobs and `CI Required Gate` fail for this PR, which prevents the OD-2 squash merge. The branch's own changes did not cause the drift.
- Required fix:
  1. In `scripts/harness-generation/sources/rules/orchestrator-state.md`, add a section marker line `<!-- harness-section: release-commit-allowance-scope -->` followed by the exact text of the committed section (from `## Release-Commit Allowance Scope` through the `Honest disclosure:` paragraph and its trailing blank line), placed after the `regeneration-path-scope-and-backward-compatibility` section.
  2. In `scripts/harness-generation/sources/rules/orchestrator-state.json`, insert `"release-commit-allowance-scope"` into the Claude target's `sections` array between `"regeneration-path-scope-and-backward-compatibility"` and `"enforcement"`. Do not add it to the Codex target.
  3. Run `scripts/harness-generation/Invoke-HarnessGeneration.ps1` and then its check mode; confirm no drift is reported and that `git diff` shows no change to `.claude/rules/orchestrator-state.md` or its bundle copy (byte-identical output).
  4. Rerun the Pester gate through `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester` and record 0 failures under `<FEATURE>/evidence/qa-gates/`.
- Files: `scripts/harness-generation/sources/rules/orchestrator-state.md`, `scripts/harness-generation/sources/rules/orchestrator-state.json` (generated files expected unchanged).
- Path note: the light path is not used because the fix edits two files outside the branch diff (the #1028 generator source pair), which exceeds the light-path file inventory; the change itself is local and alters no behavior, acceptance criterion, public interface, validator contract, or hook decision.

## Non-blocking notes (not remediation items)

- `evidence/qa-gates/final-jest.2026-11-18T11-19.md` states 14 entries in `jest.push-down-coverage.json`; the file holds 13. Evidence is append-only; a later record may note the correct count.
