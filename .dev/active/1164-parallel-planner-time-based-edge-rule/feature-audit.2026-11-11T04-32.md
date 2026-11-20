# Feature Audit: parallel-planner-time-based-edge-rule (#1164)

**Audit Date:** 2026-11-11
**Feature Folder:** `docs/features/active/parallel-planner-time-based-edge-rule-1164`
**Base Branch:** `main`
**Head Branch:** `feature/parallel-planner-time-based-edge-rule-1164`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `228e6f8c4606e53f36963dc9aa57d71b4882b49e`, equal to `origin/main` after a fetch at review time)
- **Head branch/commit:** `feature/parallel-planner-time-based-edge-rule-1164` (commit `35e8a26275d7f89e559449f2437dfc18aa654b0f`, clean worktree)
- **Merge base:** `228e6f8c4606e53f36963dc9aa57d71b4882b49e`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (Head SHA `35e8a2627`, generated 2026-11-11 03:57 UTC)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/parallel-planner-time-based-edge-rule-1164/evidence/**`
  - Additional evidence: reviewer parse of the canonical coverage artifacts; mirror `cmp` of 16 pairs; real-process probes of `test-precedence` (9 shapes) and `access-paths`; branch-versus-`main` validator run over 8 real checkpoints; esbuild cross-runtime probe of the TypeScript validator against the Python validator
- **Feature folder used:** `docs/features/active/parallel-planner-time-based-edge-rule-1164`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 10 carries `- Work Mode: full-feature`. `user-story.md` holds the 13 checkbox criteria (US-AC1 to US-AC13). `spec.md` states its criteria as behavior sections B1 to B10, mapped to the user-story criteria by `## Acceptance Criteria Traceability`, a non-checkbox table. The spec's `## Definition of Done` checkboxes are a template checklist, not acceptance criteria, so this review left them unchanged. Each spec section is evaluated through the user-story criterion that cites it.
- **Scope note:** full branch diff against the merge base (162 files, including the 61 paths merged from `main` by `25dcbcdc2` that the branch shares with `main`).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/parallel-planner-time-based-edge-rule-1164/user-story.md` (13 checkbox items under `## Acceptance Criteria`)
- `docs/features/active/parallel-planner-time-based-edge-rule-1164/spec.md` (behavior sections B1 to B10, traced to the user-story items; no checkbox criteria)

### Acceptance criteria

1. US-AC1: pinned sentence and rule text on the twelve surfaces; wording contract test.
2. US-AC2: `parallel-orchestrate` consistent; no tolerated-not-validated statement for `hard`, `cost`, `benefit`, `tolerated_overlaps`.
3. US-AC3: committed minute values in both configs; `weights.separable` reader rules in PowerShell and Python.
4. US-AC4: edge iff `cost > benefit` at defaults in both runtimes; every B4 row tested via the shared corpus.
5. US-AC5: optional `read_paths`/`separable_paths`; `access-paths` derivation; radius never narrowed; drift escape and peer re-pricing.
6. US-AC6: checkpoint estimates recorded and validated in Python and TypeScript with byte-identical strings; a pair in both lists rejected.
7. US-AC7: manifest M9 `pair_decisions[]` validated by Python and bash; `parallel-scheduling.json` projections.
8. US-AC8: records without the new fields stay valid; `seed-scheduling-record.json` unchanged.
9. US-AC9: `test-precedence` accept, reject (exact line), correctness accept, blank-reason reject; tests.
10. US-AC10: legacy entries honoured; `precedence_not_justified` listed in three places; no `tools:` change.
11. US-AC11: overlay of `weights.same_file` composes over the recalibrated base; base-only `separable` passes through.
12. US-AC12: byte-equal mirrors; `core.json` entries; push-down contract tests pass.
13. US-AC13: the PR body states the default behaviour change (OD-1164-1) and the MCP release dependency.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | US-AC1 pinned sentence on twelve surfaces | PASS | Reviewer `grep -rlF` of the sentence finds exactly the six sources and six mirrors; none under `.github`, `.agents`, `.codex`. `parallel-scheduling-rule-wording.Tests.ps1` 228 passed post-merge. | `grep -rlF "<sentence>" .claude extensions/drm-copilot/resources .github .agents .codex` | Rule text with minutes, read-only 0, shorter band, hard edges, tie, `precedence_not_justified` present (for example `parallel-orchestration.md` line 522) |
| 2 | US-AC2 `parallel-orchestrate` consistent | PASS | The remaining "tolerated-not-validated" statements concern `mergeable_conflicts_resolved` and `observed_resolution` only (rule lines 395 and 630; orchestrator agent line 292); none concerns `hard`, `cost`, `benefit`, or `tolerated_overlaps`. Mirror byte-equal after the merge. | `grep -n -i "tolerated-not-validated"` over the rule, skills, agents | |
| 3 | US-AC3 committed values and reader rules | PASS | Parsed `conflict_tolerance` equal in both copies and equal to spec B3 (tolerance 100; bands 30/45/90/180; weights 90/90/20/10/10/15; `append_only_paths` includes `extensions/drm-copilot/resources/**`; threshold 400). Reader cases in `test_blast_radius_config_tolerance_keys.py` and `BlastRadiusScheduling.Tests.ps1` pass. | Python `json.load` of both copies | Copies differ outside `conflict_tolerance`, as at the merge base |
| 4 | US-AC4 edge iff cost > benefit; B4 rows | PASS | `scheduling-1164-committed-minutes.json` carries every B4 row (read-only C1/C1 and C4/C4, append-only, separable, same file C2/C2, C3/C3 tie, C1/C4, both hard classes) at tolerance 100 and 0, consumed by `BlastRadiusScheduling.Tests.ps1` and `test_blast_radius_scheduling.py`. Strict case for absent `conflict_tolerance` in the same suites. | Post-merge Pester and pytest gates, 0 failed | |
| 5 | US-AC5 access declarations, derivation, drift | PASS | `access-paths` probe on the item's own plan returned only `scripts/powershell/PoshQC/PoshQC.psd1`, which is named only by `Run` tasks. Created and written paths were excluded. The validator rejects a list entry absent from `blast_radius.paths`. Drift tests: `ParallelDriftAccess.Tests.ps1`, `test_parallel_drift_scheduling.py`. | `pwsh ... Invoke-ParallelAdmission.ps1 access-paths -Entry <json>` | Title-word heuristic limits in code review (Info) |
| 6 | US-AC6 checkpoint estimates validated, byte-identical | PASS | 23-case corpus `tests/fixtures/parallel_state_scheduling/` identical in Python (22 passed) and Jest (suite passed), including `reject-pair-in-both-lists.json`. The reviewer probe found two divergences for apostrophe-bearing values, both from the unchanged shared `pythonRepr` helper. | esbuild bundle vs `validate_parallel_planner_state_text` | Documented as a Minor code-review row; corpus parity holds |
| 7 | US-AC7 manifest M9 and durable record | PASS | `parallel_manifest_contract.py` 100% lines and branches; bats `parallel_manifest_parity.bats` ok 154 to 156 in CI run 42746009388; `hard: true` with `verdict: tolerated` fixture present; `parallel-scheduling.json` projection tests in `ParallelAdmissionPrecedence.Tests.ps1`. | CI `shell-coverage` job; post-merge pytest gate | |
| 8 | US-AC8 legacy records valid | PASS | `seed-scheduling-record.json` absent from the branch diff. The branch and `main` validators both return 0 errors on 8 real planner and orchestrator checkpoints. `accept-without-fields.json` passes. | `r1164_real.txt` probe under both roots | |
| 9 | US-AC9 `test-precedence` outcomes | PASS | Real-process probe: cost edge exit 0. Tolerated cost exit 1 with exactly `PARALLEL_ADMISSION_REJECTED: precedence_not_justified: --after 2:1 fails the parallel scheduling rule (merge time 90 min does not exceed parallel gain 90 min); add --reason "<text>" to record a correctness ordering`. Non-conflict exit 1 with merge time 0 and gain 45. Correctness with reason exit 0; blank reason exit 1. Tests: `ParallelAdmissionPrecedenceGate.Tests.ps1`, `Invoke-ParallelAdmission.PrecedenceGate.Tests.ps1`. | `sh r1164_probe.sh` | |
| 10 | US-AC10 legacy honoured; code listed; no tools change | PASS | Probe: an entry without `kind` exits 0 with `checked: 0`. `precedence_not_justified` appears in `$script:AdmissionRejectionCode`, the helper `.DESCRIPTION`, and the rule's `**Admission output signal.**` paragraph (line 273). 0 `tools:` lines changed. | `git diff -- .claude/agents` | |
| 11 | US-AC11 overlay composition | PASS | `config-carriage.test-helpers.ts` overlay case and `tests/fixtures/blast_radius_overlay/` pass in the post-merge Jest and pytest gates. | Post-merge Jest gate, 0 failed | |
| 12 | US-AC12 mirrors and payload | PASS | `cmp` equal for all 16 changed `.claude/` files; one `core.json` entry per new file (4); push-down resource, completeness, dependency-closure, and config-parity suites passed post-merge. | `cmp`; `grep -c` on `core.json` | |
| 13 | US-AC13 PR body statements | UNVERIFIED | No pull request exists for the branch (PR context: "no PR exists yet"). | `gh pr list` via PR context | Pending-PR; owned by the orchestrator at PR authoring; not a remediation finding |

---

## Summary

**Overall Feature Readiness:** PASS (one criterion pending the PR)

**Criteria summary:**
- **PASS:** 12 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (US-AC13, pending-PR)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. US-AC13 can be satisfied only by the PR body. The orchestrator must state (a) the owner-directed default scheduling change (OD-1164-1) and (b) that the new validator rules reach MCP only after the next extension release. It then checks the item off.

**Recommended follow-up verification steps:**

1. After the PR opens, confirm the CI run on the PR head is green, including `quality-checks7 / Code Quality & Tests (3.13)`, the `poshqc` jobs, the extension test jobs, and `shell-coverage`.
2. Confirm the PR body carries both US-AC13 statements before checking that item.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if they are markdown checkboxes and not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

US-AC1 to US-AC12 were already checked by the executor and all evaluate PASS, so this review made no source-file change. US-AC13 is UNVERIFIED and stays unchecked.

### AC Status Summary

- Source: `docs/features/active/parallel-planner-time-based-edge-rule-1164/user-story.md` (checkbox items); `docs/features/active/parallel-planner-time-based-edge-rule-1164/spec.md` (non-checkbox behavior sections traced to them)
- Total AC items: 13
- Checked off (delivered): 12
- Remaining (unchecked): 1
- Items remaining: US-AC13 (the PR body states the default scheduling behaviour change as directed by the owner (OD-1164-1), and that the new validator rules apply through MCP only after the next extension release).

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/parallel-planner-time-based-edge-rule-1164/user-story.md` | 13 | 12 | 1 | US-AC13 pending-PR |
| `docs/features/active/parallel-planner-time-based-edge-rule-1164/spec.md` | 0 checkbox items | 0 | 0 | Behavior sections B1 to B10 traced to US-AC1 to US-AC13 |
