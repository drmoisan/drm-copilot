# parallel-add-and-plan-resume-prepared-items-without-replanning - Remediation Plan (cycle 2)

- **Issue:** #1047
- **Branch:** `feature/parallel-add-and-plan-resume-prepared-items-1047`
- **Work Mode:** full-feature (from `issue.md`)
- **Remediation-Mode:** proportionate (from `remediation-inputs.2026-11-03T21-16.md`)
- **Inputs:** `remediation-inputs.2026-11-03T21-16.md` (N1, N2); `code-review.2026-11-03T21-04.md` (two Minor findings); the cycle 1 plan `remediation-plan.2026-11-03T18-43.md` and its evidence, whose tool routes and evidence shapes this plan reuses.

## Required References

- Policies: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md` (`.claude/lib/parallel-admission` is classified T3).
- Tool routes, launchers, command-text restrictions, PoshQC result limits, the batch budget, CI shape, the contract tests that pin mirrored files, and the isolation-check list are owned by `.claude/skills/execution-environment/SKILL.md`. This plan references that skill and does not restate it.
- `<FEATURE>` is `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`. Evidence goes only to `<FEATURE>/evidence/<kind>/`, named `<name>.<timestamp>.md` with the UTC write time; a consumer selects the lexicographically greatest match. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Earlier evidence files are not rewritten.
- `SCRATCH` is `<session scratchpad>/issue-1047/`. Every launcher, helper script, and seed-order file lives under it, and artifacts record the token `SCRATCH`, never a host path.
- Pester counts come from `artifacts/pester/pester-junit.xml`; PowerShell line coverage comes from `artifacts/pester/powershell-coverage.xml` (per-file `sourcefile` LINE counters and the report-level LINE counter). An MCP PoshQC result is never the source of a count or a percentage.
- Scope comparisons use the merge base of `origin/main` and `HEAD`.
- No Python file changes and no new Python script. Nothing under `artifacts/` is committed. Coverage configuration, thresholds, `config/poshqc-coverage.json`, and `pyproject.toml` are not changed. No `## Acceptance Criteria` line of `spec.md` or `user-story.md` is edited. `tests/scripts/dev-tools/run-actionlint.Tests.ps1` is not edited.
- Host limit: on this Linux Codespace the full-scan Pester run fails in host-fixture suites outside this item (recorded in the cycle 1 `evidence/regression-testing/pester-full.*.md` files). A zero-failure full-scan run is therefore not an acceptance condition here; the `windows-latest` shards of `poshqc / PowerShell QC` remain the full-suite gate.

## Design Summary

- **N1 (option-shaped refs).** In `Get-ParallelAdmissionUsageError`, after the required-option loop, a non-empty `-Branch`, `-Main`, or `-Ref` value that begins with `-` returns the usage error `-<Name> must not begin with '-'; got '<value>'.`, which `Invoke-ParallelAdmissionCli` turns into exit 2 with the `parallel admission usage error: ` prefix before any git call or file read. Values with a dash elsewhere (for example `origin/feature/sample-1101`) are unaffected. The defaulting of an empty `-Main` to `origin/main` in `Invoke-ParallelAdmissionCli` is unchanged.
- **N1 tests.** The existing table-driven It `exits 2 on reuse-edges <Name> <Value>` in Describe `Usage errors` is generalized to `exits 2 on <Subcommand> <Name> <Value>`: each row carries its `Subcommand` and full `Arguments` (the `-PlanHash 'c2c2'` that the body passed moves into the three existing rows), and three rows are added, one per option. This adds three logical lines, keeping `Invoke-ParallelAdmission.Tests.ps1` within 700.
- **N2 (spec design).** The first bullet under `- Implementation scope (what changes, not sequencing):` in `## Implementation Strategy` of `<FEATURE>/spec.md` names `.claude/lib/parallel-admission/ParallelAdmissionJson.psm1` (JSON parse and serialize helpers) beside the other three helper files. No other spec line changes.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read, in the `policy-compliance-order` order: `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/quality-tiers.md`, `.claude/skills/execution-environment/SKILL.md`, and `remediation-inputs.2026-11-03T21-16.md`.
  - Acceptance: `<FEATURE>/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md` exists with `Timestamp:`, `Policy Order:`, and every file above listed.
- [x] [P0-T2] Record the scope baseline: the branch head, the merge-base `git diff --name-only --no-renames`, `git status --porcelain`, and the logical line counts of `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` and `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1`.
  - Acceptance: `<FEATURE>/evidence/remediation-baseline/scope-baseline.<timestamp>.md` records all four items; the porcelain listing shows no tracked modification outside `<FEATURE>/`.
- [x] [P0-T3] Record the PowerShell coverage baseline from the cycle 1 run: compute the SHA256 of `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` at the branch head and compare it with the canonical hash for that file in the lexicographically greatest `<FEATURE>/evidence/other/mirror-hashes.*.md`; when equal, carry the per-file and repo-wide figures of the lexicographically greatest `<FEATURE>/evidence/qa-gates/pester-coverage.*.md` as the baseline.
  - Acceptance: `<FEATURE>/evidence/remediation-baseline/pester-coverage-baseline.<timestamp>.md` names both source artifacts, records the hash comparison as equal, and records `Invoke-ParallelAdmission.ps1` covered, missed, and percentage figures (96.44% expected) and the repo-wide figure. If the hashes differ, the task instead runs the [P3-T5] coverage command before any edit and records its figures.
- [x] [P0-T4] Capture the PowerShell static baseline for `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` and `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1`: a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` and an `Invoke-Formatter` comparison that writes nothing.
  - Acceptance: `<FEATURE>/evidence/remediation-baseline/poshqc-static-baseline.<timestamp>.md` records the finding count per file and whether formatting would change each file.

### Phase 1 — Option-Shaped Ref Rejection (N1)

- [x] [P1-T1] In `Get-ParallelAdmissionUsageError` of `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`, after the loop over `$script:AdmissionRequiredOption[$Subcommand]`, return `-<Name> must not begin with '-'; got '<value>'.` for the first of `Branch`, `Main`, and `Ref` whose `$Option` value is non-empty and starts with `-` (ordinal comparison). No other function changes.
  - Asserting tests (searched in `tests/` for `Get-ParallelAdmissionUsageError` and for `-Branch`, `-Main`, `-Ref` values beginning with `-`; no match): every It of Describes `assess`, `reuse-edges`, and `Usage errors` in `Invoke-ParallelAdmission.Tests.ps1` and every It of `Invoke-ParallelAdmission.Integration.Tests.ps1` is unchanged, because each passes a ref value that does not begin with `-` (for example `origin/feature/sample-1101` and `origin/parallel/other-plan` in It `reads the record once by ref from <Expected> and runs no fetch`) or leaves `-Main` empty; those Its prove that valid ref values still pass.
  - Acceptance: `Invoke-ParallelAdmission.Tests.ps1` and `Invoke-ParallelAdmission.Integration.Tests.ps1` report zero failures in the JUnit file.
- [x] [P1-T2] In Describe `Usage errors` of `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1`, rename It `exits 2 on reuse-edges <Name> <Value>` to `exits 2 on <Subcommand> <Name> <Value>`, call `Invoke-ParallelAdmissionCli -Subcommand $Subcommand @Arguments`, add `Subcommand = 'reuse-edges'` and `PlanHash = 'c2c2'` to the three existing rows, and add three rows, each carrying the `Name` and `Value` keys that the It title renders (`-Branch`, `-Main`, `-Ref` with the option value below), with the exact messages after the usage prefix: `assess` with `Branch = '--upload-pack=x'` and `FeatureFolder = 'docs/features/active/x'` expecting `-Branch must not begin with '-'; got '--upload-pack=x'.`; `assess` with `Branch = 'origin/feature/x'`, `FeatureFolder = 'docs/features/active/x'`, and `Main = '--output=x'` expecting `-Main must not begin with '-'; got '--output=x'.`; `reuse-edges` with `Slug = 'admission-seed'`, `IssueNum = '1102'`, `PlanHash = 'c2c2'`, and `Ref = '-p'` expecting `-Ref must not begin with '-'; got '-p'.` The Describe `BeforeEach` mocks, which throw on any git call or file read, stay in force for the new rows.
  - Acceptance: the six rows pass, Describe `Usage errors` reports zero failures, and the file's logical line count is at most 700.
- [x] [P1-T3] Copy the final `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`.
  - Acceptance: `<FEATURE>/evidence/other/mirror-hashes.<timestamp>.md` shows equal SHA256 for the pair, and `tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1` reports zero failures in the JUnit file.

### Phase 2 — Spec Design Description (N2)

- [x] [P2-T1] In `<FEATURE>/spec.md` `## Implementation Strategy`, edit the first implementation-scope bullet (the one that creates `ParallelAdmission.psm1`, `ParallelAdmissionPrecedence.psm1`, and `Invoke-ParallelAdmission.ps1`) to also name `.claude/lib/parallel-admission/ParallelAdmissionJson.psm1` (JSON parse and serialize helpers).
  - Acceptance: a diff of `<FEATURE>/spec.md` anchored to the branch head recorded in [P0-T2] shows exactly one removed and one added line, both inside `## Implementation Strategy`, with the added line containing `ParallelAdmissionJson.psm1`, and no `## Acceptance Criteria` line changed; recorded in `<FEATURE>/evidence/other/spec-diff.<timestamp>.md`.

### Phase 3 — Final QA Loop and Self-Review

Restart at [P3-T1] whenever a task fails or changes a file. [P3-T5] is the last Pester run, so the coverage artifact describes the final head.

- [x] [P3-T1] Format `Invoke-ParallelAdmission.ps1`, its bundle copy, and `Invoke-ParallelAdmission.Tests.ps1` with `Invoke-Formatter` and the PoshQC settings.
  - Acceptance: a before-and-after SHA256 comparison shows no file changed, recorded in `<FEATURE>/evidence/qa-gates/poshqc-format.<timestamp>.md`.
- [x] [P3-T2] Run `Invoke-ScriptAnalyzer` directly with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `Invoke-ParallelAdmission.ps1` and `Invoke-ParallelAdmission.Tests.ps1`.
  - Acceptance: zero findings, recorded in `<FEATURE>/evidence/qa-gates/poshqc-analyze.<timestamp>.md`.
- [x] [P3-T3] Run a branch-current `Invoke-PoshQCTest` over `tests/scripts/claude-lib/parallel-admission`, `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, and `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`.
  - Acceptance: zero failures and zero errors in the JUnit file, with per-suite counts and the pass of It `exits 2 on <Subcommand> <Name> <Value>` (six rows) in `<FEATURE>/evidence/qa-gates/pester-targeted.<timestamp>.md`.
- [x] [P3-T4] Run the six suites under `tests/scripts/claude-lib/parallel-admission/` in one process in a seeded shuffled file order for seeds 11, 23, and 47, with the order-preserving `-ResolveScanFolders` seam used in cycle 1.
  - Acceptance: `<FEATURE>/evidence/regression-testing/pester-shuffle.<timestamp>.md` records, per seed, zero failures and the executed file order read from the JUnit `testsuite` order, equal to the seeded order.
- [x] [P3-T5] Run one fresh single-process branch-current `Invoke-PoshQCTest -ScanFolders tests/scripts` with the module-default settings, which derive the coverage population from `config/poshqc-coverage.json`.
  - Acceptance: `artifacts/pester/powershell-coverage.xml` is written by this run; `Invoke-ParallelAdmission.ps1` line coverage is at or above 96.44% and at or above the [P0-T3] figure; no missed line of `Invoke-ParallelAdmission.ps1` falls in `Get-ParallelAdmissionUsageError`; the repo-wide report-level LINE figure is recorded; and no failure line printed by the run names a suite under `tests/scripts/claude-lib/parallel-admission`, `ClaudeLibModuleConvention.Tests.ps1`, or `FileSizePolicy.RepoGate.Tests.ps1`. Baseline and post-change figures with covered and missed counts, and the run's total and failed counts, are in `<FEATURE>/evidence/qa-gates/pester-coverage.<timestamp>.md`.
- [x] [P3-T6] Run the `## Contract Test Set` of `remediation-plan.2026-11-03T18-43.md` serially under the project addopts (`--strict-markers --strict-config`); it includes the bundle-mirror and pack-manifest contract tests.
  - Acceptance: zero failures and zero errors, with counts in `<FEATURE>/evidence/qa-gates/pytest-contracts.<timestamp>.md`.
- [x] [P3-T7] Record the logical line counts of `Invoke-ParallelAdmission.ps1` and `Invoke-ParallelAdmission.Tests.ps1`.
  - Acceptance: `<FEATURE>/evidence/other/module-size.<timestamp>.md` shows both at most 700.
- [x] [P3-T8] Record the scope evidence: the merge-base `git diff --name-only --no-renames` and `git status --porcelain`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/scope-diff.<timestamp>.md` shows, relative to the [P0-T2] listing, no new path outside `<FEATURE>/`; no `.py` path changed by this cycle; and no path under `artifacts/`.
- [x] [P3-T9] Walk `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md` against the merge-base branch diff, this plan, and the cycle evidence, including the tonality of every new prose line in `spec.md`, this plan, and the evidence.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` holds one PASS, FAIL, or N/A row per checklist item, with rows for N1 and N2, and no FAIL row. A FAIL is fixed, the loop restarts at [P3-T1], and the self-review is rewritten.

## AC Traceability

| ID | Implementation | Tests | Evidence |
| --- | --- | --- | --- |
| N1 option-shaped `-Ref`, `-Branch`, `-Main` rejected | [P1-T1], [P1-T3] | It `exits 2 on <Subcommand> <Name> <Value>` ([P1-T2]); unchanged `assess` and `reuse-edges` Describes for valid refs; `ParallelAdmission.Manifest.Tests.ps1` | `pester-targeted`, `pester-shuffle`, `pester-coverage`, `mirror-hashes` |
| N2 spec names `ParallelAdmissionJson.psm1` | [P2-T1] | anchored spec diff | `spec-diff` |

The spec acceptance criteria are unchanged.

## Pre-Mortem

- Review checklists: The code review asks for rejection of option-shaped ref values and for the spec to name the JSON module; [P1-T1] and [P2-T1] address exactly those two rows, and [P3-T9] walks all three templates, including the tonality of new prose.
- Coverage: The new lines in `Get-ParallelAdmissionUsageError` run on every CLI call and the return runs for the three new rows, so `Invoke-ParallelAdmission.ps1` cannot fall below its 96.44% baseline from them; [P3-T5] checks the figure and that no missed line is in that function. No Python changes, so no Python coverage run is needed.
- Mirror parity: [P1-T3] re-copies the bundle script and records equal hashes, and [P3-T6] runs the mirror and pack-manifest contract tests. No new file, so no manifest entry. `spec.md` has no mirror. Execution-environment brief: no CI job, required context, tool route, or batch-budget rule changes, so no brief-update task is needed.
- File size: `Invoke-ParallelAdmission.Tests.ps1` starts at 692 logical lines; [P1-T2] generalizes the existing table instead of adding an It, adding three lines, and [P3-T7] checks both files at most 700 (the script starts at 621). `FileSizePolicy.RepoGate.Tests.ps1` runs in [P3-T3].
- Test isolation: The new rows use the existing Describe mocks and create no temporary files. Isolation runs: [P3-T4] seeded shuffled file-order Pester runs with seeds 11, 23, and 47, each seed and file order recorded; [P3-T5] fresh single-process run; [P3-T6] serial pytest under the strict addopts. A seeded shuffled Jest run and a reversed-order Python run are not applicable because no TypeScript or Python file changes.
- CI-only behavior: The tests compare in-memory strings with no path, drive letter, or line-ending dependence, so the `windows-latest` shards of `poshqc / PowerShell QC` see the same values. The full-scan host-fixture failures on Linux are recorded, not waived, and the shards remain the full-suite gate.
- Evidence: Every artifact goes to `<FEATURE>/evidence/<kind>/` with a write-time UTC stamp and the four fields; Phase 0 uses `remediation-baseline/`. Counts come from the JUnit file and coverage from the XML report, never from MCP results. No artifact records a host path, and nothing under `artifacts/` is committed.
