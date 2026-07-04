# Feature Audit — relocate-research-canonical-location (Issue #227)

- **Timestamp:** 2026-06-24T14-18
- **Review type:** Re-audit after remediation

## Scope and Baseline

- **Base branch (resolved):** origin/main @ ea94a068e0a071940858a0694c47e204244c09af
- **Head:** drm-copilot-wt-2026-06-24-13-02 @ eb85c8789cd99907cac8363a95c3c9043341d995
- **Merge base:** ea94a068e0a071940858a0694c47e204244c09af
- **Range:** ea94a068e0a071940858a0694c47e204244c09af..eb85c8789cd99907cac8363a95c3c9043341d995
- **Work mode:** full-feature (marker in issue.md: `- Work Mode: full-feature`)
- **AC sources (per full-feature):** `spec.md` and `user-story.md`.
  - `spec.md` is present and is the authoritative AC source (7 mapped acceptance criteria plus 3 seeded test conditions).
  - `user-story.md` does NOT exist in the feature folder. Documented gap: the work-mode contract names `user-story.md` as a secondary AC source for full-feature, but none was authored for this refactor. No additional acceptance criteria are lost: the issue.md acceptance criteria are fully mapped into spec.md, which serves as the complete AC inventory. This is recorded as an assumption, not a blocker.
- **Scope evaluated:** full branch diff vs merge-base, both commits (`d200d89` relocation, `eb85c87` coverage remediation).

## Acceptance Criteria Inventory

Source: `docs/features/active/2026-06-24-relocate-research-canonical-location-227/spec.md` (## Acceptance Criteria), plus Seeded Test Conditions.

| # | Criterion |
|---|---|
| AC1 | Feature-associated research written to `<FEATURE>/research/<timestamp>-<short-name>-research.md` and one-off research to `docs/research/<timestamp>-<short-name>-research.md`; `artifacts/research/` no longer the canonical target. |
| AC2 | Claude ecosystem (root `.claude/` and bundled `claude-customizations`) reflects the contract in `task-researcher.md` (frontmatter `tools`, description, body), `orchestrator.md`, `research-issue/SKILL.md`, `orchestrate/SKILL.md`, `evidence-and-timestamp-conventions/SKILL.md`, and both hooks. |
| AC3 | Codex ecosystem (bundled `codex-and-agents-customizations`) reflects the contract in `task-researcher.toml` (embedded frontmatter, body, stop hook), `orchestrator.toml`, the three mirrored skills, and the `enforce-evidence-locations.ps1` docstring. |
| AC4 | GitHub Copilot ecosystem (root `.github/` and bundled `customizations`) reflects the contract in `task-researcher.agent.md`, `research-issue.prompt.md`, and `fillout-prd-feature.prompt.md`. |
| AC5 | `validate-task-researcher-output.ps1` accepts both new roots and rejects `artifacts/research/`, three error messages updated; `enforce-evidence-locations.ps1` and `validate_evidence_locations.py` reject `artifacts/research/`; tests updated in all three test files. |
| AC6 | Both tracked research locations resolve to git-tracked paths (under `docs/`, not under ignored `artifacts/`); no `.gitignore` change. |
| AC7 | Root copies and their bundled mirrors are content-identical; Codex translations contain equivalent text changes. |
| STC1 | Hook unit tests for accepted (feature and one-off) and rejected research paths. |
| STC2 | Filename-convention validation preserved under the new roots. |
| STC3 | Evidence-location enforcement unaffected for non-research paths. |

## Acceptance Criteria Evaluation

| # | Verdict | Evidence |
|---|---|---|
| AC1 | PASS | `Test-IsUnderResearchRoot` (validate-task-researcher-output.ps1 L60-83) accepts feature `/research/` paths and `docs/research/`; `Test-EvidenceLocationForbidden` and `_FORBIDDEN_PREFIX_TO_CANONICAL` block `artifacts/research/`. Feature research is physically written to `docs/features/active/2026-06-24-.../research/2026-06-24T13-02-...-research.md` in the diff. |
| AC2 | PASS | Root vs Claude bundled mirror IDENTICAL for task-researcher.md, orchestrator.md, research-issue/SKILL.md, orchestrate/SKILL.md, evidence-and-timestamp-conventions/SKILL.md, and both hooks (diff verified). task-researcher.md frontmatter shows the two new `Write(...)` allowlist forms; no residual `artifacts/research` in the agent. |
| AC3 | PASS | Codex task-researcher.toml and orchestrator.toml carry the equivalent relocation text; the Codex enforce-evidence-locations.ps1 contains the `artifacts/research/` forbidden prefix and updated docstring. Codex/root divergence is limited to translation conventions (converted-hook header, `.agents/skills/` path). codex-equivalence.2026-06-24T13-09.md EXIT 0. |
| AC4 | PASS | Root vs Copilot bundled mirror IDENTICAL for task-researcher.agent.md, research-issue.prompt.md, fillout-prd-feature.prompt.md (diff verified). |
| AC5 | PASS | Reviewer re-ran both Pester suites (35 tests, 0 failures) and the Python suite (7 tests incl. new `test_artifacts_research_is_forbidden`, 100% cov). The retired-path rejection test and dual-root acceptance tests pass. Three error messages updated to cite both new roots (L192, L196, L200). |
| AC6 | PASS | Both roots are under `docs/` (tracked). `git diff --stat` shows no `.gitignore` change. The feature research file at `docs/features/active/.../research/...` is tracked in the diff. |
| AC7 | PASS | All root/Claude and root/Copilot mirror pairs byte-identical (diff). Remediation refactor applied to both root and Claude-bundled enforce-evidence-locations.ps1, still IDENTICAL. Codex translations carry equivalent text. cross-ecosystem-equality.2026-06-24T13-55.md. |
| STC1 | PASS | enforce-evidence-locations.Tests.ps1 covers allow (feature research, one-off research, canonical evidence, source) and block (artifacts/research retired path); validate-task-researcher-output.Tests.ps1 covers dual-root acceptance and rejection of retired/malformed paths. |
| STC2 | PASS | `Test-IsValidResearchFileName` regex unchanged (L95-98); filename-convention tests assert enforcement under the new roots. |
| STC3 | PASS | Non-research forbidden prefixes (baselines, qa, coverage, evidence, etc.) unchanged in both the hook and the Python validator; allowed artifacts sub-paths (orchestration) still pass. Verified by passing tests and `validate_evidence_locations.py --root .` EXIT 0. |

## Summary

All 7 acceptance criteria and 3 seeded test conditions evaluate PASS. The prior review's single Blocking item (enforce-evidence-locations.ps1 coverage below 85%) is resolved: line coverage is 96.43% (was 81.5%), verified by independent reviewer Pester re-run. The feature is functionally complete, policy-compliant, and cross-ecosystem-consistent.

Documented gap (non-blocking): `user-story.md` is absent for this full-feature work mode. The issue.md acceptance criteria are fully mapped into spec.md, which serves as the complete AC inventory, so no acceptance criterion is unaccounted for.

**Go / No-Go: GO for PR.** No blocking findings remain.

## Acceptance Criteria Check-off

All 7 AC items in `spec.md` (## Acceptance Criteria) and the 3 Seeded Test Conditions are already marked `- [x]` and all evaluate PASS in this re-audit. No checkbox state change is required; the existing checked state is corroborated by the evidence above. The `issue.md` (## Acceptance Criteria — early draft) items remain `- [ ]`; they are an early draft superseded by the spec.md AC inventory per the work-mode contract and are not the authoritative tracking surface for full-feature mode.

### Acceptance Criteria Status
- Source: docs/features/active/2026-06-24-relocate-research-canonical-location-227/spec.md (user-story.md absent — documented gap)
- Total AC items: 7 (plus 3 seeded test conditions)
- Checked off (delivered): 7 of 7 AC + 3 of 3 STC
- Remaining (unchecked): 0
- Items remaining: none
