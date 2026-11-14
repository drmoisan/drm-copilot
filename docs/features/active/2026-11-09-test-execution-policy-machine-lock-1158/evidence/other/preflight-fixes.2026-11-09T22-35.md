# Preflight Fixes

Timestamp: 2026-11-09T22-35
Plan: docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/plan.2026-11-09T16-31.md

Each entry is a trivial defect fixed in task or preamble text. No task was added, removed, or reordered, and no pass or fail criterion changed.

1. `## Execution Constraints` (SCRATCH line) | glob token in a write-path rule | `scratch files are named issue-1158-*` reworded to `scratch file names start with issue-1158-`.
2. `## Execution Constraints` | placeholder evidence root | added a line defining `<FEATURE>` as `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158`, so every evidence path resolves to a concrete path.
3. `## Execution Constraints` (Batch budget) | unnamed scratch write path | the copy script is named `SCRATCH/issue-1158-copy-mirrors.sh`.
4. [P0-T5] | unnamed scratch write path | the JSON report is named `SCRATCH/issue-1158-pytest-baseline.json`.
5. [P0-T6] | evidence left for the executor to select | the four integration-named Jest files are named: `extension.collect-commit-context.integration.test.ts`, `extension.integration.test.ts`, `lib/pr-context/collector-integration.test.ts`, `lib/push-down/codex-bundle-publish.integration.test.ts` under `extensions/drm-copilot/test/` (verified present with `git ls-files`).
6. [P1-T1] | literal wording that cannot hold for a function that returns a value | "No helper writes to the success or warning stream" now reads "when dot-sourced, and no function emits output beyond its return value".
7. [P1-T4] | incomplete literal of the committed configuration | the `command` and `runner` values of `jest-extension` (`node run-jest.cjs`, `jest`) and `bats` (`bash scripts/bash/shell-qc.sh test`, `bats`) are stated, matching spec `## Inputs / Outputs`.
8. [P3-T2] | CI-only failure class (file mode) | every committed shell fixture is mode 100644, and the Linux `shell-coverage / Shell Coverage (Bats + kcov)` job cannot execute a 100644 stub named by `TEST_SUITE_PWSH_BIN`; the task now commits the stub with mode 100755 through `git update-index --chmod=+x`.
9. [P3-T3] | unnamed scratch write path | the proof script is named `SCRATCH/issue-1158-lock-two-process-proof.sh`.
10. [P6-T1] | acceptance condition that cannot fail | `test_claude_rules_frontmatter.py` validates rule frontmatter and agent preload lists only, so it passes whatever this skill's frontmatter holds; the acceptance now reads the frontmatter `name` and non-empty `description` directly and keeps the test as a non-regression check.
11. [P6-T6] | ambiguous file set | "typed-engineer" agents did not name `typescript-engineer`, whose copies P6-T7 rows require to carry the D13 statements; `typescript-engineer` is now named.
12. [P7-T3] | command operand the tool rejects | `shell-qc.sh check` takes no path operand (extra positionals exit 2) and discovers `tools`, `scripts`, `.claude/lib/bash`, `.claude/skills`, and `.codex` (`discover_shell_scripts` in `scripts/bash/shell_qc_lib.sh`); the task text now states what the unchanged command covers.
13. [P7-T5] | unnamed scratch write path | the JSON report is named `SCRATCH/issue-1158-pytest-final.json`.
14. [P7-T6] | evidence reference | "the four integration-named files" now points at the files named in P0-T6.
15. [P7-T8] | missing contract field | the comparison artifact lists new or changed-code coverage per file, a field the Coverage Evidence Contract of `atomic-plan-contract` requires.

Each fix was checked against the rule it enforces: the fix text contains no glob token, no line or commit citation, no host path, and no promotional wording.
