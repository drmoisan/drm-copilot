# Feature Audit: Epic-Level Checkpoint Seam for Enforcement Gates (#663)

**Audit Date:** 2026-09-25
**Feature Folder:** `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663`
**Base Branch:** `origin/main`
**Head Branch:** `bug/enforcement-gates-lack-epic-level-checkpoint-seam-663`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `d754f83f`)
- **Head branch/commit:** `bug/enforcement-gates-lack-epic-level-checkpoint-seam-663` (commit `ac8ef840`)
- **Merge base:** `d754f83f714b087e404577cb7a1b02f48d2023bb`
- **Evidence sources:**
  - Primary: `git diff origin/main...HEAD` and `git log origin/main..HEAD` (the PR context summary and appendix are absent in the worktree and the collector is not in this reviewer's toolset; see code review CR-9)
  - Secondary baseline diff: per-file `git diff origin/main...HEAD -- <path>` inspections
  - Feature evidence: `evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, `evidence/other/`
  - Additional evidence: reviewer SHA-256 mirror comparison, `git ls-files --eol`, `validate_evidence_locations.py` (exit 0), code trace of the staging-exemption parser
- **Feature folder used:** `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663`
- **Requirements source:** `spec.md` only (`## Acceptance Criteria`, lines 222-277)
- **Work mode resolution note:** `issue.md:3` reads `- Work Mode: full-bug`; `spec.md:9` agrees.
- **Scope note:** Operator-approved decisions D1-D5 (`spec.md:69-73`) were evaluated for conformance and not reopened. Pester and pytest results are taken from the executor's recorded evidence (full runs at 2026-09-25T20-07 and 20-13 local); the reviewer could not execute PowerShell in this worktree because the isolation guard denies `pwsh`/`powershell` command text.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/spec.md` — only source

### Acceptance criteria

1. (spec.md:226) `EpicScopeResolution.Tests.ps1` passes with cases proving: epic scope when the branch signal equals the epic checkpoint's `integration_branch`; epic scope for a command leg whose `-C` selector worktree HEAD, or session-root HEAD when no selector is present, equals `integration_branch`; not epic scope when the epic checkpoint is absent, unparseable, has `route_id` other than `epic`, or the branch does not match; the returned checkpoint path is absolute and is never taken from command or prompt text.
2. (spec.md:230) `enforce-pr-author-skill.EpicScope.Tests.ps1` allow case: `gh pr create --head <integration_branch> --base main` is allowed when the epic checkpoint has `route_id: epic`, a matching `integration_branch`, and every `features[].merge_status` in `{merged, worktree_removed}`, with no per-feature checkpoint present.
3. (spec.md:231) `enforce-pr-author-skill.EpicScope.Tests.ps1` deny cases: the same command is denied when a feature has a non-terminal `merge_status`, when `features` is empty, and when the epic checkpoint is absent; each epic-scope denial reason names the epic checkpoint and the failed conjunct.
4. (spec.md:232) `enforce-pr-author-skill.EpicScope.Tests.ps1` standalone case: a per-feature PR (`--head` not equal to any epic `integration_branch`) yields the same decision and reason text as before the change, and all existing `enforce-pr-author-skill*.Tests.ps1` suites pass unmodified.
5. (spec.md:236) `enforce-pr-author-skill.epic-base-branch.Tests.ps1` epic-scope cases: `--base main` is allowed and any other `--base` value is denied with `EPIC_BASE_BRANCH_MISMATCH`, using the scope result gate 1 resolved (a single resolution per call).
6. (spec.md:237) The existing per-feature `epic_mode: true` / `epic_mode: false` rows in `enforce-pr-author-skill.epic-base-branch.Tests.ps1` and `enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` pass without modification.
7. (spec.md:241) `enforce-model-routing-receipt.EpicScope.Tests.ps1` allow case: `Agent(pr-author)` with a `branch:` label equal to `integration_branch` is allowed when the epic checkpoint's `model_routing_receipts[]` contains a `pr-author` receipt.
8. (spec.md:242) `enforce-model-routing-receipt.EpicScope.Tests.ps1` deny case: the same delegation is denied with `MODEL_ROUTING_RECEIPT_BLOCKED` when the epic checkpoint has no `pr-author` receipt.
9. (spec.md:243) `enforce-model-routing-receipt.EpicScope.Tests.ps1` standalone case: a per-feature delegation resolves the per-feature checkpoint with unchanged decision and reason text, and the existing `enforce-model-routing-receipt*.Tests.ps1` suites pass unmodified.
10. (spec.md:247) `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` allow case: in epic scope with a ready epic checkpoint and a mocked `MERGE_HEAD` present, `git add <production path>` is allowed.
11. (spec.md:248) `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` deny cases: in epic scope, `git add <production path>` is denied with `PREIMPLEMENTATION_GATE_BLOCKED` when no merge is in progress (D2), and when an epic-shape conjunct (`route_id`, `epic_feature_folder`, `epic_manifest_path`, `integration_branch`, or `features`) is missing; the reason names the epic checkpoint and the failed conjunct.
12. (spec.md:249) `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` path-leg case: an Edit or Write to a production path in epic scope follows the same readiness decision as the command leg.
13. (spec.md:250) `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` standalone case: with no epic checkpoint, the command and path legs return the single-feature decision and reason text unchanged, and the existing `enforce-orchestration-preimplementation-gate*.Tests.ps1` suites pass unmodified (including the delegation-leg mode-resolution suite from #554).
14. (spec.md:254) `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` passes new rows proving: `git add <exempt path> && git commit -m "<message with Co-Authored-By: Name <noreply@anthropic.com> and an apostrophe such as it's>"` is exempt; a single-quoted `-m` value containing `<` and `>` is exempt; the `'\''` apostrophe idiom is denied (D4); `$(`, `$VAR`, and backtick inside a double-quoted message are denied; and the existing unquoted `>` and `<` redirection rows still deny.
15. (spec.md:255) `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` carries the same new rows and passes against the `.codex/hooks` helpers copy.
16. (spec.md:256) `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` passes, proving all four copies of `enforce-orchestration-preimplementation-gate-helpers.ps1` are SHA-256 identical after the change, and `legacy-codex-hook-contracts.Tests.ps1` passes.
17. (spec.md:260) `enforce-completion-consistency.Tests.ps1` pinning rows pass: a completion-asserting Write or Edit to `artifacts/orchestration/epic-orchestrator-state.json` is not intercepted, and a per-feature `orchestrator-state.json` whose `feature-folder` is `docs/features/epics/<slug>` is still denied with `COMPLETION_CONSISTENCY_BLOCKED`; `git diff origin/main -- .claude/hooks/enforce-completion-consistency.ps1 .claude/hooks/enforce-completion-helpers.ps1` is empty.
18. (spec.md:264) `enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1`, `enforce-parallel-worktree-removal-gate.Tests.ps1`, and `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` pass unmodified, and `git diff origin/main -- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1` is empty.
19. (spec.md:268) `.claude/skills/epic-plan/SKILL.md` and `.claude/agents/epic-planner.md` state that `epic-planner` promotes an epic-level issue at planning time through `mcp__drm-copilot__potential_to_issue` with `promotion_type: epic` and records the resulting number as `epic_issue_num` in the epic checkpoint; `epic-planner.md` frontmatter lists `mcp__drm-copilot__potential_to_issue`. Verified by new rows in `checkpoint-hygiene-skill-contract.Tests.ps1`.
20. (spec.md:269) `.claude/skills/epic-orchestrate/SKILL.md` states the integration-PR checkpoint shape, that the integration PR and its `Agent(pr-author)` delegation are gated against `epic-orchestrator-state.json`, and that the `pr-author` receipt is recorded in that file's `model_routing_receipts[]`; `.claude/agents/epic-orchestrator.md` lists `epic_issue_num` and `model_routing_receipts` in its epic checkpoint field list. Verified by new rows in `checkpoint-hygiene-skill-contract.Tests.ps1`; the existing #673 hygiene rows pass unmodified.
21. (spec.md:270) `test_validate_epic_orchestrator_state.py` passes a new case proving `validate_epic_orchestrator_state` accepts an epic checkpoint carrying `epic_issue_num` and `model_routing_receipts`, and `test_parallel_planner_surface_contracts.py` passes unmodified.
22. (spec.md:274) Every new or modified `.claude/**` file is text-identical to its mirror; new `.claude/**` files are listed in `pack-manifests/core.json`; `WorktreeResolution.Manifest.Tests.ps1` passes with the new module(s) registered in `ExpectedPaths` and SHA-256 identical to the bundle copy.
23. (spec.md:275) `enforcement-hooks-no-python-invocation.Tests.ps1` passes, and the new resolver and predicate module headers declare the epic readiness predicates PowerShell-authoritative (D5).
24. (spec.md:276) No new or modified production or test file exceeds 500 lines, and `WorktreeResolution.psm1` and `OrchestratorState.psm1` show an empty `git diff origin/main`.
25. (spec.md:277) Full PowerShell toolchain passes in one pass, and each new or changed PowerShell production file reports line coverage >= 85% in the coverage evidence recorded under the feature folder's `evidence/coverage/`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Resolver suite | PASS | 21 resolver names Passed (`final-pester-coverage.md`); tests at `EpicScopeResolution.Tests.ps1:57-120` and later rows cover branch signal, `-C` HEAD, session-root HEAD, absent, unparseable, non-epic, mismatch, absolute path, path-not-from-text. Code: `EpicScopeResolution.psm1:317-321` composes the path from the resolved root only. | `git diff origin/main...HEAD -- .claude/lib/worktree-resolution/EpicScopeResolution.psm1` | Fail-closed behaviour confirmed by reading every early return. |
| 2 | Gate 1 allow | PASS | `enforce-pr-author-skill.EpicScope.Tests.ps1:83-95`; per-feature seams invoked 0 times. | test file inspection; `final-pester-coverage.md` | |
| 3 | Gate 1 deny | PASS | Rows for `pr_open` and empty `features` assert reason names `epic-orchestrator-state.json` and the conjunct; absent-checkpoint row denies through the unchanged per-feature path. | test file inspection | An absent checkpoint is not epic scope (`spec.md:99`), so its denial is not an epic-scope denial. |
| 4 | Gate 1 standalone | PASS | Row comparing decision/reason with and without an epic checkpoint; `p7-existing-suites.md` shows pr-author suites unmodified except the extended epic-base-branch suite (additions only). | `git diff --numstat origin/main...HEAD -- tests` | |
| 5 | Gate 2 epic scope | PASS | `enforce-pr-author-skill.epic-base-branch.Tests.ps1` new context: `--base main` allow, `development`/integration-branch/absent `--base` deny with `EPIC_BASE_BRANCH_MISMATCH`, single `Get-EpicScopeCheckpointText` invocation. | test diff inspection | |
| 6 | Gate 2 existing rows | PASS | Existing rows unchanged (numstat 82/0); TriggerScoping suite absent from numstat; full Pester 0 failures. | `git diff --numstat origin/main...HEAD -- tests` | |
| 7 | Gate 3 allow | PASS | `enforce-model-routing-receipt.EpicScope.Tests.ps1` first row; per-feature resolution invoked 0 times. | test file inspection | |
| 8 | Gate 3 deny | PASS | Second row asserts `MODEL_ROUTING_RECEIPT_BLOCKED`, epic checkpoint name, and `model_routing_receipts`. | test file inspection | |
| 9 | Gate 3 standalone | PASS | Third row asserts the byte-identical pre-change reason; both existing model-routing suites unmodified. | test file inspection; `p7-existing-suites.md` | |
| 10 | Gate 4 allow (D2) | PASS | Gate EpicScope suite row 1 (merge in progress, allow). | test file inspection | |
| 11 | Gate 4 deny | PASS | No-merge row names `'merge-in-progress'`; `epic_feature_folder`, `epic_manifest_path`, `features` rows name the checkpoint and conjunct; `route_id`/`integration_branch` rows deny through the single-feature path. | test file inspection; `plan.2026-09-25T08-25.md:157` (RS-2) | For `route_id`/`integration_branch` the reason does not name the epic checkpoint. These two fields decide scope (`spec.md:83`), and `spec.md:99` requires that a checkpoint without them is not epic scope, so the literal wording cannot be met for those two without breaking that rule. The readiness predicate names both conjuncts when called directly. Treated as PASS under the documented RS-2 interpretation. |
| 12 | Gate 4 path leg | PASS | Edit allow with merge; Write deny without merge naming the checkpoint and conjunct. | test file inspection | |
| 13 | Gate 4 standalone | PASS | No-checkpoint command and path rows return the exact pre-change reason; existing gate-4 suites including mode-resolution unmodified. | `p7-existing-suites.md` | |
| 14 | Gate 4b rows | PASS | Eight new rows in `CommandExemption.Tests.ps1:432-465` cover every listed case and passed. | test diff inspection; `final-pester-coverage.md` | The listed rows pass. Separately, code review CR-1 (Blocker) shows that a backslash-escaped double quote lets a redirection through; none of this AC's rows covers that form. The AC as written is met; the defect is tracked as CR-1. |
| 15 | Codex 4b rows | PASS | Codex suite numstat 35/0 with the same rows; helpers copy byte-identical. | `git diff --numstat`; `sha256sum` | |
| 16 | Helper parity | PASS | Reviewer SHA-256: all four copies `28164c591831d1f3...`; parity (2) and legacy-codex (43) suites passed. | `sha256sum` over the four copies | |
| 17 | Gate 5 pinning (D3) | PASS | Two D3 rows added and passed; `git diff --stat origin/main...HEAD -- .claude/hooks/enforce-completion-consistency.ps1 .claude/hooks/enforce-completion-helpers.ps1` empty. | reviewer `git diff --stat` | |
| 18 | Gate 6 non-regression | PASS | Three suites absent from numstat; `enforce-parallel-worktree-removal-gate.ps1` diff empty. | reviewer `git diff --stat` | |
| 19 | epic-plan / epic-planner contract | PASS | `## Epic-Level Issue Promotion` section; frontmatter lists `mcp__drm-copilot__potential_to_issue` and `Write(docs/features/potential/**)`; `epic_issue_num` in Checkpoint Persistence; two contract rows passed. | diff inspection | |
| 20 | epic-orchestrate / epic-orchestrator contract | PASS | Integration-PR checkpoint-shape paragraph; agent field list gains both fields; two contract rows passed; #673 rows unmodified. | diff inspection | |
| 21 | Validator additive test | PASS | New test passed (32 passed); `test_parallel_planner_surface_contracts.py` unmodified and in the 119-pass contract run. | `final-pytest-validator-coverage.md`, `final-pytest-contracts.md` | The frozen-surface pin data in `parallel_orchestrator_surface_expectations.py` was re-baselined (a different suite's data file); digests verified. |
| 22 | Mirrors and manifests | PASS | Reviewer SHA-256 equality for all 12 `.claude/**` files and mirrors; `core.json` gains three entries; manifest test registers both modules. Contract suites 119 passed; Jest 16 passed. | `sha256sum`; diff inspection | |
| 23 | No Python in hooks (D5) | PASS | No added hook/lib line invokes `python`, `poetry`, or a `.py` file; `AUTHORITY: PowerShell-authoritative` line in both module headers; no-Python suite passed in the full run. | grep over `git diff origin/main...HEAD -- .claude/hooks .claude/lib` | |
| 24 | 500-line limit | PASS | Max production 488 (helpers), max test 496 (`test_validate_epic_orchestrator_state.py`); `WorktreeResolution.psm1` and `OrchestratorState.psm1` diff empty. | `wc -l`; `git diff --stat` | |
| 25 | Toolchain and coverage | PASS | Pass 2 clean (`final-seven-stage-loop.md`); nine measured files 90.38%-100.00%; no regression (`final-coverage-delta.md`). | evidence inspection | Evidence is under `evidence/qa-gates/`, the canonical location. `evidence/coverage/` is not a canonical evidence kind: `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <FEATURE>/evidence/coverage/ replaced with <FEATURE>/evidence/qa-gates/`. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

All 25 acceptance criteria are satisfied as written. Readiness is NEEDS REVISION because the code review contains one Blocker (CR-1) in the gate-4b change. CR-1 is outside the listed AC rows but inside the spec's stated risk mitigation (`spec.md:283`).

**Criteria summary:**
- **PASS:** 25 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. CR-1 (Blocker): backslash-escaped double quotes let a shell-unquoted `>` redirection through the staging exemption (`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:139-149`, all four copies).
2. CR-2 (Major): in gate 4 a text branch signal overrides the `-C` selector, so the D2 `MERGE_HEAD` probe can target the session root instead of the effective worktree (`.claude/lib/worktree-resolution/EpicScopeResolution.psm1:336-355`).
3. The manual #655-sequence rerun (`spec.md:292`) and the CI run on the branch head are outstanding.

**Recommended follow-up verification steps:**

1. After CR-1 remediation, add deny rows for `git commit -m "a\"" > out.txt "\"" -- <exempt path>` and for the equivalent `;` form to both command-exemption suites, and rerun the full PowerShell toolchain and parity suite.
2. Regenerate PR context against `origin/main` and confirm the CI workflow is green on the remediated head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 25 criteria were already checked by the executor and each was independently evaluated as PASS. No checkbox in `spec.md` was changed by this review.

### AC Status Summary

- Source: `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/spec.md`
- Total AC items: 25
- Checked off (delivered): 25
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/spec.md` | 25 | 25 | 0 | Checkbox-backed; no change made by this review |
