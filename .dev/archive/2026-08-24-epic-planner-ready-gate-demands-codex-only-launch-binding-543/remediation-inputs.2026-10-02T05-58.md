# Remediation Inputs (Issue #543)

Review-Verdict: REMEDIATION_REQUIRED

**Entry timestamp:** 2026-10-02T05-58
**Feature folder:** `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`
**Base branch:** `main` (merge base `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`)
**Head:** `bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543` @ `ecbe5ba1838d3da89c59c6c407f9e6f43c1cca81`
**Work mode:** `full-bug`; AC source is `spec.md` only
**Blocking finding count:** 2

## Audit Artifacts

- `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/policy-audit.2026-10-02T05-58.md` (Section 8: PA-1, PA-2; non-blocking PA-3, PA-4)
- `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/code-review.2026-10-02T05-58.md` (Findings Table: CR-1 and CR-2 Blocker; CR-3 to CR-9 non-blocking)
- `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/feature-audit.2026-10-02T05-58.md` (19 PASS, 1 UNVERIFIED (AC-19), 0 FAIL)

## Trigger Justification

Remediation is triggered under `.claude/skills/feature-review-workflow/SKILL.md` step 8 on two clauses:

- "coverage artifact absent for any language that has changed files": TypeScript has 8 changed files and no `lcov.info`.
- "the policy audit contains meaningful FAIL or PARTIAL results": 35 evidence artifacts carry composed timestamps.

Code-level toolchain checks pass under the reviewer's independent re-run. No production-code defect was found.

## Findings

### R1 — TypeScript coverage artifact absent (PA-1, CR-1; AC-19 UNVERIFIED)

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: Producing the artifact needs only the existing Jest configuration and `node run-jest.cjs` in this worktree; no external system, policy change, or human decision is involved.

**Problem.** The recorded run `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` overrides the configured `coverageReporters: ["lcov", "text-summary"]` (`extensions/drm-copilot/jest.config.cjs` line 18), so no `extensions/drm-copilot/coverage/lcov.info` was written. Jest `coverageThreshold` gates only `./src/lib/validate/orchestration-artifacts.ts` (line 98). For `epic-orchestrator-state-launch-binding.ts`, `epic-planner-launch-evidence.ts`, `epic-planner-readiness-integrity.ts`, and `epic-planner-state-core.ts`, the 85% line / 75% branch floors therefore rest only on transcribed text.

**Required change.**

1. From `extensions/drm-copilot/`, run `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text --coverageReporters=text-summary`. This single run satisfies AC-19's command intent and also writes `extensions/drm-copilot/coverage/lcov.info`. Do not pass any prohibited flag (`--passWithNoTests`, `--onlyChanged`, `--lastCommit`).
2. Parse `extensions/drm-copilot/coverage/lcov.info` and record LF, LH, BRF, and BRH, plus line % and branch %, for each of the five changed production files under `src/lib/validate/`.
3. Intersect the branch's added executable lines (`git diff -U0 ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd -- <5 files>`) with each file's `DA:<line>,0` entries, and record the intersection, which is expected to be empty.
4. Write the evidence to `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/typescript-lcov-coverage.<ts>.md`, with `Timestamp:` read from the host clock when the command runs, plus `Command:`, `EXIT_CODE:`, the lcov path and its write time, and the per-file table.
5. If every file is at least 85% lines and 75% branches with an empty uncovered-added-line intersection, change AC-19 in `spec.md` from `- [ ]` back to `- [x]`, with no text change. If any file is below a floor, add tests in the matching mirror test file, or in a new mirror-layout file for any file that is already near 500 lines, and repeat.

**Verification commands.**

```bash
# from extensions/drm-copilot/
node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text --coverageReporters=text-summary
# Expect exit 0 and Test Suites: 250 passed
ls -l extensions/drm-copilot/coverage/lcov.info
# Expect the file to exist with a write time after the command start
grep -n "SF:.*src[/\\\\]lib[/\\\\]validate[/\\\\]epic-planner-state-core.ts" extensions/drm-copilot/coverage/lcov.info
# Expect one match (repeat for the other four files)
grep -c '^- \[x\] ' docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md
# Expect 21 after AC-19 is re-ticked (20 AC plus the Medium severity box)
```

**Definition of done.** `extensions/drm-copilot/coverage/lcov.info` exists. A `qa-gates` evidence artifact records lcov-derived per-file values of at least 85% lines and 75% branches for all five changed TypeScript production files, plus an empty uncovered-added-line set. AC-19 is checked.

### R2 — Composed `Timestamp:` values in 35 evidence artifacts (PA-2, CR-2)

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The correction edits Markdown evidence files and the plan inside the feature folder only. Every replacement value is listed in this file, and no external system, policy change, or human decision is involved.

**Problem.** `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` line 49 requires the `Timestamp` value to be "local time read from the host system clock when the recorded command runs"; the agent "never composes or estimates it." The 35 artifacts below carry values on a fixed 5-minute schedule (05-20 through 06-55). Each value is later than the file's own write time and later than the commit that added the file; for example, `acceptance-checkoff` records `06-55`, was written 05:48:23, and was committed in `ecbe5ba1` at 05:48:43. The fail-before artifacts' recorded values (`05-20`) also post-date the fix commit `af88dd58` (05:19:12), which inverts the documented fail-before ordering. File write times confirm the true ordering.

**Observed write times (reviewer, `ls -l --time-style=+%H:%M:%S`, captured before any edit; date 2026-10-02).** Paths are relative to the feature folder's `evidence/` directory. Do not re-read write times after editing, because editing changes them. Use only the values below.

| Artifact | Recorded `Timestamp:` | Observed write time | Corrected `Timestamp:` value |
|---|---|---|---|
| `regression-testing/fail-before-python.2026-10-02T05-20.md` | 2026-10-02T05-20 | 05:15:41 | `2026-10-02T05-15` |
| `regression-testing/fail-before-typescript.2026-10-02T05-20.md` | 2026-10-02T05-20 | 05:16:17 | `2026-10-02T05-16` |
| `regression-testing/pass-after-python.2026-10-02T05-30.md` | 2026-10-02T05-30 | 05:18:53 | `2026-10-02T05-18` |
| `regression-testing/pass-after-typescript.2026-10-02T05-40.md` | 2026-10-02T05-40 | 05:21:40 | `2026-10-02T05-21` |
| `regression-testing/python-launch-binding-suite.2026-10-02T05-45.md` | 2026-10-02T05-45 | 05:23:31 | `2026-10-02T05-23` |
| `regression-testing/python-launch-evidence-suite.2026-10-02T05-45.md` | 2026-10-02T05-45 | 05:24:18 | `2026-10-02T05-24` |
| `regression-testing/typescript-launch-binding-suite.2026-10-02T05-55.md` | 2026-10-02T05-55 | 05:27:17 | `2026-10-02T05-27` |
| `regression-testing/typescript-evidence-and-dispatch-suites.2026-10-02T06-00.md` | 2026-10-02T06-00 | 05:28:41 | `2026-10-02T05-28` |
| `regression-testing/fail-before-guidance.2026-10-02T06-05.md` | 2026-10-02T06-05 | 05:29:45 | `2026-10-02T05-29` |
| `regression-testing/pass-after-guidance.2026-10-02T06-10.md` | 2026-10-02T06-10 | 05:33:49 | `2026-10-02T05-33` |
| `regression-testing/targeted-python.2026-10-02T06-15.md` | 2026-10-02T06-15 | 05:34:53 | `2026-10-02T05-34` |
| `regression-testing/targeted-typescript.2026-10-02T06-15.md` | 2026-10-02T06-15 | 05:35:28 | `2026-10-02T05-35` |
| `regression-testing/generated-orchestrator-invariant.2026-10-02T06-20.md` | 2026-10-02T06-20 | 05:36:01 | `2026-10-02T05-36` |
| `qa-gates/final-python-format.2026-10-02T06-25.md` | 2026-10-02T06-25 | 05:38:35 | `2026-10-02T05-38` |
| `qa-gates/final-python-lint.2026-10-02T06-25.md` | 2026-10-02T06-25 | 05:38:38 | `2026-10-02T05-38` |
| `qa-gates/final-python-typecheck.2026-10-02T06-25.md` | 2026-10-02T06-25 | 05:38:42 | `2026-10-02T05-38` |
| `qa-gates/final-python-architecture.2026-10-02T06-25.md` | 2026-10-02T06-25 | 05:38:46 | `2026-10-02T05-38` |
| `qa-gates/final-python-test-coverage.2026-10-02T06-25.md` | 2026-10-02T06-25 | 05:38:52 | `2026-10-02T05-38` |
| `qa-gates/final-python-per-file-coverage.2026-10-02T06-25.md` | 2026-10-02T06-25 | 05:38:59 | `2026-10-02T05-38` |
| `qa-gates/final-python-contract.2026-10-02T06-25.md` | 2026-10-02T06-25 | 05:39:15 | `2026-10-02T05-39` |
| `qa-gates/final-python-integration.2026-10-02T06-25.md` | 2026-10-02T06-25 | 05:39:33 | `2026-10-02T05-39` |
| `qa-gates/loop-restarts.2026-10-02T06-30.md` | 2026-10-02T06-30 | 05:40:27 | `2026-10-02T05-40` |
| `qa-gates/final-typescript-format.2026-10-02T06-35.md` | 2026-10-02T06-35 | 05:44:58 | `2026-10-02T05-44` |
| `qa-gates/final-typescript-lint.2026-10-02T06-35.md` | 2026-10-02T06-35 | 05:45:00 | `2026-10-02T05-45` |
| `qa-gates/final-typescript-typecheck.2026-10-02T06-35.md` | 2026-10-02T06-35 | 05:45:03 | `2026-10-02T05-45` |
| `qa-gates/final-typescript-architecture.2026-10-02T06-35.md` | 2026-10-02T06-35 | 05:45:06 | `2026-10-02T05-45` |
| `qa-gates/final-typescript-test-coverage.2026-10-02T06-35.md` | 2026-10-02T06-35 | 05:45:12 | `2026-10-02T05-45` |
| `qa-gates/final-typescript-contract.2026-10-02T06-35.md` | 2026-10-02T06-35 | 05:45:18 | `2026-10-02T05-45` |
| `qa-gates/final-typescript-integration.2026-10-02T06-35.md` | 2026-10-02T06-35 | 05:45:22 | `2026-10-02T05-45` |
| `qa-gates/coverage-delta-verification.2026-10-02T06-45.md` | 2026-10-02T06-45 | 05:46:46 | `2026-10-02T05-46` |
| `qa-gates/final-qa-clean-pass.2026-10-02T06-45.md` | 2026-10-02T06-45 | 05:47:02 | `2026-10-02T05-47` |
| `qa-gates/scope-exclusions.2026-10-02T06-50.md` | 2026-10-02T06-50 | 05:47:13 | `2026-10-02T05-47` |
| `qa-gates/scope-verification.2026-10-02T06-50.md` | 2026-10-02T06-50 | 05:47:33 | `2026-10-02T05-47` |
| `qa-gates/line-counts-final.2026-10-02T06-50.md` | 2026-10-02T06-50 | 05:47:54 | `2026-10-02T05-47` |
| `qa-gates/acceptance-checkoff.2026-10-02T06-55.md` | 2026-10-02T06-55 | 05:48:23 | `2026-10-02T05-48` |

**Required change.**

1. In each of the 35 artifacts above, replace the value on the existing first `Timestamp:` row with the corrected value from the table. Do not add a second `Timestamp:` row, because the PR-context parser keeps the first occurrence.
2. Immediately after that row in each artifact, add one line: `Timestamp-Correction: original value <recorded value> was composed on a fixed schedule rather than read from the host clock; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T05-58.md), an upper bound on the command run time.`
3. Do not rename the files. Renaming would cascade into cross-references in `acceptance-checkoff`, `final-qa-clean-pass`, and other evidence files. Instead, add a `## Plan Deviations` section to `plan.2026-09-29T16-06.md`, if absent, with entry `D-TIMESTAMPS`. The entry names the 35 artifacts by reference to this file and states that their filename suffixes retain the composed values and are not clock readings. It also records D1-D3 as used in the evidence: the D1 orchestrator-supplied anchors, the D2 literal merge-base SHA `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`, and the D3 native and PoshQC-MCP substitutions for PowerShell observations (per `evidence/other/pwsh-task-classification.2026-10-02T05-00.md`).
4. Change no other artifact content. Do not re-run the recorded commands to obtain new values.

**Verification commands.**

```bash
grep -rln "^Timestamp: 2026-10-02T06-" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/
# Expect no output (every 06-xx value in the table was composed; all corrected values are 05-xx)
grep -rln "^Timestamp: 2026-10-02T05-\(20\|30\|40\|45\|55\)$" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/regression-testing/
# Expect no output (none of the corrected regression-testing values falls on these minutes)
grep -rc "^Timestamp-Correction:" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/ | grep -c ":1$"
# Expect 35 (52 if the optional N1 correction is also applied)
grep -c "D-TIMESTAMPS" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md
# Expect at least 1
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
# Expect exit 0
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md
# Expect pass after the deviation section is added
```

**Definition of done.** None of the 35 artifacts carries a `Timestamp:` value later than its observed write time. Each carries one `Timestamp-Correction:` line. The plan records `D-TIMESTAMPS` and D1-D3. The plan still passes its validator.

## Non-blocking Items (optional in this cycle)

- **N1 (PA-3).** 17 `evidence/baseline/` artifacts and `evidence/other/python-batch-budget.2026-10-02T05-01.md` reuse a single `05-01` reading but were written between 05:01:50 and 05:18:16. These values are not later than their write times, so they do not block. If corrected in the same pass, use the write-time minutes:
  - `phase0-instructions-read` 05-01; `scope-confirmation` 05-02; `scope-anchor` 05-02; `toolchain-availability` 05-06; `line-counts` 05-07; `baseline-python-format` 05-07; `baseline-python-lint` 05-07; `baseline-python-typecheck` 05-07
  - `baseline-python-test-coverage` 05-09; `baseline-python-per-file-coverage` 05-09; `baseline-typescript-format` 05-10; `baseline-typescript-lint` 05-10; `baseline-typescript-typecheck` 05-10; `baseline-architecture` 05-10
  - `baseline-typescript-test-coverage` 05-11; `baseline-pester-guidance-contracts` 05-14; `baseline-spec-checkboxes` 05-14; `other/python-batch-budget` 05-18

  Leave `phase0-instructions-read` unchanged, since its value already matches.
- **CR-3 (Minor).** Moving the three `test_readiness_integrity_*` tests to a mirror-layout file is optional. The plan authorized the current placement.
- **CR-6 / CR-7 (Nit).** Optional import merge and stronger assertions. Do not combine these with R1 or R2 unless the full toolchain loop is re-run.
- **CR-8 (Info).** No action in this cycle. The PR body must say "Partially addresses #543" and must not use a closing keyword.

## Do-not-do List

1. Do not change any production code to address R1 or R2; both are evidence corrections. Tests may be added only if R1 step 5 finds a file below a coverage floor.
2. Do not edit any file under `.claude/rules/`, `.github/instructions/`, `.claude/**`, or `.github/**`.
3. Do not compose or estimate any timestamp. Use the observed values in the R2 table, and read the host clock for every new artifact written during remediation.
4. Do not write evidence under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/`. The lcov file at `extensions/drm-copilot/coverage/lcov.info` is a gitignored tool output, not an evidence artifact; cite it from the `qa-gates` evidence file.
5. Do not modify `scripts/dev_tools/validate_orchestration_artifacts.py` (the Python CLI deferral stands).
6. Do not check off AC-19 until the lcov-derived values meet the floors.
7. Do not expand scope to the Codex-only topology or model-routing receipt checks; they are outside this spec.

## Exit Gate for This Cycle

The cycle closes when a re-audit finds the R1 and R2 definitions of done met, AC-19 checked and evaluated PASS, and zero blocking findings.
