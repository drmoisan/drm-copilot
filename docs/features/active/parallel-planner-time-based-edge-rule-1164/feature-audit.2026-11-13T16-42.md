# Feature Audit: parallel-planner-time-based-edge-rule (#1164)

**Audit Date:** 2026-11-13
**Feature Folder:** `docs/features/active/parallel-planner-time-based-edge-rule-1164`
**Base Branch:** `main`
**Head Branch:** `feature/parallel-planner-time-based-edge-rule-1164`
**Work Mode:** `full-feature`
**Audit Type:** Remediation cycle 2 re-audit (exit review); prior review `feature-audit.2026-11-13T14-04.md`

---

## Scope and Baseline

- **Base branch:** `main` (commit `1d62aa292161035aec8058e6c370f133e10a04db`, equal to `origin/main` after a fetch at review time)
- **Head branch/commit:** `feature/parallel-planner-time-based-edge-rule-1164` (commit `e6391c3b91e530ad5a54d1a000a3196b639571af`, clean worktree)
- **Merge base:** `1d62aa292161035aec8058e6c370f133e10a04db`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-13 16:37:02 UTC at head `e6391c3b9`, range `1d62aa292..e6391c3b9`), cross-checked with `git diff 1d62aa292..e6391c3b9`
  - Secondary: the cycle inputs `remediation-inputs.2026-11-13T14-14.md` and plan `remediation-plan.2026-11-13T14-14.md`
  - Feature evidence: `docs/features/active/parallel-planner-time-based-edge-rule-1164/evidence/**`, in particular the cycle 2 final gates under `evidence/qa-gates/` (2026-11-13T16-15 to 16-33) and `evidence/remediation-baseline/` (2026-11-13T14-28 to 14-54)
  - Additional evidence: reviewer parse of the canonical coverage artifacts; mirror `cmp` of 16 pairs; full code-point esbuild sweep of `pythonRepr` against CPython `repr`; real-process `access-paths` probe
- **Feature folder used:** `docs/features/active/parallel-planner-time-based-edge-rule-1164`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 10 carries `- Work Mode: full-feature`. `user-story.md` holds the 13 checkbox criteria (US-AC1 to US-AC13). `spec.md` states its criteria as behavior sections B1 to B10, which `## Acceptance Criteria Traceability` maps to the user-story criteria in a non-checkbox table. The spec's `## Definition of Done` checkboxes are a template checklist, not acceptance criteria, and are left unchanged. The cycle added and removed no criterion.
- **Scope note:** full branch diff against the merge base (226 files, 111 under the feature folder).

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
| 1 | US-AC1 pinned sentence on twelve surfaces | PASS | Reviewer search of the sentence over `.claude` and `extensions/drm-copilot/resources` finds 12 files (six sources, six mirrors). `parallel-scheduling-rule-wording.Tests.ps1` 228 passed in `pester-gate.2026-11-13T16-28.md`. | `grep -rlF "<sentence>" .claude extensions/drm-copilot/resources` | Cycle 2 changed one `## Enforcement` sentence of the rule; no wording token affected |
| 2 | US-AC2 `parallel-orchestrate` consistent | PASS | No change to the skill or its mirror in cycle 2; both byte-equal. | `cmp` of the skill pair | |
| 3 | US-AC3 committed values and reader rules | PASS | Parsed `conflict_tolerance` equal in both copies and equal to spec B3 (tolerance 100; bands 30/45/90/180; weights 90/90/20/10/10/15; `append_only_paths` includes `extensions/drm-copilot/resources/**`; threshold 400). `e0851033f` is parse-identical in both copies. Reader suites pass in the cycle gates. | Node `JSON.parse` of both copies before and after `e0851033f` | Copies differ outside `conflict_tolerance`, as at the merge base |
| 4 | US-AC4 edge iff cost > benefit; B4 rows | PASS | `scheduling-1164-committed-minutes.json` corpus consumed by `BlastRadiusScheduling.Tests.ps1` and `test_blast_radius_scheduling.py`; 0 failed in the cycle 2 Pester and pytest gates. | Cycle 2 Pester and pytest gates | |
| 5 | US-AC5 access declarations, derivation, drift | PASS | R5 adds the six irregular write forms (fail-safe direction). The real-process `access-paths` probe excludes paths named with `written`, `wrote`, and `overwritten`, and keeps the `Read` path and the noun-control (`writer`) path. 21 write-form rows and the control case pass. Drift suites pass. | `sh ap.sh` (SCRATCH) | Radius never narrowed |
| 6 | US-AC6 checkpoint estimates validated, byte-identical | PASS | 30-case corpus `tests/fixtures/parallel_state_scheduling/` passes in Python (31 tests) and Jest; six new escape stems. The reviewer sweep matches CPython `repr` on all 12 multi-character probes and on 1104124 of 1114112 code points. The 9988 differences are code points unassigned in Python UCD 15.1.0 and assigned in Node Unicode 17.0, a residual stated in the rule's class (1). | esbuild bundle of `parallel-state-shared.ts` vs CPython 3.13 `repr` | Residual is documented and outside the corpus |
| 7 | US-AC7 manifest M9 and durable record | PASS | No change in cycle 2; `parallel_manifest_contract.py` 168/168 lines, 82/82 branches at the cycle 1 review; bats parity in CI run 42746009388, no bash change since. | Cycle 2 pytest gate; CI `shell-coverage` | |
| 8 | US-AC8 legacy records valid | PASS | `seed-scheduling-record.json` absent from the branch diff; `accept-without-fields.json` passes in both runtimes. | `git diff --name-only` of the fixture | |
| 9 | US-AC9 `test-precedence` outcomes | PASS | `ParallelAdmissionPrecedenceGate.Tests.ps1` and `Invoke-ParallelAdmission.PrecedenceGate.Tests.ps1` (5 tests) pass; the gate module is at 42/42 lines. | Cycle 2 Pester gate | |
| 10 | US-AC10 legacy honoured; code listed; no tools change | PASS | `precedence_not_justified` listing unchanged since the cycle 1 review; 0 `tools:` lines changed in `.claude/agents/` or its mirror. | `git diff -- .claude/agents` filtered for `tools:` | |
| 11 | US-AC11 overlay composition | PASS | `config-carriage.test-helpers.ts` overlay case and `tests/fixtures/blast_radius_overlay/` pass in the cycle 2 Jest and pytest gates. | Cycle 2 Jest gates | |
| 12 | US-AC12 mirrors and payload | PASS | `cmp` equal for all 16 changed `.claude/` files, including the cycle's `BlastRadiusAccess.psm1` and `rules/parallel-orchestration.md`; four `core.json` entries; `test_push_down_claude_resource_contracts` 14 passed. | `cmp`; search of `core.json` | |
| 13 | US-AC13 PR body statements | UNVERIFIED | No pull request exists for the branch (`gh pr list --head` returns none). | `gh pr list --head feature/parallel-planner-time-based-edge-rule-1164 --state all` | Pending-PR; owned by the orchestrator at PR authoring; not a remediation finding |

---

## Summary

**Overall Feature Readiness:** PASS (one criterion pending the PR).

**Criteria summary:**
- **PASS:** 12 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (US-AC13, pending-PR)
- **FAIL:** 0 criteria

**Cycle findings:** R5 and R6 of `remediation-inputs.2026-11-13T14-14.md` are resolved (policy audit Executive Summary; code review Executive Summary).

**Top gaps preventing PASS:**

1. US-AC13 can be satisfied only by the PR body. The orchestrator must state (a) the owner-directed default scheduling change (OD-1164-1) and (b) that the new validator rules reach MCP only after the next extension release. It then checks the item off.

**Recommended follow-up verification steps:**

1. After the PR opens, confirm the CI run on the PR head is green, including `quality-checks7 / Code Quality & Tests (3.13)`, the `poshqc` jobs, the extension test jobs, and `shell-coverage`. No CI run exists yet for any code-bearing commit after `02f7ff869`.
2. Confirm the PR body carries both US-AC13 statements before checking that item.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if they are markdown checkboxes and not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

US-AC1 to US-AC12 were already checked and all evaluate PASS again, so this review made no source-file change. US-AC13 is UNVERIFIED (pending-PR) and stays unchecked.

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
