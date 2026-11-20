# 2026-08-28-collect-pr-context-reports-ok-without-writing (Plan)

- **Issue:** #574
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-28T09-31
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug
- **Requirements source:** `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/spec.md` (Status Approved, Version 1.1, Last Updated 2026-08-28T14-05). Under `full-bug` the spec is the sole acceptance-criteria source; `user-story.md` is correctly absent and is not required.
- **Research source:** `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/research/2026-08-28T12-00-collect-pr-context-silent-write-failure-research.md`

**Fail-closed evidence rule:** Every baseline, final-QC, and coverage-comparison artifact named below is mandatory. If any required artifact is missing, or any of its `Timestamp:`, `Command:`, `EXIT_CODE:`, or `Output Summary:` fields is absent or carries a placeholder in place of a numeric coverage value, the verdict is BLOCKED or INCOMPLETE, never PASS.

**Known pre-existing suite failure, bounded exemption.** In this workspace the test `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails before any task of this plan runs. It enumerates every file under the repository `.claude` tree by filesystem walk and requires a bundled counterpart, excluding only `settings.local.json` and the `agent-memory` subtree; it does not consult `.gitignore`. The `PreToolUse` hook `.claude/hooks/enforce-python-batch-budget.ps1` writes `.claude/state/python-batch-budget.default.json`, `.gitignore` line 68 excludes `.claude/state/`, `git ls-files .claude/state/` reports nothing, and the bundled `.claude/state/` directory does not exist. The failure is therefore local to a developer workspace and unrelated to this change, and it is green in CI. Deleting the file is not a remedy: the hook recreates it on the next Python write, which P4-T1 performs before P6-T2, P8-T9, and P8-T10 run, and the deletion would additionally reset that hook's enforcement counter. Exactly one exemption is granted, and only when all three of the following hold, each recorded in the artifact: the failing node ID is exactly the one named above; the run reports exactly one failed test; and the assertion message names a path under `.claude/state/`, in either the backslash or the forward-slash rendering pytest emits. An artifact exercising the exemption records the observed `EXIT_CODE:` verbatim together with `ExpectedExitCode: 1`. A second failing test, a different node ID, or an assertion message naming a path outside `.claude/state/` is a real failure and the exemption does not apply.

**Evidence accounting rule:** Every evidence-producing task names its artifact path. Do not mark an evidence-backed task complete without the artifact on disk. All evidence resolves under `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/` in the `baseline/`, `regression-testing/`, `qa-gates/`, and `other/` subtrees. No evidence is written under `artifacts/`. The Python coverage JSON reports written under `artifacts/python/` are tool output read by the evidence artifacts, not evidence artifacts themselves.

**Timestamp convention:** `TIMESTAMP` in an artifact filename means the ISO-8601 `yyyy-MM-ddTHH-mm` value of the run that produced it, for example `2026-08-28T14-05`.

**Working directories:** every `npm` command runs with the working directory `extensions/drm-copilot`. Every `poetry` and `git` command runs with the working directory at the repository root.

**Python coverage-reading convention.** A pytest run using `--cov-report=term-missing` together with `--cov-branch` prints a single combined `Cover` column. It does not print a separate line percentage and a separate branch percentage, so neither value can be read off the terminal table. Every Python coverage artifact named in this plan therefore records, for each named file row and for the `TOTAL` row, the four raw integer columns `Stmts`, `Miss`, `Branch`, and `BrPart` verbatim, together with the printed `Cover` value. Line coverage IS derivable from the printed columns as `(Stmts - Miss) / Stmts`, stated to one decimal place with the arithmetic shown; that expression equals coverage.py's `percent_statements_covered` exactly. Branch coverage is NOT derivable from the printed columns. `BrPart` is the count of branch statements that ran but did not take every exit, not the count of missing branch exits: a branch statement that never ran contributes 0 to `BrPart` while leaving all of its exits uncovered, and a statement with three exits and one taken contributes 1 while leaving two uncovered. `(Branch - BrPart) / Branch` therefore overstates branch coverage, and overstates it by more as coverage falls. Measured on this branch, `scripts/dev_tools/pr_context/summary_helpers.py` under the full suite prints `Stmts` 154, `Miss` 14, `Branch` 70, `BrPart` 9, `Cover` 88 percent, from which that expression yields 87.1 while the true branch coverage is 81.4; under a single test file it yields 80.0 while the truth is 31.4. A further measured run of the same summary-helpers module printed `Branch` 70 and `BrPart` 17, from which the discarded expression yields 75.7 against a true `percent_branches_covered` of 61.4, so a threshold of 75 applied to the derived value would have passed a value that genuinely fails by 13.6 points.

Every Python coverage command in this plan therefore adds a JSON reporter alongside the terminal reporter, and every Python branch and line percent this plan asserts is read from that JSON, never derived from the terminal columns. The run-level values are the `percent_statements_covered` and `percent_branches_covered` keys of the JSON's `totals` object, which carries both keys directly. The per-file values are those same two keys inside the `summary` object of that file's entry under `files`, and not on the entry itself: an entry under `files` carries only the keys `classes`, `excluded_lines`, `executed_branches`, `executed_lines`, `functions`, `missing_branches`, `missing_lines`, and `summary`, so neither percent key can be read from the entry directly. Those two values, read from `totals` for a run-level figure and from a file entry's `summary` object for a per-file figure, are the line percent and the branch percent this plan means wherever it names them. The combined `percent_covered` key is neither of them and is never read for a threshold. Each JSON is written under `artifacts/python/`, which `.gitignore` excludes, so it enters neither the P7-T1 scope union nor the P7-T2 file-size gate. Each command writes its own JSON filename, because a shared filename would let a later run overwrite an earlier run's data before it is read. Every Python coverage artifact records the raw columns verbatim alongside the two JSON values. When a row's `Branch` value is 0, the artifact records the phrase no branches measured in place of a branch percent value. The TypeScript side is unaffected: the Jest text reporter prints separate columns for branch and line coverage, and those values are read directly.

**Note on the spec's TypeScript coverage command.** Spec acceptance criterion 18 names `npm run test:coverage -- --coverageReporters=text` run from `extensions/drm-copilot`, which is exactly what this plan states. Plan and spec agree, and no correction is carried. The reason the extension-scoped invocation is the required one is that the per-file `coverageThreshold` gate lives exclusively in `extensions/drm-copilot/jest.config.cjs`; the repository-root `jest.config.cjs` declares no `coverageThreshold` map at all, so a root-level coverage run could never fail on the per-file entries this fix adds.

**Correction to the spec's Python coverage command, carried deliberately.** Spec acceptance criterion 23 names `poetry run pytest --cov --cov-branch --cov-report=term-missing`. A bare `--cov` immediately followed by another flag is read by the plan acceptance gate as taking that flag as its value. The identical invocation is stated here with the bare `--cov` placed last, which changes nothing about what pytest-cov measures.

## Scope of the diff

The committed diff writes exactly these repo-relative paths and no others.

Production, TypeScript:
1. `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts`
2. `extensions/drm-copilot/src/lib/pr-context/collector-output.ts`
3. `extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts`

Production, Python:
4. `scripts/dev_tools/pr_context/collector.py`
5. `scripts/dev_tools/pr_context/summary_helpers.py`
6. `scripts/dev_tools/pr_context/collector_documents.py` (new)

Configuration:
7. `extensions/drm-copilot/jest.config.cjs`

Documentation, six copies:
8. `.claude/skills/pr-context-artifacts/SKILL.md`
9. `.github/skills/pr-context-artifacts/SKILL.md`
10. `.agents/skills/pr-context-artifacts/SKILL.md`
11. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-context-artifacts/SKILL.md`
12. `extensions/drm-copilot/resources/customizations/.github/skills/pr-context-artifacts/SKILL.md`
13. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/SKILL.md`

Tests, TypeScript:
14. `extensions/drm-copilot/test/lib/pr-context/tree-file-system.ts`
15. `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts`
16. `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts`
17. `extensions/drm-copilot/test/lib/pr-context/collector-output-freshness.test.ts` (new)
18. `extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts`
19. `extensions/drm-copilot/test/lib/pr-context/summary-helpers.test.ts`
20. `extensions/drm-copilot/test/extension.collect-pr-context.test.ts`
21. `extensions/drm-copilot/test/extension.integration.test.ts`
22. `extensions/drm-copilot/test/repo-automation-dispatch.test.ts`
23. `extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts` (new)

Tests, Python:
24. `tests/scripts/dev_tools/test_pr_context_freshness.py` (new)

Evidence, feature-owned:
25. `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/**`

Requirements and planning documents, already present in the worktree and untracked at plan time:
26. `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/issue.md`
27. `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/spec.md`
28. `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/plan.2026-08-28T09-31.md`
29. `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/research/2026-08-28T12-00-collect-pr-context-silent-write-failure-research.md`

Explicitly not written by this diff: `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `extensions/drm-copilot/test/mcp-server.test.ts` (its collect-pr-context cases mock the service and already assert the workspace-joined pair), and the output-path resolution in `scripts/dev_tools/pr_context/collector.py`.

Out of scope and not attempted: the `render.ts` degraded-artifact catch-all surfacing through the MCP `warnings` array; the GitHub CLI being unavailable to the MCP server process; the absent `quality-tiers.yml`; any hook change; a general cross-runtime parity harness beyond the single literal assertion in P4-T5.

## Fixed literals this plan introduces

The executor writes these exact strings; they are quoted here so acceptance conditions that name them are exonerated as literals the plan instructs the executor to create.

- Section title, reused unchanged in both runtimes: `Context generated`
- Head-SHA label line prefix, both runtimes: `Head SHA:`
- Unknown-value token when the collected context carries no head SHA, matching the existing convention: `(unknown)`
- Level-3 heading added to each of the six skill copies: Freshness Cross-Check

### Phase 0 — Policy Reads and Baseline Capture

Baseline capture precedes every source edit. Both write-mode formatter tasks in this phase record the working-tree state immediately before and immediately after the run, so that drift the formatter repaired here is visible and is not silently credited to the final QC loop.

- [x] [P0-T1] Read the repository policy files in the canonical order and record the read.
  - Read, in this order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/plan-acceptance-gates.md`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/phase0-instructions-read.TIMESTAMP.md` exists and carries `Timestamp:`, `Policy Order:`, and the explicit list of the nine files read, each as a repo-relative path.

- [x] [P0-T2] Read the requirements and research inputs and record the read.
  - Read `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/issue.md`, `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/spec.md`, and `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/research/2026-08-28T12-00-collect-pr-context-silent-write-failure-research.md`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/phase0-requirements-read.TIMESTAMP.md` exists, records the three paths, records that the persisted work mode read from `issue.md` is full-bug, and records the count of acceptance criteria found in the spec's `## Acceptance Criteria` section as the integer 23.

- [x] [P0-T3] Record the branch and base-commit baseline.
  - Run `git rev-parse --abbrev-ref HEAD`, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git status --porcelain`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/git-baseline.TIMESTAMP.md` records all four commands with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, the branch name is `bug/collect-pr-context-reports-ok-without-writing-574`, and both resolved SHAs are recorded verbatim as forty-character values.

- [x] [P0-T4] Capture the TypeScript formatter baseline with a before-and-after tree observation.
  - Run `git status --porcelain`, then `npm run format`, then `git status --porcelain` again.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/ts-format.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying both porcelain listings verbatim plus the explicit list of tracked files the run rewrote. When the two listings are identical the summary states that the run left every matched file unchanged; when they differ the summary names each rewritten file. If the two listings differ, the run repaired pre-existing drift. Revert every rewritten file that is not in the "Scope of the diff" enumeration with git checkout -- and record both the rewritten list and the revert in the artifact; do not carry unrelated formatting into this change set.

- [x] [P0-T5] Capture the TypeScript lint baseline.
  - Run `npm run lint`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/ts-lint.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the integer error count and the integer warning count reported by the run. A clean run of this command prints no summary line at all; record empty output plus exit code 0 as the counts 0 and 0, and quote the output verbatim when it is non-empty.

- [x] [P0-T6] Capture the TypeScript type-check baseline.
  - Run `npm run typecheck`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/ts-typecheck.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the integer diagnostic count reported by the run. A clean run of this command prints no summary line at all; record empty output plus exit code 0 as the counts 0 and 0, and quote the output verbatim when it is non-empty.

- [x] [P0-T7] Capture the TypeScript unit-test baseline.
  - Run `npm run test:unit`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/ts-test-unit.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the passed, failed, and total test counts and the suite count reported by the run.

- [x] [P0-T8] Capture the TypeScript coverage baseline including per-file rows for the three production files in scope.
  - Run `npm run test:coverage -- --coverageReporters=text`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/ts-coverage.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the numeric overall statement, branch, function, and line percentages printed by the run, plus the numeric per-file row printed for each of `src/lib/pr-context/pr-context-service-call.ts`, `src/lib/pr-context/collector-output.ts`, and `src/lib/pr-context/summary-helpers.ts`. Placeholder values are not acceptable.

- [x] [P0-T9] Capture the Python formatter baseline with a before-and-after tree observation.
  - Run `git status --porcelain`, then `poetry run black .`, then `git status --porcelain` again.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/py-black.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying both porcelain listings verbatim plus the integer count of files the run reformatted and the integer count it left unchanged. If the two listings differ, the run repaired pre-existing drift. Revert every rewritten file that is not in the "Scope of the diff" enumeration with git checkout -- and record both the rewritten list and the revert in the artifact; do not carry unrelated formatting into this change set.

- [x] [P0-T10] Capture the Python lint baseline.
  - Run `poetry run ruff check .`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/py-ruff.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording verbatim the final line the run printed — `All checks passed!` on a clean run, otherwise the `Found N errors.` line — together with the integer diagnostic count that line reports. This repository's Ruff configuration sets no `fix` key, so `ruff check .` never rewrites a file and prints no fixed-file count; do not record one.

- [x] [P0-T11] Capture the Python type-check baseline.
  - Run `poetry run pyright`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/py-pyright.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the integer error, warning, and information counts reported by the run.

- [x] [P0-T12] Capture the repository-wide Python coverage baseline.
  - Run `poetry run pytest --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p0t12.json --cov`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/py-pytest-coverage.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the passed and failed test counts, the node ID of every failed test so the bounded exemption stated at the head of this plan is anchored in baseline evidence, and, for the `TOTAL` row of the terminal coverage table, the `Stmts`, `Miss`, `Branch`, `BrPart`, and `Cover` values recorded verbatim together with the `percent_statements_covered` and `percent_branches_covered` values read from the `totals` object of `artifacts/python/cov-p0t12.json`, per the Python coverage-reading convention stated at the head of this plan. Placeholder values are not acceptable.

- [x] [P0-T13] Capture the targeted Python coverage baseline for the two pr-context modules named by the spec.
  - Run `poetry run pytest --cov=scripts.dev_tools.pr_context.collector --cov=scripts.dev_tools.pr_context.summary_helpers --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p0t13.json`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/py-pr-context-coverage.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying, for the row printed for `scripts/dev_tools/pr_context/collector.py` and for the row printed for `scripts/dev_tools/pr_context/summary_helpers.py`, the `Stmts`, `Miss`, `Branch`, `BrPart`, and `Cover` values recorded verbatim together with the `percent_statements_covered` and `percent_branches_covered` values read from the `summary` object of that file's entry under `files` in `artifacts/python/cov-p0t13.json`, per the Python coverage-reading convention stated at the head of this plan. Placeholder values are not acceptable.

- [x] [P0-T14] Capture the baseline line count of every production and test file this diff will write.
  - Write into `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/scope-files.txt`, one repo-relative path per line, the twenty paths drawn from items 1 through 24 of the "Scope of the diff" enumeration that exist at baseline. Items 6, 17, 23, and 24 are the four paths marked new; they do not yet exist and are omitted.
  - Run `pwsh -NoProfile -Command "Get-Content docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/scope-files.txt | ForEach-Object { [pscustomobject]@{ Path = $_; Lines = (Get-Content -LiteralPath $_).Count } }"`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/file-line-counts.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` listing every path with its integer line count, and explicitly records that `scripts/dev_tools/pr_context/collector.py` exceeds the 500-line limit at baseline. That pre-existing overage is what P4-T1 repairs.

- [x] [P0-T15] Verify the Python batch-budget hook allows the three production Python files this plan writes.
  - Read `.claude/state/python-batch-budget.default.json`. The `PreToolUse` hook `.claude/hooks/enforce-python-batch-budget.ps1` is registered on matcher `Write|Edit` and denies a Write or Edit of a distinct production `.py` path once `prodFiles` holds `prodCap` entries. Classification is textual: only a path matching `(^|/)tests/.*\.py$` or `(^|/)test_[^/]+\.py$` counts as a test file, and every other `.py` path counts as production. `CLAUDE_SESSION_ID` is unset in this workspace, so the session id resolves to `default` and entries left by any earlier agent count against this plan.
  - Run `pwsh -NoProfile -Command "Get-Content -LiteralPath .claude/state/python-batch-budget.default.json"`.
  - This plan writes three distinct production Python paths — `scripts/dev_tools/pr_context/collector_documents.py`, `scripts/dev_tools/pr_context/collector.py`, and `scripts/dev_tools/pr_context/summary_helpers.py` — and one test path, `tests/scripts/dev_tools/test_pr_context_freshness.py`. A path already listed in `prodFiles` is free; each of the three that is absent consumes one slot.
  - When the free-slot count is smaller than the absent-path count, the operator clears the shortfall before [P0-T1] runs, by removing the stale entries from the `prodFiles` array in place and leaving the file present on disk. Deleting the file is not an acceptable remedy here: the file is enumerated by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, so its absence makes the P0-T12 and P0-T13 baselines record zero failed tests, and P4-T1 then recreates it so that P6-T2, P8-T9, and P8-T10 fail against a baseline that recorded no such failure. That would destroy the anchoring the node-ID requirement in P0-T12 exists to provide. The executor does not perform this remedy; it is an operator precondition.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/python-batch-budget.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying `prodCap`, `testCap`, the `prodFiles` and `testFiles` lists verbatim, the integer count of the three production paths above that are absent from `prodFiles`, and the integer count of free production slots, which is `prodCap` minus the length of `prodFiles`. The free-slot count must be greater than or equal to the absent-path count. A smaller free-slot count is a failure of this task, not a note.

### Phase 1 — Fail-First Regression Evidence

Both tasks in this phase add an assertion that the current code cannot satisfy, and run only the single test file that carries it. No whole-suite run occurs between this phase and P2-T5, so no gate in between is made unsatisfiable by the deliberately failing cases.

- [x] [P1-T1] Record every written path on the in-memory filesystem double so a set-equality assertion is expressible.
  - Edit `extensions/drm-copilot/test/lib/pr-context/tree-file-system.ts` to add a public readonly array field that `writeTextFile` appends its `path` argument to on every call, in call order, without changing any existing method's behaviour or signature.
  - Acceptance: `npm run test:unit -- test/lib/pr-context` exits 0, proving the recorder is additive and broke no existing pr-context test.

- [x] [P1-T2] [expect-fail] Add the service-seam path-identity test and record its failure.
  - Add a named test to `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts` that invokes `collectPrContextServiceCall` with the in-memory filesystem and a fixed workspace root, then asserts one equality between the sorted array of paths recorded by the P1-T1 recorder and the sorted `artifacts` array of the returned record, and asserts that this single value equals the sorted workspace-joined summary and appendix pair. Two independent literal assertions are not acceptable; the assertion must be the set equality itself.
  - Run `npm run test:unit -- test/lib/pr-context/pr-context-service-call.test.ts`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/regression-testing/fail-first-service-seam.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 1, `ExpectedExitCode: 1`, and an `Output Summary:` naming the new test and quoting the reported difference between the written set and the reported set.

- [x] [P1-T3] [expect-fail] Add the node:fs boundary path-identity test and record its failure.
  - Add a named test to `extensions/drm-copilot/test/extension.collect-pr-context.test.ts` that asserts the recorded `node:fs` write arguments for a collect-pr-context invocation are exactly the two workspace-joined artifact paths, and that no recorded write argument is a repository-relative path.
  - Run `npm run test:unit -- test/extension.collect-pr-context.test.ts`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/regression-testing/fail-first-nodefs-boundary.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 1, `ExpectedExitCode: 1`, and an `Output Summary:` naming the new test and quoting the recorded write arguments that failed the assertion.

### Phase 2 — Path Identity and Read-Back Verification at the Service Seam

- [x] [P2-T1] Compute each absolute output path once in the service call and use that one value for both the write and the report.
  - Edit `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts` so that each repo-relative constant is joined to `input.workspaceRoot` and passed through `normalizeGeneratedPath` exactly once, producing two local variables that already carry the normalized forward-slash form. Those same two variables are the values passed to `collectAndWrite` as the summary and appendix output paths, the values read back in P2-T3, the values the two collector log lines carry, and the entries of the returned `artifacts` array, with no further joining or normalizing anywhere in the file. Normalizing before the write rather than after it is required, not stylistic: `join` emits backslash separators on Windows, so a write that used the raw joined value while the report used the normalized value would remain two different strings and the P1-T2 set-equality assertion would fail on Windows. Node accepts forward-slash separators on Windows, so the write is unaffected.
  - Acceptance: the file contains exactly two `join` call sites and exactly two `normalizeGeneratedPath` call sites, each applied to its value before that value is used for anything; the returned `artifacts` array references the two local variables directly rather than re-joining or re-normalizing the constants; `npm run typecheck` exits 0.

- [x] [P2-T2] Return the two rendered strings from the collector write entry point.
  - Edit `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` so that `collectAndWrite` returns an object carrying the rendered summary text and the rendered appendix text instead of returning void. Write ordering stays summary first then appendix, and no root-joining logic is introduced into `collectAndWrite` or `writeOutput`.
  - Acceptance: `npm run typecheck` exits 0 and `npm run test:unit -- test/lib/pr-context/collector-output.test.ts` exits 0.

- [x] [P2-T3] Verify both writes by reading each file back through the injected filesystem.
  - Edit `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts` so that, after `collectAndWrite` returns and before the result record is built, each of the two absolute paths is read back through `input.fileSystem` and compared to the corresponding string that this invocation rendered. A read that throws, or content that differs, raises an error whose message names the offending absolute artifact path. This is a read-back comparison against the rendered text; an existence check is not acceptable, because a stale file satisfies it and that is the defect under repair.
  - Acceptance: `npm run typecheck` exits 0, and the file contains no call to the filesystem existence predicate on either output path.

- [x] [P2-T4] Correct the two pre-existing service-call assertions that pin the defective behaviour.
  - Edit `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts` so that the existing write assertion names the workspace-joined pair rather than the repository-relative pair, its stale comment is corrected, and the existing log-line assertion expects the two collector log lines to carry the absolute workspace-joined artifact paths.
  - Acceptance: the assertion that previously named a repository-relative key now names an absolute path, and no assertion in the file expects a repository-relative artifact path.

- [x] [P2-T5] Record pass-after evidence for both fail-first tests.
  - Run `npm run test:unit -- test/lib/pr-context/pr-context-service-call.test.ts test/extension.collect-pr-context.test.ts`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/regression-testing/pass-after-path-identity.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` naming both tests added in P1-T2 and P1-T3 and recording the passed and failed counts for the two files.

### Phase 3 — Freshness Marker, TypeScript

- [x] [P3-T1] Extend the generation-timestamp helper to carry the head SHA.
  - Edit `extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts` so the generation-timestamp helper accepts the head SHA in addition to the injected clock and emits, after the timestamp line, a line whose prefix is the literal `Head SHA:` followed by the SHA. When no head SHA is available the line renders the literal `(unknown)` in place of the SHA. The existing section title `Context generated` is reused unchanged, and the clock stays injected. The head-SHA parameter is declared optional with a default, so the single production call site at extensions/drm-copilot/src/lib/pr-context/collector-output.ts line 286 continues to compile unchanged and this task's type-check acceptance is reachable before P3-T2 updates that call site.
  - Acceptance: `npm run typecheck` exits 0 and the file stays at or under 500 lines.

- [x] [P3-T2] Render one shared generated-context section first in both documents from a single timestamp.
  - Edit `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` so that `collectAndWrite` renders the generated-context section exactly once per invocation and passes that same string to both builders; `buildSummaryText` gains the parameters it needs to place that section as the first entry of the summary sections, ahead of the GitHub CLI status section; and `buildAppendixText` places the same string first, replacing its current timestamp-only section. The head SHA supplied is the one already on the collected record, so no new git call is made.
  - Acceptance: `npm run typecheck` exits 0, the file stays at or under 500 lines, and the summary and appendix builders receive the identical rendered section string rather than each calling the clock.

- [x] [P3-T3] Update the generation-timestamp helper test for the new signature and the head-SHA line.
  - Edit `extensions/drm-copilot/test/lib/pr-context/summary-helpers.test.ts` so the existing deterministic-clock test passes the new head-SHA input and additionally asserts the rendered head-SHA line for a concrete forty-character fixture SHA supplied by the test.
  - Acceptance: `npm run test:unit -- test/lib/pr-context/summary-helpers.test.ts` exits 0.

- [x] [P3-T4] Extend the summary section-ordering assertion to place the generated-context section first.
  - Edit `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` so the ordering array in the canonical-section-order test begins with the generated-context section banner and every section entry it already asserted stays present in its existing relative order.
  - Acceptance: `npm run test:unit -- test/lib/pr-context/collector-output.test.ts` exits 0, and the ordering array contains one more entry than it did at baseline with all previous entries retained in the same relative order.

- [x] [P3-T5] Add the freshness-header tests for both rendered documents.
  - Create `extensions/drm-copilot/test/lib/pr-context/collector-output-freshness.test.ts` carrying three named tests: one that, with a fixed injected clock and a fixed head SHA, asserts the first section of the rendered summary text and the first section of the rendered appendix text are both the generated-context section and that the timestamp line extracted from each text is byte-identical; one that asserts both rendered texts contain the head-SHA line built from a concrete forty-character fixture SHA supplied by the test; and one that asserts the head-SHA line renders the unknown token when the collected context carries no head SHA and that no error is raised in that case.
  - Acceptance: `npm run test:unit -- test/lib/pr-context/collector-output-freshness.test.ts` exits 0 with three passing tests, and the new file is at or under 500 lines.

- [x] [P3-T6] Update the two integration suites that observe the rendered artifact text and the written paths.
  - Edit `extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts` and `extensions/drm-copilot/test/extension.integration.test.ts` so every assertion that names a repository-relative artifact key names the workspace-joined path instead, and every assertion that observes the rendered summary or appendix accommodates the new leading generated-context section without deleting an assertion it previously carried.
  - Acceptance: `npm run test:unit -- test/lib/pr-context/collector-integration.test.ts test/extension.integration.test.ts` exits 0, and neither file retains an assertion expecting a repository-relative artifact path.

### Phase 4 — Freshness Marker and Module-Size Compliance, Python

- [x] [P4-T1] Extract the two document-assembly blocks out of the collector so the module returns to the 500-line limit.
  - Create `scripts/dev_tools/pr_context/collector_documents.py` holding the summary-document assembly and the appendix-document assembly currently inlined in `collect_and_write`, exposed as two module-level functions, together with the two character-budget constants those blocks truncate against, and together with `_render_verification_evidence_section` (`collector.py` lines 115-170) and the feature-summary assembly (`collector.py` lines 409-423), which the summary builder consumes. Moving the two assembly blocks alone is not sufficient: they span 123 lines while their two call sites cost roughly 29, so the module would land near 519 lines. Should the module still exceed 500 after these moves, continue relocating adjacent summary-preparation blocks in this order until it does not — the changed-file bucketing (lines 374-384), the scoping-summary assembly (lines 386-404), then the digest joins (lines 406-407) — and record in the size artifact which blocks were moved. Edit `scripts/dev_tools/pr_context/collector.py` to call the two new functions, to re-export both the two budget constants and `_render_verification_evidence_section` so existing importers are unaffected, and to keep `write_output`, `collect_and_write`, `parse_args`, `main`, the module entry-point guard, and the two output-path defaults exactly where they are. The re-export of `_render_verification_evidence_section` is required, not tidiness: `tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py` imports that name directly from `scripts.dev_tools.pr_context.collector`, and that file records in its own docstring that it reaches the private symbol deliberately rather than through a public wrapper. Moving the function without the re-export leaves a dangling import. The output-path resolution is not changed: the assignment of the summary path directly from the supplied output argument stays as written.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_pr_context_integration.py tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_collect_pr_context_part2.py tests/scripts/dev_tools/test_collect_pr_context_part3.py tests/scripts/dev_tools/test_collect_pr_context_part4.py tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py` exits 0, and `pwsh -NoProfile -Command "(Get-Content -LiteralPath scripts/dev_tools/pr_context/collector.py).Count"` prints an integer at or below 500 recorded in `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/collector-size.TIMESTAMP.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P4-T2] Mirror the head-SHA extension in the Python generation-timestamp helper.
  - Edit `scripts/dev_tools/pr_context/summary_helpers.py` so the generation-timestamp helper accepts the head SHA and emits the same head-SHA line shape as the TypeScript helper, reusing the section title `Context generated`, rendering the literal `(unknown)` when no SHA is available. The helper takes no clock parameter; that pre-existing divergence from the TypeScript helper is deliberate and must not be corrected in either direction. The head-SHA parameter is declared optional with a default of None, so the single production call site at scripts/dev_tools/pr_context/collector.py line 544 continues to pass Pyright unchanged and this task's type-check acceptance is reachable before P4-T3 updates that call site.
  - Acceptance: `poetry run pyright` exits 0 and the file stays at or under 500 lines.

- [x] [P4-T3] Render one shared generated-context section first in both Python documents.
  - Edit `scripts/dev_tools/pr_context/collector.py` and `scripts/dev_tools/pr_context/collector_documents.py` so the generated-context section is rendered once per invocation with the head SHA from the collected context result, passed to both document builders, placed as the first entry of the summary sections ahead of the GitHub CLI status section and as the first entry of the appendix parts.
  - Acceptance: `poetry run pyright` exits 0 and both files stay at or under 500 lines.

- [x] [P4-T4] Add the Python freshness-header tests.
  - Create `tests/scripts/dev_tools/test_pr_context_freshness.py` carrying two named tests: one that invokes the Python collect-and-write entry point with a stubbed runner and an in-memory write seam and asserts that the summary text and the appendix text it writes each open with the generated-context section and that the generated-context block is byte-identical between the two texts; and one that asserts the Python-rendered head-SHA line for a concrete forty-character fixture SHA equals the expected concrete line and that the unknown token renders when no SHA is supplied. No temporary file is created by either test.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_pr_context_freshness.py` exits 0 with at least two passing tests.

- [x] [P4-T5] Add the narrow cross-runtime literal parity test.
  - Add a third named test to `tests/scripts/dev_tools/test_pr_context_freshness.py` that reads the source text of `extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts` and asserts that the generated-context section title literal and the head-SHA label literal it contains are equal to the corresponding literals used by `scripts/dev_tools/pr_context/summary_helpers.py`. The test spawns no process and adds no harness beyond this comparison.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_pr_context_freshness.py` exits 0 with at least three passing tests, and the file is at or under 500 lines.

- [x] [P4-T6] Drive the Python pr-context suite to a clean run after the header change.
  - Run `poetry run pytest tests/scripts/dev_tools/test_pr_context_integration.py tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_collect_pr_context_part2.py tests/scripts/dev_tools/test_collect_pr_context_part3.py tests/scripts/dev_tools/test_collect_pr_context_part4.py tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py tests/scripts/dev_tools/test_pr_context_freshness.py`. Correct any assertion superseded by the new leading section in the file that carries it, without deleting an assertion that was checking something else, and rerun until the command exits 0.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/regression-testing/py-pr-context-suite.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the passed and failed counts and naming every test file the task edited, or stating that no file needed an edit.

### Phase 5 — Verification Tests and Coverage Configuration

- [x] [P5-T1] Add the three read-back negative tests at the service seam.
  - Add three named tests to `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts`, each using an in-memory filesystem and no temporary file: one injecting a filesystem whose write method accepts the call and discards the content, asserting the service call raises; one that pre-seeds both target paths with prior-invocation content, injects the same discarding write, and asserts the service call raises, which is the scenario an existence-only check would pass; and one in which the summary write succeeds and the appendix write fails, asserting the service call raises and the raised message names the appendix artifact path.
  - Prove the verification is what makes those tests pass, by mutation. Temporarily remove the read-back verification added in P2-T3 from `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts`, run `npm run test:unit -- test/lib/pr-context/pr-context-service-call.test.ts` and record that failing run; then restore the verification exactly as P2-T3 left it, run the same command again, and record that passing run.
  - Acceptance: `npm run test:unit -- test/lib/pr-context/pr-context-service-call.test.ts` exits 0 with the verification in place; `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/regression-testing/readback-mutation-check.TIMESTAMP.md` records the removed-verification run with `Timestamp:`, `Command:`, `EXIT_CODE:` 1, `ExpectedExitCode: 1`, and an `Output Summary:` naming the two tests that failed while the verification was absent; and `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/regression-testing/readback-mutation-check-restored.TIMESTAMP.md` records the restored run with `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` recording the passed and failed counts. The two runs are recorded in two artifacts rather than one because a single evidence artifact carries exactly one `ExpectedExitCode` value, and these two runs declare different expectations.

- [x] [P5-T2] Add the degradation-is-not-failure test.
  - Add a named test to `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts` asserting that when the GitHub CLI is reported unavailable, both artifacts are still written and the service call returns successfully.
  - Acceptance: `npm run test:unit -- test/lib/pr-context/pr-context-service-call.test.ts` exits 0, and the file is at or under 500 lines.

- [x] [P5-T3] Correct the dispatch-level test that encodes the defect.
  - Edit `extensions/drm-copilot/test/repo-automation-dispatch.test.ts` so the assertion that today names a repository-relative write key and the assertion that names the workspace-joined reported path both name the same workspace-joined pair.
  - Acceptance: `npm run test:unit -- test/repo-automation-dispatch.test.ts` exits 0, the file retains both assertions rather than deleting one, and the file is at or under 500 lines.

- [x] [P5-T4] Add the tool-dispatch boundary contract tests.
  - Create `extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts` carrying two named tests: one asserting that when the service call raises, the tool result carries an `ok` value of false and the failure text appears in the result record; and one asserting that a successful invocation returns an `ok` value of true and an `artifacts` array whose two entries are equal to the two paths written during that same test run. Neither test invokes the live MCP tool; both exercise the in-process dispatch path against this branch's source.
  - Acceptance: `npm run test:unit -- test/repo-automation-dispatch-pr-context-verification.test.ts` exits 0 with two passing tests, and the new file is at or under 500 lines.

- [x] [P5-T5] Add the per-file coverage thresholds for the three touched production modules and prove the gate runs.
  - Edit `extensions/drm-copilot/jest.config.cjs` to add three entries to the existing `coverageThreshold` map, keyed `./src/lib/pr-context/pr-context-service-call.ts`, `./src/lib/pr-context/collector-output.ts`, and `./src/lib/pr-context/summary-helpers.ts`, each specifying 85 lines and 75 branches, matching every existing entry in that map. Add no `global` key.
  - Run `npm run test:coverage -- --coverageReporters=text`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/ts-coverage-thresholds.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the numeric per-file line and branch percentages printed for each of the three files and stating that the run reported no coverage threshold failure. Placeholder values are not acceptable.

### Phase 6 — Consumer Documentation Across the Six Skill Copies

- [x] [P6-T1] Document the two-step freshness cross-check in the three self-hosted skill copies.
  - Edit `.claude/skills/pr-context-artifacts/SKILL.md`, `.github/skills/pr-context-artifacts/SKILL.md`, and `.agents/skills/pr-context-artifacts/SKILL.md` so each gains, inside its refresh rule, a level-3 heading whose text is Freshness Cross-Check, stating the two-step check: pair identity, meaning the generated-context timestamp is byte-identical in the summary and the appendix; and head binding, meaning the head SHA recorded in both files equals the current head of the branch under review. The section states explicitly that file existence and file modification time are not freshness signals.
  - Acceptance: all three files carry the heading and both steps, and the wording added is identical across the three copies.

- [x] [P6-T2] Mirror the same edit byte-identically into the three bundled skill copies.
  - Edit `extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-context-artifacts/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/pr-context-artifacts/SKILL.md`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/SKILL.md` so each bundled copy is byte-identical to its self-hosted counterpart after the P6-T1 edit.
  - Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`.
  - Acceptance: the command above runs, and `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/push-down-parity.TIMESTAMP.md` records `Timestamp:`, `Command:`, the observed `EXIT_CODE:`, and an `Output Summary:` carrying the passed and failed counts, the node ID of every failed test, and the assertion message of every failed test. The task passes when the run exits 0, or when it exits 1 and satisfies every condition of the bounded exemption stated at the head of this plan, in which case the artifact also carries `ExpectedExitCode: 1`.

- [x] [P6-T3] Prove all six copies carry the cross-check.
  - Run `git grep -F -l "Freshness Cross-Check" -- .claude/skills/pr-context-artifacts/SKILL.md .github/skills/pr-context-artifacts/SKILL.md .agents/skills/pr-context-artifacts/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-context-artifacts/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/pr-context-artifacts/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/SKILL.md`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/skill-copies-cross-check.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` listing exactly six paths, one per copy.

### Phase 7 — Scope Invariants and File-Size Compliance

- [x] [P7-T1] Produce the authoritative list of files this change writes.
  - Run `git diff --name-only origin/main...HEAD`, then `git status --porcelain --untracked-files=all`, and write the union of the reported paths to `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/changed-files.txt`, one repo-relative path per line. The two commands are complementary and neither alone is sufficient: the anchored name listing enumerates committed changes and is blind to a file that is not yet tracked, and the porcelain listing enumerates the working tree and goes empty once every change is committed. The union is complete in either state. The --untracked-files=all form is mandatory: the default porcelain form collapses an untracked directory into a single entry ending in a slash, which is not a file, produces no line count in P7-T2, and matches no entry in the Scope enumeration.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/changed-files.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` reproducing both command outputs verbatim and the derived union, the union is non-empty, and every path in the union appears in the "Scope of the diff" enumeration at the head of this plan.

- [x] [P7-T2] Prove every non-Markdown file this change writes is at or under 500 lines.
  - Run `pwsh -NoProfile -Command "Get-Content docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/changed-files.txt | Where-Object { $_ -notlike '*.md' } | ForEach-Object { [pscustomobject]@{ Path = $_; Lines = (Get-Content -LiteralPath $_).Count } } | Sort-Object Lines -Descending"`.
  - Run `pwsh -NoProfile -Command "Get-Content docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/changed-files.txt | Where-Object { $_ -like '*.md' } | ForEach-Object { [pscustomobject]@{ Path = $_; Lines = (Get-Content -LiteralPath $_).Count } } | Sort-Object Lines -Descending"`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/file-size-compliance.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` for both runs. The first run's summary lists every non-Markdown path with its integer count and its largest recorded line count is at most 500. The second run's Markdown line counts are recorded as information only and are not subject to the limit: `.claude/rules/general-code-change.md` exempts Markdown documentation files from the 500-line limit, and a verbatim coverage-table transcript in an evidence file must not fail this gate for a reason unrelated to the fix.

- [x] [P7-T3] Prove the two scope exclusions held.
  - Run `git grep -F "summary_path = out" -- scripts/dev_tools/pr_context/collector.py` and confirm it reports the line, proving the Python output-path resolution was not converted into a repository-root join.
  - Run `git diff --name-only origin/main...HEAD` and `git status --porcelain --untracked-files=all` and confirm that the union of the two outputs, which is the same union P7-T1 derived, reports neither `.claude/hooks/enforce-pr-author-skill.ps1` nor `.claude/hooks/enforce-pr-author-skill-helpers.ps1`. The porcelain span is what makes the check non-vacuous before the change is committed; the anchored name listing is what makes it non-vacuous after.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/scope-invariants.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` for all three commands, quotes the matched collector line verbatim, records the non-empty union derived from the two listing commands, and states that neither hook path appears in that union.

### Phase 8 — Final QC Loop, TypeScript and Python

Run every task in this phase unconditionally. If any task fails, or any write-mode task rewrites a tracked file, restart this phase from P8-T1 and rerun every task in order until one uninterrupted pass completes with all tasks exiting 0 and no file rewritten. The single exception is the bounded exemption stated at the head of this plan: a P8-T9 or P8-T10 run that exits 1 with exactly that one failure, recorded to the standard that exemption sets, does not trigger a restart. Both tasks invoke pytest with no test-path operand, so each collects the whole repository suite and each encounters that pre-existing failure; measured on this branch each reports `1 failed, 4194 passed, 5 skipped`. Every other failure triggers a restart. No task in this phase may be recorded as skipped.

- [x] [P8-T1] Run the TypeScript formatter and record a tree observation beyond the exit code.
  - Run `git status --porcelain`, then `npm run format`, then `git status --porcelain` again.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-ts-format.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying both porcelain listings and stating that the two listings are identical, which is what proves the run left every matched file unchanged. A differing pair requires a restart of this phase.

- [x] [P8-T2] Run the TypeScript linter.
  - Run `npm run lint`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-ts-lint.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the integer error and warning counts, with the error count at 0. A clean run of this command prints no summary line at all; record empty output plus exit code 0 as the counts 0 and 0, and quote the output verbatim when it is non-empty.

- [x] [P8-T3] Run the TypeScript type checker.
  - Run `npm run typecheck`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-ts-typecheck.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the integer diagnostic count at 0. A clean run of this command prints no summary line at all; record empty output plus exit code 0 as the counts 0 and 0, and quote the output verbatim when it is non-empty.

- [x] [P8-T4] Run the TypeScript unit suite.
  - Run `npm run test:unit`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-ts-test-unit.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the passed, failed, and total counts and the suite count, with the failed count at 0.

- [x] [P8-T5] Run the TypeScript coverage gate.
  - Run `npm run test:coverage -- --coverageReporters=text`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-ts-coverage.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the numeric overall statement, branch, function, and line percentages plus the numeric per-file line and branch percentages for each of the three pr-context production files, each at or above 85 lines and 75 branches. Placeholder values are not acceptable.

- [x] [P8-T6] Run the Python formatter and record a tree observation beyond the exit code.
  - Run `git status --porcelain`, then `poetry run black .`, then `git status --porcelain` again.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-py-black.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying both porcelain listings, the integer count of files reformatted at 0, and the integer count of files the run reported as left unchanged. A non-zero reformat count requires a restart of this phase.

- [x] [P8-T7] Run the Python linter.
  - Run `poetry run ruff check .`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-py-ruff.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` recording verbatim the final line the run printed, which must be `All checks passed!`. `ruff check .` is read-only under this repository's configuration, so no fixed-file count is printed and none is recorded; the restart trigger for this task is a non-zero exit code or a `Found N errors.` line.

- [x] [P8-T8] Run the Python type checker.
  - Run `poetry run pyright`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-py-pyright.TIMESTAMP.md` records `Timestamp:`, `Command:`, `EXIT_CODE:` 0, and an `Output Summary:` carrying the integer error count at 0 alongside the warning and information counts.

- [x] [P8-T9] Run the repository-wide Python test and coverage gate.
  - Run `poetry run pytest --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p8t9.json --cov`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-py-pytest-coverage.TIMESTAMP.md` records `Timestamp:`, `Command:`, the observed `EXIT_CODE:`, and an `Output Summary:` carrying the passed and failed counts, the node ID and assertion message of every failed test, and, for the `TOTAL` row of the terminal coverage table, the `Stmts`, `Miss`, `Branch`, `BrPart`, and `Cover` values recorded verbatim together with the `percent_statements_covered` and `percent_branches_covered` values read from the `totals` object of `artifacts/python/cov-p8t9.json`, per the Python coverage-reading convention stated at the head of this plan. Placeholder values are not acceptable. The task passes when the run exits 0 with zero failures, or when it exits 1 with exactly one failure satisfying every condition of the bounded exemption stated at the head of this plan, in which case the artifact also carries `ExpectedExitCode: 1`.

- [x] [P8-T10] Run the targeted Python coverage gate for the two modules the spec names, and for the new module.
  - Run `poetry run pytest --cov=scripts.dev_tools.pr_context.collector --cov=scripts.dev_tools.pr_context.summary_helpers --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p8t10-a.json`.
  - Run `poetry run pytest --cov=scripts.dev_tools.pr_context.collector_documents --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p8t10-b.json`.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-py-pr-context-coverage.TIMESTAMP.md` records `Timestamp:`, `Command:`, the observed `EXIT_CODE:`, and `Output Summary:` for both runs, carrying the passed and failed counts and the node ID and assertion message of every failed test, and carrying for each of the rows printed for `scripts/dev_tools/pr_context/collector.py`, `scripts/dev_tools/pr_context/summary_helpers.py`, and `scripts/dev_tools/pr_context/collector_documents.py` the `Stmts`, `Miss`, `Branch`, `BrPart`, and `Cover` values recorded verbatim, together with the `percent_statements_covered` and `percent_branches_covered` values read from the `summary` object of that file's entry under `files` in the JSON that run wrote, per the Python coverage-reading convention stated at the head of this plan, with `percent_statements_covered` at or above 85 and `percent_branches_covered` at or above 75 for every one of the three rows. Placeholder values are not acceptable. Neither command carries a test-path operand, so each collects the whole repository suite. The task passes when both runs exit 0 with zero failures, or when both exit 1 with exactly one failure satisfying every condition of the bounded exemption stated at the head of this plan, in which case the artifact also carries `ExpectedExitCode: 1`. One artifact suffices for both runs because both declare the same expectation; a run pair with differing expectations must be split into two artifacts, as P5-T1 does.

- [x] [P8-T11] Record the coverage delta comparison for both runtimes.
  - Read the baseline artifacts written by P0-T8, P0-T12, and P0-T13, and the final artifacts written by P8-T5, P8-T9, and P8-T10.
  - Acceptance: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/coverage-delta.TIMESTAMP.md` records, as numeric values with no placeholders, the baseline and post-change overall line and branch percentages for each runtime, the baseline and post-change per-file line and branch percentages for each of the five production files in scope that existed at baseline, the post-change percentages for the one production file created by this change, and an explicit statement for each file that its post-change line coverage is at or above 85, its post-change branch coverage is at or above 75, and neither value regressed against its baseline. Python line and branch percent values are the `percent_statements_covered` and `percent_branches_covered` values defined by the Python coverage-reading convention stated at the head of this plan, carried over from the source artifacts together with the raw terminal columns recorded beside them; TypeScript line and branch percent values are read directly from the line and branch columns of the Jest text reporter, which prints them separately. A regression on any changed file is a failure of this task, not a note.

## Acceptance-criteria coverage map

Every criterion in the spec's `## Acceptance Criteria` section is delivered by the task named here.

| Spec criterion | Delivered by |
| --- | --- |
| 1. Set-equality of written and reported paths at the service seam | P1-T1, P1-T2, P2-T1, P2-T5 |
| 2. node:fs write arguments are the workspace-joined pair | P1-T3, P2-T1, P2-T5 |
| 3. Dispatch-level test corrected to one workspace-joined pair | P5-T3 |
| 4. Discarding write raises | P2-T3, P5-T1 |
| 5. Stale pre-seed plus discarding write raises | P2-T3, P5-T1 |
| 6. Partial write raises and names the appendix | P2-T3, P5-T1 |
| 7. Dispatch boundary reports ok false with the failure text | P5-T4 |
| 8. Successful invocation reports ok true with artifacts equal to the written pair | P5-T4 |
| 9. Generated-context section first in both texts, identical timestamp | P3-T2, P3-T5 |
| 10. Head-SHA line from a concrete forty-character fixture SHA in both texts | P3-T1, P3-T5 |
| 11. Unknown token when no head SHA, with no error | P3-T1, P3-T5 |
| 12. Section-ordering assertion places generated-context first with prior order intact | P3-T4 |
| 13. Collector log lines carry the absolute workspace-joined paths | P2-T1, P2-T4 |
| 14. GitHub CLI unavailable still writes both artifacts and succeeds | P5-T2 |
| 15. Python collect-and-write opens both documents with a byte-identical generated-context block | P4-T3, P4-T4 |
| 16. Python head-SHA line concrete value and unknown token | P4-T2, P4-T4 |
| 17. Cross-runtime literal parity over the section title and head-SHA label | P4-T5 |
| 18. Three jest coverageThreshold entries and a clean coverage run | P5-T5, P8-T5 |
| 19. Targeted Python coverage at or above 85 lines and 75 branches for both named modules | P0-T13, P8-T10 |
| 20. Six skill copies carry the cross-check and the push-down parity tests pass | P6-T1, P6-T2, P6-T3 |
| 21. No repository-root join in the Python collector and no hook change | P4-T1, P7-T3 |
| 22. Every changed file at or under 500 lines | P0-T14, P4-T1, P7-T1, P7-T2 |
| 23. Full toolchain pass in a single run for both runtimes | Phase 8 |

## Behaviour-semantics coverage map

| Spec behaviour condition | Delivered by |
| --- | --- |
| 1. Path identity, reported set always equals written set | P2-T1, P1-T2, P1-T3 |
| 2. ok semantics, true only when both files were written and read back equal | P2-T2, P2-T3, P5-T1, P5-T4 |
| 3. Ordering, summary before appendix, verification after both, record built last | P2-T2, P2-T3 |
| 4. Pair atomicity is not claimed | P5-T1 partial-write test, plus the shared timestamp from P3-T2 |
| 5. Degradation is not failure | P5-T2 |
| 6. Consumer backward compatibility, no hook change required | P7-T3 |

## Notes for the executor

- No acceptance condition in this plan asserts the existence, modification time, or content of the real generated artifacts `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`. A prior run's file satisfies such a condition, and that is the defect under repair.
- No acceptance condition in this plan invokes the live MCP tool. The MCP client resolves an unpinned package, so a live call exercises the installed build rather than this branch. Live verification is post-release evidence and is not a gate.
- The 500-line limit applies to every file this diff writes. Two files are already at risk: the Python collector exceeds the limit at baseline and is repaired by P4-T1, and the TypeScript collector output module has limited headroom, which is why the head-SHA rendering is added to the helper module in P3-T1 rather than inlined in P3-T2.
- Removing the read-back verification added in P2-T3 must make the first two tests of P5-T1 fail. If it does not, the verification is an existence check and the task is not complete.
