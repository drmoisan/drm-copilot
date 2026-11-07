# codex-review-coverage-hook-reads-stale-or-foreign-artifacts (Remediation Plan, cycle 2)

- **Issue:** #1114
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T20-49
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** full-bug
- **Remediation-Mode:** proportionate
- **Branch:** bug/codex-coverage-hook-freshness
- **Inputs:** `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/remediation-inputs.2026-11-07T20-49.md` (finding CR-3, Low)
- **Review:** `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/code-review.2026-11-07T20-40.md`
- **Cycle 1 template:** `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/remediation-plan.2026-11-07T20-08.md`

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Terms and Execution Rules

- `<FEATURE>` is `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114`.
- `SCRATCH` resolves to `<session scratchpad>/issue-1114/`; scratch file names start with `issue-1114-`, and artifacts record the token `SCRATCH`, never a host path.
- Tool routes, launchers, the PowerShell route, PoshQC MCP output limits, and command-text restrictions are owned by the `execution-environment` skill and are not restated. Pester counts and coverage come from the files a direct `Invoke-PoshQCParallelTest` run writes, never from a PoshQC MCP result.
- The executor commits each completed task and pushes to `origin bug/codex-coverage-hook-freshness` after each task. No git tags. No unqualified `poetry install`. Hooks stay PowerShell only: no `.py` file is added under `.codex/hooks/`.
- Scope: the function `Get-CodexReviewPolicyAuditPath` in `.codex/hooks/feature-review-coverage-target.ps1`, its byte-identical bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, and `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1`. Do not change `.codex/hooks/hook-target-worktree.ps1`, any file under `.claude/hooks` or `.claude/lib`, or `.codex/config.toml`; add no recency fallback (decision D2).
- Fixtures are `/`-rooted forward-slash literals in exact case with no drive letters; tests create no temporary files and read no gitignored `artifacts/` state.
- A focused run of one test file is debugging only and never a gate or evidence.
- The merge base is the output of `git merge-base origin/main HEAD`, recorded in [P0-T1] as `MERGE_BASE`.
- Cycle 1 final gate evidence: the lexicographically greatest `<FEATURE>/evidence/qa-gates/pester-parallel.*.md`, `pytest-parallel.*.md`, and `poshqc-analyze.*.md` present at the start of this cycle. This cycle writes new stamped files and never edits those.

## Fixed Design (CR-3)

`Get-CodexReviewPolicyAuditPath -Message` keeps its name, parameters, candidate sources, normalization, eligibility rule, shape pattern, prefix rule, and return shape. One change: the `..` segment check runs only when the examined candidate is a policy-audit candidate, meaning its final path segment is `policy-audit.md` or matches `policy-audit.<timestamp>.md`. The check still runs before the shape test, so a policy-audit candidate with a `..` segment in any position keeps reporting `AUDIT_PATH_TRAVERSAL` with the existing reason text naming the `'..' segment`. A candidate whose final segment is anything else (for example `code-review.<timestamp>.md`) with a `..` segment is skipped as before cycle 1, because it fails the shape test. Comment-based help states the narrowed rule.

## Existing Tests That Assert the Changed Behavior (searched in `tests/` for `Get-CodexReviewPolicyAuditPath`, `Resolve-CodexReviewCoverageTarget`, and `AUDIT_PATH_TRAVERSAL`)

The only test file that names `AUDIT_PATH_TRAVERSAL` is `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1`. Dispositions:

- `1114: returns AUDIT_PATH_TRAVERSAL for a path with a .. segment` (extractor Describe): unchanged because unaffected; its final segment is a policy-audit file name, so the check still fires.
- `1114: returns AUDIT_PATH_TRAVERSAL for a .. path with two segments below the feature folder` (the CR-2 row): unchanged because unaffected; final segment is `policy-audit.2026-11-07T20-00.md`.
- `1114: returns AUDIT_PATH_TRAVERSAL for a path with a .. segment` (`Resolve-CodexReviewCoverageTarget` Describe): unchanged because unaffected; the path ends in a policy-audit file name.
- Remaining extractor and resolver rows, including `returns each distinct path once and ignores other artifacts` (a code-review path with no `..`) and the guard row for one labelled line with two audits: unchanged because unaffected; none carries a `..` segment in a non-audit candidate.
- `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`: unchanged because unaffected; its messages carry no `..` segment.
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` and the bundle parity pytest `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`: unchanged because unaffected; they read file length, shared-module registration, and byte equality, which [P2-T1] preserves.

[P3-T3] proves every disposition by listing these rows as passing.

## Pre-Mortem

- Review checklists: a reviewer could find the narrowed check also dropping CR-2 for a policy-audit path, or the new row asserting nothing; [P1-T1] keeps the CR-2 rows untouched and adds a row that asserts both the selected path and the absent reason code, [P1-T2] proves the new row fails first, and [P3-T5] walks the policy-audit, code-review, and feature-audit templates against the diff from `MERGE_BASE`.
- Coverage: the change adds one condition inside an existing branch; the new row and the unchanged CR-2 rows exercise both outcomes, and [P3-T3] reads line coverage of `.codex/hooks/feature-review-coverage-target.ps1` from the merged coverage report and requires at least 85% with no drop against the cycle 1 final gate figure.
- Mirror parity: the fix edits one `.codex/hooks` file, so [P2-T1] writes the byte-identical bundle copy in the same task and [P3-T4] runs the bundle contract tests; no file is added, so no pack manifest, shared-module name, or `core.json` entry changes, and no execution-environment brief fact changes, so no brief task is needed (the six brief copies stay untouched).
- File size: the hook file is far below the 500-line cap that `legacy-codex-hook-contracts.Tests.ps1` enforces and the test file is far below 800; [P0-T1] and [P2-T1] record physical line counts, and the change stays inside the existing function.
- Test isolation: the new row calls the pure extractor, creates no files, sets no environment variable or global, and changes no location; the gates are one `Invoke-PoshQCParallelTest` run ([P1-T2] fail-before, then [P3-T3] final) and one `pytest -n auto` run ([P3-T4]), each re-run only after a fix; Jest is not in scope.
- CI-only behavior: `poshqc / PowerShell hook suites (Linux)` runs `tests/scripts/codex-hooks` on a case-sensitive file system, so the new row uses forward-slash exact-case literals and the existing `$script:AuditA` fixture with no drive letter; `poshqc / PowerShell QC static` runs `Invoke-PoshQCLeakScan`, which [P3-T2] runs as CI runs it; the Linux job result stays pending-CI for the orchestrator.
- Evidence: the fail-before artifact lands in `<FEATURE>/evidence/regression-testing/`, the baseline reference in `<FEATURE>/evidence/baseline/`, and the format, analyze, leak scan, Pester, pytest, and self-review artifacts in `<FEATURE>/evidence/qa-gates/`; counts and coverage come from JUnit and coverage files of a direct parallel run, not from PoshQC MCP results, and every filename carries the UTC write-time stamp.

### Phase 0 — Baseline Reference

- [ ] [P0-T1] Write `<FEATURE>/evidence/baseline/scope-check.<timestamp>.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`) recording: `MERGE_BASE` from `git merge-base origin/main HEAD`; that `.codex/hooks/feature-review-coverage-target.ps1` and its bundle copy hash equal before any edit; the physical line counts of the hook file and of `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1`; and the cycle 1 reference figures read from the cycle 1 final gate artifacts (pass, fail, and skip counts; repo-wide line coverage; line coverage of `.codex/hooks/feature-review-coverage-target.ps1`). Acceptance: the artifact exists with the four fields and all listed facts; the two hashes are equal; if the hashes differ or a cycle 1 artifact is absent the task stops BLOCKED and no production file is written. No new baseline test run is made: the cycle 1 final gate is the reference.

### Phase 1 — Regression Row (fail first)

- [ ] [P1-T1] Add one row to the `Get-CodexReviewPolicyAuditPath` Describe in `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1`, named `1114: ignores a non-audit path with a .. segment cited beside a valid policy audit`, without editing any existing row. The message is a `policy-audit-path:` line carrying `$script:AuditA`, a line break, then a code-review path under `docs/features/active/2026-11-07-item-a-1114/` with a `..` segment (`../other/code-review.2026-11-07T20-00.md`). It expects `Paths` equal to `@($script:AuditA)` and a null or empty `ReasonCode`. Acceptance: the row exists by name; the diff of the test file against the cycle-start `HEAD`, taken before the task commit, shows added lines only (no removed content line; the file was added on this branch, so a diff against `MERGE_BASE` could not detect an edited existing row); the file stays below 800 lines (physical count recorded).
- [ ] [P1-T2] [expect-fail] Run one `Invoke-PoshQCParallelTest` against the unfixed extractor and write `<FEATURE>/evidence/regression-testing/fail-before.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode:` set to the non-zero `ExitCode` the run returns, and `Output Summary:`. Acceptance: read from the per-shard JUnit files, the summary lists exactly one failing test, the row named in [P1-T1], failing on an outcome assertion (`ReasonCode` of `AUDIT_PATH_TRAVERSAL` and an empty path list, not a missing command), and states that the three existing `AUDIT_PATH_TRAVERSAL` rows pass.

### Phase 2 — Fix

- [ ] [P2-T1] Change `Get-CodexReviewPolicyAuditPath` in `.codex/hooks/feature-review-coverage-target.ps1` per `## Fixed Design`: run the `..` segment check only when the final segment of the examined candidate is `policy-audit.md` or matches `policy-audit.<timestamp>.md`, and update the comment-based help to say so. Copy the file byte-identically to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/feature-review-coverage-target.ps1`. Edit nothing else in the production tree. Acceptance: the two copies have equal SHA-256 hashes; the hook file is at most 500 lines (count recorded); the only command element named `git` still lies inside `Invoke-CodexReviewCoverageGitExe`; no `.py` file is added; the scope diff `git diff --name-only` anchored on `MERGE_BASE` and `HEAD` over `.claude/hooks`, `.claude/lib`, `.codex/config.toml`, and `.codex/hooks/hook-target-worktree.ps1` lists nothing, and `git status --porcelain` is empty after the commit; behavior is proven by the parallel gate in [P3-T3].

### Phase 3 — Final QA and Closure

- [ ] [P3-T1] Run the PoshQC formatter over `.codex/hooks`, `tests/scripts/codex-hooks`, and the edited bundle copy; if it changes a file, re-copy the bundle copy and restart at this task. Write `<FEATURE>/evidence/qa-gates/poshqc-format.<timestamp>.md`. Acceptance: a check-only run after the last write reports zero files that would change (record the count 0), and `git status --porcelain` is empty after committing.
- [ ] [P3-T2] Run a direct `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `.codex/hooks` and `tests/scripts/codex-hooks`, and run `Invoke-PoshQCLeakScan -Root` over the item worktree through the `sh` launcher route as `poshqc / PowerShell QC static` runs it. Write `<FEATURE>/evidence/qa-gates/poshqc-analyze.<timestamp>.md` and `<FEATURE>/evidence/qa-gates/poshqc-leakscan.<timestamp>.md`. Acceptance: zero analyzer findings in the two edited files and none elsewhere that the cycle 1 analyze artifact does not list; the leak scan launcher exits 0 with zero failures; `config/poshqc-leak-allowlist.json` is unchanged (`git status --porcelain` empty for it); a fix restarts at [P3-T1].
- [ ] [P3-T3] Run the final Pester gate: one `Invoke-PoshQCParallelTest` run, and write `<FEATURE>/evidence/qa-gates/pester-parallel.<timestamp>.md`. Acceptance: the returned `ExitCode` is 0; pass, fail, and skip counts and repo-wide line coverage are recorded beside the cycle 1 final gate figures with no new failing test and no repo-wide drop; line coverage of `.codex/hooks/feature-review-coverage-target.ps1` read from `artifacts/pester/powershell-coverage.xml` is at least 85% and at least the cycle 1 figure; the [P1-T1] row, the three `AUDIT_PATH_TRAVERSAL` rows named under `## Existing Tests That Assert the Changed Behavior`, and `legacy-codex-hook-contracts.Tests.ps1` are listed as passing. A fix re-runs the loop from [P3-T1].
- [ ] [P3-T4] Run one `pytest -n auto` run (no coverage, because no Python file is in scope) over `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` through Poetry in module form, and write `<FEATURE>/evidence/qa-gates/pytest-parallel.<timestamp>.md`. Acceptance: exit code 0 with zero failures; `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` and `test_bundled_codex_files_are_listed_in_some_pack_manifest` are each recorded as passed, as in the cycle 1 pytest artifact.
- [ ] [P3-T5] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the diff from `MERGE_BASE` to `HEAD` and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item, including a row for CR-3 citing the [P1-T2], [P3-T3], and [P3-T4] artifacts and a row for the do-not-do boundary (the scope diff of [P2-T1] re-run after the last commit, listing nothing). Acceptance: no FAIL row remains; a FAIL is fixed, the loop re-runs from [P3-T1], and the self-review is rewritten.
