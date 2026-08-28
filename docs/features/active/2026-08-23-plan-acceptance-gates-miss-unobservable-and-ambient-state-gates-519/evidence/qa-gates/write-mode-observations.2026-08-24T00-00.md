# Final QC — write-mode observation summary — [P8-T11]

Timestamp: 2026-08-26T10-39
Task: [P8-T11]
Command: read of the three recorded Phase 8 artifacts named below; no new command was executed for this task
EXIT_CODE: 0

Output Summary: three write-mode tools were run by this plan — the Python formatter, the Python linter, and the TypeScript format script. Each one's artifact records an observation beyond its exit code, quoted below with the artifact path the observation was read from. **No entry rests on an exit code alone.**

## Why an exit code is not sufficient for these three tools

All three exit 0 whether or not they rewrote a file. An exit code of 0 therefore does not distinguish a clean run from a repairing one, and a gate whose only evidence is that exit code cannot fail when the tool repairs the tree. This is the exact defect class G7 reports, and this plan is subject to it.

## Entry 1 — the Python formatter

- **Tool:** `black`
- **Command:** `poetry run black .`
- **Task and artifact:** [P8-T1], `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/python-format-final.2026-08-24T00-00.md`
- **Exit code recorded there:** 0
- **Observation beyond the exit code, quoted from that artifact:**

  > Its summary line is `455 files left unchanged.`, which contains the literal `left unchanged`. No output line contains the literal `reformatted`.

- **Why that observation discriminates:** `black` prints `reformatted <path>` for every file it rewrites and a trailing `N files left unchanged.` summary for those it did not. The presence of `left unchanged` together with the absence of `reformatted` is what shows the tool wrote nothing. Register entry 1 of the write-mode register names the markers `reformatted`, `left unchanged`, and `unchanged` for exactly this tool.

## Entry 2 — the Python linter

- **Tool:** `ruff check`
- **Command:** `poetry run ruff check .`
- **Task and artifact:** [P8-T2], `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/python-lint-final.2026-08-24T00-00.md`
- **Exit code recorded there:** 0
- **Observation beyond the exit code, quoted from that artifact:**

  > Its final line is `All checks passed!`, which contains the literal `All checks passed!`. No output line contains the literal `Fixed`.

- **Why that observation discriminates:** `pyproject.toml` configures `fix = true`, so `ruff check` rewrites fixable violations in place and still exits 0. The presence of `All checks passed!` together with the absence of `Fixed` is what shows no violation was found and none was repaired. Register entry 2 names the markers `Fixed`, `All checks passed`, and `fixes applied` for this tool.

## Entry 3 — the TypeScript format script

- **Tool:** `prettier --write`, invoked through `npm run format`
- **Command:** `npm run format` from `extensions/drm-copilot`
- **Task and artifact:** [P8-T6], `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/typescript-format-final.2026-08-24T00-00.md`
- **Exit code recorded there:** 0
- **Observation beyond the exit code, quoted from that artifact:**

  > processed-file count 408; count of printed file lines carrying the trailing literal `(unchanged)` 408. The two counts are equal

  and, as a second and independent observation recorded in the same artifact:

  > `git status --porcelain -- extensions/drm-copilot` produced **no output** after the run

- **Why that observation discriminates:** `prettier --write` prints one line per processed file; a file it did not rewrite carries the trailing literal `(unchanged)` and a file it rewrote does not. Equality of the two counts is what shows every processed file was left alone. Register entry 3 names the markers `(unchanged)`, `unchanged`, and `rewrote` for this tool. The porcelain-status observation is independent of the tool's own output and corroborates it.

## Tools deliberately not listed

- **`pyright`, `eslint`, and `tsc --noEmit`** are read-only invocations. `eslint` was run without `--fix` and `tsc` with `--noEmit`, so none of them can write a source file and none is a write-mode register member.
- **`npm ci`** was run once during this phase to repair an incomplete dependency tree. It is excluded from the write-mode register because its only write target, `node_modules`, is git-ignored. That exclusion and its reason are recorded in `.claude/rules/plan-acceptance-gates.md` by [P7-T2]. Its own observation beyond the exit code was nonetheless captured — `added 457 packages, and audited 458 packages in 6s` — and is recorded in `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/typescript-lint-final.2026-08-24T00-00.md`.
- **`pytest` and `jest`** write under the artifacts tree (`artifacts/python/lcov.info` and the coverage output) without being register members; that fact is recorded in the rule file by [P7-T2].
- **The three PoshQC tools** are register members but were not run by this plan: this change touches no PowerShell file.

## Verdict

**PASS.** Three write-mode tools were run; each is named, each carries a quoted observation beyond its exit code, and each observation names the artifact path it was read from. No entry's only recorded evidence is an exit code.
