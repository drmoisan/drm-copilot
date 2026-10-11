# Feature Audit: validate-orchestrator-output session-relative checkpoint read (#787, bundling #840)

---

**Audit Date:** 2026-10-09 (timestamp 2026-10-09T00-12)
**Feature Folder:** `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787`
**Base Branch:** `origin/epic/enforcement-hook-precision-integration` @ `497cb504`
**Head Branch:** `bug/validate-orchestrator-output-session-relative-read-exec-787` @ `a9fcabc5`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/enforcement-hook-precision-integration` (commit `497cb504`; epic #852, child C6, wave 1)
- **Head branch/commit:** `bug/validate-orchestrator-output-session-relative-read-exec-787` (commit `a9fcabc5`)
- **Merge base:** `497cb504` (equals the base tip)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated at head `a9fcabc5`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/evidence/{baseline,regression-testing,qa-gates,other}/`
  - Additional evidence: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info` (read directly)
- **Feature folder used:** `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787`
- **Requirements source:** `spec.md` only (`user-story.md` intentionally absent)
- **Work mode resolution note:** `issue.md` declares `full-bug`, so `spec.md` is the sole AC source.
- **Plan:** `plan.2026-10-08T13-54.md` (137 checked, 2 unchecked: P6-T5 and P6-T17)

### Baseline vs Delivered

| Area | Baseline (`497cb504`) | Delivered |
|---|---|---|
| Checkpoint read at SubagentStop | Process-relative literal (`-CheckpointPath`) at every use | Resolved through WRR exports into an absolute path beneath the run's worktree; blocks with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` when there is not exactly one target |
| `runbook_path` existence check | Process-relative `Test-Path` | Beneath the resolved root, through a mockable seam |
| Layer 2 wave-barrier at epic SubagentStop | Not run (structural check only) | PowerShell port invoked on the checkpoint text already read; violation lines unwrapped, then a report-and-halt instruction |
| Parity with the Python authority | Not applicable | Shared corpus checked by Pester and by pytest against `validate_epic_orchestrator_state_text` |
| #840 documents | Claimed that Layer 2 ran at SubagentStop | Corrected in SKILL.md, the agent, and the Layer 1 header, with a transport-defect caveat |

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/spec.md` — only source (`## Acceptance Criteria`, lines 184-209, 26 checkbox items)

### Acceptance criteria

The full criterion wording is authoritative in `spec.md`; the labels below identify each item by its order in that section.

1. AC-1 (spec line 184) — resolve all three checkpoint types through exported `WorktreeRunResolution.psm1` functions.
2. AC-2 (line 185) — every downstream read uses the resolved absolute root.
3. AC-3 (line 186) — `NoTarget`/`Ambiguous` block with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:`.
4. AC-4 (line 187) — bound `-CheckpointPath` leaf cross-check.
5. AC-5 (line 188) — guarded resolver import with `RESOLVER_IMPORT_FAILED`.
6. AC-6 (line 189) — `ROUTING_CONTRACT_BLOCKED:`/`MODEL_ROUTING_BLOCKED:` unchanged.
7. AC-7 (line 190) — new two-worktree suite `validate-orchestrator-output.WorktreeResolution.Tests.ps1`.
8. AC-8 (line 191) — existing suites mock the resolution seam; relative-literal rows assert absolute paths.
9. AC-9 (line 192) — `OrchestratorStateEpicWaveBarrier.psm1` exports `Get-OrchestratorStateEpicWaveBarrierError`.
10. AC-10 (line 193) — Layer 2 for `epic-orchestrator-state` only, after routing, on text already read.
11. AC-11 (line 194) — no Python introduced.
12. AC-12 (line 195) — byte-identical violation text, including `str()` rendering.
13. AC-13 (line 196) — fail-closed divergence classes produce `EPIC_WAVE_BARRIER_UNEVALUABLE:`.
14. AC-14 (line 197) — new fixture `layer2-parity-edge-cases.json` covering research section 3.5.
15. AC-15 (line 198) — parity suite runs every case of every file with count assertions.
16. AC-16 (line 199) — pytest lane runs every case through the Python authority.
17. AC-17 (line 200) — divergence classes listed in the parity suite header with pinning rows.
18. AC-18 (line 201) — violation block instructs report-and-halt with no history-edit suggestion.
19. AC-19 (line 202) — SKILL.md Layer 2 bullet corrected.
20. AC-20 (line 203) — agent SubagentStop sentence corrected.
21. AC-21 (line 204) — Layer 1 header comment corrected after C2 (#565) merges.
22. AC-22 (line 205) — transport-defect note on each corrected passage.
23. AC-23 (line 206) — byte-identical mirrors, Codex check, `core.json` registration.
24. AC-24 (line 207) — no file over 500 lines.
25. AC-25 (line 208) — Pester line coverage at least 85% per file for hook, sibling, and port.
26. AC-26 (line 209) — full PowerShell and Python toolchain loops clean in a single pass; baseline Pester failures are residuals.

---

## Acceptance Criteria Evaluation

| AC | Criterion (abridged) | Verdict | Evidence (reviewer-verified unless noted) |
|---|---|---|---|
| AC-1 | Resolve all three types through exported WRR functions plus `Get-WorktreeItemLiveRoot`; WRR unchanged | PASS | Sibling calls only exported functions (code review). No `.claude/lib/worktree-resolution/` path in the diff. R1-R12. |
| AC-2 | Every downstream read uses the resolved absolute root; Pester asserts the path at each seam | PASS | Hook diff. R1 (read, `Get-OrchestratorStateCheckpoint`, Layer 2 text), R12 (`Test-OrchestratorStateCompletionReadiness`), R13 (runbook seam). |
| AC-3 | `NoTarget`/`Ambiguous` block with the lead token, type, status, and reason; no read, routing, or Layer 2 | PASS | R5, R6, R7, R8, R10 assert the prefix and `-Times 0` on all three seams. |
| AC-4 | `-CheckpointPath` leaf cross-check; rooted, escaping, and non-canonical values block with `CHECKPOINT_PATH_MISMATCH`; existing registrations pass | PASS | S2-1 to S2-5, R14. S2-6 parses all six registrations in `settings.json` and three agent files. I confirmed the registration values by grep. |
| AC-5 | Guarded resolver import; failure blocks with `RESOLVER_IMPORT_FAILED` and the module name; no read | PASS | Hook lines 53-77 and 385-388; S2-12. |
| AC-6 | `ROUTING_CONTRACT_BLOCKED:`/`MODEL_ROUTING_BLOCKED:` unchanged; existing assertions unedited | PASS | Message lines unchanged in the diff. The dispatch and model-routing suites gained only a `BeforeAll` mock. JUnit: dispatch 17/0, model-routing 6/0, main 25/0. |
| AC-7 | New two-worktree suite: epic, parallel, item, stale copy, signal precedence, discovery, ambiguity; module-scope mocks only; no files | PASS | `validate-orchestrator-output.WorktreeResolution.Tests.ps1` R1-R14. The purity scan is clean. |
| AC-8 | Existing suites mock the seam by default; relative-literal rows assert absolute paths | PASS | Default mocks added to three suites. The two relative-literal rows were moved into the new suite as absolute-path assertions (R12 defaults; R1/R14 custom) instead of being edited in place, to respect the 500-line cap. Judged to meet the criterion's intent. |
| AC-9 | Port exports `Get-OrchestratorStateEpicWaveBarrierError`; full algorithm; `System.Text.Json` | PASS | Port line 346; parity trace in the code review; `JsonDocument::Parse` at line 331; no `ConvertFrom-Json` in the port. |
| AC-10 | Layer 2 for the epic type only, after routing, on the text already read | PASS | Hook lines 461-466; H1, H5, H6, H7. |
| AC-11 | No Python introduced | PASS | Grep shows comment-only matches. No-Python suite 27/0 and main suite 25/0 in JUnit. |
| AC-12 | Byte-identical violation text including `str()` rendering; surfaced unwrapped | PASS | Parity lane 7/0; pytest lane 30/30 against the authority; U8 (`False`); H1, H2. |
| AC-13 | Fail-closed classes produce `EPIC_WAVE_BARRIER_UNEVALUABLE:` | PASS | U9-U12, D3-D5, H8-H11. |
| AC-14 | New corpus covers the research section 3.5 categories; `start-guard-matrix.json` unchanged | PASS | New fixture, 334 lines. `start-guard-matrix.json` is not in the diff. Category coverage per `evidence/regression-testing/corpus-written.2026-10-08T22-36.md` (executor-recorded). |
| AC-15 | Parity suite runs every case of every file; count and non-empty asserts | PASS | Parity suite lines 56-95. |
| AC-16 | pytest lane runs every case through the authority with the prefix filter and count assert; existing count assertions unchanged | PASS | `final-py-targeted` 149 passed; TS lanes 16/16. |
| AC-17 | Divergence classes listed in the parity header with pinning rows; duplicate keys in the unit suite | PASS | Parity header D1-D5 with rows; U6. |
| AC-18 | Violation block instructs report-and-halt with no history-edit suggestion; Pester asserts both | PASS | Sibling line 37; H3. |
| AC-19 | SKILL.md Layer 2 bullet corrected (port, hook, fixtures, Python authority via MCP) | PASS | SKILL diff; mirror SHA-256 identical. |
| AC-20 | Agent SubagentStop sentence matches | PASS | Agent diff; mirror identical. |
| AC-21 | Layer 1 header comment corrected after C2 merges; comment-only change | PASS | Diff touches only lines 29-36 of the comment block; `wave-comment-only` evidence; mirror identical. |
| AC-22 | Each corrected passage carries the transport-defect note | PASS | All three diffs cite `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`. |
| AC-23 | Mirrors byte-identical; Codex checked; `core.json` registers both; manifest test updated; parity suites pass | PASS | Six SHA-256 pairs identical (independent). Codex copies make no Layer 2 claim (grep). `core.json` +2. Manifest +1, 6/0 in JUnit. Bundle suites 17/17. |
| AC-24 | No file over 500 lines | PASS | Independent `wc -l`; maximum 482. |
| AC-25 | Pester line coverage at least 85% for the hook, sibling, and port | PASS | Hook 94.62% (repo artifact, independently read); sibling 98.96%; port 100% (executor per-file run; see the policy audit coverage note). |
| AC-26 | Full PS and Python toolchain loops clean in a single pass; baseline Pester failures are residuals | PASS | See the AC-26 evaluation below. **Checked off by this review.** |

### AC-26 Evaluation

The spec text is the AC source: "The full PowerShell toolchain loop (format, analyze, test) and the full Python toolchain loop (black, ruff, pyright, pytest with coverage) complete without errors in a single pass. Pester failures recorded in the Phase 0 SET-LIB and SET-FULL baselines as pre-existing (...) are reported as residuals and do not block this criterion; any other failure does."

Independent verification:

1. **Format and analyze.** Both passed in pass 1 with no file rewritten (`final-ps-format`, `final-ps-analyze`; PSSA DiagnosticCount=0).
2. **Test, via the MCP runner.** I read `artifacts/pester/pester-junit.xml` directly. It was written at 23:53, after the last code-changing commit (`73319552` at 23:32). Totals: `tests="7659" errors="0" failures="2"`. Exactly two `<testsuite>` elements have non-zero failures:
   - `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (1 failure)
   - `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (1 failure)

   Both case names appear verbatim in the Phase 0 SET-FULL baseline (`evidence/baseline/pester-set-full.2026-10-08T22-36.md` lines 33 and 72), classified KL-HERMETIC and tracked by #737. No `<testsuite>` has a non-zero `errors` count. Every suite added or changed by this branch reports zero failures. The MCP exit code (2) equals the residual failure count.
3. **Test, via the self-hosted SET-FULL run.** 7659 total, 40 failed, `FAILED-SET baseline=40 final=40 new=0` (`final-pester`). The 38 KL-ADOPT lines pass in the MCP run, so the MCP failure set is a strict subset of the baseline set.
4. **Python loop.** black, ruff, pyright, and pytest (6633 passed, 0 failed; line 93.71% and branch 87.16%, cross-checked against `artifacts/python/lcov.info`) all passed in the same pass.

No failure occurred outside the baseline set. Under the spec text, the two KL-HERMETIC failures are residuals and do not block. **AC-26: PASS.** I checked it off in `spec.md`.

Residuals (reported, non-blocking):
- KL-HERMETIC (#737): `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`; `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`.
- KL-ADOPT (`docs/features/potential/2026-10-01-issue-adoption-pester-folder-scoped-command-not-found.md`): 38 lines in the self-hosted folder-scoped runs only.

### Plan-checklist state (recorded, not changed by this review)

- **P6-T5** (`[ ]`): its acceptance required the MCP call to return with disposition `EXIT_CODE: 0`. This is a plan-level gate stricter than the spec, because it does not carry the baseline-residual exemption. The call exited 2 because of the two residuals.
- **P6-T17** (`[ ]`): inherits P6-T5's unmet acceptance.
- **P6-T21** (`[x]`): executed via its "otherwise" branch, which left AC-26 unchecked for reviewer decision.

The divergence lies between the plan's task-level acceptance and the spec's criterion. It is not a product or toolchain defect: every check that the spec criterion names passed or failed only on baseline residuals. The plan tasks are left as the executor recorded them. Whether to annotate them is an orchestration decision. This is not a blocking finding for this review, because the spec is the AC source.

### Executor Departures

All seven recorded departures were assessed as non-defects. See the code review section "Assessment of the Seven Recorded Departures from Plan Text".

### Out of Scope (confirmed)

- The SubagentStop stdin/exit-2 envelope (`docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`) is an operator decision and is left unchanged. The corrected documents state that the runtime effect likely depends on it.
- `WorktreeRunResolution.psm1` is unchanged (owned by C3 #850).
- The TypeScript parity lane was not extended (non-goal); its existing lanes pass 16/16.

---

## Summary

**Overall Feature Readiness:** PASS

PASS. All 26 acceptance criteria evaluate PASS. There are no blocking findings, so no remediation inputs were produced.

**Criteria summary:**
- **PASS:** 26 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Orchestration decision on whether to annotate plan tasks P6-T5 and P6-T17 (see "Plan-checklist state" above).

---

## Acceptance Criteria Check-off

AC-26 evaluated PASS and was checked off in `spec.md` by this review. AC-1 through AC-25 were already checked. No criterion is left unchecked.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/spec.md`
- Total AC items: 26
- Checked off (delivered): 26
- Remaining (unchecked): 0
- Items remaining: none
- Newly checked off by this review: AC-26 ("The full PowerShell toolchain loop (format, analyze, test) and the full Python toolchain loop ... complete without errors in a single pass. ...")

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 26 | 26 | 0 | Checkbox-backed; AC-26 checked off by this review |
