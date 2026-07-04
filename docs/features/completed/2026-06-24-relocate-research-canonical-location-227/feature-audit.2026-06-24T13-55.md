# Feature Audit — relocate-research-canonical-location (Issue #227)

- **Timestamp:** 2026-06-24T13-55
- **Work mode:** full-feature

## Scope and Baseline

- **Base branch (resolved):** origin/main @ ea94a068e0a071940858a0694c47e204244c09af
- **Head:** drm-copilot-wt-2026-06-24-13-02 @ d200d8961843f8b9d040f6c847b8ae186035dc90
- **Merge base:** ea94a068e0a071940858a0694c47e204244c09af
- **Range:** ea94a068e0a071940858a0694c47e204244c09af..d200d8961843f8b9d040f6c847b8ae186035dc90
- **AC source resolution:** Work mode `full-feature` resolves AC sources to `spec.md` and `user-story.md`. `user-story.md` is absent from the feature folder (folder contains only issue.md, spec.md, plan, evidence/, research/). The authoritative AC checklist is the `## Acceptance Criteria` section of `spec.md`, which mirrors the issue #227 acceptance criteria. The absence of `user-story.md` is recorded as an assumption; evaluation proceeds against `spec.md`.

## Acceptance Criteria Inventory

Source: docs/features/active/2026-06-24-relocate-research-canonical-location-227/spec.md, `## Acceptance Criteria` (7 items), plus `## Seeded Test Conditions` (3 items).

| ID | Criterion |
|---|---|
| AC1 | Feature-associated research written to `<FEATURE>/research/<timestamp>-<short-name>-research.md` and one-off research to `docs/research/<timestamp>-<short-name>-research.md`; `artifacts/research/` is no longer the canonical target. |
| AC2 | Claude ecosystem (root `.claude/` and bundled `claude-customizations`) reflects the new contract in task-researcher.md, orchestrator.md, research-issue/SKILL.md, orchestrate/SKILL.md, evidence-and-timestamp-conventions/SKILL.md, and both hooks. |
| AC3 | Codex ecosystem (bundled `codex-and-agents-customizations`) reflects the new contract in task-researcher.toml (embedded frontmatter, body, stop hook), orchestrator.toml, the three mirrored skills, and the enforce-evidence-locations.ps1 docstring. |
| AC4 | GitHub Copilot ecosystem (root `.github/` and bundled `customizations`) reflects the new contract in task-researcher.agent.md, research-issue.prompt.md, and fillout-prd-feature.prompt.md. |
| AC5 | validate-task-researcher-output.ps1 accepts both new tracked roots and rejects `artifacts/research/`, with three error messages updated; enforce-evidence-locations.ps1 and validate_evidence_locations.py reject `artifacts/research/`; tests updated in all three test files. |
| AC6 | Both tracked research locations resolve to git-tracked paths (under `docs/`, not under the ignored `artifacts/` tree); no `.gitignore` change. |
| AC7 | Root copies and their bundled mirrors are content-identical after the change; Codex translations contain the equivalent text changes. |
| STC1 | Hook unit tests for accepted (feature and one-off) and rejected research paths. |
| STC2 | Filename-convention validation preserved under the new roots. |
| STC3 | Evidence-location enforcement unaffected for non-research paths. |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC1 | PASS | Spec and all instruction surfaces define the two new roots; `artifacts/research/` removed from permitted lists and added to forbidden-prefix sets. Validator run on repo root exits 0 with the relocated feature research file under docs/ not flagged (validator-run.2026-06-24T13-09.md). |
| AC2 | PASS | git diff confirms changes in .claude/agents/task-researcher.md (frontmatter tools, description, body), .claude/agents/orchestrator.md, research-issue/orchestrate/evidence-and-timestamp-conventions SKILL.md, and both hooks; all root vs Claude-bundled mirrors verified IDENTICAL. |
| AC3 | PASS | git diff confirms task-researcher.toml (embedded write allowlist `Write(/docs/features/**/research/**)` + `Write(/docs/research/**)`, body, stop-hook text), orchestrator.toml, the three .agents/skills/ files, and the Codex enforce-evidence-locations.ps1 forbidden-prefix entry (lines 23, 71). |
| AC4 | PASS | git diff confirms .github/agents/task-researcher.agent.md, .github/prompts/research-issue.prompt.md, .github/prompts/fillout-prd-feature.prompt.md updated; root vs Copilot-bundled mirrors verified IDENTICAL. |
| AC5 | PASS | Test-IsUnderResearchRoot rewritten for dual-root acceptance; three error messages updated (no `artifacts/research/` substring remains in them); forbidden prefix added to both PowerShell hook and Python validator. All three test files updated; Pester 32/32 pass, pytest 7/7 pass. |
| AC6 | PASS | Both roots are under `docs/` (tracked). No .gitignore change in the branch diff. The relocated feature research file is committed under docs/features/.../research/ and is tracked. |
| AC7 | PASS | All seven Claude root/bundled pairs and three Copilot root/bundled pairs verified byte-IDENTICAL by diff. Codex translations carry the equivalent relocation text (verified by diff). |
| STC1 | PASS | Positive tests for feature-root and one-off-root acceptance; negative tests for retired path, missing `/research/` segment, and non-conforming filename. |
| STC2 | PASS | Filename regex left unchanged (spec invariant); filename-convention test asserts a non-conforming name under a valid root is rejected. |
| STC3 | PASS | enforce-evidence-locations exclusion-only model unchanged; non-research evidence paths unaffected; reviewer ran validate_evidence_locations.py --root . with exit 0. |

## Summary

All 7 acceptance criteria and 3 seeded test conditions evaluate PASS. The feature delivers the relocation contract consistently across the three ecosystems and their bundled copies, preserves the filename-convention and exclusion-only invariants, and updates the test suites accordingly.

One quality gate outside the acceptance-criteria set is not met: modified-file line coverage for `enforce-evidence-locations.ps1` is 81.5%, below the uniform 85% threshold (see policy-audit.2026-06-24T13-55.md and remediation-inputs.2026-06-24T13-55.md). This does not invalidate any acceptance criterion — the changed line is covered and there is no regression on changed lines — but it is a Blocking coverage finding under the SKILL coverage contract and routes to remediation. PR readiness is therefore no-go until the coverage finding is resolved.

## Acceptance Criteria Check-off

All AC items in spec.md are already marked `[x]` (checked off during execution) and the reviewer evaluation confirms PASS for each; no change to the checkbox state is required. No items require flipping from `[ ]` to `[x]`. The issue.md early-draft AC list remains `[ ]` (early-draft section, not the authoritative full-feature AC source) and is left unchanged per acceptance-criteria-tracking (reviewers do not author or alter draft AC sections).

### Acceptance Criteria Status
- Source: docs/features/active/2026-06-24-relocate-research-canonical-location-227/spec.md (authoritative); user-story.md absent (documented assumption)
- Total AC items: 7 (plus 3 seeded test conditions)
- Checked off (delivered): 7 (already `[x]` in spec.md; all confirmed PASS)
- Remaining (unchecked): 0
- Items remaining: none
