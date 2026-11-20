# Feature Audit: Push-Down CI Workflows per Ecosystem Pack (#1050)

**Audit Date:** 2026-11-19
**Feature Folder:** `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050`
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration`
**Head Branch:** `feature/push-down-ci-workflows-per-ecosystem-pack-1050`
**Work Mode:** `full-feature`
**Audit Type:** Remediation cycle 1, R4 re-audit (full branch scope)

---

## Scope and Baseline

- **Base branch:** `origin/epic/shared-agent-harness-layer-integration` (resolved at `c78a72e3cb88ad5a692ae8185a42d62c345a2d4f`, 13 commits ahead of the merge base after the #1049 merge; PR #1210 reported `MERGEABLE`)
- **Head branch/commit:** `feature/push-down-ci-workflows-per-ecosystem-pack-1050` (commit `5ab48d8308964a34b7ec79cef4ba7e0a0a8f5261`)
- **Merge base:** `021a52e74999d17c6ae67ed7a32c14958448ceab`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-19 14:38:12 UTC at `6db294022`; the later commit `5ab48d830` adds only feature-folder documents, inspected directly)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/evidence/**`, including the cycle-1 records `advisory-baseline-reference.2026-11-19T14-26.md`, task checks `P1-T1` to `P1-T4` of 2026-11-19T14-28, `phase-gate.P1.2026-11-19T14-33.md`, `final-qc-ts-static`, `final-qc-jest`, `final-qc-workflows`, `self-review` of 2026-11-19T14-32, and the dispatch record `ci-dispatch.2026-11-19T14-42.md`; earlier records as listed in `feature-audit.2026-11-19T13-45.md`
  - Plan: `plan.2026-11-14T09-31.md` (all tasks checked, including [P3-T5]) and `remediation-plan.2026-11-19T14-16.md` (all tasks checked)
  - Additional evidence: reviewer `git hash-object` of the four workflow pairs (all equal); reviewer lcov recomputation; reviewer `gh run view` of the five dispatch runs and `referenced_workflows` of runs 44545593464 and 44541165447; `gh pr view 1210` check state; `validate_evidence_locations.py --root .` exit 0
- **Feature folder used:** `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so the AC sources are `spec.md` (`## Acceptance Criteria`, S1-S17) and `user-story.md` (`## Acceptance Criteria`, U1-U8). The `issue.md` checkboxes are not AC sources in this mode.
- **Scope note:** The review covers the full branch diff from the integration merge base (127 files). Cycle 1 changed `harness-python.yml`, its bundle copy, and two TypeScript test files; no production TypeScript or PowerShell file changed. The base advance (#1049) touches six brief copies also changed on the branch; GitHub reports no conflict.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/spec.md` — primary source (17 items)
- `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/user-story.md` — secondary source (8 items)

### From spec.md

1. S1: Every push-down MCP tool accepts `ci_workflows` (`off`, `reference`, `copy`; default `off`); other values fail before any write naming the value; an omitted input with no data-file entry plans no CI path.
2. S2: Omitted `ci_workflows` reuses the mode inferred from the manifest; tests for `reference` and `copy` reuse and explicit `off`.
3. S3: Caller holds one job per selected language pack plus `CI Required Gate`; Python-only, PowerShell-plus-TypeScript, and C# variant cases.
4. S4: A selection union with both C# variants fails before any write.
5. S5: Reference mode pins `harness-<pack>.yml@v<payload_version>`; no copy planned.
6. S6: Copy mode uses local copies; only selected copies written; manifest entries with layer `shared` and canonical hashes; schema `1.0.0`.
7. S7: Data file content exact in both modes and when the caller is withheld.
8. S8: Second identical apply reports CI files `unchanged`; dry run writes nothing.
9. S9: Unmanaged differing CI file reported `unmanaged-conflict` even with `overwrite_unmanaged: true`; edited managed caller reported `conflict`; no other workflows path written.
10. S10: Another workflow named `CI` withholds the caller with a `push-down conflict:` warning; data file still delivered; warning also in dry run.
11. S11: Four `harness-*.yml` exist, `workflow_call` only, destination-generic, no `NPM_TOKEN`, Template Contract artifact paths; .NET JaCoCo counters and `legacy` on `windows-latest`.
12. S12: Contract test pins caller name, merge-gate literal, data file, gate context, triggers, and coverage-hook paths, with a negative diverging-template case.
13. S13: Every execution-environment brief copy gains the data-file bullet after the Refresh rule bullet, outside ledger revert blocks; the three named tests pass.
14. S14: `Set-CiRequiredChecks.ps1` Pester behaviors with mocked `Invoke-GhExe`; line coverage >= 85%; no `gh` in the new push-down modules.
15. S15: README and CHANGELOG document pin, bump, tag risks, private-source copy mode, and the #1049 copy-mode limitation; `.github/workflows/README.md` lists the harness workflows.
16. S16: No `.py` added or modified; no hook file changed; new production code is TypeScript, PowerShell, YAML, or JSON.
17. S17 (CI-dependent, orchestrator-owned): A rendered reference-mode caller per pack, dispatched in a scratch destination, parses and completes, and shows the pack check and `CI Required Gate`; evidence under `evidence/` with clock-read timestamps.

### From user-story.md

18. U1: Omitted or `off` delivers no CI; `reference`/`copy` deliver; omitted input keeps the recorded mode; invalid value or both C# variants stop before any write.
19. U2: Caller has a job per selected pack plus the gate; reference pins harness workflows at `v<payload_version>`; copy uses hashed local copies.
20. U3: Data file names workflow `CI` and context `CI Required Gate`; every brief copy names the file.
21. U4: Check names and artifact paths match the merge gate and coverage hooks; contract test fails on divergence; one dispatched run per pack in a scratch destination shows the checks.
22. U5: No existing workflow overwritten; each conflict reported; identical re-run reports CI files `unchanged`.
23. U6: Branch protection changes only through `Set-CiRequiredChecks.ps1 -Apply`, which creates and never edits; default is a dry run.
24. U7: Documented pin-bump steps with tag, private-source, and copy-mode exemption limits.
25. U8: No Python added; no hook changed.

---

## Acceptance Criteria Evaluation

Jest evidence comes from `evidence/qa-gates/final-qc-jest.2026-11-19T14-32.md` (374 suites, 6185 tests passed, 0 failed). Pester evidence comes from `evidence/qa-gates/final-pester.2026-11-19T13-38.md` (29242 tests, 0 failures, 0 errors); no PowerShell file changed after it.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | S1 `ci_workflows` input, rejection, default off | PASS | `mcp-tool-inputs.push-down-ci-workflows.test.ts`; `parseCiWorkflowsMode accepts off, reference and copy and names a rejected value`; harness default-off case | `run-test-suite.sh jest-extension --coverage` | Unchanged by cycle 1 |
| 2 | S2 recorded-mode reuse | PASS | harness `reuses recorded reference mode`, `reuses recorded copy mode`, `explicit off plans no CI file` | same | |
| 3 | S3 one job per selected pack plus gate | PASS | Python-only, PowerShell-plus-TypeScript, and C# variant rendering cases | same | Scratch runs show one pack job plus the gate per caller |
| 4 | S4 both C# variants fail before write | PASS | `rejects a selection union holding both C# variants` (unit and harness) | same | |
| 5 | S5 reference pin, no copy | PASS | `reference mode pins harness workflows at the payload version`; harness `reference mode plans no drm-copilot copy` | same | |
| 6 | S6 copy mode, manifest entries and hashes, schema 1.0.0 | PASS | harness `copy mode writes selected copies with shared-layer manifest entries` | same | |
| 7 | S7 exact data file in three runs | PASS | harness `writes the data file exactly in reference, copy, and withheld-caller runs` | same | |
| 8 | S8 idempotence and dry run | PASS | harness `second identical apply reports every CI file unchanged`; `dry run writes no file and no manifest` | same | |
| 9 | S9 conflicts and confinement | PASS | harness unmanaged-conflict, edited managed caller, and confinement cases | same | |
| 10 | S10 name collision | PASS | harness `withholds the caller when another workflow is named CI, including in a dry run` | same | |
| 11 | S11 harness workflow text contract | PASS | `harness workflows are destination-generic`; new `python harness threshold step parses the report with -AsHashtable`; actionlint 0 findings (`final-qc-workflows.2026-11-19T14-32.md`); pair hashes equal | same; `actionlint` | CI-1 fix keeps Template Contract paths |
| 12 | S12 merge-gate and coverage-hook contract with negative case | PASS | `caller, data file and consumers agree`; `reports a diverging in-memory template` | same | |
| 13 | S13 brief bullet in every copy | PASS | `every brief copy names the CI data file after the refresh rule`; `task-check.P2-T5.2026-11-19T10-04.md` | `run-test-suite.sh pytest`; `run-test-suite.sh pester` | No brief copy changed in cycle 1 |
| 14 | S14 opt-in command behaviors, coverage, no `gh` in TS | PASS | `Set-CiRequiredChecks.Tests.ps1` (30 tests, 0 failures); 98.36% lines (60/61); `new push-down CI modules invoke no gh` | `run-test-suite.sh pester` | |
| 15 | S15 documentation | PASS | `docs-check.2026-11-19T10-05.md`; README, CHANGELOG, `.github/workflows/README.md` | `grep -c -F` per token | |
| 16 | S16 language and hook scope | PASS | reviewer `git diff --name-status <merge-base> HEAD` excluding the feature folder: no `.py`, no path under `.claude/hooks/` or `.codex/hooks/` | `git diff --name-status` | |
| 17 | S17 scratch-destination dispatch per pack | PASS | `ci-dispatch.2026-11-19T14-42.md`: python 44545593464, powershell 44541165447, typescript 44541160197, csharp-modern 44541170750, csharp-legacy 44541175317, all `workflow_dispatch` / `success`; each job list shows the pack check (`Python / Python QC`, `PowerShell / PowerShell QC`, `TypeScript / TypeScript QC`, `.NET / .NET QC (modern)`, `.NET / .NET QC (legacy)`) and `CI Required Gate` `success`. Reviewer confirmed each through `gh run view`; run 44545593464 references `harness-python.yml@6db29402...` | `gh run view <run> --json ...` | Method per orchestrator decision AD-13 (orphan scratch branches; caller at `.github/workflows/ci.yml`; branch-head pin as the plan permits). The superseded failing run 44541154665 is retained in the record. The record stamp `14-42` falls after the last run creation it cites and before commit `5ab48d830` (09:43 -05:00); the reviewer cannot independently confirm the clock read. |
| 18 | U1 | PASS | Same evidence as S1, S2, S4 | same | |
| 19 | U2 | PASS | Same evidence as S3, S5, S6, S11 | same | |
| 20 | U3 | PASS | Same evidence as S7, S13 | same | |
| 21 | U4 | PASS | Contract legs (S11, S12) and the dispatched-run leg (S17) | see S11, S12, S17 | |
| 22 | U5 | PASS | Same evidence as S8, S9, S10 | same | |
| 23 | U6 | PASS | Same evidence as S14 | same | |
| 24 | U7 | PASS | Same evidence as S15 | same | |
| 25 | U8 | PASS | Same evidence as S16 | same | |

---

## Summary

**Overall Feature Readiness:** READY, pending the final-head PR CI run

**Criteria summary:**
- **PASS:** 25 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

Every acceptance criterion is met at the head with test and evidence support. CI-1 is resolved, and S17 and U4 are now supported by five successful scratch dispatch runs that the reviewer confirmed independently. The remaining open item is a policy item, not an acceptance criterion: the `pull_request` CI run on the final head is in progress (see the policy audit, PA-B1).

**Top gaps preventing PASS:**

1. None in the acceptance criteria. The green-run policy item awaits the final-head PR run.

**Recommended follow-up verification steps:**

1. At S9, confirm the `pull_request` run on `5ab48d8308964a34b7ec79cef4ba7e0a0a8f5261` (or any later final head) concludes `success`, including `CI Required Gate`, and record `ci_gate.head_sha` equal to the final head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 25 PASS criteria were already checked (`- [x]`) in the source files at the reviewed head; S17 and U4 were checked off by commit `5ab48d830` with the dispatch evidence. This review made no checkbox change.

### AC Status Summary

- Source: `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/spec.md`, `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/user-story.md`
- Total AC items: 25
- Checked off (delivered): 25
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/spec.md` | 17 | 17 | 0 | S17 supported by `ci-dispatch.2026-11-19T14-42.md` |
| `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/user-story.md` | 8 | 8 | 0 | U4 supported by S11, S12, S17 |
