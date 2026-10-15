# Remediation Inputs (Issue #744)

Review-Verdict: REMEDIATION_REQUIRED

**Entry timestamp:** 2026-10-02T02-02
**Feature folder:** `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744`
**Base branch:** `main` (merge base `b080a69ecb60b65d016362b21fffed0a34be9144`)
**Head:** `bug/orchestration-completion-gate-and-tooling-friction-744` @ `45506adcb0506261aaf897d0993da9532d791146`
**Work mode:** `full-bug`; AC source is `spec.md` only
**Blocking finding count:** 1

## Audit Artifacts

- `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/policy-audit.2026-10-02T02-02.md` (Section 8, PA-1)
- `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/code-review.2026-10-02T02-02.md` (Findings Table, CR-0)
- `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/feature-audit.2026-10-02T02-02.md` (17 PASS, 2 pending-CI, 0 FAIL)

## Trigger Justification

Remediation is triggered under `.claude/skills/feature-review-workflow/SKILL.md` step 8, clause "the policy audit contains meaningful FAIL or PARTIAL results": the general code change policy is PARTIAL because evidence artifacts contain inaccurate `Timestamp:` values. Toolchain checks pass, coverage meets every threshold, and no acceptance criterion is FAIL or PARTIAL.

## Findings

### R1 — Inaccurate `Timestamp:` values in Phase 0-4 evidence

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The correction edits Markdown evidence files and the plan inside the feature folder only; every value needed is recorded in this file, and no external system, policy change, or human decision is involved.

**Problem.** Twenty-nine evidence artifacts written in Phases 0-4 carry `Timestamp: 2026-10-02T01-17`. Twenty-seven of them were written at 01:18 or later, up to 01:31:18, and several record runs that could only occur after commits dated 01:24:54 to 01:31:46 (for example `regression-testing/pass-after-parser-modules` records a post-fix run, while the fix commit `c768450a` is dated 01:27:41). The plan's Execution Conventions require the `Timestamp` value to be "read from the host system clock when the recorded command runs ... never composed or estimated", and R5.1 on this branch adds the same rule to all three evidence-and-timestamp-conventions skills. Artifacts written in Phases 5-15 are consistent with their write times and are not affected.

**Observed write times (reviewer, `ls -l --time-style=+%H:%M:%S`, captured before any edit; date 2026-10-02).** Paths are relative to the feature folder's `evidence/` directory; all file names end in `.2026-09-30T03-18.md`.

| Artifact | Observed write time | Corrected `Timestamp:` value |
|---|---|---|
| `baseline/tracked-surfaces` | 01:18:30 | `2026-10-02T01-18` |
| `baseline/file-sizes` | 01:18:38 | `2026-10-02T01-18` |
| `baseline/mirror-hashes` | 01:18:55 | `2026-10-02T01-18` |
| `baseline/py-black` | 01:19:33 | `2026-10-02T01-19` |
| `baseline/py-ruff` | 01:19:35 | `2026-10-02T01-19` |
| `baseline/py-pyright` | 01:19:38 | `2026-10-02T01-19` |
| `baseline/py-pytest-coverage` | 01:21:56 | `2026-10-02T01-21` |
| `baseline/python-coverage-baseline` | 01:22:01 | `2026-10-02T01-22` |
| `baseline/py-collect-verification-evidence` | 01:22:11 | `2026-10-02T01-22` |
| `baseline/py-targeted-contracts` | 01:22:26 | `2026-10-02T01-22` |
| `baseline/py-claude-bundle-parity` | 01:22:35 | `2026-10-02T01-22` |
| `baseline/pester-doc-contracts` | 01:22:45 | `2026-10-02T01-22` |
| `baseline/ts-prettier` | 01:23:04 | `2026-10-02T01-23` |
| `baseline/ts-eslint` | 01:23:17 | `2026-10-02T01-23` |
| `baseline/ts-tsc` | 01:23:30 | `2026-10-02T01-23` |
| `baseline/ts-dependency-cruiser` | 01:23:36 | `2026-10-02T01-23` |
| `baseline/ts-jest-coverage` | 01:24:09 | `2026-10-02T01-24` |
| `baseline/ts-jest-verification-evidence` | 01:24:18 | `2026-10-02T01-24` |
| `regression-testing/fail-before-two-gate-first-occurrence` | 01:25:57 | `2026-10-02T01-25` |
| `regression-testing/fail-before-first-occurrence-module` | 01:26:07 | `2026-10-02T01-26` |
| `regression-testing/pass-after-two-gate-first-occurrence` | 01:27:16 | `2026-10-02T01-27` |
| `regression-testing/pass-after-parser-modules` | 01:27:19 | `2026-10-02T01-27` |
| `other/py-shape06-comment-check` | 01:27:26 | `2026-10-02T01-27` |
| `other/ts-comment-check` | 01:28:17 | `2026-10-02T01-28` |
| `other/ts-comment-only-diff` | 01:28:22 | `2026-10-02T01-28` |
| `regression-testing/ts-jest-verification-evidence` | 01:29:01 | `2026-10-02T01-29` |
| `regression-testing/fail-before-doc-contracts` | 01:31:18 | `2026-10-02T01-31` |

`baseline/phase0-instructions-read.md` (01:17:43) and `baseline/scope-anchor.2026-09-30T03-18.md` (01:17:54) are consistent with `01-17` and are not changed.

**Required change.**

1. In each of the 27 artifacts above, replace the value on the existing `Timestamp:` row with the corrected value from the table. Do not add a second `Timestamp:` row; the PR-context parsers keep the first occurrence, so a second row would be ignored.
2. Immediately after the `Timestamp:` row in each of those artifacts, add one line: `Timestamp-Correction: original value 2026-10-02T01-17 was a Phase 0 start reading reused through Phase 4; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T02-02.md), an upper bound on the command run time.` The key `Timestamp-Correction` is not a schema key and is not parsed as one.
3. Add a `## Plan Deviations` entry `D-TIMESTAMPS-P0-P4` to `plan.2026-09-30T03-18.md` naming the 27 artifacts (by reference to this file), the original value, the correction basis (observed write time), and the reason (the Phase 0-4 pass reused one clock reading instead of reading the clock per command).
4. Do not change any other content of those artifacts. Do not re-run Phase 0-4 commands to obtain new values; the baseline runs cannot be reproduced at the current head.

**Verification commands.**

```bash
grep -rl "^Timestamp: 2026-10-02T01-17" docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/
# Expect exactly two paths: baseline/phase0-instructions-read.md and baseline/scope-anchor.2026-09-30T03-18.md
grep -rc "^Timestamp-Correction:" docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/ | grep -c ":1$"
# Expect 27
grep -c "D-TIMESTAMPS-P0-P4" docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/plan.2026-09-30T03-18.md
# Expect at least 1
poetry run python -m scripts.dev_tools.pr_context.collector --base b080a69ecb60b65d016362b21fffed0a34be9144 --head HEAD --repo-root .
# Expect every verification-evidence row in artifacts/pr_context.summary.txt to remain "Normalized result: pass"
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
# Expect exit 0
```

**Definition of done.** Every evidence artifact's `Timestamp:` value is consistent with its observed write time; each corrected artifact carries one `Timestamp-Correction:` line; the plan records the deviation; the PR-context verification rows are unchanged in result.

## Non-blocking Items (optional in this cycle)

- **CR-1 (Minor).** In `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `.agents/skills/acceptance-criteria-tracking/SKILL.md`, and `.github/skills/acceptance-criteria-tracking/SKILL.md` (`### When Orchestrators Enforce AC Tracking`), qualify "Orchestrators do not directly check off AC items." with a reference to `### CI-Dependent Criteria`. If done, update the three bundled mirrors byte-identically and re-run `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` and `tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py`. Deferring this to a follow-up is acceptable; record the decision.
- **PA-2 (Minor).** `evidence/qa-gates/acceptance-criteria-checkoff.2026-09-30T03-18.md` and `evidence/other/ac-status-summary-local.2026-09-30T03-18.md` have no `Command:`/`EXIT_CODE:` rows and are omitted from the PR-context verification rows. No action is required.

## Do-not-do List

1. Do not change any production code, test code, skill, agent, or mirror to address R1; it is an evidence-metadata correction only.
2. Do not edit any file under `.claude/rules/` or `.github/instructions/`.
3. Do not check off AC-16 or AC-19; they remain pending-CI and are owned by the item's orchestrator run at S9.
4. Do not compose or estimate any timestamp. Use only the observed values in the table above, and read the host clock for any new artifact written during remediation.
5. Do not write evidence under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/`.

## Exit Gate for This Cycle

The cycle closes when a re-audit finds the R1 definition of done met and records zero blocking findings. AC-16 and AC-19 continue under the S9 CI-dependent rule after the PR is created.
