# Fail-before exception dossier — B-3, the unreadable-session-id catch block in both hooks

Timestamp: 2026-08-30T00-48

Task: [P2-T7] of the cycle-1 remediation plan for issue #596.

Finding covered: B-3, Minor (folded in) — the unreadable-session-id catch block is untested in both
hook suites.

## Execution context

The plan states its commands worktree-relative. Every command reproduced in this dossier was
executed with the absolute prefix
`cd "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5" && ` prepended
to the plan's command text. The plan's command text is recorded verbatim in each `Command:` field.

Command: `pwsh -NoProfile -Command '[xml]$report = Get-Content -LiteralPath "artifacts/pester/powershell-coverage.xml" -Raw; $targets = @{ ".claude/hooks/enforce-powershell-batch-budget.ps1" = @(154, 155); ".claude/hooks/enforce-python-batch-budget.ps1" = @(151, 152) }; foreach ($leaf in $targets.Keys) { foreach ($pkg in @($report.report.package)) { foreach ($sf in @($pkg.sourcefile)) { $full = ($pkg.name + "/" + $sf.name).Replace("\", "/"); if ($full.EndsWith("/" + $leaf)) { foreach ($nr in $targets[$leaf]) { $ln = @($sf.line) | Where-Object { [int]$_.nr -eq $nr }; if ($ln) { "{0} line={1} mi={2} ci={3}" -f $leaf, $nr, $ln.mi, $ln.ci } else { "{0} line={1} ABSENT" -f $leaf, $nr } } } } } }'`

This is the plan's Form D per-line coverage extraction. It was executed four times across the
remediation: once in [P0-T10], once in [P0-T11], once in [P1-T6], and once in [P2-T6]. Every
invocation exited 0.

EXIT_CODE: 0

Output Summary: All four invocations of Form D exited 0. The eight rows they produced move the four
targeted catch-body lines from `ci=0` before the remediation to `mi=0` with `ci` greater than 0
after it, which is the alternative proof this dossier supplies in place of a failing run.

## WhyFailingRunImpossible

The catch block already exists and already behaves correctly at
`.claude/hooks/enforce-powershell-batch-budget.ps1:151-156` and
`.claude/hooks/enforce-python-batch-budget.ps1:148-153`: each wraps the `ReadSessionIdFile`
invocation in `try`/`catch`, writes a verbose diagnostic, and resets `$fromFile` so resolution falls
through to the worktree-derived identifier. B-3 changes no production line, because the defect is the
absence of a test rather than a defect in behaviour. A test that drives the catch therefore passes
against the pre-remediation tree by construction, so tagging its task `[expect-fail]` would assert a
failure the executor cannot produce.

## Alternative proof — the four targeted lines move from uncovered to covered

The two statements in each catch block are the proof surface. In the PowerShell hook they are
absolute lines 154 and 155; in the Python hook they are absolute lines 151 and 152. Those absolute
numbers stayed valid across the whole remediation because the D-1 edit was a strict one-line-for-one-
line replacement: [P1-T4] verified the PowerShell hook still measures 457 lines and [P2-T4] verified
the Python hook still measures 454 lines, each unchanged from the [P0-T5] baseline.

### The four before rows, `ci=0`

| Source task | File | Line | Statement | mi | ci |
| --- | --- | --- | --- | --- | --- |
| [P0-T10] | `.claude/hooks/enforce-powershell-batch-budget.ps1` | 154 | `Write-Verbose "Ignoring unreadable session-id file ..."` | 2 | 0 |
| [P0-T10] | `.claude/hooks/enforce-powershell-batch-budget.ps1` | 155 | `$fromFile = ''` | 1 | 0 |
| [P0-T11] | `.claude/hooks/enforce-python-batch-budget.ps1` | 151 | `Write-Verbose "Ignoring unreadable session-id file ..."` | 2 | 0 |
| [P0-T11] | `.claude/hooks/enforce-python-batch-budget.ps1` | 152 | `$fromFile = ''` | 1 | 0 |

Source artifacts:
`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/remediation-baseline/powershell-suite-baseline.2026-08-29T23-07.md`
and
`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/remediation-baseline/python-suite-baseline.2026-08-29T23-07.md`.

### The four after rows, `mi=0`

| Source task | File | Line | Statement | mi | ci |
| --- | --- | --- | --- | --- | --- |
| [P1-T6] | `.claude/hooks/enforce-powershell-batch-budget.ps1` | 154 | `Write-Verbose "Ignoring unreadable session-id file ..."` | 0 | 2 |
| [P1-T6] | `.claude/hooks/enforce-powershell-batch-budget.ps1` | 155 | `$fromFile = ''` | 0 | 1 |
| [P2-T6] | `.claude/hooks/enforce-python-batch-budget.ps1` | 151 | `Write-Verbose "Ignoring unreadable session-id file ..."` | 0 | 2 |
| [P2-T6] | `.claude/hooks/enforce-python-batch-budget.ps1` | 152 | `$fromFile = ''` | 0 | 1 |

Source artifacts:
`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/regression-testing/powershell-containment-pass-after.2026-08-29T23-07.md`
and
`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/regression-testing/python-containment-pass-after.2026-08-29T23-07.md`.

Each of the eight rows names its file and its line number, and each before row is paired with the
after row for the same file and line. The transition is genuine rather than nominal: `ci` is the
covered-instruction count, so a move from `ci=0` to `ci=2` and `ci=1` records that the two statements
were actually executed by the new tests.

### What drives the catch

One test per suite, titled `falls through to the worktree-derived id when the session-id file is
unreadable`, calls `Get-PowerShellBatchBudgetSessionId` or `Get-PythonBatchBudgetSessionId` directly
with `-SessionId ''`, `$env:CLAUDE_SESSION_ID` set to the empty string, and a `-ReadSessionIdFile`
scriptblock whose body throws. The throw enters the catch, the two statements execute, and the
function falls through to the worktree-derived identifier, which the test asserts against the pattern
`^worktree-repo-[0-9a-f]{8}$`. Both tests passed in [P1-T6] and [P2-T6] with no `failure` child, and
both are absent from the failing sets recorded in [P1-T3] and [P2-T3], confirming they also passed
before the D-1 fix landed.

Calling the resolver directly rather than driving it through `Invoke-*BatchBudgetHook` is also the
better test under the isolation requirement in `.claude/rules/general-unit-test.md`, because it
targets the one function whose catch block is the subject. No temporary file is created and no real
filesystem path is touched.

## Negative-evidence record

No failing run for B-3 exists, and this is by construction rather than by omission.

SearchScope: `docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/regression-testing/`
and `docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/remediation-baseline/`

SearchPatterns: `fail-before-exception.*.md`, `*fail-before*.md`

SearchResult: `powershell-containment-fail-before.2026-08-29T23-07.md` and
`python-containment-fail-before.2026-08-29T23-07.md`, both of which are the B-1 fail-before runs and
neither of which contains a B-3 failure; and this dossier itself. The two B-1 fail-before artifacts
each record exactly one failing testcase, named
`discards an absolute candidate path in a sibling directory whose name extends the root`, and
explicitly record that the B-3 test is absent from the failing set.

## Disposition

Under `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, a fail-before exception dossier
carrying `WhyFailingRunImpossible:` plus an alternative proof section satisfies the fail-before
requirement for audit and plan reconciliation. This dossier is that artifact for B-3 in both hooks.
No `[expect-fail]` task was authored for B-3, because a failure the executor cannot produce is not an
acceptance condition.

The exact-root admission guard, titled `admits a candidate path that is exactly the resolved root`,
is likewise not tagged `[expect-fail]` and needs no dossier entry of its own: it passes before and
after the D-1 fix, and its role is to prevent that fix from narrowing behaviour rather than to
demonstrate a defect.
