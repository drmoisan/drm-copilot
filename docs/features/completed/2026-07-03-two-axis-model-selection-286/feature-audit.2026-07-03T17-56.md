# Feature Audit: two-axis-model-selection (Issue #286)

**Audit Date:** 2026-07-03
**Feature Folder:** `docs/features/active/2026-07-03-two-axis-model-selection-286`
**Base Branch:** `main` @ `9a5de0c549327f2e47521cae51d2514e8b28b54b`
**Head Branch:** `feature/two-axis-model-selection-286` @ `e2d47f6d610fcbeca97d57a24603168a167b87ec`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification (remediation cycle 1 exit).

---

## Scope and Baseline

- **Base branch:** `main` (commit `9a5de0c549327f2e47521cae51d2514e8b28b54b`, merge base)
- **Head branch/commit:** `feature/two-axis-model-selection-286` (commit `e2d47f6d610fcbeca97d57a24603168a167b87ec`)
- **Merge base:** `9a5de0c549327f2e47521cae51d2514e8b28b54b`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/**`
  - Fresh toolchain execution this run (Black/Ruff/Pyright/Pytest+coverage) and bundle-sync `cmp` comparison.
- **Feature folder used:** `docs/features/active/2026-07-03-two-axis-model-selection-286`
- **Requirements source:** `spec.md` and `user-story.md` (full-feature work mode).
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so AC sources are `spec.md` and `user-story.md`, tracked independently.
- **Scope note:** The feature commit was cherry-picked onto current `main`; the branch base is now `9a5de0c` and head `e2d47f6`. All verdicts below were re-derived from the `main..HEAD` diff and fresh checks, not from any prior audit.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — primary source (16 checkbox criteria)
- `user-story.md` — co-authoritative source (13 checkbox criteria)

### From spec.md

WS1 — Model-selection machinery (8):
1. `route` is not a model-selection input anywhere; `complexity_band` is the sole feature-level input.
2. `config/orchestration-routing.json` contains `model_policy` and `model_budget.fable_policy` default `disabled`; bundled mirror byte-identical.
3. `compute_complexity_floor` deterministic; each `[floor]` guard contributes C3; floor is max triggered; never exceeds C3; C4 never floor-forced; unit tests cover each case.
4. `resolve_delegation_model` deterministic; base table, `preferred` overlay, `disabled` clamp; unit tests cover base table, available intact, disabled clamp with `clamped_from: fable`, preferred four agents at C3, `atomic-executor`/`pr-author` unchanged.
5. Complexity validator passes well-formed and fails closed on band-enum, band>=floor, floor==compute, non-empty rationale with literal messages.
6. Model-routing validator passes well-formed and fails closed on model!=resolve, disabled-mode fable, missing clamp provenance.
7. Both validators wired into Python `validate_orchestration_artifacts` via key-gated blocks; checkpoint without arrays validates unchanged.
8. `orchestrate` and `epic-orchestrate` skills each carry a `## Model Selection` section naming the two reference implementations and documenting the `model_budget.fable_policy` marker.

WS2 — commit-message agent (3):
9. `.claude/agents/commit-message.md` exists with `model: haiku`, `skills: [commit-message]`, `memory: project`, read-only tools; valid frontmatter.
10. `.claude/settings.json` authorizes `Agent(commit-message)`.
11. Both commit points in `orchestrate/SKILL.md` delegate message generation to `Agent(commit-message)`; `git commit` stays on the orchestrator.

WS3 — human-exception-runbook agent (3):
12. `.claude/agents/human-exception-runbook.md` exists with `model: sonnet`, `skills: [human-exception-runbook]`, `memory: project`, `Write(<FEATURE>/runbooks/**)` plus read/sourcing tools; valid frontmatter.
13. `.claude/settings.json` authorizes `Agent(human-exception-runbook)`.
14. `orchestrate/SKILL.md` exception-runbook requirement delegates authoring to `Agent(human-exception-runbook)`; orchestrator still records `runbook_path`.

Cross-cutting (2):
15. All new fields additive and optional; existing routes and checkpoints validate unchanged; validators fail closed only on present-but-malformed data.
16. Bundle sync complete for every mirror path; byte-identity and content-parity pytest contracts pass; Python (Black/Ruff/Pyright/Pytest) and PowerShell (PoshQC/Pester) toolchains green.

### From user-story.md

WS1 (7): 17–23 mirror spec items 1–8 in condensed form (route separation; config block; floor determinism + band>=floor; resolver determinism + overlay/clamp; validators pass/fail-closed + unchanged legacy; validators wired; skills document model selection + marker).
WS2 (2): 24 agent exists+valid+authorized; 25 both commit points delegate while `git commit` stays.
WS3 (2): 26 agent exists+valid+authorized; 27 exception path delegates authoring while orchestrator records `runbook_path`.
Cross-cutting (2): 28 additive/optional, legacy unchanged; 29 bundle sync complete, pytest and Pester green.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | route not a model input | PASS | grep `route` in `compute_complexity_floor.py` = no match; `resolve_delegation_model(agent, band, fable_policy)` has no route param; validators do not read route; `route-not-model-input.md` evidence | `grep -in route scripts/dev_tools/*.py` | Only docstring mentions route to state it is never an input. |
| 2 | model_policy + model_budget default disabled; mirror byte-identical | PASS | config diff shows `model_policy` (tier_order, complexity+signals+[floor], complexity_to_model, preferred_overlay) and `model_budget.fable_policy: "disabled"`; `cmp -s` identical | `cmp -s config/orchestration-routing.json <mirror>` | Byte-identity confirmed. |
| 3 | compute_complexity_floor invariants + tests | PASS | `FLOOR_CEILING_BAND="C3"`, `min(...)` clamp; empty->C1; test file covers every case; 100% coverage | `pytest test_compute_complexity_floor.py` | C4 unreachable by construction. |
| 4 | resolve_delegation_model + tests | PASS | base table + overlay (four agents at C3) + disabled clamp; tests assert non-overlay agents stay opus; config cross-check; 100% coverage | `pytest test_resolve_delegation_model.py` | Overlay agent set cross-checked against config. |
| 5 | complexity validator fail-closed | PASS | `_validate_one_assessment` enforces enum/floor==compute/band>=floor/non-empty rationale with literal messages; fail-closed tests present | `pytest test_validate_orchestrator_state_complexity.py` | 100% coverage. |
| 6 | model-routing validator fail-closed | PASS | `_validate_one_receipt` + `_validate_disabled_clamp` enforce model==resolve, no-fable, clamp provenance | `pytest test_validate_orchestrator_state_model_routing.py` | 100% coverage. |
| 7 | validators wired + backward-compat | PASS | `optional_key_validators` tuple with `if key in state_map` gate; both backward-compat tests pass | `pytest -k backward_compat` | Absent key -> zero errors. |
| 8 | orchestrate + epic-orchestrate Model Selection sections | PASS | Both skills add `## Model Selection` naming the two reference impls and the `model_budget.fable_policy` marker | diff of both SKILL.md | Matches spec text. |
| 9 | commit-message.md frontmatter | PASS | `model: haiku`, `skills: [commit-message]`, `memory: project`, tools `Read`/`Bash(git log *)`/`Bash(git diff *)` | Read of agent file | Read-only surface confirmed. |
| 10 | settings authorizes Agent(commit-message) | PASS | settings.json diff adds `Agent(commit-message)`; orchestrator.md allowlist adds it | diff of settings.json/orchestrator.md | Both source and mirror updated. |
| 11 | both commit points delegate; git commit stays | PASS | orchestrate SKILL Pre-Feature-Review and Pre-R4 bullets delegate to `Agent(commit-message)`; `git add`/`git commit` remain on orchestrator | diff of orchestrate SKILL | Explicitly stated. |
| 12 | human-exception-runbook.md frontmatter | PASS | `model: sonnet`, `skills: [human-exception-runbook]`, `memory: project`, `Write(<FEATURE>/runbooks/**)` + Read/Grep/Glob/WebFetch | Read of agent file | Write scope limited to runbooks tree. |
| 13 | settings authorizes Agent(human-exception-runbook) | PASS | settings.json + orchestrator.md allowlist additions | diff | Both source and mirror updated. |
| 14 | exception path delegates; orchestrator records runbook_path | PASS | orchestrate SKILL exception-runbook requirement delegates authoring and records returned `runbook_path` | diff of orchestrate SKILL | Matches spec. |
| 15 | additive/optional; legacy unchanged; fail-closed only on malformed | PASS | Keys not in `REQUIRED_STATE_KEYS`; key-gated; backward-compat tests; 1257 passed incl. legacy checkpoint tests | `pytest` full run | No regression. |
| 16 | bundle sync + toolchains green | PASS | 8/8 mirrors byte-identical; Black/Ruff/Pyright/Pytest green this run; Pester green per `final-pester.md` (no .ps1 changed in diff) | fresh toolchain run + `cmp` | PowerShell has zero changed source files; Pester bundle-sync contract evidence present. |
| 17–23 | user-story WS1 (condensed WS1) | PASS | Same evidence as items 1–8 | as above | Co-authoritative restatement. |
| 24 | user-story WS2 agent exists/valid/authorized | PASS | Items 9–10 evidence | as above | |
| 25 | user-story WS2 both commit points delegate | PASS | Item 11 evidence | as above | |
| 26 | user-story WS3 agent exists/valid/authorized | PASS | Items 12–13 evidence | as above | |
| 27 | user-story WS3 exception path delegates | PASS | Item 14 evidence | as above | |
| 28 | user-story cross-cutting additive/legacy unchanged | PASS | Item 15 evidence | as above | |
| 29 | user-story cross-cutting bundle sync + pytest/Pester green | PASS | Item 16 evidence | as above | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 29 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Track the spec-recorded follow-up to port the two validators to the TypeScript MCP path (`orchestrator-state-core.ts`) so the live MCP tool also rejects malformed `complexity_assessments[]`/`model_routing_receipts[]` data. This is an intentional out-of-scope deferral, not a gap in this feature.
2. Retain the recorded agent-frontmatter smoke-check evidence for the `haiku`/`sonnet` `model:` values.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules:
- All 29 criteria across `spec.md` and `user-story.md` are evaluated **PASS**.
- Every criterion in both source files was already marked `- [x]` prior to this audit; the evaluations confirm those check-offs against fresh evidence. No checkbox state change was required.
- No criterion was found PARTIAL/FAIL/UNVERIFIED, so no criterion needed to be reverted to unchecked.

### AC Status Summary

- Source: `spec.md`, `user-story.md`
- Total AC items: 29 (16 in spec.md, 13 in user-story.md)
- Checked off (delivered): 29
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 16 | 16 | 0 | Checkbox-backed; all confirmed against fresh evidence. |
| `user-story.md` | 13 | 13 | 0 | Checkbox-backed; all confirmed against fresh evidence. |

No source-file checkbox change was made because all criteria were already checked and every evaluation confirmed PASS.
