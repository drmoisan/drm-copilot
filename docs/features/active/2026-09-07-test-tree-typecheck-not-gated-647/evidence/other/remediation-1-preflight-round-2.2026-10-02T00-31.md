# Remediation Cycle 1 — Executor Preflight, Round 2 (issue #647)

Timestamp: 2026-10-02T00-31
Directive: PREFLIGHT VALIDATION ONLY
Plan: `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/remediation-plan.2026-10-02T00-06.md` (revision 1)
Worktree HEAD: `cc0c59b24663eed036a11ab7ef566ab0aa42b8c5` (branch `bug/test-tree-typecheck-not-gated-647`; `origin/bug/test-tree-typecheck-not-gated-647` at the same SHA; `git status --porcelain` empty)
Result: PREFLIGHT: REVISIONS REQUIRED
Convergence: CONVERGENCE: NO FURTHER ROUNDS EXPECTED

## Round-1 deltas

| Delta | Location | Status |
|---|---|---|
| D1 | Section 1, rule 11, final clause | Applied verbatim: `or `TEST_FILE` (in Phase 1, from [P1-T1] until the [P1-T8] commit; in Phase 2, only after a loop-restart repair).` Consistent with [P1-T4] (permitted-paths check while `TEST_FILE` is dirty), [P1-T6] (lists `TEST_FILE` as modified), [P2-T1] (first pass must not list `TEST_FILE`), and [P2-T12] (adds `TEST_FILE` only after a restart repair). |
| D2 | [P2-T9] Acceptance, second clause | Applied verbatim: `the numstat command prints no line (the file is unchanged since `BASE_SHA`), or prints one line whose added count is at most its deleted count;`. Consistent with the sibling clauses of [P2-T9]; the condition still fails on a row whose added count exceeds its deleted count. |

The revision note (line 7) states that no task, command, or write path was added or removed. `git diff -U0 40a20ac0 HEAD -- <plan>` confirms this: the only changed lines are the header (Last Updated, Status, Revision note), rule 11, and [P2-T9].

## Verification performed (read-only; no repository file other than this record was written)

| Check | Command or method | Result |
|---|---|---|
| Change since round 1 | `git diff --name-only 40a20ac0 HEAD` | only the round-1 record and the plan file; no file under `extensions/` changed, so the round-1 baseline observations (P0-T14 `TSC_EXIT=0`, P0-T15 `5 passed, 5 total`, 3786 full-suite count) remain valid. |
| Base SHA | `git merge-base origin/main HEAD` | `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9`, equal to the audit base. |
| Cited lines in `TEST_FILE` | `grep -n` | 163 lines; title at 82; line 83 begins `// Arrange: optional fields omitted;`; `// Act` at 90; five `in result` assertions at 97-101. Matches section 0 and [P1-T1]. |
| Pre-change token counts | `grep -c` for `value: undefined`, `const optionalKeys = \[`, `expect(Object.entries(input)).toEqual(`, `Object.defineProperty(input, key` | all 0, so the "prints 1" conditions in [P1-T1] and [P1-T3] cannot be met by pre-existing text. |
| npm scripts | `extensions/drm-copilot/package.json` lines 208-213 | `lint` script text contains no `problem` token ([P2-T2]); `typecheck` chains `typecheck:test`, whose banner is `> tsc -p tsconfig.jest.json --noEmit` ([P2-T3]); `test:coverage` passes `text-summary` ([P0-T16], [P2-T6]). |
| Success literals | prior recorded runs: `qa-gates/phase-1-format`, `final-prettier-write`, `final-typecheck`, `final-coverage`, `final-prettier-check` (all `2026-10-01T23-18`) | `(unchanged)` suffix, typecheck banner, `Lines`/`Branches` rows (97.07 / 91.35) with `Tests: 3786 passed, 3786 total`, and `All matched files use Prettier code style!` all appear in recorded success-case runs. |
| Ignored executor state | `git check-ignore -v .claude/agent-memory/atomic-executor/x.md` | ignored (`.gitignore:67`), so executor memory writes cannot add a porcelain line outside `FEATURE/`. |
| Untracked-files mode | `git config --get status.showUntrackedFiles` | unset (exit 1), so git's default `normal` mode applies. In that mode a file inside a new untracked directory is reported as the directory, not as the file. |
| Evidence subfolders present | `ls FEATURE/evidence/` | `baseline/`, `other/`, `qa-gates/`, `regression-testing/`. `remediation-baseline/` does not exist yet. |

An attempt to demonstrate the untracked-directory collapse in a scratch repository was refused by the worktree-isolation guard, because the command pointed git at a directory outside the worktree. The finding below therefore rests on git's documented default for `git status -u` (`normal`: shows untracked files and directories) and on the configuration check above.

## Clean feature folder: [P0-T13] and [P0-T17]

The orchestrator asked whether these tasks still behave correctly when no uncommitted feature paths exist. The empty case itself is handled: the plan says the `PRE_EXISTING_FEATURE_PATHS` list may be empty, and [P0-T17] then stages only its six named paths. The plan file is modified by the Phase 0 check-offs, so its `git add` stages a real change, and the five new artifacts make the commit non-empty. The defect below occurs whether or not the folder starts clean.

## Defects

### D3 — [P0-T13] records the [P0-T12] artifact's untracked directory as a pre-existing path, and [P0-T17] then stages a directory, which rule 10 prohibits

[P0-T12] creates `FEATURE/evidence/remediation-baseline/phase0-instructions-read.<ts>.md` before [P0-T13] runs. The directory `FEATURE/evidence/remediation-baseline/` does not exist at HEAD, and `status.showUntrackedFiles` is unset. The plain `git status --porcelain` in [P0-T13] therefore prints `?? docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/evidence/remediation-baseline/` (a directory entry) next to ` M` for the plan file. Under the [P0-T13] text, "every listed path other than `FEATURE/remediation-plan.2026-10-02T00-06.md`" goes into `PRE_EXISTING_FEATURE_PATHS`, so that list holds the directory, and the directory is mislabelled as pre-existing. [P0-T17] then stages "each path in `PRE_EXISTING_FEATURE_PATHS` ... named individually", which here means `git add` of a directory. Rule 10 says staging is "never `-A`, `.`, or a directory". The executor would face conflicting instructions at [P0-T17]. If it stopped there, the plan would block on a clean tree.

The Phase 1 and Phase 2 porcelain checks are not affected, because `evidence/regression-testing/` and `evidence/qa-gates/` are tracked directories, so new files in them are listed individually.

Delta ([P0-T13], replace the command list and the `PRE_EXISTING_FEATURE_PATHS` sentence):
- Old: `` `git merge-base origin/main HEAD` (`BASE_SHA`), and `git status --porcelain`. ``
- New: `` `git merge-base origin/main HEAD` (`BASE_SHA`), and `git status --porcelain --untracked-files=all`. ``
- Old: `Every listed path other than `FEATURE/remediation-plan.2026-10-02T00-06.md` is recorded verbatim as `PRE_EXISTING_FEATURE_PATHS``
- New: `Every listed path other than `FEATURE/remediation-plan.2026-10-02T00-06.md` and `FEATURE/evidence/remediation-baseline/phase0-instructions-read.<ts>.md` is recorded verbatim as `PRE_EXISTING_FEATURE_PATHS``

After the delta, a clean start gives an empty `PRE_EXISTING_FEATURE_PATHS`, and [P0-T17] stages exactly its six named files. An uncommitted file such as this round-2 record, if the orchestrator has not committed it, is listed by its own path and staged individually. The "no path outside `FEATURE/`" check keeps its meaning, and with `--untracked-files=all` it inspects file paths, not collapsed directory names.

## Non-blocking observations (no delta required)

- Line 6 still reads "awaiting validator run"; the orchestrator reports that the validator has passed. This is status wording only.
- The plan validator was not re-run in this pass because the `validate_orchestration_artifacts` MCP tool is not available to this agent. The G6 warning on `grep -c ''` in [P2-T9] remains a false positive for the reason recorded in round 1.
- [P2-T9]'s over-limit filter relies on `grep -c` printing `path:count`, which requires more than one `.ts` path in `SCRATCH/am-files.txt`. Round 1 observed 64 paths, and Phase 1 adds no file, so this holds.

## Whole-plan pass

All of section 1 (rules 1-12), section 2, Phase 0 ([P0-T1] to [P0-T17]), Phase 1 ([P1-T1] to [P1-T8]), Phase 2 ([P2-T1] to [P2-T12]), and the section 3 traceability table were reviewed in this pass. Apart from D3, no defect was found. Task IDs are sequential per phase, and the phase headings use the canonical form. Every evidence path resolves to `FEATURE/evidence/{remediation-baseline,regression-testing,qa-gates}/`. No command contains `cd`, a heredoc, `pwsh`, `bash`, `wsl`, or a shell variable other than `$?`. The `$` characters in the [P2-T9] regexes are anchors inside single quotes.

## Delta self-check

D3 adds one git flag to an existing [P0-T13] command and one exclusion to an existing sentence. It adds no task, no write path, no shell construct the worktree guard refuses, and no placeholder in an asserted token. The `<ts>` in the exclusion follows the rule 1 symbol convention, which the plan already uses in the [P0-T17] paths. The condition can still fail: [P0-T13] still blocks on any path outside `FEATURE/`, and [P0-T17] still requires an empty porcelain and matching `HEAD`/remote SHAs after the commit. The delta stages no directory, so it complies with rule 10. Its wording is plain, in line with `.claude/rules/tonality.md`.
