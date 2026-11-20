# Feature Audit: Regenerate path after an integration merge (#1156)

---

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/regenerate-after-integration-merge-1156`
**Base Branch:** `main`
**Head Branch:** `feature/regenerate-after-integration-merge-1156`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` at commit `063504dc4b2ea08a2c5bd39b57d70ce5963815ed`)
- **Head branch/commit:** `feature/regenerate-after-integration-merge-1156` (commit `8533618dd00aa5dc43ee353598fdf1107a76d192`)
- **Merge base:** `063504dc4b2ea08a2c5bd39b57d70ce5963815ed`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-14 04:19:41 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/regenerate-after-integration-merge-1156/evidence/**`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` parsed by the reviewer; reviewer runs recorded in `evidence/qa-gates/jest-gate.2026-11-14T04-29.md`, `evidence/qa-gates/quality-tiers-check.2026-11-14T04-29.md`, and `evidence/other/process-start-probe.2026-11-14T04-29.md`
- **Feature folder used:** `docs/features/active/regenerate-after-integration-merge-1156`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the AC sources; the `issue.md` checklist is not an AC source in this mode.
- **Scope note:** full branch diff from the merge base to the reviewed head (118 files). Commits after the final Pester gate (c0e1746c1, f25ca9054, 8533618dd) change only feature-folder files, so the gate evidence describes the head's code. Per OD-4, the reviewer ran no serial or single-file test run; test discrimination was judged by inspection of the suites and the row data, plus direct real-process probes of the shipped entry point.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/regenerate-after-integration-merge-1156/spec.md` — primary source (41 checkbox items)
- `docs/features/active/regenerate-after-integration-merge-1156/user-story.md` — secondary source (8 checkbox items)

### Acceptance criteria

The criteria are the checkbox items under `## Acceptance Criteria` in each file. The evaluation table below abbreviates them by ID; spec items are numbered in order within each `[ACn]` group (AC1.1 to AC1.7, AC2.1 to AC2.4, AC3.1 to AC3.8, AC4.1 to AC4.3, AC5.1 to AC5.6, AC6.1 to AC6.9, AC7.1 to AC7.4), and user-story items are US-1 to US-8 in order.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC1.1 | `Get-RegenerationConfigError` rules 1-9, accumulating, one Pester case per rule | PASS | `RegenerationConfig.Tests.ps1` 44 passed in the final gate | `Invoke-PoshQCParallelTest` (pester-final.2026-11-14T04-07.md) | |
| AC1.2 | Absent / no key / null config: `no_config`, no `git merge`, no command, exit 3 | PASS | Row cases with git-call and process-call count classes; reviewer probe: Validate without a config exits 3 `no_config` | same gate; real-process probe | |
| AC1.3 | Invalid config: `config_invalid`, errors in `config_errors`, exit 3, no git merge | PASS | Rows R22, R27, R46 | same gate | |
| AC1.4 | Skill section and rules-file section document the keys and default-off rule, pinned | PASS | Orchestrate `## Merge-Conflict Remediation` item 2; rules `## Regeneration-Path Scope and Backward Compatibility`; skill-contract suite 52 passed | same gate; diff inspection | |
| AC1.5 | No `config/orchestration-regeneration.json` in repo or bundle | PASS | Both paths absent at head | `ls` of both paths | D11 |
| AC1.6 | Tip config-stage rows: reasons, no git or process call, exit 3, twenty keys | PASS | Tip config-stage rows | same gate | |
| AC1.7 | Validate exits 0/3, no git or process call, rejects `-MergeRef`/`-Trigger` with exit 2 | PASS | Validate and usage rows; reviewer probe exit codes 0, 3, 2 | same gate; real-process probe | |
| AC2.1 | Classifier rule order cases incl. no-config plus empty-set order | PASS | `RegenerationClassifier.Tests.ps1` 21 passed | same gate | |
| AC2.2 | `Test-RegenerationPathMatch` root double-star, star across slash, case, backslash | PASS | Classifier suite | same gate | |
| AC2.3 | `Get-RegenerationChangedPath` intersection cases | PASS | Classifier suite | same gate | |
| AC2.4 | Classifier tests use no I/O mock or temporary file | PASS | Suite inspection: no `Mock`, no temp path | diff inspection | |
| AC3.1 | Merge call order through mocked wrappers, exit 0 prepared | PASS | Merge call-order rows and `Invoke-RegenerationPath.Merge.Tests.ps1` 37 passed | same gate | |
| AC3.2 | Each failure branch exits 3 or 1, one `git merge --abort`, no commit | PASS | Failure rows with abort counts | same gate | |
| AC3.3 | Delta decision pass and one-sided fail cases | PASS | `RegenerationDelta.Tests.ps1` 38 passed | same gate | |
| AC3.4 | Tip snapshot idempotency, no add/commit, restore calls | PASS | Tip rows R28-R42 and `Invoke-RegenerationPath.Tip.Tests.ps1` 24 passed; reviewer end-to-end Tip run left the change unstaged | same gate; real-process probe | |
| AC3.5 | Builders produce exact shapes; evidence text fields; injected clock; no absolute path | PASS | Builder field-mapping cases in the delta suite | same gate | |
| AC3.6 | Orchestrate skill post-success and failure sequence, pinned | PASS | Orchestrate items 5 and 6; skill-contract suite | same gate; diff inspection | |
| AC3.7 | D16 boundaries each with a failing test; one JSON object keeping nulls | PASS | Row cases and AST checks (a)-(h); reviewer probe printed one JSON object with null values | same gate; real-process probe | |
| AC3.8 | One `-ForEach` case per D17 row with every column asserted | PASS | 74 rows in `RegenerationResultTable.psd1`, 74 distinct row IDs in the spec table, 74 row cases passed, 4 structure checks passed | same gate; row count by `grep` | |
| AC4.1 | No `cycles[]` entry, `completed_attempts` unchanged; skill and agent state it, pinned | PASS | Orchestrate item 7; `.claude/agents/orchestrator.md` sentence; skill-contract suite | same gate; diff inspection | |
| AC4.2 | Two fixtures with `expected_errors: []` pass Python, TypeScript, PowerShell parity suites | PASS | pytest-final, jest-final (parity suite loads both), pester-final | `pytest -n auto`; Jest; Pester gate | |
| AC4.3 | Termination guard and pinned literals unchanged; named suites pass unmodified | PASS | `light-remediation-skill-contract.Tests.ps1` and `test_orchestrator_state_remediation_docs.py` absent from the diff and passing | `git diff --stat` on both files (empty) | |
| AC5.1 | Epic integration-tip flow stated and pinned | PASS | `## Integration-Tip Regeneration`; skill-contract suite | same gate | |
| AC5.2 | Child-side tip CI check with 30 s polling, 90 min limit, `awaiting_ci` | PASS | Epic skill sentences; skill-contract suite | same gate | |
| AC5.3 | `Get-EpicRegenerationAllowance` admit and deny cases | PASS | `hook-epic-regeneration.Tests.ps1` and epic-scope suites passed | same gate | |
| AC5.4 | Epic agent has only the new `Invoke-RegenerationPath.ps1` grant | PASS | Agent diff adds exactly one line; skill-contract suite | `git diff` of the agent file | |
| AC5.5 | Epic main-sync regenerate path in step 3, pinned | PASS | Epic lifecycle step 3; skill-contract suite | same gate | |
| AC5.6 | Default-off boundary in both epic places; Validate exit 0 defines valid | PASS | Epic skill literals; skill-contract suite | same gate | |
| AC6.1 | Orchestrate `## Merge-Conflict Remediation`; rule 7 and rule 11 sentences; concurrent-review suite unmodified | PASS | Diff inspection; `concurrent-review-skill-contract.Tests.ps1` absent from the diff and passing | same gate | |
| AC6.2 | Parallel skill paragraph, pinned | PASS | Diff inspection; skill-contract suite | same gate | |
| AC6.3 | Rules section and invariants section parity | PASS | Rules section present; `test_orchestrator_state_remediation_docs.py` passed | `pytest -n auto` | |
| AC6.4 | Merge-gate allow, deny per field, stale head, no process | PASS | Claude suite 22 and Codex suite 38 passed; helper body starts no process (inspected) | same gate | |
| AC6.5 | Byte-identical bundle copies, manifests, push-down tests | PASS | 21 source/bundle pairs equal by `cmp`; both manifests list the new files | `cmp` loop; same gate | |
| AC6.6 | Frozen-surface digests re-baselined with a dated comment; test passes | PASS | Both pinned digests equal the SHA-256 of the current files | `sha256sum` | Comment omits #1174, which did not touch the files |
| AC6.7 | Six brief copies identical; comparison tests pass | PASS | One SHA-256 across all six copies | `sha256sum` | |
| AC6.8 | Handoff projection omits the new keys; rules disclosure | PASS | Appended pytest case passed; rules-file disclosure sentence present | `pytest -n auto` | |
| AC6.9 | `.agents` orchestrate skills hold no `Invoke-RegenerationPath` | PASS | 0 matches in both files | `grep -c` | |
| AC7.1 | Existing merge-gate and fan-in suites pass in the single parallel gate | PASS | pester-final 0 failures | same gate | |
| AC7.2 | ReviewGuard regression cases | PASS | Appended cases passed | same gate | |
| AC7.3 | EpicFanIn regression cases | PASS | Appended cases passed | same gate | |
| AC7.4 | Corpus fixtures and parity suites pass unmodified | PASS | The diff only adds two fixtures; parity suites passed | `git diff --stat` on the fixture folder | |
| US-1 | (issue AC1) config opt-in, default-off, `config_invalid`, documented | PASS | AC1.1-AC1.7 | as above | |
| US-2 | (issue AC2) pure classifier decisions and reasons | PASS | AC2.1-AC2.4 | as above | |
| US-3 | (issue AC3) regenerate path runs, confines, verifies, records; failure falls back | PASS | AC3.1-AC3.8; end-to-end Tip probe | as above | A Windows `.cmd`/`.ps1` shim command cannot start and falls back (finding CR-2); the criterion holds for a directly startable command, and the fallback behavior it requires is what occurs |
| US-4 | (issue AC4) no remediation cycle, attempts unchanged | PASS | AC4.1-AC4.3 | as above | |
| US-5 | (issue AC5) epic tip regeneration and child CI check | PASS | AC5.1-AC5.6 | as above | |
| US-6 | (issue AC6) skills, agents, rules, fixtures, gates accept the evidence; deny code | PASS | AC6.1-AC6.9 | as above | |
| US-7 | (issue AC7) unchanged decisions for checkpoints without the new keys | PASS | AC7.1-AC7.4 | as above | |
| US-8 | Codex keeps today's behavior; policy-level disclosure; no self-declared config | PASS | `.agents` skills unedited for the path; Codex helpers are inert without `review_kind`; rules-file disclosure; config absent | diff inspection | |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 49 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. CR-1 / PA-1: `quality-tiers.yml` lacks an entry for `.claude/lib/regeneration`; the CI `tier-classification` step fails (QT008). No AC names this check, but the PR cannot reach a green CI.
2. CR-2 / PA-2: the AD-1 process default cannot start Windows command shims, so a declared `npm`-style command never takes the regenerate path on a Windows host.

**Recommended follow-up verification steps:**

1. After the tier entry is added, run `python -m scripts.dev_tools.check_quality_tiers` and confirm exit 0.
2. After the CR-2 fix, repeat the real-process probe with `["npm","--version"]` (code fix) or confirm the pinned documentation sentence (documentation fix), then run the parallel Pester gate.

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
| `spec.md` | 41 | 41 | 0 | Checkbox-backed; all were already checked by the executor and each was verified above |
| `user-story.md` | 8 | 8 | 0 | Checkbox-backed; all were already checked by the executor and each was verified above |

No source-file checkbox change was made: every criterion was already checked, and each evaluated PASS. No criterion is CI-dependent by its text. The two blocking findings are recorded in `remediation-inputs.2026-11-14T04-29.md` and do not falsify any criterion.
