# 2026-07-03-parallel-ci-subworkflows - Plan

- **Issue:** #294
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-03T18-07
- **Status:** Draft
- **Version:** 0.2

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- GitHub Actions Workflow Policy: [`.github/instructions/github-actions.instructions.md`](../../../../.github/instructions/github-actions.instructions.md)
- Precedent pattern: [`.github/workflows/_npm-audit-gate.yml`](../../../../.github/workflows/_npm-audit-gate.yml), [`.github/workflows/npm-audit-gate.yml`](../../../../.github/workflows/npm-audit-gate.yml)
- Authoritative research: [`research/2026-07-03T19-00-parallel-ci-subworkflows-research.md`](research/2026-07-03T19-00-parallel-ci-subworkflows-research.md)

**All work must comply with these policies; do not duplicate their content here.**

## Scope Statement

This feature is `.github/workflows/**`-only. No `.py`, `.ts`, `.ps1`, or `.cs` production or test
file is created, modified, or deleted by this feature. Consequently, the Python
(Black/Ruff/Pyright/Pytest), TypeScript (ESLint/TSC/Vitest), PowerShell (PSScriptAnalyzer/Pester),
and C# toolchain loops defined in `.claude/rules/general-code-change.md` and
`.claude/rules/general-unit-test.md` do not apply to this change, and no coverage delta is
expected or measured for any of those languages. The actual verification surface for this feature
is: (a) YAML validity for every new/modified workflow file (`actionlint`, per
`.github/instructions/github-actions.instructions.md`), and (b) a green workflow run against the
branch head, per the `modified-workflow-needs-green-run` policy rule. This statement is captured
formally in Phase 5.

Out of scope (no tasks target these): `.github/workflows/publish-extension.yml`,
`.github/workflows/publish-mcp-npm.yml`, and any file under `src/` or
`extensions/drm-copilot/src`.

## Task Ownership

Phase 0-3 and Phase 5 tasks (file edits, `actionlint`/YAML validation, policy reads) are executed by
`atomic-executor`. Task P0-T8 and Phase 4 tasks P4-T1 through P4-T10 — which invoke `gh api` or
`gh workflow run` — are executed directly by the orchestrator (not delegated to atomic-executor),
because atomic-executor's tool allowlist does not include `gh`. P4-T11 uses only `git diff --stat`
(no `gh` invocation) and remains an atomic-executor task, run after P4-T1..P4-T10 complete.
atomic-executor's preflight/execution passes for this plan therefore SKIP P0-T8 and P4-T1..P4-T10 by
design; the orchestrator performs those steps itself after atomic-executor's file-edit phases
complete and are committed. Every task below carries an explicit `Owner:` line so preflight can
mechanically confirm routing to an agent that has the tools it needs.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance, Baseline Capture, and Required-Check Baseline

- [x] [P0-T1] Read `.github/copilot-instructions.md` in full.
  - Acceptance: File content reviewed; confirmed as step 1 of the Policy Compliance Reading Order in `CLAUDE.md`.
  - Owner: atomic-executor
- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md` in full.
  - Acceptance: File content reviewed; confirmed as step 2 of the Policy Compliance Reading Order.
  - Owner: atomic-executor
- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md` in full.
  - Acceptance: File content reviewed; confirmed as step 3 of the Policy Compliance Reading Order.
  - Owner: atomic-executor
- [x] [P0-T4] Read `.github/instructions/github-actions.instructions.md` in full (the applicable language/domain policy for this feature's file scope, `.github/workflows/**/*.yml`).
  - Acceptance: File content reviewed; the `applyTo` frontmatter pattern is confirmed to match every file this feature creates or modifies.
  - Owner: atomic-executor
- [x] [P0-T5] Create Phase 0 policy-read evidence artifact at `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:` (numbered list matching P0-T1..P0-T4 in order), and the explicit list of the four files read.
  - Acceptance: File exists at the exact path above and contains all three required fields.
  - Owner: atomic-executor
- [x] [P0-T6] Capture a pre-change `actionlint` baseline run against the current, unmodified `.github/workflows/ci.yml` using `scripts/dev-tools/run-actionlint.ps1` (or the repository's documented equivalent invocation), and write the result to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/baseline/baseline-actionlint-ci-yml.2026-07-03T18-07.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (must report 0 errors, confirming the pre-extraction file is itself lint-clean).
  - Acceptance: Artifact exists with all four required fields and `EXIT_CODE: 0`.
  - Owner: atomic-executor
- [x] [P0-T7] Capture a pre-change working-tree baseline via `git status --porcelain` and `git diff --stat`, confirming the working tree is clean before Phase 1 edits begin, and write both raw outputs to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/baseline/baseline-git-status.2026-07-03T18-07.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists; `Output Summary:` states the working tree was clean (or lists any pre-existing untracked/modified files) prior to this feature's edits.
  - Owner: atomic-executor
- [ ] [P0-T8] Capture the pre-extraction required-status-check baseline by running `gh api repos/drmoisan/drm-copilot/branches/main/protection/required_status_checks` (GET) and recording the raw JSON response — specifically the current `checks[].context` strings for `quality-checks7`, `security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`, and `drm-copilot-extension-tests` (and their matrix legs, if individually required) — to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/baseline/baseline-required-status-checks.2026-07-03T18-07.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists and lists the exact pre-extraction `context` strings currently configured as required, or explicitly states none of the seven job names are currently configured as required checks.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`; this task is executed directly by the orchestrator, not delegated.

### Phase 1 — Extract Each Current `ci.yml` Job into Its Own Reusable Workflow File

- [x] [P1-T1] Create `.github/workflows/_quality-checks.yml` containing a single job whose steps are lifted byte-for-byte from `quality-checks7` (current `ci.yml` lines 11–84: the 4-way `python-version` matrix `["3.10", "3.11", "3.12", "3.13"]` declared inline, and all 12 steps including the Codecov upload gated on `matrix.python-version == '3.13'`), with a top-level `on:` block declaring both `workflow_call:` and `workflow_dispatch:` (no `inputs:` block, mirroring `_npm-audit-gate.yml`'s `on:` shape).
  - Acceptance: File exists at `.github/workflows/_quality-checks.yml`; its `on:` block contains both `workflow_call:` and `workflow_dispatch:` keys; a manual comparison against `ci.yml` lines 11–84 shows the job's `strategy.matrix` and every step's `name`/`run`/`uses`/`with`/`if` content is identical (only indentation and the enclosing `on:`/wrapper shape differ); the file contains exactly 12 `- name:` step entries.
  - Owner: atomic-executor
- [x] [P1-T2] Create `.github/workflows/_security-scan.yml` containing a single job whose steps are lifted byte-for-byte from `security-scan` (current `ci.yml` lines 86–108, including the `continue-on-error: true` on the security-check step), with a top-level `on:` block declaring both `workflow_call:` and `workflow_dispatch:` (no `inputs:`).
  - Acceptance: File exists at `.github/workflows/_security-scan.yml`; its `on:` block contains both `workflow_call:` and `workflow_dispatch:` keys; the `continue-on-error: true` attribute is present on the same step it was on in the source; all 4 steps' content is identical to `ci.yml` lines 86–108 apart from indentation/wrapper shape.
  - Owner: atomic-executor
- [x] [P1-T3] Create `.github/workflows/_docs-validation.yml` containing a single job whose steps are lifted byte-for-byte from `docs-validation` (current `ci.yml` lines 110–139), with a top-level `on:` block declaring both `workflow_call:` and `workflow_dispatch:` (no `inputs:`).
  - Acceptance: File exists at `.github/workflows/_docs-validation.yml`; its `on:` block contains both `workflow_call:` and `workflow_dispatch:` keys; all 4 steps' content is identical to `ci.yml` lines 110–139 apart from indentation/wrapper shape.
  - Owner: atomic-executor
- [x] [P1-T4] Create `.github/workflows/_build-check.yml` containing a single job whose steps are lifted byte-for-byte from `build-check` (current `ci.yml` lines 141–168), with a top-level `on:` block declaring both `workflow_call:` and `workflow_dispatch:` (no `inputs:`).
  - Acceptance: File exists at `.github/workflows/_build-check.yml`; its `on:` block contains both `workflow_call:` and `workflow_dispatch:` keys; all 5 steps' content is identical to `ci.yml` lines 141–168 apart from indentation/wrapper shape.
  - Owner: atomic-executor
- [x] [P1-T5] Create `.github/workflows/_poshqc.yml` containing a single job whose steps are lifted byte-for-byte from `poshqc` (current `ci.yml` lines 170–214, `runs-on: windows-latest`, including the `actions/upload-artifact@v7` step with its exact `path:` list and `if-no-files-found: ignore`), with a top-level `on:` block declaring both `workflow_call:` and `workflow_dispatch:` (no `inputs:`).
  - Acceptance: File exists at `.github/workflows/_poshqc.yml`; `runs-on: windows-latest` is preserved; its `on:` block contains both `workflow_call:` and `workflow_dispatch:` keys; all 6 steps' content, including the `actions/upload-artifact@v7` step's `path:` list, is identical to `ci.yml` lines 170–214 apart from indentation/wrapper shape.
  - Owner: atomic-executor
- [x] [P1-T6] Create `.github/workflows/_shell-coverage.yml` containing a single job whose steps are lifted byte-for-byte from `shell-coverage` (current `ci.yml` lines 216–293, including the `actions/cache@v6` step keyed `kcov-v43-ubuntu-latest` and the `actions/upload-artifact@v7` step with `if-no-files-found: error`), with a top-level `on:` block declaring both `workflow_call:` and `workflow_dispatch:` (no `inputs:`).
  - Acceptance: File exists at `.github/workflows/_shell-coverage.yml`; its `on:` block contains both `workflow_call:` and `workflow_dispatch:` keys; all 12 steps' content, including both cache-key and artifact-upload configuration, is identical to `ci.yml` lines 216–293 apart from indentation/wrapper shape.
  - Owner: atomic-executor
- [x] [P1-T7] Create `.github/workflows/_drm-copilot-extension-tests.yml` containing a single job whose steps are lifted byte-for-byte from `drm-copilot-extension-tests` (current `ci.yml` lines 295–317, keeping the 2-way `os: [windows-latest, ubuntu-latest]` matrix declared inline), with a top-level `on:` block declaring both `workflow_call:` and `workflow_dispatch:` (no `inputs:`).
  - Acceptance: File exists at `.github/workflows/_drm-copilot-extension-tests.yml`; its `on:` block contains both `workflow_call:` and `workflow_dispatch:` keys; `strategy.matrix.os` retains both `windows-latest` and `ubuntu-latest`; all 4 steps' content is identical to `ci.yml` lines 295–317 apart from indentation/wrapper shape.
  - Owner: atomic-executor

### Phase 2 — Rewrite `ci.yml` as a Thin Orchestrator and Validate YAML

- [x] [P2-T1] Rewrite `.github/workflows/ci.yml` so that its top-level `on:` block (`push` to `main`/`development`, `pull_request` to `main`/`development`, `workflow_dispatch`) is textually unchanged from the pre-Phase-1 file, and its `jobs:` block contains exactly seven jobs — `quality-checks7`, `security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`, `drm-copilot-extension-tests` — each with a body consisting solely of `uses: ./.github/workflows/_<name>.yml` (mapping to the seven files created in Phase 1), no `needs:` key on any of the seven jobs, and no inline `steps:` key anywhere in the file.
  - Acceptance: `grep -n "steps:" .github/workflows/ci.yml` returns zero matches; `grep -n "needs:" .github/workflows/ci.yml` returns zero matches; each of the seven jobs' body is exactly one `uses:` line pointing at its corresponding `_<name>.yml` file from Phase 1; a diff of the file's `on:` block (lines 3–8 in the original) against the rewritten file's `on:` block shows no differences.
  - Owner: atomic-executor
- [x] [P2-T2] Validate YAML syntax and `actionlint` compliance for all 8 workflow files touched by this feature (`ci.yml` plus the 7 new `_<name>.yml` files) using `scripts/dev-tools/run-actionlint.ps1` (or a plain YAML parse per file if `actionlint` is unavailable in the execution environment), and write the result to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/qa-gates/yaml-validation-phase2.2026-07-03T18-07.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists; `EXIT_CODE: 0`; `Output Summary:` explicitly lists all 8 file paths and confirms 0 errors across all of them. If any error is found, Phase 1/Phase 2 file(s) must be corrected and this task rerun until `EXIT_CODE: 0` is achieved before proceeding to Phase 3.
  - Owner: atomic-executor

### Phase 3 — Author `.github/workflows/README.md`

- [x] [P3-T1] Create `.github/workflows/README.md` with a "Per-Stage Dispatch" section containing a table with one row per one of the 7 new `_<name>.yml` files (`_quality-checks.yml`, `_security-scan.yml`, `_docs-validation.yml`, `_build-check.yml`, `_poshqc.yml`, `_shell-coverage.yml`, `_drm-copilot-extension-tests.yml`), each row listing the file's declared triggers (`workflow_call`, `workflow_dispatch`) and the exact standalone dispatch command (e.g. `gh workflow run _shell-coverage.yml`).
  - Acceptance: `.github/workflows/README.md` exists; its "Per-Stage Dispatch" section table contains exactly 7 rows, one per file listed above, each with a non-empty `gh workflow run _<name>.yml` command cell.
  - Owner: atomic-executor
- [x] [P3-T2] Add a "Required-Status-Check Rename Procedure" section to `.github/workflows/README.md` documenting the exact 4-step procedure from `spec.md`'s Implementation Strategy: (1) land the extraction and produce a green run against the branch head, (2) read actual composed check-run names via `gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs`, (3) update branch protection via `gh api repos/{owner}/{repo}/branches/{branch}/protection/required_status_checks` (PATCH) with the confirmed new context strings and removal of stale pre-extraction context strings, (4) document both old and new context strings plus the exact `gh api` commands used.
  - Acceptance: The section exists in `.github/workflows/README.md`, is numbered as a 4-step procedure, and contains the literal `gh api` command templates for both the GET (`.../commits/{sha}/check-runs`) and PATCH (`.../protection/required_status_checks`) endpoints.
  - Owner: atomic-executor
- [x] [P3-T3] Add an explicit "Scope of This Refactor" section to `.github/workflows/README.md` stating that this extraction does not, by itself, change job-DAG concurrency (all 7 jobs already lacked `needs:` edges before this change and remain independent afterward), and stating that its purpose is architecture-conformance with the pattern already established by `_npm-audit-gate.yml`/`npm-audit-gate.yml`, independent per-gate `workflow_dispatch` re-run capability, and reduced single-file blast radius.
  - Acceptance: The section exists in `.github/workflows/README.md` and contains, verbatim in substance, all three stated purposes (architecture-conformance, independent re-run, reduced blast radius) plus the explicit no-concurrency-change statement.
  - Owner: atomic-executor

### Phase 4 — Dispatch, Green-Run, and Required-Check Evidence Capture

- [ ] [P4-T1] Execute `gh workflow run _quality-checks.yml --ref <feature-branch>` and confirm the resulting run's conclusion is `success`; record the run URL, `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (run conclusion) to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/other/workflow-dispatch-quality-checks.2026-07-03T18-07.md`.
  - Acceptance: Artifact exists with all four required fields and `Output Summary:` states `conclusion: success` for all 4 matrix legs.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`; this task is executed directly by the orchestrator, not delegated.
- [ ] [P4-T2] Execute `gh workflow run _security-scan.yml --ref <feature-branch>` and confirm the resulting run's conclusion is `success`; record evidence to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/other/workflow-dispatch-security-scan.2026-07-03T18-07.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists with all four required fields and `Output Summary:` states `conclusion: success`.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`; this task is executed directly by the orchestrator, not delegated.
- [ ] [P4-T3] Execute `gh workflow run _docs-validation.yml --ref <feature-branch>` and confirm the resulting run's conclusion is `success`; record evidence to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/other/workflow-dispatch-docs-validation.2026-07-03T18-07.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists with all four required fields and `Output Summary:` states `conclusion: success`.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`; this task is executed directly by the orchestrator, not delegated.
- [ ] [P4-T4] Execute `gh workflow run _build-check.yml --ref <feature-branch>` and confirm the resulting run's conclusion is `success`; record evidence to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/other/workflow-dispatch-build-check.2026-07-03T18-07.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists with all four required fields and `Output Summary:` states `conclusion: success`.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`; this task is executed directly by the orchestrator, not delegated.
- [ ] [P4-T5] Execute `gh workflow run _poshqc.yml --ref <feature-branch>` and confirm the resulting run's conclusion is `success`; record evidence to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/other/workflow-dispatch-poshqc.2026-07-03T18-07.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists with all four required fields and `Output Summary:` states `conclusion: success`.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`; this task is executed directly by the orchestrator, not delegated.
- [ ] [P4-T6] Execute `gh workflow run _shell-coverage.yml --ref <feature-branch>` and confirm the resulting run's conclusion is `success`; record evidence to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/other/workflow-dispatch-shell-coverage.2026-07-03T18-07.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists with all four required fields and `Output Summary:` states `conclusion: success`.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`; this task is executed directly by the orchestrator, not delegated.
- [ ] [P4-T7] Execute `gh workflow run _drm-copilot-extension-tests.yml --ref <feature-branch>` and confirm the resulting run's conclusion is `success`; record evidence to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/other/workflow-dispatch-drm-copilot-extension-tests.2026-07-03T18-07.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists with all four required fields and `Output Summary:` states `conclusion: success` for both `os` matrix legs.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`; this task is executed directly by the orchestrator, not delegated.
- [ ] [P4-T8] Capture the branch-head green run required by `modified-workflow-needs-green-run`: identify the workflow run of the rewritten `ci.yml` triggered against the feature branch head (via its `push`/`pull_request` trigger, or a `workflow_dispatch` run of `ci.yml` itself against the branch head), confirm all 7 jobs (11 job runs counting matrices) conclude `success`, and record the run URL, head SHA, `Timestamp:`, `Command:` (`gh run view <run-id> --json conclusion,jobs`), `EXIT_CODE:`, `Output Summary:` to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/qa-gates/green-run-branch-head.2026-07-03T18-07.md`.
  - Acceptance: Artifact exists with all required fields; `Output Summary:` lists all 11 job runs with `conclusion: success`. This artifact satisfies AC-6.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`; this task is executed directly by the orchestrator, not delegated.
- [ ] [P4-T9] Record the actual composed required-status-check names: run `gh api repos/drmoisan/drm-copilot/commits/{head_sha}/check-runs` against the branch-head run's SHA captured in P4-T8, and record the raw response plus a table listing the confirmed check-run `name` string for each of the 7 extracted jobs (and their matrix legs) to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/other/required-status-check-names.2026-07-03T18-07.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists; the table lists a non-empty confirmed `name` string for each of the 7 jobs (11 rows counting matrix legs).
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`; this task is executed directly by the orchestrator, not delegated.
- [ ] [P4-T10] Compare the confirmed check-run names from P4-T9 against the pre-extraction baseline from P0-T8, and reconcile branch protection: run `gh api repos/drmoisan/drm-copilot/branches/main/protection/required_status_checks` (GET), then execute `gh api repos/drmoisan/drm-copilot/branches/main/protection/required_status_checks` (PATCH) with a `checks` array reflecting the confirmed post-extraction context strings (removing any stale pre-extraction context string no longer produced), then re-run the GET to confirm the update took effect; record all three raw outputs and the before/after diff to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/other/branch-protection-update.2026-07-03T18-07.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (stating either "updated: <old> to <new>" per changed context, or "unchanged: no context-name drift detected").
  - Acceptance: Artifact exists; the final GET response's `checks[].context` list matches the confirmed post-extraction names from P4-T9 with no stale pre-extraction context string remaining.
  - Owner: orchestrator (direct `gh` invocation) — atomic-executor's tool allowlist does not include `gh`; this task is executed directly by the orchestrator, not delegated.
- [x] [P4-T11] Run `git diff --stat` (against the pre-feature base commit) and confirm zero lines under `src/` or `extensions/drm-copilot/src` appear in the output; record the command, `EXIT_CODE:`, and `Output Summary:` to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/other/scope-guard-git-diff.2026-07-03T18-07.md`.
  - Acceptance: Artifact exists; `Output Summary:` confirms 0 files under `src/` or `extensions/drm-copilot/src` are present in the diff, and confirms `.github/workflows/publish-extension.yml` and `.github/workflows/publish-mcp-npm.yml` are also absent from the diff.
  - Owner: atomic-executor — this task uses only `git diff --stat` (no `gh` invocation), which is within atomic-executor's `Bash(git *)` allowlist entry; it runs after the orchestrator-owned P4-T1..P4-T10 tasks complete, since it validates the same branch-head state captured in P4-T8.

### Phase 5 — Final QA Loop and Language-Applicability Statement

- [x] [P5-T1] Write an explicit language-applicability statement to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/qa-gates/final-qa-loop-language-applicability.2026-07-03T18-07.md` stating that the Python (Black/Ruff/Pyright/Pytest), TypeScript (ESLint/TSC/Vitest), and PowerShell (PSScriptAnalyzer/Pester) toolchain loops are N/A for this feature (no `.py`/`.ts`/`.ps1` production or test file was changed, per P4-T11's confirmed diff scope), and that YAML validity (`actionlint`) plus the green branch-head run (P4-T8) constitute this feature's actual verification surface.
  - Acceptance: Artifact exists and explicitly states N/A for each of the three named language toolchains, citing P4-T11 as the confirming diff-scope evidence.
  - Owner: atomic-executor
- [x] [P5-T2] Run a final `actionlint` pass (via `scripts/dev-tools/run-actionlint.ps1` or equivalent) across all 8 files touched by this feature (`ci.yml` plus the 7 `_<name>.yml` files) after Phase 3's `README.md` addition and Phase 4's dispatch runs, confirming zero errors, and record the result to `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/qa-gates/final-qa-loop-actionlint.2026-07-03T18-07.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: Artifact exists; `EXIT_CODE: 0`; `Output Summary:` confirms 0 errors across all 8 files. If any error is found, restart from Phase 1's affected file, re-run Phase 2's validation task, and repeat this task until a clean pass completes.
  - Owner: atomic-executor

## Test Plan

- Unit: Not applicable. This is a `.github/workflows/**`-only change; no Python, TypeScript,
  PowerShell, or C# production or test file is created, modified, or deleted (confirmed by
  P4-T11's scope-guard diff and stated explicitly in P5-T1).
- Integration: Not applicable in the traditional sense; the equivalent integration surface for a
  GitHub Actions workflow change is a real workflow run. This is covered by Phase 4 (per-file
  `workflow_dispatch` runs, P4-T1..P4-T7) and the branch-head green run required by
  `modified-workflow-needs-green-run` (P4-T8).
- Manual/CLI: `gh workflow run _<name>.yml` for each of the 7 new files (Phase 4); `gh api`
  GET/PATCH sequence for branch-protection required-status-check reconciliation (P4-T10).
- Coverage evidence: Not applicable. No language with a mandatory coverage policy
  (Python/TypeScript/PowerShell/C#) has any file in scope for this feature; no coverage baseline,
  post-change, or comparison artifact is produced or required. The actual verification-surface
  evidence for this feature is YAML validity (`evidence/qa-gates/yaml-validation-phase2.*.md`,
  `evidence/qa-gates/final-qa-loop-actionlint.*.md`) and the green branch-head run
  (`evidence/qa-gates/green-run-branch-head.*.md`).

## Open Questions / Notes

- P4-T1..P4-T10 and P0-T8 use `<feature-branch>` and `drmoisan/drm-copilot` as placeholders for the
  actual working branch and confirmed `owner/repo`; the orchestrator (owner of these `gh`-dependent
  tasks per Task Ownership above) substitutes the real branch name and confirms `owner/repo` against
  `git remote get-url origin` before running any `gh` command.
- If P4-T9's confirmed check-run names exactly match P0-T8's pre-extraction baseline (no naming
  drift), P4-T10's `Output Summary:` records "unchanged: no context-name drift detected" rather
  than performing a functionally-empty PATCH; the GET/PATCH/GET sequence is still executed in full
  to produce auditable evidence either way.
- `publish-extension.yml` and `publish-mcp-npm.yml` are explicitly out of scope; no task in this
  plan reads or modifies either file beyond confirming their absence from the diff (P4-T11).
