# Known-Red Inventory (issue #545)

Timestamp: 2026-09-07T11-53

Task: [P1-T13]

Command: derived from the five fail-before artifacts listed below; no additional command was executed

EXIT_CODE: 0

## Purpose

Regression tests are written before the fixes that make them pass, so a repository-wide green
assertion is unsatisfiable from Phase 1 until Phase 10. Every batch toolchain gate from Phase 2
onward is evaluated against **this inventory** rather than against an absolute zero: stage 3 of the
gate accepts a failing test only when its name is a member of this inventory minus the entries that
batch closes.

## Source artifacts

| Task | Artifact | Failing cases recorded |
| --- | --- | --- |
| [P1-T3] | `evidence/regression-testing/fail-before-acceptance-cases.2026-09-07T11-35.md` | 6 |
| [P1-T5] | `evidence/regression-testing/fail-before-claude-triggerscoping.2026-09-07T11-40.md` | 13 |
| [P1-T7] | `evidence/regression-testing/fail-before-codex-triggerscoping.2026-09-07T11-44.md` | 13 |
| [P1-T9] | `evidence/regression-testing/fail-before-claude-commandexemption.2026-09-07T11-48.md` | 1 |
| [P1-T11] | `evidence/regression-testing/fail-before-codex-commandexemption.2026-09-07T11-52.md` | 1 |
| | **Union total** | **34** |

## Inventory

Row count: **34**. One row per failing test name, with the phase that closes it.

### From [P1-T3] — `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1` (6 rows)

| # | `It` name | Closed by phase | Closing task |
| --- | --- | --- | --- |
| 1 | `AT-1 denies a relocating git worktree remove against an epic checkpoint with no authorizing record` | **8** | [P8-T14] |
| 2 | `AT-2 returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag` | **9** | [P9-T11] |
| 3 | `AT-3 allows a heredoc whose JSON body names promotion tools as receipt values` | **6** | [P6-T9] |
| 4 | `AT-4 allows a printf whose double-quoted text mentions the gated merge phrase` | **9** | [P9-T11] |
| 5 | `AT-5 blocks a relocating gh issue create spelling that carries a repo global option` | **6** | [P6-T9] |
| 6 | `AT-7 resolves the worktree path when the force flag precedes it, in both removal gates` | **8** | [P8-T14] |

### From [P1-T5] — `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` (13 rows)

All thirteen are closed by **Phase 5**, task [P5-T3], which rewrites the Claude preimplementation
gate's `Test-ImplementationCommand` onto per-segment scan text plus the structural `git` legs.

| # | `It` name | Closed by phase |
| --- | --- | --- |
| 7 | `allows a quoted mention of the staging invocation inside an echo argument` | **5** |
| 8 | `allows a heredoc body that quotes the staging invocation in prose` | **5** |
| 9 | `allows prose containing the English word black` | **5** |
| 10 | `allows a cross-segment line whose npm segment and lint mention are in different segments` | **5** |
| 11 | `denies a relocating git add carrying a directory global option` | **5** |
| 12 | `denies a relocating git commit carrying a git-dir global option` | **5** |
| 13 | `denies a relocating git add carrying a work-tree global option` | **5** |
| 14 | `denies an unmodeled dash-leading token between git and its subcommand` | **5** |
| 15 | `denies the subshell spelling of a staging command` | **5** |
| 16 | `denies the command-substitution spelling of a staging command` | **5** |
| 17 | `wrapper deny pin 2: denies a staging command nested inside a bash -c argument` | **5** |
| 18 | `wrapper deny pin 3: denies a staging command nested inside an sh -c argument` | **5** |
| 19 | `wrapper deny pin 7: denies a live substitution inside a double-quoted span` | **5** |

### From [P1-T7] — `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` (13 rows)

All thirteen are closed by **Phase 5**, task [P5-T7], which applies the equivalent edit to the Codex
copy. The `It` names are identical to rows 7 through 19; the rows are distinct because they belong to
a different suite file.

| # | `It` name | Closed by phase |
| --- | --- | --- |
| 20 | `allows a quoted mention of the staging invocation inside an echo argument` | **5** |
| 21 | `allows a heredoc body that quotes the staging invocation in prose` | **5** |
| 22 | `allows prose containing the English word black` | **5** |
| 23 | `allows a cross-segment line whose npm segment and lint mention are in different segments` | **5** |
| 24 | `denies a relocating git add carrying a directory global option` | **5** |
| 25 | `denies a relocating git commit carrying a git-dir global option` | **5** |
| 26 | `denies a relocating git add carrying a work-tree global option` | **5** |
| 27 | `denies an unmodeled dash-leading token between git and its subcommand` | **5** |
| 28 | `denies the subshell spelling of a staging command` | **5** |
| 29 | `denies the command-substitution spelling of a staging command` | **5** |
| 30 | `wrapper deny pin 2: denies a staging command nested inside a bash -c argument` | **5** |
| 31 | `wrapper deny pin 3: denies a staging command nested inside an sh -c argument` | **5** |
| 32 | `wrapper deny pin 7: denies a live substitution inside a double-quoted span` | **5** |

### From [P1-T9] — `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` (1 row)

| # | `It` name | Closed by phase | Closing task |
| --- | --- | --- | --- |
| 33 | `denies a message-body payload that merely contains the staging literal` | **5** | [P5-T3] |

### From [P1-T11] — `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (1 row)

| # | `It` name | Closed by phase | Closing task |
| --- | --- | --- | --- |
| 34 | `denies a message-body payload that merely contains the staging literal` | **5** | [P5-T7] |

## Union check

| Source | Count |
| --- | --- |
| [P1-T3] | 6 |
| [P1-T5] | 13 |
| [P1-T7] | 13 |
| [P1-T9] | 1 |
| [P1-T11] | 1 |
| Sum | **34** |
| Rows in this inventory | **34** |

The two sets are equal. Every name in this inventory appears in one of the five fail-before
artifacts, and every failing name recorded in those five artifacts appears here.

## Expected red count by phase boundary

| After phase | Rows still red | Rows closed |
| --- | --- | --- |
| 1 (now) | 34 | 0 |
| 5 | 6 | 28 (rows 7 through 34) |
| 6 | 4 | rows 3 and 5 close |
| 8 | 2 | rows 1 and 6 close |
| 9 | 0 | rows 2 and 4 close |

Phases 2, 3, 4, 7, and 10 close no row of this inventory. Their batch toolchain gates must therefore
find the full set still red for the suites they touch, which is the correct expectation and not a
failure signal.

## Amendment 1 — rows appended at [P10-T2] on 2026-09-07T15-10

Phase 10 writes its own regression tests before the fix that makes them pass, exactly as Phase 1 did,
so it adds rows to this inventory rather than only closing them. The four rows below were observed
failing against the unfixed `.claude/hooks/validate-bash.ps1` and are recorded in
`evidence/regression-testing/fail-before-validate-bash.2026-09-07T15-10.md`.

### From [P10-T2] — `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` (4 rows)

| # | `It` name | Closed by phase | Closing task |
| --- | --- | --- | --- |
| 35 | `AT-8 allows git push --force-with-lease because --force-with-lease is not the token --force` | **10** | [P10-T3] |
| 36 | `AT-9 denies a relocating git push --force carrying a directory global option` | **10** | [P10-T3] |
| 37 | `AT-10 allows a commit message that quotes a dangerous pattern in prose` | **10** | [P10-T3] |
| 38 | `allows a commit message whose quoted text contains a cd-then-read phrase` | **10** | [P10-T3] |

The fifth case in that suite, `still denies a read command that is not adjacent to the cd segment`,
**passed** against the unfixed hook and is deliberately NOT an inventory row. It is a preservation
pin for existing non-adjacent reach that acceptance criterion 9 forbids narrowing.

### Revised row count and closure schedule

| After phase | Rows still red | Note |
| --- | --- | --- |
| 1 | 34 | original inventory |
| 5 | 6 | 28 rows closed |
| 6 | 4 | rows 3 and 5 close |
| 8 | 2 | rows 1 and 6 close |
| 9 | **0** | rows 2 and 4 close; observed at [P9-T11] |
| 10 (at [P10-T2]) | **4** | rows 35 through 38 added |
| 10 (at [P10-T3]) | **0** | rows 35 through 38 close |

Total rows in this inventory after amendment 1: **38**.

## Amendment 2 — rows appended at [P10-T14] on 2026-09-07T15-28

The second Phase 10 regression-first suite adds three more rows. All three were observed failing
against the unfixed `.claude/hooks/enforce-parallel-abandon-gate.ps1` and are recorded in
`evidence/regression-testing/fail-before-parallel-abandon.2026-09-07T15-28.md`.

### From [P10-T14] — `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` (3 rows)

| # | `It` name | Closed by phase | Closing task |
| --- | --- | --- | --- |
| 39 | `AT-11 takes a grep whose quoted search term is the disposition token out of scope` | **10** | [P10-T15] |
| 40 | `AT-12 brings the equals-joined spelling of the disposition option into scope` | **10** | [P10-T15] |
| 41 | `does not accept a confirmation marker that sits in a different segment from the disposition token` | **10** | [P10-T15] |

### Revised row count and closure schedule

| After phase or task | Rows still red | Note |
| --- | --- | --- |
| 9 | **0** | rows 2 and 4 close; observed at [P9-T11] |
| 10, at [P10-T2] | 4 | rows 35 through 38 added |
| 10, at [P10-T3] | **0** | rows 35 through 38 close; observed at [P10-T6] |
| 10, at [P10-T14] | 3 | rows 39 through 41 added |
| 10, at [P10-T15] | **0** | rows 39 through 41 close; observed at [P10-T16] |

Total rows in this inventory after amendment 2: **41**.

## Appendix — pre-existing baseline failures, NOT part of this inventory

The following two failures were observed on the unmodified baseline tree at HEAD
`a36b6dca7809e456f00c7d5b01eec5da49f7fca0` and are recorded in
`evidence/baseline/baseline-selfhosted-test.2026-09-07T10-57.md`. They are **excluded from the
inventory union above**, so that the union-equality check with the five fail-before artifacts remains
exact. They are recorded here so a later reviewer seeing them in a wider run can attribute them
correctly.

| Suite | `It` | Cause |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | Pre-existing at baseline. Returns `deny` where `allow` is expected. |
| `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `allows every registered handler for every tool name its own matcher admits` | Pre-existing at baseline. `enforce-epic-wave-barrier.ps1` denies with `EPIC_WAVE_BARRIER_BLOCKED` because the epic checkpoint in this worktree names item `545` with unmerged `depends_on` edges. Ambient-state dependent. |

A third condition is expected to appear from [P1-T2] onward and is likewise not part of this
inventory: `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. It passed at baseline because
`.claude/state/` was empty; the batch-budget hook has since written a state file there, and that file
has no bundle mirror. The cause is open issue #510, and the plan's assertions against that module are
stated as selected-case assertions that exclude it by node ID.

Output Summary: Known-red inventory recorded with **34 rows**, one per failing test name from the
five Phase 1 fail-before artifacts, each carrying the phase that closes it. Union check passes: 6 +
13 + 13 + 1 + 1 = 34 equals the 34 rows listed. Closure schedule: 28 rows close in Phase 5, 2 in
Phase 6, 2 in Phase 8, and 2 in Phase 9, reaching zero after Phase 9. Two pre-existing baseline
failures and one expected issue #510 condition are recorded in an appendix and are explicitly
excluded from the inventory union.
