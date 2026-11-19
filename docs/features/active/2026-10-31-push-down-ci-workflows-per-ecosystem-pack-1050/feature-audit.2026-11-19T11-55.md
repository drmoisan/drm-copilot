# Feature Audit: Push-Down CI Workflows per Ecosystem Pack (#1050)

**Audit Date:** 2026-11-19
**Feature Folder:** `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050`
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration`
**Head Branch:** `feature/push-down-ci-workflows-per-ecosystem-pack-1050`
**Work Mode:** `full-feature`
**Audit Type:** Opening review (full branch scope)

---

## Scope and Baseline

- **Base branch:** `origin/epic/shared-agent-harness-layer-integration` (resolved at `021a52e74999d17c6ae67ed7a32c14958448ceab`, equal to the merge base)
- **Head branch/commit:** `feature/push-down-ci-workflows-per-ecosystem-pack-1050` (commit `f4cf77c6a374e3c8369d6e6abe5506c3d135d5a6`)
- **Merge base:** `021a52e74999d17c6ae67ed7a32c14958448ceab`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-19 11:53:34 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/evidence/**` (Phase 0 gate and baselines, task checks P0-T1 to P2-T6, phase gates P1 and P2, final-QC static records `final-*-static.2026-11-19T11-02.md`, `final-jest.2026-11-19T11-31.md`, `final-pytest.2026-11-19T11-34.md`, `final-pester.2026-11-19T11-46.md`, `coverage-delta.2026-11-19T11-46.md`, `final-scope-check.2026-11-19T11-47.md`, `self-review.2026-11-19T11-49.md`)
  - Plan: `plan.2026-11-14T09-31.md` (tasks through [P3-T4] checked; [P3-T5] pending CI by design)
  - Additional evidence: reviewer `git hash-object` byte-identity check of the five source/bundle pairs (all equal); reviewer read of per-file `LF/LH/BRF/BRH` records in `extensions/drm-copilot/coverage/lcov.info`; reviewer read of the `Set-CiRequiredChecks.ps1` sourcefile in `artifacts/pester/powershell-coverage.xml`; `validate_evidence_locations` exit 0
- **Feature folder used:** `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so the AC sources are `spec.md` (`## Acceptance Criteria`, S1-S17) and `user-story.md` (`## Acceptance Criteria`, U1-U8).
- **Scope note:** The review covers the full branch diff from the integration merge base (89 files). The last commit that changes a file outside the feature folder is `99a0c1499` (2026-11-19T11:02:11Z); the final Jest, pytest, and Pester runs (11:31Z, 11:34Z, 11:46Z) and final static records (11:02Z) were taken on that tree, and the two later commits change only feature-folder files. Upstream: #1028 and #1029 are merged into the integration branch; #1049 runs in parallel and is not merged (plan Planning Decision D6, epic OD-4); its absence is not treated as a defect.

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
17. S17 (CI-dependent, orchestrator-owned): A rendered reference-mode caller per pack, dispatched in a scratch destination, completes and shows the pack check and `CI Required Gate`.

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

Jest evidence comes from `evidence/qa-gates/final-jest.2026-11-19T11-31.md` (374 suites, 6184 tests passed, 0 failed) on the tree at `99a0c1499`; no `.ts` file changed after that commit. Pester evidence comes from `evidence/qa-gates/final-pester.2026-11-19T11-46.md` (29237 tests, 0 failures, 0 errors).

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | S1 `ci_workflows` input, rejection, default off | PASS | `mcp-tool-inputs.push-down-ci-workflows.test.ts`; `push-down-ci-workflows.test.ts` `parseCiWorkflowsMode accepts off, reference and copy and names a rejected value`; harness `plans no CI path when ci_workflows is omitted and no data-file entry exists`; schema enum in `mcp-push-down-schema-properties.ts` | `run-test-suite.sh jest-extension --coverage` | |
| 2 | S2 recorded-mode reuse | PASS | harness `reuses recorded reference mode`, `reuses recorded copy mode`, `explicit off plans no CI file`; inference cases in `push-down-ci-workflows.test.ts` | same | |
| 3 | S3 one job per selected pack plus gate | PASS | `Python-only selection renders no PowerShell, TypeScript or .NET job`; `PowerShell plus TypeScript selection renders only those jobs`; `csharp-modern and csharp-legacy render variant modern and variant legacy` | same | |
| 4 | S4 both C# variants fail before write | PASS | `rejects a selection union holding both C# variants` (unit and harness) | same | |
| 5 | S5 reference pin, no copy | PASS | `reference mode pins harness workflows at the payload version`; harness `reference mode plans no drm-copilot copy` | same | |
| 6 | S6 copy mode, manifest entries and hashes, schema 1.0.0 | PASS | harness `copy mode writes selected copies with shared-layer manifest entries` | same | |
| 7 | S7 exact data file in three runs | PASS | harness `writes the data file exactly in reference, copy, and withheld-caller runs` | same | |
| 8 | S8 idempotence and dry run | PASS | harness `second identical apply reports every CI file unchanged`; `dry run writes no file and no manifest` | same | |
| 9 | S9 conflicts and confinement | PASS | harness `reports unmanaged-conflict at a CI path even with overwriteUnmanaged true (%s)` (data file and caller); `keeps an edited managed caller as conflict`; `writes no workflows path other than the caller and selected copies` | same | |
| 10 | S10 name collision | PASS | harness `withholds the caller when another workflow is named CI, including in a dry run`; `push-down-ci-layer.test.ts` quoted/unquoted and `.yml`/`.yaml` cases | same | |
| 11 | S11 harness workflow text contract | PASS | `push-down-ci-contract.test.ts` `harness workflows are destination-generic`; actionlint 1.7.12 zero findings (`final-yaml-static.2026-11-19T11-02.md`); reviewer inspection of the four workflows | same; `actionlint` | Runtime behavior is covered by S17 |
| 12 | S12 merge-gate and coverage-hook contract with negative case | PASS | `caller, data file and consumers agree`; `reports a diverging in-memory template` | same | |
| 13 | S13 brief bullet in every copy | PASS | `every brief copy names the CI data file after the refresh rule`; `task-check.P2-T5.2026-11-19T10-04.md` (brief contract pytest and `ProcessReductionChain.Ledger.Tests.ps1` passed; generator `-Surface all -Check` exit 0); full pytest and Pester gates pass | `run-test-suite.sh pytest`; `run-test-suite.sh pester` | |
| 14 | S14 opt-in command behaviors, coverage, no `gh` in TS | PASS | `Set-CiRequiredChecks.Tests.ps1` (25 tests, 0 failures); line coverage 98.08% (51/52) from `artifacts/pester/powershell-coverage.xml`; `new push-down CI modules invoke no gh` | `run-test-suite.sh pester` | Code review Minor: the same-name check reads one page of rulesets; the tested behaviors pass |
| 15 | S15 documentation | PASS | `docs-check.2026-11-19T10-05.md` (each token 0 before, >= 1 after); diff of `extensions/drm-copilot/README.md`, `CHANGELOG.md`, `.github/workflows/README.md` | `grep -c -F` per token | |
| 16 | S16 language and hook scope | PASS | `final-scope-check.2026-11-19T11-47.md`; reviewer `git diff --name-status <merge-base> HEAD`: no `.py`, no path under `.claude/hooks/` or `.codex/hooks/` | `git diff --name-status` | |
| 17 | S17 scratch-destination dispatch per pack | UNVERIFIED | Pending CI: orchestrator-owned plan task [P3-T5], run after the PR exists | `gh workflow run` in a scratch destination (orchestrator) | CI-dependent; not a branch defect |
| 18 | U1 | PASS | Same evidence as S1, S2, S4 | same | |
| 19 | U2 | PASS | Same evidence as S3, S5, S6, S11 | same | |
| 20 | U3 | PASS | Same evidence as S7, S13 | same | |
| 21 | U4 | UNVERIFIED | Contract legs pass (S11, S12); the dispatched-run leg is pending CI (S17) | see S17 | CI-dependent; not a branch defect |
| 22 | U5 | PASS | Same evidence as S8, S9, S10 | same | |
| 23 | U6 | PASS | Same evidence as S14 | same | |
| 24 | U7 | PASS | Same evidence as S15 | same | |
| 25 | U8 | PASS | Same evidence as S16 | same | |

---

## Summary

**Overall Feature Readiness:** READY, pending CI

**Criteria summary:**
- **PASS:** 23 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria (S17, U4; pending CI, orchestrator-owned)
- **FAIL:** 0 criteria

Every acceptance criterion that can be verified before the pull request exists is met at the head with test and evidence support. S17 and U4 require a dispatched run of the rendered caller per pack in a scratch destination and stay unchecked until the orchestrator records that evidence at [P3-T5].

**Top gaps preventing PASS:**

1. S17 / U4: scratch-destination dispatch per pack (pending CI, orchestrator-owned).

**Recommended follow-up verification steps:**

1. After the PR is opened, run [P3-T5]: render a reference-mode caller per pack, dispatch it once in a scratch destination, and record the check list showing the pack check and `CI Required Gate` under `evidence/` with clock-read timestamps.
2. Confirm `CI Required Gate` on the PR head through the S9 CI gate; then check off S17 and U4 from the item worktree and re-run the gate on the new head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 23 PASS criteria were already checked (`- [x]`) in the source files at the reviewed head (spec.md S1-S16; user-story.md U1-U3, U5-U8), so this review made no checkbox change. S17 and U4 remain unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/spec.md`, `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/user-story.md`
- Total AC items: 25
- Checked off (delivered): 23
- Remaining (unchecked): 2
- Items remaining: S17 (CI-dependent, orchestrator-owned scratch-destination dispatch per pack); U4 (check names and artifact paths match, with one dispatched run per pack).

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/spec.md` | 17 | 16 | 1 | S17 pending CI |
| `docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/user-story.md` | 8 | 7 | 1 | U4 pending CI |
