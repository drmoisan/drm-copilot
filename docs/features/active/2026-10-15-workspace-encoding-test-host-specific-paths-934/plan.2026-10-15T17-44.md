# workspace-encoding-test-host-specific-paths (Plan)

- **Issue:** #934
- **Parent (optional):** none
- **Owner:** drmoisan
- **Branch:** bug/workspace-encoding-test-host-specific-paths-934
- **Last Updated:** 2026-10-15T17-44
- **Status:** Draft (awaiting preflight)
- **Version:** 0.3
- **Work Mode:** minor-audit (source: `- Work Mode: minor-audit` in FEATURE/issue.md metadata block)

**Revision history**

- 0.2: initial minimal-audit plan.
- 0.3: preflight round 1 deltas. `SCRATCH` redefined as the untracked worktree-root directory `SCRATCH/` (not the session scratchpad, never replaced by an absolute path); coverage directories in the AC-6 equivalence note, P0-T18, and P2-T8 use `../../SCRATCH/issue-934/...` relative to `EXT`; P2-T16 porcelain acceptance tolerates `?? SCRATCH/`; P0-T5 fallback uses the Bash tool and blocks if both routes are denied; P1-T1 and P1-T2 delegation is performed by the orchestrator after the Phase 0 checkpoint, with the executor verifying on resume; the loop rule routes Phase 1 defects through the orchestrator.

DIRECTIVE: PREFLIGHT VALIDATION ONLY

**Fail-closed evidence rule:** If any required baseline artifact, QA-gate artifact, or coverage-comparison artifact is missing or lacks a required field, the audit verdict is BLOCKED or INCOMPLETE, never PASS. A checklist box stays unchecked while its artifact is absent or incomplete.

## Definitions and Conventions

- `FEATURE` = `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934`.
- `EXT` = `extensions/drm-copilot`. Every `npx` command in this plan runs with working directory `EXT`. Every `git` command runs from the worktree root.
- `SCRATCH` = the literal directory `SCRATCH/` at the worktree root (untracked; not git-ignored). It is not the session scratchpad and is never replaced by an absolute path in any command, plan text, or evidence artifact. Every scratch file, probe file, and coverage directory in this plan lives under `SCRATCH/issue-934/`, and nothing is written to the `SCRATCH/` root or to any fixed shared name outside `SCRATCH/issue-934/`. `git` commands, which run from the worktree root, address it as `SCRATCH/issue-934/...`. `npx` commands, which run in `EXT`, address it as `../../SCRATCH/issue-934/...`. The Write tool requires an absolute path argument, so the executor supplies the worktree-root-qualified form only in that tool call; every plan and evidence reference records the relative form `SCRATCH/issue-934/...`. `git status --porcelain` lists this directory as `?? SCRATCH/`.
- Requirements source: `FEATURE/issue.md`, section `## Acceptance Criteria`, items AC-1 through AC-6, and nothing else. `spec.md` and `user-story.md` are intentionally absent (minor-audit). The research artifact `FEATURE/research/2026-10-15T17-50-workspace-encoding-host-paths-research.md` (Option A) supplies the design; none of its expected command outputs is treated as observed.
- Files in scope (edit only): `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts` (WE-TEST) and `extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts` (STR-TEST, included per decision OD-1). The production modules `extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts` and `extensions/drm-copilot/src/lib/subagent-tree/session-transcript-resolver.ts` must not change.
- Write boundary: the executor and the delegated engineer write only to WE-TEST, STR-TEST, `FEATURE/**`, and `SCRATCH/issue-934/**` (the worktree-root directory defined above). The single exception is `EXT/node_modules/**`, the git-ignored install output of P0-T5 (`node_modules` is ignored by `.gitignore` line 3). No tracked file is deleted. No `git fetch`, `git pull`, `git stash`, or `git reset` is run during execution, so the local `origin/main` ref stays fixed at the value P0-T3 records.
- Evidence artifacts are named `<name>.<timestamp>.md`, where the timestamp is the UTC write time in `yyyy-MM-ddTHH-mm` form read from the host clock immediately before the write. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md` in the named folder. Every command artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is non-zero also carries `ExpectedExitCode: <int>`.
- Git search scope: WE-TEST and STR-TEST are tracked files. `git grep` without `--cached` searches the working-tree content of tracked files, so every `git grep` in this plan observes the edited content without a `git add`.
- Coverage thresholds: the root `CLAUDE.md` states no coverage threshold, so the defaults apply (line >= 85%, branch >= 75%); `EXT/jest.config.cjs` lines 206-209 and 214-217 gate both production modules at those values. `quality-tiers.yml` classifies `extensions/drm-copilot` as T3 (no property-test or mutation obligation).
- Coverage command equivalence (AC-6): the `EXT/package.json` script `test:coverage` is `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`, and `EXT/run-jest.cjs` line 28 runs `jest --config jest.config.cjs` with the remaining arguments. Its `text-summary` reporter prints totals only. This plan runs the same configuration and the same thresholds as `npx jest --config jest.config.cjs --coverage --coverageReporters=text --coverageDirectory=../../SCRATCH/issue-934/coverage-<phase>`, which replaces the reporters with `text` (per-file table on stdout) and moves the coverage directory into `SCRATCH` (the relative path resolves from `EXT`, the jest rootDir and working directory, to `SCRATCH/issue-934/` at the worktree root). No `run-jest.cjs`-prohibited flag (`--passWithNoTests`, `--onlyChanged`, `--lastCommit`) is used anywhere in this plan.
- Host-path regex (HOSTPATH-REGEX), POSIX ERE, backslash-free: `(^|[^[:alnum:]_])[[:alpha:]](:[^[:alnum:][:space:]]|--)`. It matches a single letter that is preceded by start-of-line or a non-alphanumeric character and is followed either by `:` plus a non-alphanumeric, non-space character (a drive-letter absolute path such as a drive letter, colon, and slash or backslash) or by `--` (an encoded absolute directory name). It does not match `node:path` (the letter before the colon is preceded by a letter), TypeScript annotations such as `label: string` (same reason), or the Option A templates, where a closing brace precedes the colon or the double hyphen. P0-T10 and P0-T11 verify these properties on probe files before the plan relies on them.

**Observed success-case output (recorded runs in this repository)**

Each literal below was read from a recorded successful run, not from tool documentation. A cited prior feature folder may have moved; resolve it under `docs/features/active/`, `docs/features/completed/`, or `docs/features/archive/`.

- `npx prettier --check` success line: `All matched files use Prettier code style!` (recorded in `2026-08-22-push-down-root-folders-divergence-507/policy-audit.2026-09-29T18-12.md`, line 113).
- `npx prettier --write` per-file line for an unmodified file: `<path> <N>ms (unchanged)` (recorded in `promotion-receipt-destination-unverified-623/evidence/qa-gates/ts-format.2026-09-30T08-46.md`, line 26). A rewritten file's line lacks `(unchanged)`.
- Jest summary line: `Tests:       <N> passed, <N> total` (recorded in `2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/evidence/other/p1-models-test.2026-10-08T02-38.md`, line 10).
- Jest `text` coverage reporter: header `File | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s`, a directory row ` src/lib/subagent-tree`, and file rows `  workspace-encoding.ts | ... |` and `  session-transcript-resolver.ts | ... |` (recorded in `2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-coverage-output.2026-10-09T01-33.txt`, lines 13, 163, 166, 172). In each file row the second numeric column is `% Branch` and the fourth is `% Lines`.
- `npx eslint` and `npx tsc --noEmit` on a clean input print nothing and exit 0.

**Loop and remediation rule**

Phase 2 tasks P2-T1 through P2-T8 form the final QC loop (format, lint, type check, test with coverage). If any of them fails, or P2-T1 reports a rewritten file, the executor records the artifact, leaves the task unchecked, reports the defect to the orchestrator for re-delegation to the Phase 1 engineer when the defect is in WE-TEST or STR-TEST (the executor does not edit WE-TEST or STR-TEST itself), and restarts from P2-T1. Each loop pass writes new artifacts with new timestamps. The targeted verification tasks P2-T9 onward run only after a single loop pass in which P2-T1 through P2-T8 all pass. A failure whose cause lies outside WE-TEST and STR-TEST stops execution with a BLOCKED report; the executor does not edit other files.

## Implementation Specification (binding for Phase 1)

WE-TEST (`extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`):

1. Add the import `import * as path from "node:path";`.
2. Add module-scope constants with these exact names and values: `UPPER_DRIVE` = `"C"`, `PARENT_SEGMENTS` = `["Users", "fixtureuser", "repos"]`, `REPO` = `"drm-copilot"`, `OTHER_REPO` = `"some-other-repo"`, `BACKSLASH` = `path.win32.sep`, `SLASH` = `path.posix.sep`.
3. Add the module-scope helper `function workspacePathOf(separator: string, ...segments: string[]): string` returning the template `${UPPER_DRIVE}:${separator}${[...PARENT_SEGMENTS, ...segments].join(separator)}`.
4. Add the module-scope helper `function encodedNameOf(drive: string, ...segments: string[]): string` returning the template `${drive}--${[...PARENT_SEGMENTS, ...segments].join("-")}`. Its body must not reference `encodeWorkspacePath` or `workspacePathOf` (AC-4).
5. Replace every workspace-path literal and every expected or on-disk encoded-name literal using the derivation table in research section 4 ("Derivations"). The lowercase on-disk directory in the test titled `matches an on-disk directory whose drive-letter segment uses a lowercase letter against an uppercase-encoded workspace name` is `encodedNameOf(UPPER_DRIVE, REPO).toLowerCase()`. Worktree suffixes keep their existing timestamp text: `wt-2026-06-13-11-51`, `wt-2026-07-03-16-18`, `wt-2026-07-03-22-30`, `wt-2026-07-07T12-00`, `wt-2026-07-07T18-00`. The unrelated-suffix directory keeps `unrelated-suffix`.
6. Rewrite the comments at current lines 35-37 and 122-126 so they describe the shape in words (for example "an uppercase drive letter in the workspace path and a lowercase drive-letter segment on disk", and "`<workspace parent>/drm-copilot-wt/<timestamp>`") without any drive letter, colon-separator sequence, or encoded name.
7. Keep both `describe` titles and all nine `it` titles byte-identical, keep the Arrange/Act/Assert comments, and add or remove no test.

STR-TEST (`extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts`):

1. Add the import `import * as path from "node:path";`.
2. Replace the constants at current lines 5-12 with runtime composition: `DRIVE` = `"C"`; `WORKSPACE_SEGMENTS` = `["Users", "fixtureuser", "repos", "drm-copilot"]`; `WORKSPACE_ROOT` = `${DRIVE}:${path.win32.sep}${WORKSPACE_SEGMENTS.join(path.win32.sep)}`; `EXACT_DIR` = `${DRIVE}--${WORKSPACE_SEGMENTS.join("-")}`; `SIBLING_DIR` = `${EXACT_DIR}-wt-2026-07-09T09-18`. `PROJECTS_ROOT` and `VALID_ID` are unchanged. The file continues not to import `encodeWorkspacePath`.
3. Reword the doc comments on those constants without a drive letter, colon-separator sequence, or encoded name.
4. Keep every `describe` title, the `malformedIds` table, the `it.each` title, and all `it` titles byte-identical; add or remove no test.

Both files:

- No line may match HOSTPATH-REGEX. In particular no comment or string may contain a single letter immediately followed by a colon and punctuation (for example a drive letter written inside backticks) or by `--`.
- No occurrence of `danmoisan` in any letter case, and no backslash-separated path literal.
- At most 500 lines each; no ESLint or TypeScript suppression comments; no new files; no change to any other file.

## Phases

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Read the policy files in this order and note each as read: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`, and `quality-tiers.yml` (record the tier entry for `extensions/drm-copilot`).
  - Acceptance: all seven files were opened with the Read tool in the stated order; the tier recorded for `extensions/drm-copilot` is the value on the `tier:` line following `path: "extensions/drm-copilot"` in `quality-tiers.yml`.
- [x] [P0-T2] Write `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact contains `Timestamp:`, `Policy Order:` (the seven paths in P0-T1 order), the list of files read, the recorded tier, and the statement that the root `CLAUDE.md` states no coverage threshold so the 85% line / 75% branch defaults apply.
- [x] [P0-T3] Verify minor-audit preconditions and record git refs: confirm `FEATURE/issue.md` contains the heading `## Acceptance Criteria` with items AC-1 through AC-6, confirm `FEATURE/spec.md` and `FEATURE/user-story.md` are absent, and run `git rev-parse HEAD origin/main` and `git merge-base HEAD origin/main`. Write `FEATURE/evidence/baseline/preconditions-and-refs.<timestamp>.md`.
  - Acceptance: both git commands exit 0 and the three SHAs are recorded; the artifact records the heading and AC-1 through AC-6 as present and both documents as absent. If the heading or any AC is missing, or either document exists, the executor stops with a BLOCKED report (fail closed).
- [x] [P0-T4] Baseline the production-file diff (AC-5): run `git diff origin/main --name-only -- extensions/drm-copilot/src` and `git status --porcelain -- extensions/drm-copilot/src`. Write `FEATURE/evidence/baseline/production-diff.<timestamp>.md`.
  - Acceptance: both commands exit 0 with empty output. Non-empty output is a pre-existing divergence; the executor stops with a BLOCKED report naming the listed paths.
- [x] [P0-T5] Install dependencies in `extensions/drm-copilot`: run `pwsh -NoProfile -WorkingDirectory extensions/drm-copilot -Command "npm ci"`. If the runtime denies the `pwsh` invocation, run `cd extensions/drm-copilot && npm ci` through the Bash tool and record the command actually run; if that is also denied, the executor stops with a BLOCKED report naming both denied commands. Write `FEATURE/evidence/baseline/npm-ci.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0, and a Glob for `extensions/drm-copilot/node_modules/.bin/jest*` returns at least one file (resolved-binary observation recorded in `Output Summary:`). The install writes only the git-ignored `extensions/drm-copilot/node_modules/`.
- [x] [P0-T6] Baseline line counts: run `git grep -c -E -e '^' -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts`. Write `FEATURE/evidence/baseline/line-counts.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0; one `<path>:<count>` line per file is recorded.
- [x] [P0-T7] Baseline the AC-1 token count: run `git grep -c -i -F -e danmoisan -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`. Write `FEATURE/evidence/baseline/ac1-token-count.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0 and the recorded count is greater than 0 (non-vacuity of the AC-1 search). Planner static reading of the current file finds 33 matching lines, consistent with the issue text; the executor records the observed value.
- [x] [P0-T8] Baseline the AC-2 host-path count on both files: run `git grep -c -E -e '(^|[^[:alnum:]_])[[:alpha:]](:[^[:alnum:][:space:]]|--)' -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts`. Write `FEATURE/evidence/baseline/ac2-hostpath-count.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0 and both files appear with a count greater than 0 (non-vacuity on each file). Planner static reading finds 35 matching lines in WE-TEST (drive-letter lines 10, 21, 22, 37, 39, 59, 87, 107, 123, 128, 153, 174 and encoded-name lines including 16, 36, 42, 43) and 3 in STR-TEST (lines 6, 10, 12); the executor records the observed values. EXIT_CODE 128 (regex error) or a missing file stops execution.
- [x] [P0-T9] Write the two regex probe files with the Write tool. `SCRATCH/issue-934/probe/helper-templates.txt` contains exactly these six lines:

    ```text
    import * as path from "node:path";
    const UPPER_DRIVE = "C";
      return `${UPPER_DRIVE}:${separator}${[...PARENT_SEGMENTS, ...segments].join(separator)}`;
      return `${drive}--${[...PARENT_SEGMENTS, ...segments].join("-")}`;
    const WORKSPACE_ROOT = `${DRIVE}:${path.win32.sep}${WORKSPACE_SEGMENTS.join(path.win32.sep)}`;
    const EXACT_DIR = `${DRIVE}--${WORKSPACE_SEGMENTS.join("-")}`;
    ```

    `SCRATCH/issue-934/probe/positive-control.txt` contains exactly these three lines:

    ```text
    const forwardSlashed = "C:/x";
    const backslashed = "C:\\x";
    const encoded = "C--x";
    ```

  - Acceptance: both files exist under `SCRATCH/issue-934/probe/` with the stated line counts (6 and 3).
- [x] [P0-T10] Run the negative probe: `git -C SCRATCH/issue-934/probe grep --no-index -n -E -e '(^|[^[:alnum:]_])[[:alpha:]](:[^[:alnum:][:space:]]|--)' -- helper-templates.txt`. Write `FEATURE/evidence/baseline/regex-probe-negative.<timestamp>.md` with `ExpectedExitCode: 1`.
  - Acceptance: EXIT_CODE 1 and empty output, demonstrating that HOSTPATH-REGEX does not match the Option A helper templates or the `node:path` import. Any match stops execution; the plan is returned to the planner.
- [x] [P0-T11] Run the positive control: `git -C SCRATCH/issue-934/probe grep --no-index -n -E -e '(^|[^[:alnum:]_])[[:alpha:]](:[^[:alnum:][:space:]]|--)' -- positive-control.txt`. Write `FEATURE/evidence/baseline/regex-probe-positive.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0 and exactly 3 output lines (lines 1, 2, and 3), demonstrating that the regex matches a forward-slash drive path, a backslash drive path, and an encoded name.
- [x] [P0-T12] Baseline formatting (check mode, no write): run `npx prettier --check test/lib/subagent-tree/workspace-encoding.test.ts test/lib/subagent-tree/session-transcript-resolver.test.ts`. Write `FEATURE/evidence/baseline/prettier-check.<timestamp>.md`.
  - Acceptance: the artifact records the exit code and, in `Output Summary:`, either the success line `All matched files use Prettier code style!` or each flagged file. Check mode writes nothing.
- [x] [P0-T13] Baseline lint: run `npx eslint test/lib/subagent-tree/workspace-encoding.test.ts test/lib/subagent-tree/session-transcript-resolver.test.ts`. Write `FEATURE/evidence/baseline/eslint.<timestamp>.md`.
  - Acceptance: the artifact records the exit code and the problem count (0 when the output is empty).
- [x] [P0-T14] Baseline production type check: run `npx tsc -p ./ --noEmit`. Write `FEATURE/evidence/baseline/tsc-src.<timestamp>.md`.
  - Acceptance: the artifact records the exit code and the number of `error TS` lines (0 when the output is empty).
- [x] [P0-T15] Baseline test type check: run `npx tsc -p tsconfig.jest.json --noEmit`. Write `FEATURE/evidence/baseline/tsc-jest.<timestamp>.md`.
  - Acceptance: the artifact records the exit code and the number of `error TS` lines (0 when the output is empty).
- [x] [P0-T16] Baseline WE-TEST: run `npx jest --config jest.config.cjs --verbose --runTestsByPath test/lib/subagent-tree/workspace-encoding.test.ts`. Write `FEATURE/evidence/baseline/jest-workspace-encoding.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0; `Output Summary:` records the `Tests:` line and the list of passing test titles with durations removed. Planner static reading counts 9 tests; the executor records the observed count, which is the AC-3 baseline.
- [x] [P0-T17] Baseline STR-TEST: run `npx jest --config jest.config.cjs --verbose --runTestsByPath test/lib/subagent-tree/session-transcript-resolver.test.ts`. Write `FEATURE/evidence/baseline/jest-session-transcript-resolver.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0; `Output Summary:` records the `Tests:` line and the list of passing test titles with durations removed. Planner static reading counts 12 tests (7 `it.each` rows plus 5 `it` blocks); the executor records the observed count, which is the AC-3 baseline.
- [x] [P0-T18] Baseline full coverage run: run `npx jest --config jest.config.cjs --coverage --coverageReporters=text --coverageDirectory=../../SCRATCH/issue-934/coverage-baseline`. Write `FEATURE/evidence/baseline/jest-coverage.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0 and no output line contains `coverage threshold`. `Output Summary:` records the `Test Suites:` and `Tests:` lines, the `All files` row, and the numeric `% Branch` and `% Lines` values from the `workspace-encoding.ts` and `session-transcript-resolver.ts` rows beneath the ` src/lib/subagent-tree` directory row. A non-zero exit or a threshold message is a pre-existing failure; the executor stops with a BLOCKED report quoting the failing lines.

### Phase 1 — Delegated Implementation (typescript-engineer)

- [x] [P1-T1] The orchestrator delegates to `typescript-engineer` (after Phase 0 completes and is checkpointed) the rewrite of `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts` exactly as specified under "Implementation Specification" (WE-TEST items 1-7 and the both-files constraints), followed by `npx prettier --write test/lib/subagent-tree/workspace-encoding.test.ts` in `extensions/drm-copilot`. The engineer writes `FEATURE/evidence/other/implementation-workspace-encoding.<timestamp>.md`.
  - Acceptance: the artifact lists each specification item with the line numbers that satisfy it, records the prettier output line for the file and a second run of the same `npx prettier --write` command whose output line ends with `(unchanged)`, and records `npx jest --config jest.config.cjs --runTestsByPath test/lib/subagent-tree/workspace-encoding.test.ts` with EXIT_CODE 0 and a `Tests:` count equal to the P0-T16 count. Only WE-TEST is modified by this task. On resume, the executor verifies the artifact against these conditions and checks off the task; it does not perform the rewrite itself.
- [x] [P1-T2] The orchestrator delegates to `typescript-engineer` (after Phase 0 completes and is checkpointed) the rewrite of `extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts` exactly as specified under "Implementation Specification" (STR-TEST items 1-4 and the both-files constraints), followed by `npx prettier --write test/lib/subagent-tree/session-transcript-resolver.test.ts` in `extensions/drm-copilot`. The engineer writes `FEATURE/evidence/other/implementation-session-transcript-resolver.<timestamp>.md`.
  - Acceptance: the artifact lists each specification item with the line numbers that satisfy it, records the prettier output line for the file and a second run of the same `npx prettier --write` command whose output line ends with `(unchanged)`, and records `npx jest --config jest.config.cjs --runTestsByPath test/lib/subagent-tree/session-transcript-resolver.test.ts` with EXIT_CODE 0 and a `Tests:` count equal to the P0-T17 count. Only STR-TEST is modified by this task. On resume, the executor verifies the artifact against these conditions and checks off the task; it does not perform the rewrite itself.

### Phase 2 — Final QC Loop, Targeted Verification, and End-State Evidence

- [x] [P2-T1] Format both files: run `npx prettier --write test/lib/subagent-tree/workspace-encoding.test.ts test/lib/subagent-tree/session-transcript-resolver.test.ts`. Write `FEATURE/evidence/qa-gates/prettier-write.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0 and both per-file output lines end with `(unchanged)`. A line without `(unchanged)` means the file was rewritten; record it and restart the loop from P2-T1 per the loop rule.
- [x] [P2-T2] Check formatting: run `npx prettier --check test/lib/subagent-tree/workspace-encoding.test.ts test/lib/subagent-tree/session-transcript-resolver.test.ts`. Write `FEATURE/evidence/qa-gates/prettier-check.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0 and the output contains `All matched files use Prettier code style!`.
- [x] [P2-T3] Lint: run `npx eslint test/lib/subagent-tree/workspace-encoding.test.ts test/lib/subagent-tree/session-transcript-resolver.test.ts`. Write `FEATURE/evidence/qa-gates/eslint.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0 and empty output (0 problems).
- [x] [P2-T4] Production type check: run `npx tsc -p ./ --noEmit`. Write `FEATURE/evidence/qa-gates/tsc-src.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0 and empty output.
- [x] [P2-T5] Test type check: run `npx tsc -p tsconfig.jest.json --noEmit`. Write `FEATURE/evidence/qa-gates/tsc-jest.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0 and empty output.
- [x] [P2-T6] Run WE-TEST: `npx jest --config jest.config.cjs --verbose --runTestsByPath test/lib/subagent-tree/workspace-encoding.test.ts`. Write `FEATURE/evidence/qa-gates/jest-workspace-encoding.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0; the `Tests:` line reports N passed, N total with N equal to the count in the greatest `FEATURE/evidence/baseline/jest-workspace-encoding.*.md`; the recorded title list (durations removed) is identical to the baseline title list.
- [x] [P2-T7] Run STR-TEST: `npx jest --config jest.config.cjs --verbose --runTestsByPath test/lib/subagent-tree/session-transcript-resolver.test.ts`. Write `FEATURE/evidence/qa-gates/jest-session-transcript-resolver.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0; the `Tests:` line reports N passed, N total with N equal to the count in the greatest `FEATURE/evidence/baseline/jest-session-transcript-resolver.*.md`; the recorded title list (durations removed) is identical to the baseline title list.
- [x] [P2-T8] Full coverage run: `npx jest --config jest.config.cjs --coverage --coverageReporters=text --coverageDirectory=../../SCRATCH/issue-934/coverage-final`. Write `FEATURE/evidence/qa-gates/jest-coverage.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0 and no output line contains `coverage threshold`. `Output Summary:` records the `Test Suites:` and `Tests:` lines, the `All files` row, and the numeric `% Branch` and `% Lines` values from the `workspace-encoding.ts` and `session-transcript-resolver.ts` rows beneath the ` src/lib/subagent-tree` directory row.
- [x] [P2-T9] Write the coverage comparison `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md` from the greatest `FEATURE/evidence/baseline/jest-coverage.*.md` and the greatest `FEATURE/evidence/qa-gates/jest-coverage.*.md`.
  - Acceptance: a table gives baseline and post-change `% Lines` and `% Branch` for `src/lib/subagent-tree/workspace-encoding.ts` and `src/lib/subagent-tree/session-transcript-resolver.ts` (four numeric pairs, no placeholders); every post-change value is greater than or equal to its baseline value and every post-change value is at least 85 (lines) and 75 (branch); changed-production-code coverage is recorded as not applicable because the plan edits no production file (AC-5 scope; P0-T4 recorded an empty production diff at baseline and P2-T15 re-verifies it after this task). Any regression or missing value makes the verdict remediation-required.
- [x] [P2-T10] AC-1 search after the change: run `git grep -n -i -F -e danmoisan -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`. Write `FEATURE/evidence/qa-gates/ac1-token-count.<timestamp>.md` with `ExpectedExitCode: 1`.
  - Acceptance: EXIT_CODE 1 and empty output (zero matches; the P0-T7 baseline count was greater than zero).
- [x] [P2-T11] AC-2 search after the change: run `git grep -n -E -e '(^|[^[:alnum:]_])[[:alpha:]](:[^[:alnum:][:space:]]|--)' -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts`. Write `FEATURE/evidence/qa-gates/ac2-hostpath-count.<timestamp>.md` with `ExpectedExitCode: 1`.
  - Acceptance: EXIT_CODE 1 and empty output for both files (the P0-T8 baseline counts were greater than zero for each file, and P0-T10 showed the Option A templates do not match).
- [x] [P2-T12] AC-4 helper isolation: run `git grep -n -E -e 'function (encodedNameOf|workspacePathOf)|encodeWorkspacePath' -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`, then Read WE-TEST from the `function encodedNameOf` line S through the first subsequent line E that consists only of `}`. Write `FEATURE/evidence/qa-gates/ac4-helper-isolation.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0; exactly one output line contains `function encodedNameOf`; the artifact records S, E, and lines S through E verbatim; no `encodeWorkspacePath` match line number lies in the range S to E; and lines S through E contain no `workspacePathOf(` call.
- [x] [P2-T13] AC-3 input-shape preservation: run `git grep -n -w -F -e BACKSLASH -e SLASH -e toLowerCase -e OTHER_REPO -e unrelated-suffix -e wt-2026-06-13-11-51 -e wt-2026-07-03-22-30 -e wt-2026-07-07T18-00 -e 'toEqual([])' -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`. Write `FEATURE/evidence/qa-gates/ac3-shape-tokens.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0, and the artifact maps each of the nine tokens to at least one output line that contains it as a whole word, with the AC-3 shape each token represents. For `BACKSLASH`, `SLASH`, and `OTHER_REPO` the mapped line must be a use site, not the `const` declaration line of that name. Shapes: `BACKSLASH` (backslash separator), `SLASH` (forward-slash separator, a line where `SLASH` is not part of `BACKSLASH`), `toLowerCase` (uppercase input against lowercase on-disk directory), `wt-2026-06-13-11-51` (`-wt-` worktree suffix), `wt-2026-07-03-22-30` and `wt-2026-07-07T18-00` (nested worktree suffixes), `unrelated-suffix` (unrelated-suffix rejection), `OTHER_REPO` (other-repository rejection), `toEqual([])` (empty result). A token with no line fails the task.
- [x] [P2-T14] Line-count limit: run `git grep -c -E -e '^' -- extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts`. Write `FEATURE/evidence/qa-gates/line-counts.<timestamp>.md`.
  - Acceptance: EXIT_CODE 0 and both recorded counts are at most 500; the artifact also lists the P0-T6 baseline counts for comparison.
- [x] [P2-T15] AC-5 production diff: run `git diff origin/main --name-only -- extensions/drm-copilot/src`, `git status --porcelain -- extensions/drm-copilot/src`, and `git rev-parse origin/main`. Write `FEATURE/evidence/qa-gates/production-diff.<timestamp>.md`.
  - Acceptance: all three commands exit 0; the first two print nothing; the `git rev-parse origin/main` output equals the `origin/main` SHA in the greatest `FEATURE/evidence/baseline/preconditions-and-refs.*.md`.
- [x] [P2-T16] Scope boundary: run `git status --porcelain` and `git diff origin/main --name-only`. Write `FEATURE/evidence/qa-gates/scope-boundary.<timestamp>.md`.
  - Acceptance: both commands exit 0; every path in the `git diff origin/main --name-only` listing is WE-TEST, STR-TEST, or a path under `FEATURE/`; every `git status --porcelain` entry is WE-TEST, STR-TEST, a path under `FEATURE/` (modified or untracked), or the untracked entry `?? SCRATCH/` (or an untracked path under `SCRATCH/issue-934/`); WE-TEST and STR-TEST each appear in the diff listing; no deleted (`D`) entry appears in either output.
- [x] [P2-T17] Write the end-state summary `FEATURE/evidence/qa-gates/end-state-summary.<timestamp>.md`.
  - Acceptance: the artifact contains one row per AC-1 through AC-6 naming the consumed artifacts (by `<name>.*.md` pattern and the selected filename) and a PASS or FAIL verdict derived only from those artifacts' acceptance results; the overall verdict is PASS only when all six rows are PASS and every Phase 0 and Phase 2 artifact exists with its required fields.
- [x] [P2-T18] Update `FEATURE/issue.md`: change `- [ ]` to `- [x]` for each of AC-1 through AC-6 whose row in the greatest `FEATURE/evidence/qa-gates/end-state-summary.*.md` is PASS.
  - Acceptance: the checked set in `FEATURE/issue.md` equals the PASS set in the end-state summary; no other line of `FEATURE/issue.md` changes.

## Acceptance Criteria Traceability

| AC | Implementation | Verification | Evidence |
| --- | --- | --- | --- |
| AC-1 | P1-T1 | P0-T7, P2-T10 | baseline/ac1-token-count, qa-gates/ac1-token-count |
| AC-2 | P1-T1, P1-T2 | P0-T8, P0-T10, P0-T11, P2-T11 | baseline/ac2-hostpath-count, baseline/regex-probe-*, qa-gates/ac2-hostpath-count |
| AC-3 | P1-T1, P1-T2 | P0-T16, P0-T17, P2-T6, P2-T7, P2-T13 | baseline/jest-*, qa-gates/jest-*, qa-gates/ac3-shape-tokens |
| AC-4 | P1-T1 | P2-T12 | qa-gates/ac4-helper-isolation |
| AC-5 | P1-T1, P1-T2 (no production edit) | P0-T4, P2-T15, P2-T16 | baseline/production-diff, qa-gates/production-diff, qa-gates/scope-boundary |
| AC-6 | P1-T1, P1-T2 | P0-T12 to P0-T15, P0-T18, P2-T1 to P2-T5, P2-T8, P2-T9, P2-T14 | baseline/jest-coverage, qa-gates/jest-coverage, qa-gates/coverage-delta, qa-gates/line-counts |
