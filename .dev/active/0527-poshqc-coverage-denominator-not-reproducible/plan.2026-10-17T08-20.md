# Plan: evidence-only closure of #527 (PoshQC coverage denominator reproducibility), round 2

- Issue: #527 (canonical). Branch: `bug/poshqc-coverage-denominator-527-r2`. Work Mode: full-bug. AC source: `spec.md` section `## Acceptance Criteria` only.
- FEATURE means `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527`.
- Technical basis: `<FEATURE>/spec.md` section `## Revision 2026-10-17 (round 2)` and `<FEATURE>/research/research.2026-10-17T12-35.md` (sections 4 to 6).
- Environment: tool routes, launchers, command-text limits, the batch budget, and CI shape are owned by `.claude/skills/execution-environment/SKILL.md` and are not restated here.
- `SCRATCH` means the session scratchpad directory `issue-527/`; every scratch file name starts with `issue-527-`. Evidence artifacts record the literal token `SCRATCH`, never a host path, host name, or scratchpad path.
- Scope (decided): evidence-only closure. No production, test, configuration, workflow, or mirror file changes. The plan writes only files inside FEATURE (see `## Files Written`). The round-1 plan `plan.2026-09-29T15-32.md` is not edited. The plan posts no issue comment and does not move the folder; closure is by the PR auto-close reference, handled later by pr-author.
- ACs in scope, numbered by order in `## Acceptance Criteria`: AC-01 Deterministic derivation, AC-11 Consumer fixture coverage, AC-12 Consumer isolation, AC-13 Fixture output hygiene, AC-19 Order independence. AC-01 has a CI leg that is only satisfiable at S9, so it stays unchecked in execution.
- Verification runs use the branch PoshQC module `scripts/powershell/PoshQC/PoshQC.psd1` (`Invoke-PoshQCTest`) with `-DisableKoverageCopy` and the same absolute `-Root`. Figures are never pinned: runs are compared with each other, not with a stored file count or LINE total.

## Scratch Helper Contracts

Helpers are PowerShell files under `SCRATCH`, created by one sh generator script (not by Write or Edit on a `.ps1` file), each launched through an sh launcher per the brief. Output lines are repository-relative; the absolute root is replaced by the token `<ROOT>` before anything reaches evidence.

- `issue-527-run-poshqc.ps1` (H1): parameters Label, WorkingDirectory, Root, ScanFolders, DisableKoverageCopy. Sets the current directory to WorkingDirectory, imports the branch module, calls `Invoke-PoshQCTest`, and writes the information stream to `SCRATCH/<Label>/issue-527-run.log`. The launcher, after the PowerShell process ends (so a failing run still copies), copies `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` under the Root to `SCRATCH/<Label>/` and records the process exit code.
- `issue-527-compare.ps1` (H2): parameter Labels (one or more). Per label it normalizes each JaCoCo `package|sourcefile` key to a repository-relative path (the raw package attribute is an absolute directory), then prints FILES, ROOT_LINE_TOTAL (report-level missed plus covered), SUM_FILE_TOTALS, KEY_SHA256 (SHA-256 of the ordinally sorted key list joined by LF), JUNIT_TESTS, JUNIT_FAILURES, and POPULATION_LINE (the `Code coverage population` line from the run log). Against the first label it prints KEY_SET_EQUAL and PER_FILE_DIFF_COUNT (files whose LINE total differs, plus keys present in only one report).
- `issue-527-shuffle-run.ps1` (H3): parameters Seed, Root. Lists `*.Tests.ps1` under `tests/scripts/powershell/PoshQC`, sorts ordinally, shuffles with a System.Random seeded by Seed, prints SEED and the resulting ORDER. It runs one Pester process whose `Run.Container` is one `New-PesterContainer -Path` entry per file in shuffled order, because `Invoke-PoshQCTest` hands Pester the scan folder, not an ordered file list (`Resolve-PoshQCScanFolder` returns sorted folders, and the `EnumerateTests` seam output only gates the empty-run check and sharding). Settings are the shipped `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` with `Run.Exit` off and `Run.Path` empty; the shipped `TestResult.OutputPath` and `CodeCoverage.OutputPath` values are relative, so H3 resolves both against the Root (as `Invoke-PoshQCTest` does) before the run, which places the files under `artifacts/pester` of the Root whatever the current directory; `CodeCoverage.Path` comes from `Resolve-PoshQCCoveragePopulation` called in module scope with the Root, the loaded settings, the effective scan folder `tests/scripts/powershell/PoshQC`, and the default exclusions. It prints POPULATION_SOURCE and POPULATION_FILES from that resolver result, copies the coverage and JUnit files to `SCRATCH/<Label>/`, and prints ORDER_MATCH (the sequence of `*.Tests.ps1` testsuite names in the JUnit file, each reduced to its leaf file name because Pester writes the absolute file path as the testsuite name, equals ORDER).
- `issue-527-fixture-check.ps1` (H4): parameter CoverageXmlPath. Prints SOURCEFILE_COUNT, SOURCEFILE_NAMES, SAMPLE_LINE_COVERED, PACKAGE_RELATIVE (the single package attribute made fixture-root-relative), STANDIN_PRESENT, and OUTSIDE_PACKAGE_COUNT.

## Pre-Mortem

- Review checklists: each of AC-01, AC-11, AC-12, AC-13, and AC-19 maps to named evidence in `## Files Written`, and `ac-verification.<timestamp>.md` lists all 19 ACs with status; the final-phase self-review walks the three templates under `docs/features/templates/policy_audit/` and a FAIL row blocks completion.
- Coverage: no production change, nothing is excluded from measurement, and no threshold changes. The aggregate figures are recorded as evidence only.
- Mirror parity: not applicable. No mirrored file changes and no fact in the execution-environment brief changes, so no brief-update task exists.
- File size: not applicable to code; the plan writes Markdown only, which is exempt from the 500-line limit. Scratch helpers stay under `SCRATCH`, outside the repository.
- Test isolation: the plan runs the PoshQC Pester suite in three seeded shuffled file-order runs (seeds 527, 1017, 20261017), one process each, each seed and its resulting file order recorded. Jest and Python isolation runs are not applicable because no Jest or Python file changes. No test is added or changed, so no fresh single-process run over `tests/scripts` is required.
- CI-only behavior: later pushes on the PR branch may be docs-only under the change-scope rule, in which case the heavy `poshqc` jobs are skipped. The S9 comparison for AC-01 therefore uses the newest run whose `CI full run` job succeeded, and the local denominator is compared with its `Merged PowerShell line coverage` aggregator line. The different-current-directory leg cannot run in CI and is local only.
- Evidence: filenames carry the UTC write time read from the clock; each command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; absolute paths are replaced by `<ROOT>`; stale artifacts from the round-1 execution are superseded by newer files, never edited.

## Final QA Applicability

Toolchain QA (format, lint, type check, unit tests with coverage) for Python, TypeScript, C#, and PowerShell is not applicable: no code, test, or configuration file changes, and the plan writes only Markdown under FEATURE. The final phase instead re-proves scope and runs the self-review.

### Phase 0 — Baseline capture

- [x] [P0-T1] Read the policies in the order of the `policy-compliance-order` skill (`CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`, `.claude/rules/plan-acceptance-gates.md`) and write `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` carrying `Timestamp:`, `Policy Order:`, and the list of files read. Acceptance: the artifact exists and lists all seven files in that order.
- [x] [P0-T2] Capture the base ref. Run `git merge-base origin/main HEAD` and `git rev-parse --abbrev-ref HEAD`; write `<FEATURE>/evidence/baseline/base-ref.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` stating the merge base and branch name. Acceptance: EXIT_CODE is 0 for both commands and the branch name is `bug/poshqc-coverage-denominator-527-r2`.
- [x] [P0-T3] Scope check at start. Run `git diff --name-only origin/main...HEAD -- . ':(exclude)docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/'` (the three-dot form is anchored on the merge base of `origin/main` and `HEAD`) and the companion `git status --porcelain --untracked-files=all -- . ':(exclude)docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/'`; write `<FEATURE>/evidence/baseline/scope-check-start.<timestamp>.md`. Acceptance: both commands print no path, so the branch diff and the worktree state touch only paths inside FEATURE.

### Phase 1 — Scratch helpers and toolchain baseline

- [x] [P1-T1] Create the sh generator `SCRATCH/issue-527-write-helpers.sh` (Write on a `.sh` file) that emits the four helpers H1 to H4 described in `## Scratch Helper Contracts` plus their sh launchers under `SCRATCH`, then run it. Acceptance: the four `issue-527-*.ps1` helper files exist under `SCRATCH` and no `.ps1` file was created by Write or Edit in the worktree.
- [x] [P1-T2] Run a PowerShell parser check over the four helpers through an sh launcher and write `<FEATURE>/evidence/baseline/helper-parse.<timestamp>.md`. Acceptance: EXIT_CODE is 0 and `Output Summary:` states zero parse errors for each of the four helper names.
- [x] [P1-T3] Record the toolchain baseline through an sh launcher: PowerShell version, the highest installed Pester version, and a successful import of `scripts/powershell/PoshQC/PoshQC.psd1` exposing `Invoke-PoshQCTest`. Write `<FEATURE>/evidence/baseline/toolchain-versions.<timestamp>.md`. Acceptance: EXIT_CODE is 0, Pester is 5.9.0 or later (the supported range of `Invoke-PoshQCTest`), and the import succeeds.

### Phase 2 — Denominator reproducibility (AC-01, local legs)

- [x] [P2-T1] Run A: with the current directory at the worktree root, run H1 with label `run-a`, the absolute worktree `-Root`, `-ScanFolders tests/scripts/powershell/PoshQC`, and `-DisableKoverageCopy`. Write `<FEATURE>/evidence/qa-gates/denominator-run-a.<timestamp>.md` with the H2 single-label output. Acceptance: `SCRATCH/run-a/` holds both XML copies, JUNIT_FAILURES is 0, and POPULATION_LINE contains `source=config`.
- [x] [P2-T2] Run B: same command as run A with label `run-b` and the current directory at `tests/scripts`. Write `<FEATURE>/evidence/qa-gates/denominator-run-b.<timestamp>.md`. Acceptance: `SCRATCH/run-b/` holds both XML copies, JUNIT_FAILURES is 0, and POPULATION_LINE contains `source=config`.
- [x] [P2-T3] Run C: same command with label `run-c` and the current directory set to a directory under `SCRATCH` outside the repository tree. Write `<FEATURE>/evidence/qa-gates/denominator-run-c.<timestamp>.md`. Acceptance: `SCRATCH/run-c/` holds both XML copies, JUNIT_FAILURES is 0, and POPULATION_LINE contains `source=config`.
- [x] [P2-T4] Compare the runs: run H2 over labels `run-a`, `run-b`, `run-c` and write `<FEATURE>/evidence/qa-gates/determinism-comparison.<timestamp>.md` (it supersedes the older file of the same name by sorting last; the older file is not edited). The artifact reports file count, ROOT_LINE_TOTAL, the KEY_SHA256 value, and PER_FILE_DIFF_COUNT for each run. Acceptance: KEY_SET_EQUAL is True for B and C against A, PER_FILE_DIFF_COUNT is 0 for both, ROOT_LINE_TOTAL is equal across A, B, and C, and SUM_FILE_TOTALS equals ROOT_LINE_TOTAL in each run.
- [x] [P2-T5] Record the pending CI leg: write `<FEATURE>/evidence/qa-gates/ci-leg-pending.<timestamp>.md` with the local file count, ROOT_LINE_TOTAL, and KEY_SHA256 from run A, the status `PENDING-CI`, and the S9 instruction: compare these values with the newest full CI run of the PR head (the `poshqc / PowerShell QC` aggregator log line `Merged PowerShell line coverage`, taken from a run whose `CI full run` job succeeded). Acceptance: the artifact contains the token `PENDING-CI` and the three local values copied from the determinism-comparison artifact.

### Phase 3 — Consumer fixture (AC-11, AC-12, AC-13)

- [x] [P3-T1] Capture the hygiene precondition: run `git status --porcelain --untracked-files=all -- tests/fixtures/poshqc-consumer` and `git check-ignore -v tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml`; write `<FEATURE>/evidence/regression-testing/post-fix-fixture-hygiene-before.<timestamp>.md`. Acceptance: the porcelain output is empty and the check-ignore output names the `.gitignore` rule `/tests/fixtures/poshqc-consumer/artifacts/`.
- [x] [P3-T2] Run the fixture: run H1 with label `fixture`, the absolute `-Root` of `tests/fixtures/poshqc-consumer`, `-ScanFolders scripts,tests/scripts`, and without `-DisableKoverageCopy`. Write `<FEATURE>/evidence/regression-testing/post-fix-fixture-run.<timestamp>.md` with the population line and JUnit totals. Acceptance: POPULATION_LINE contains `source=fallback; files=1`, JUNIT_TESTS is at least 1, and JUNIT_FAILURES is 0.
- [x] [P3-T3] Check the fixture coverage XML with H4 against `SCRATCH/fixture/powershell-coverage.xml`; write `<FEATURE>/evidence/regression-testing/post-fix-fixture-check.<timestamp>.md`. Acceptance: SOURCEFILE_COUNT is 1, SOURCEFILE_NAMES is `Sample.psm1`, SAMPLE_LINE_COVERED is greater than 0, PACKAGE_RELATIVE is `scripts`, STANDIN_PRESENT is 0 (no sourcefile named `validate-bash.ps1`), and OUTSIDE_PACKAGE_COUNT is 0.
- [x] [P3-T4] Capture the hygiene postcondition: repeat the P3-T1 commands after the fixture run and write `<FEATURE>/evidence/qa-gates/fixture-output-hygiene.<timestamp>.md` quoting the before artifact next to the after output. Acceptance: the porcelain output is empty both before and after, and check-ignore still names `/tests/fixtures/poshqc-consumer/artifacts/` for the fixture coverage XML path.
- [x] [P3-T5] Confirm the pre-fix failing reference: write `<FEATURE>/evidence/qa-gates/fail-first-reference.<timestamp>.md` after running `git grep -c -F -e 'SAMPLE_PRESENT=0' -- docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/evidence/regression-testing/fail-first-fixture-check.2026-10-02T07-55.md` and the same search, against the same file, for `ExpectedExitCode: 1`. Acceptance: each search reports a count of 1 or more, which shows the existing pre-fix artifact `fail-first-fixture-check.2026-10-02T07-55.md` records the failing check (the companion `fail-first-fixture-run.2026-10-02T07-55.md` records the pre-fix run and is cited, not searched).

### Phase 4 — Order independence (AC-19)

- [x] [P4-T1] Seed 527: run H3 with Seed 527 and the absolute worktree `-Root`, and write `<FEATURE>/evidence/regression-testing/order-independence-seed-527.<timestamp>.md` with SEED, ORDER, and the H2 single-label output for label `shuffle-527`. Acceptance: ORDER_MATCH is True, JUNIT_FAILURES is 0, and POPULATION_SOURCE is `config`, the source recorded for run A.
- [x] [P4-T2] Seed 1017: same as P4-T1 with Seed 1017 and label `shuffle-1017`, evidence `<FEATURE>/evidence/regression-testing/order-independence-seed-1017.<timestamp>.md`. Acceptance: ORDER_MATCH is True, JUNIT_FAILURES is 0, and ORDER differs from the ORDER recorded for seed 527.
- [x] [P4-T3] Seed 20261017: same as P4-T1 with Seed 20261017 and label `shuffle-20261017`, evidence `<FEATURE>/evidence/regression-testing/order-independence-seed-20261017.<timestamp>.md`. Acceptance: ORDER_MATCH is True, JUNIT_FAILURES is 0, and ORDER differs from the ORDER recorded for seeds 527 and 1017.
- [x] [P4-T4] Compare population: run H2 over labels `run-a`, `shuffle-527`, `shuffle-1017`, `shuffle-20261017` and write `<FEATURE>/evidence/regression-testing/order-independence-summary.<timestamp>.md`. Acceptance: KEY_SET_EQUAL is True and PER_FILE_DIFF_COUNT is 0 for each shuffled run against run A, and ROOT_LINE_TOTAL is equal to run A in all three.

### Phase 5 — AC check-off and verification

- [x] [P5-T1] Check off AC-11 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` (Edit the single line beginning `- [ ] Consumer fixture coverage:`) after P3-T2, P3-T3, and P3-T5 pass. The edited line begins `- [x] Consumer fixture coverage:`. Acceptance: `grep -c -F -e '- [x] Consumer fixture coverage:' <FEATURE>/spec.md` reports 1.
- [x] [P5-T2] Check off AC-12 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P3-T3 passes. The edited line begins `- [x] Consumer isolation:`. Acceptance: `grep -c -F -e '- [x] Consumer isolation:' <FEATURE>/spec.md` reports 1.
- [x] [P5-T3] Check off AC-13 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P3-T4 passes. The edited line begins `- [x] Fixture output hygiene:`. Acceptance: `grep -c -F -e '- [x] Fixture output hygiene:' <FEATURE>/spec.md` reports 1.
- [x] [P5-T4] Check off AC-19 in `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md` after P4-T4 passes. The edited line begins `- [x] Order independence:`. Acceptance: `grep -c -F -e '- [x] Order independence:' <FEATURE>/spec.md` reports 1.
- [x] [P5-T5] Write `<FEATURE>/evidence/qa-gates/ac-verification.<timestamp>.md` listing all 19 ACs of `spec.md` with a status and the evidence file name for AC-01, AC-11, AC-12, AC-13, and AC-19. AC-01 carries the status `PENDING-CI` and names `ci-leg-pending.<timestamp>.md`; the other 18 are checked. Acceptance: the artifact contains one `PENDING-CI` entry, and `grep -c -F -e '- [ ] Deterministic derivation:' <FEATURE>/spec.md` reports 1 (AC-01 stays unchecked for the orchestrator at S9).

### Phase 6 — Final review and scope proof

- [x] [P6-T1] Self-review: walk the three templates `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md` against the branch diff from the merge base of `origin/main` and `HEAD`, and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item (code-language rows are N/A with the no-code-change reason) and the summary line `FAIL_ROWS: 0`. A FAIL row is fixed and the artifact rewritten before this task completes. Acceptance: `grep -c -F 'FAIL_ROWS: 0' <FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` reports 1, with the timestamp of the greatest-sorting self-review file.
- [x] [P6-T2] Final scope check: repeat the P0-T3 commands (`git diff --name-only origin/main...HEAD` with the FEATURE exclusion pathspec, and the companion `git status --porcelain --untracked-files=all` with the same exclusion) and write `<FEATURE>/evidence/qa-gates/scope-check.<timestamp>.md`. Acceptance: both commands print no path, so every file the branch changes is inside FEATURE and no production, test, configuration, workflow, or mirror file changed.

## Files Written

All paths are repository-relative and inside `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/`.

- `plan.2026-10-17T08-20.md` (this plan, created once)
- `spec.md` (edit: four AC checkboxes)
- `evidence/baseline/phase0-instructions-read.<timestamp>.md`
- `evidence/baseline/base-ref.<timestamp>.md`
- `evidence/baseline/scope-check-start.<timestamp>.md`
- `evidence/baseline/helper-parse.<timestamp>.md`
- `evidence/baseline/toolchain-versions.<timestamp>.md`
- `evidence/other/preflight-fixes.2026-10-17T12-43.md` (preflight fix record, written once by the preflight pass)
- `evidence/qa-gates/denominator-run-a.<timestamp>.md`
- `evidence/qa-gates/denominator-run-b.<timestamp>.md`
- `evidence/qa-gates/denominator-run-c.<timestamp>.md`
- `evidence/qa-gates/determinism-comparison.<timestamp>.md`
- `evidence/qa-gates/ci-leg-pending.<timestamp>.md`
- `evidence/qa-gates/fixture-output-hygiene.<timestamp>.md`
- `evidence/qa-gates/fail-first-reference.<timestamp>.md`
- `evidence/qa-gates/ac-verification.<timestamp>.md`
- `evidence/qa-gates/self-review.<timestamp>.md`
- `evidence/qa-gates/scope-check.<timestamp>.md`
- `evidence/regression-testing/post-fix-fixture-hygiene-before.<timestamp>.md`
- `evidence/regression-testing/post-fix-fixture-run.<timestamp>.md`
- `evidence/regression-testing/post-fix-fixture-check.<timestamp>.md`
- `evidence/regression-testing/order-independence-seed-527.<timestamp>.md`
- `evidence/regression-testing/order-independence-seed-1017.<timestamp>.md`
- `evidence/regression-testing/order-independence-seed-20261017.<timestamp>.md`
- `evidence/regression-testing/order-independence-summary.<timestamp>.md`
