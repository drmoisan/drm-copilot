# Pass-after — `validate-bash.ps1`, both suites (issue #545)

Timestamp: 2026-09-07T15-14

Task: [P10-T6]

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session because
`pwsh`, `powershell`, and `cmd` cannot be invoked from any context here. Per-suite and per-case
results were read out of `artifacts/pester/pester-junit.xml`.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count; both suites this task measures contribute 0 of it)

## Suite 1 — existing `tests/scripts/claude-hooks/validate-bash.Tests.ps1`

| Measure | Value |
| --- | --- |
| Tests | 26 |
| Failures | **0** |
| Errors | 0 |
| Skipped | 0 |
| Derived passed count | **26** |
| [P0-T10] baseline passed count | **26** |
| Equal to baseline? | **yes** |

The baseline figure is row 1 of `evidence/baseline/baseline-targeted-pester.2026-09-07T11-14.md`.

The two named assertions this task must report on both pass **unmodified**:

| Existing `It` | Result | Why it survives the matching-primitive change |
| --- | --- | --- |
| `returns the matched pattern for every repository-dangerous command` | **PASS unmodified** | All six of its cases are single-segment. `git push origin --force` still returns the literal `'git push origin --force'` rather than the structural leg's `'git push --force'`, because leg 1 is evaluated in full over every literal and every segment before any leg 2 evaluation. |
| `matches every read-command family chained after cd via '&&' or ';'` | **PASS unmodified** | All eight of its cases place a real `cd` segment before a real read segment. The segment walk widens the delimiter set from `&&` and `;` to every segment delimiter, so each remains a match, and the `sed -n` case still returns `sed -n` because the `sed` leg requires `-n` as the second token. |

Six further existing `It` blocks in the `cd`-chain context also pass unmodified, including
`the dangerous-pattern denylist takes precedence when a command matches both` and
`returns $null for a cd chained with a non-read-command (no false positive on common toolchain invocations)`.
No assertion in this suite was modified, deleted, or weakened.

## Suite 2 — new `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`

| Measure | Value |
| --- | --- |
| Tests | 7 |
| Failures | **0** |
| Errors | 0 |
| Skipped | 0 |

| # | Case | Source | Before [P10-T3] | After [P10-T3] |
| --- | --- | --- | --- | --- |
| 1 | `AT-8 allows git push --force-with-lease because --force-with-lease is not the token --force` | [P10-T1] | FAIL | **PASS** |
| 2 | `AT-9 denies a relocating git push --force carrying a directory global option` | [P10-T1] | FAIL | **PASS** |
| 3 | `AT-10 allows a commit message that quotes a dangerous pattern in prose` | [P10-T1] | FAIL | **PASS** |
| 4 | `allows git push origin main because no force flag is present` | [P10-T4] | not present | **PASS** |
| 5 | `allows git reset --soft HEAD~1 because --soft is not --hard` | [P10-T4] | not present | **PASS** |
| 6 | `allows a commit message whose quoted text contains a cd-then-read phrase` | [P10-T1] | FAIL | **PASS** |
| 7 | `still denies a read command that is not adjacent to the cd segment` | [P10-T1] | PASS | **PASS** |

Case 7 held its value across the change, which is the point of the pin: the non-adjacent reach of the
retained pattern is preserved rather than narrowed.

## Known-red inventory effect

Rows 35 through 38 of the [P1-T13] inventory, appended at [P10-T2], are cases 1, 2, 3, and 6 above.
All four now pass, so **all four close at [P10-T3]** as the amended schedule records. The inventory
returns to **0 rows remaining** at this point in Phase 10, before [P10-T14] adds its own rows.

## Remaining folder-wide failure

`tests/scripts/claude-hooks`: 1517 tests, **1** failure —
`enforce-pr-author-skill.Tests.ps1`, case
`allows gh pr create --body-file artifacts/pr_body_12.md when context exists`, the documented
pre-existing, ambient-state-dependent baseline failure recorded in the inventory's appendix. Not an
inventory member and out of scope.

Output Summary: both suites report **zero failed tests**. The existing suite is
**26 tests / 0 failures**, a derived passed count of **26**, equal to the [P0-T10] baseline of 26; the
two named assertions `returns the matched pattern for every repository-dangerous command` and
`matches every read-command family chained after cd via '&&' or ';'` both pass **unmodified**. The new
suite is **7 tests / 0 failures**, closing known-red inventory rows 35 through 38 (AT-8, AT-9, AT-10,
and the quoted `cd`-chain over-match) and holding the non-adjacent preservation pin at PASS on both
sides of the change. The only folder-wide failure is the documented pre-existing
`enforce-pr-author-skill.Tests.ps1` case.
