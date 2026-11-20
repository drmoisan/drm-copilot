# Feature Audit: Regenerate path after an integration merge (#1156)

---

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/regenerate-after-integration-merge-1156`
**Base Branch:** `main`
**Head Branch:** `feature/regenerate-after-integration-merge-1156`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 2

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at commit `2c8dee6dd3a82f210561d9efe623767ae902de51`)
- **Head branch/commit:** `feature/regenerate-after-integration-merge-1156` (commit `e25b4e07c249bc76a2ed1ee09aab07d890ca6230`)
- **Merge base:** `2c8dee6dd3a82f210561d9efe623767ae902de51`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-14 07:48:17 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/regenerate-after-integration-merge-1156/evidence/**`, including the cycle 2 task checks, `evidence/other/process-start-probe.2026-11-14T06-36.md`, `evidence/qa-gates/phase-gate.P1.2026-11-14T07-21.md`, `evidence/qa-gates/pester-final.2026-11-14T07-38.md`, `evidence/qa-gates/pytest-final.2026-11-14T07-43.md`, and `evidence/qa-gates/self-review.2026-11-14T07-44.md`
  - Reviewer evidence: direct parse of `artifacts/pester/powershell-coverage.xml`, SHA-256 and `cmp` mirror checks, the evidence-location scan, and one real-process probe in the session scratchpad, all recorded in the policy audit
- **Feature folder used:** `docs/features/active/regenerate-after-integration-merge-1156`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the AC sources; the `issue.md` checklist is not an AC source in this mode.
- **Scope note:** full branch diff from the merge base to the head (171 files). Findings C2-1, C2-2, and C2-3 were verified closed, and every criterion was re-evaluated against the head. No main sync occurred after the prior review. Per OD-4 the reviewer ran no test suite; the executor's final gates ran after the last code commit.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/regenerate-after-integration-merge-1156/spec.md` — primary source (41 checkbox items under `## Acceptance Criteria`)
- `docs/features/active/regenerate-after-integration-merge-1156/user-story.md` — secondary source (8 checkbox items)

### Acceptance criteria

The criteria are the checkbox items under `## Acceptance Criteria` in each file. The table abbreviates them by ID: spec items are numbered in order within each `[ACn]` group (AC1.1 to AC1.7, AC2.1 to AC2.4, AC3.1 to AC3.8, AC4.1 to AC4.3, AC5.1 to AC5.6, AC6.1 to AC6.9, AC7.1 to AC7.4), and user-story items are US-1 to US-8 in order. The seven unchecked items under `## Definition of Done` in `spec.md` are not acceptance criteria and are not evaluated.

---

## Acceptance Criteria Evaluation

"Final gate" below is `evidence/qa-gates/pester-final.2026-11-14T07-38.md` (one `Invoke-PoshQCParallelTest` run, 24744 tests, 0 failures).

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC1.1 | `Get-RegenerationConfigError` rules 1-9, accumulating, one Pester case per rule | PASS | `RegenerationConfig.Tests.ps1` passed | `Invoke-PoshQCParallelTest` (final gate) | |
| AC1.2 | Absent / no key / null config: `no_config`, no `git merge`, no command, exit 3 | PASS | Row cases with call-count classes | final gate | |
| AC1.3 | Invalid config: `config_invalid`, errors in `config_errors`, exit 3, no git merge | PASS | Rows R22, R27, R46 | final gate | |
| AC1.4 | Skill section and rules-file section document the keys and default-off rule, pinned | PASS | Orchestrate `## Merge-Conflict Remediation` item 2; rules-file regeneration section; skill-contract suite 56/0 | final gate; diff inspection | Cycle 2 added the start-time resolution and refusal sentence to both, pinned by the new contract test (CR-4 closed) |
| AC1.5 | No `config/orchestration-regeneration.json` in repo or bundle | PASS | Both paths absent at head | `ls` of both paths | D11 |
| AC1.6 | Tip config-stage rows: reasons, no git or process call, exit 3, twenty keys | PASS | Tip config-stage rows | final gate | |
| AC1.7 | Validate exits 0/3, no git or process call, rejects `-MergeRef`/`-Trigger` with exit 2 | PASS | Validate and usage rows | final gate | |
| AC2.1 | Classifier rule order cases incl. no-config plus empty-set order | PASS | `RegenerationClassifier.Tests.ps1` | final gate | |
| AC2.2 | `Test-RegenerationPathMatch` root double-star, star across slash, case, backslash | PASS | Classifier suite | final gate | |
| AC2.3 | `Get-RegenerationChangedPath` intersection cases | PASS | Classifier suite | final gate | |
| AC2.4 | Classifier tests use no I/O mock or temporary file | PASS | Suite unchanged; no `Mock`, no temp path | diff inspection | |
| AC3.1 | Merge call order through mocked wrappers, exit 0 prepared | PASS | Merge rows and `Invoke-RegenerationPath.Merge.Tests.ps1` | final gate | |
| AC3.2 | Each failure branch exits 3 or 1, one `git merge --abort`, no commit | PASS | Failure rows with abort counts | final gate | |
| AC3.3 | Delta decision pass and one-sided fail cases | PASS | `RegenerationDelta.Tests.ps1` | final gate | |
| AC3.4 | Tip snapshot idempotency, no add/commit, restore calls | PASS | Tip rows and `Invoke-RegenerationPath.Tip.Tests.ps1` | final gate | |
| AC3.5 | Builders produce exact shapes; evidence text fields; injected clock; no absolute path | PASS | Builder field-mapping cases | final gate | |
| AC3.6 | Orchestrate skill post-success and failure sequence, pinned | PASS | Orchestrate items 5 and 6; skill-contract suite | final gate | |
| AC3.7 | D16 boundaries each with a failing test; one JSON object keeping nulls | PASS | Row cases and AST checks (a)-(h); ProcessStart suite 33/0 with path and argument refusal rows; probes show stdout holding only the caller's output | final gate; real-process probes | |
| AC3.8 | One `-ForEach` case per D17 row with every column asserted | PASS | 74 rows in `RegenerationResultTable.psd1`, 74 row cases | final gate | |
| AC4.1 | No `cycles[]` entry, `completed_attempts` unchanged; skill and agent state it, pinned | PASS | Orchestrate item 7; orchestrator agent sentence; skill-contract suite | final gate | |
| AC4.2 | Two fixtures with `expected_errors: []` pass Python, TypeScript, PowerShell parity suites | PASS | pytest-final.2026-11-14T07-43.md, jest-final.2026-11-14T04-12.md, final gate | `pytest -n auto`; Jest; Pester gate | No `.ts` file changed since the Jest run |
| AC4.3 | Termination guard and pinned literals unchanged; named suites pass unmodified | PASS | Both named suites absent from the diff | `git diff --stat` on both files (empty) | |
| AC5.1 | Epic integration-tip flow stated and pinned | PASS | `## Integration-Tip Regeneration`; skill-contract suite | final gate | |
| AC5.2 | Child-side tip CI check with 30 s polling, 90 min limit, `awaiting_ci` | PASS | Epic skill sentences; skill-contract suite | final gate | |
| AC5.3 | `Get-EpicRegenerationAllowance` admit and deny cases | PASS | `hook-epic-regeneration.Tests.ps1` and epic-scope suites | final gate | |
| AC5.4 | Epic agent has only the new `Invoke-RegenerationPath.ps1` grant | PASS | Agent diff adds exactly one line | `git diff` of the agent file | |
| AC5.5 | Epic main-sync regenerate path in step 3, pinned | PASS | Epic lifecycle step 3; skill-contract suite | final gate | |
| AC5.6 | Default-off boundary in both epic places; Validate exit 0 defines valid | PASS | Epic skill literals; skill-contract suite | final gate | |
| AC6.1 | Orchestrate `## Merge-Conflict Remediation`; rule 7 and rule 11 sentences; concurrent-review suite unmodified | PASS | Diff inspection; concurrent-review suite absent from the diff and 58/0 in the P1-T2 task check | final gate | |
| AC6.2 | Parallel skill paragraph, pinned | PASS | Diff inspection; skill-contract suite | final gate | |
| AC6.3 | Rules section and invariants section parity | PASS | `test_orchestrator_state_remediation_docs.py` passed in pytest-final.2026-11-14T07-43.md | `pytest -n auto` | |
| AC6.4 | Merge-gate allow, deny per field, stale head, no process | PASS | Claude and Codex merge-gate helper suites | final gate | |
| AC6.5 | Byte-identical bundle copies, manifests, push-down tests | PASS | 21 source/bundle pairs equal by `cmp` at the head, including the three pairs edited in cycle 2 (equal SHA-256); push-down contract tests pass in the pytest run | `cmp` loop; `sha256sum`; `pytest -n auto` | |
| AC6.6 | Frozen-surface digests re-baselined with a dated comment; test passes | PASS | Neither pinned file changed in cycle 2; the pin test passes in the pytest run | `pytest -n auto` | |
| AC6.7 | Six brief copies identical; comparison tests pass | PASS | No brief copy changed in cycle 2; brief mirror pairs equal by `cmp` | `cmp` loop | |
| AC6.8 | Handoff projection omits the new keys; rules disclosure | PASS | Appended pytest case passed | `pytest -n auto` | |
| AC6.9 | `.agents` orchestrate skills hold no `Invoke-RegenerationPath` | PASS | Not edited in cycle 2; 0 matches in the prior review | diff inspection | |
| AC7.1 | Existing merge-gate and fan-in suites pass in the single parallel gate | PASS | Final gate | final gate | |
| AC7.2 | ReviewGuard regression cases | PASS | Appended cases passed | final gate | |
| AC7.3 | EpicFanIn regression cases | PASS | Appended cases passed | final gate | |
| AC7.4 | Corpus fixtures and parity suites pass unmodified | PASS | The diff only adds two fixtures | `git diff --stat` on the fixture folder | |
| US-1 | (issue AC1) config opt-in, default-off, `config_invalid`, documented | PASS | AC1.1-AC1.7 | as above | |
| US-2 | (issue AC2) pure classifier decisions and reasons | PASS | AC2.1-AC2.4 | as above | |
| US-3 | (issue AC3) regenerate path runs, confines, verifies, records; failure falls back | PASS | AC3.1-AC3.8; `process-start-probe.2026-11-14T06-36.md`; reviewer probe | as above | A batch path holding `&` or `%` is now refused and falls back instead of running a different command line |
| US-4 | (issue AC4) no remediation cycle, attempts unchanged | PASS | AC4.1-AC4.3 | as above | |
| US-5 | (issue AC5) epic tip regeneration and child CI check | PASS | AC5.1-AC5.6 | as above | |
| US-6 | (issue AC6) skills, agents, rules, fixtures, gates accept the evidence; deny code | PASS | AC6.1-AC6.9 | as above | |
| US-7 | (issue AC7) unchanged decisions for checkpoints without the new keys | PASS | AC7.1-AC7.4 | as above | |
| US-8 | Codex keeps today's behavior; policy-level disclosure; no self-declared config | PASS | `.agents` skills unedited for the path; Codex helpers inert without `review_kind`; config absent | diff inspection | |

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 49 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

None. Cycle 2 findings C2-1 (batch path screen), C2-2 (config contract sentence), and C2-3 (refusal table) are closed. The only remaining item is the non-blocking 792-line Warning on the adapter and its bundle copy.

**Recommended follow-up verification steps:**

1. Confirm CI on the PR head (Windows `poshqc`, Linux hook suites, `quality-checks7` including `tier-classification`, Python coverage thresholds, both Jest jobs).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### AC Status Summary

- Source: `docs/features/active/regenerate-after-integration-merge-1156/spec.md`, `docs/features/active/regenerate-after-integration-merge-1156/user-story.md`
- Total AC items: 49
- Checked off (delivered): 49
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 41 | 41 | 0 | Checkbox-backed; all were already checked and each re-verified above |
| `user-story.md` | 8 | 8 | 0 | Checkbox-backed; all were already checked and each re-verified above |

No source-file checkbox change was made. The cycle 2 spec edit extended the `command` bullet of `### Config file` on its existing line and changed no criterion text (41 checked before and after; 539 physical lines before and after). No criterion is CI-dependent by its text.
