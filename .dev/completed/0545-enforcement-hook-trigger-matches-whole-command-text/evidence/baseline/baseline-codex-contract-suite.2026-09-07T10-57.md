# Phase 0 — Baseline Codex Contract Suite

Timestamp: 2026-09-07T10-57

Task: [P0-T12]

Mandated command (attempted first, refused by the runtime worktree-isolation guard):
`pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 -Output Detailed"`

Command:
`mcp__drm-copilot__run_poshqc_test` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31` — the same run recorded in [P0-T7]; this suite's `<testsuite>` element and its 43 `<testcase>` children read from `artifacts/pester/pester-junit.xml`

EXIT_CODE: 2

The exit code 2 belongs to the whole-repository run and is caused by the two pre-existing failures
named in [P0-T7], neither of which is in this suite. This suite reports `failures="0"` and
`errors="0"`.

## Route deviation

The mandated `pwsh` invocation was refused by the runtime worktree-isolation guard, in the same terms
recorded in [P0-T7]; no process started and no exit code was produced. The per-case results below
come from the JUnit report of the whole-repository run, in which this suite is a single
`<testsuite>` element carrying all 43 of its cases.

## Suite result

Verbatim `<testsuite>` record:

```
<testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1" tests="43" errors="0" failures="0" hostname="MEGALODON4" id="122" skipped="0" disabled="0" package="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1" time="13.043">
```

| Figure | Value |
| --- | --- |
| Tests | 43 |
| **Passed** | **43** |
| Failed | 0 |
| Errors | 0 |
| Skipped | 0 |
| Time | 13.043 s |

## The four named results

| Required result | Case that carries it | Status |
| --- | --- | --- |
| **Byte-identity** | `keeps the canonical hooks byte-identical to their bundled copies` | **PASS** |
| **Pack manifest** | `lists every shared hook module in the core pack manifest` | **PASS** |
| **Parse** | `parse-checks each root and bundled hook and keeps every file within 500 lines` | **PASS** |
| **500-line cap** | same case as parse: `parse-checks each root and bundled hook and keeps every file within 500 lines` | **PASS** |

The parse check and the 500-line cap are carried by one `It`, not two. That is recorded explicitly
because an acceptance condition expecting two distinct case names for those two results would be
unsatisfiable against this suite.

Two further cases in the same suite bear on this change and both pass at baseline:

- `contains no legacy Claude environment-variable dependency in hooks or shared modules` — the
  `$env:CLAUDE_` check the new helper files must satisfy once they join `$script:SharedModuleNames`.
- `reads stdin in every hook entrypoint` — the case from which shared-module membership **exempts**
  a file. Membership removes the stdin-read requirement rather than asserting stdin-freeness, so
  entrypoint-freeness of the new helpers is a design obligation, not a test-enforced one, exactly as
  spec D7 records.

## Full case roster, 43 of 43 passing

All 43 cases pass. The roster is grouped as the suite structures it: 13 top-level contract cases,
then 30 cases in the `enforce-orchestration-preimplementation-gate in-process behaviour (issue #415
R1)` context.

Top-level contract cases (13, all PASS):

1. `parse-checks each root and bundled hook and keeps every file within 500 lines`
2. `keeps the canonical hooks byte-identical to their bundled copies`
3. `reads stdin in every hook entrypoint`
4. `contains no legacy Claude environment-variable dependency in hooks or shared modules`
5. `lists every shared hook module in the core pack manifest`
6. `ignores poisoned Claude variables when safe Codex stdin payloads are supplied`
7. `fails closed with exit 2 and stderr for malformed stdin on every hook`
8. `emits the current PreToolUse deny envelope for shell and patch violations`
9. `fails closed when the canonical checkpoint is deleted or becomes invalid JSON`
10. `denies preimplementation and batch-budget violations through their pure decisions`
11. `allows exempt checkpoint writes and preparation-mode delegations (issue #535)`
12. `reconstructs update patches in memory and includes move destinations`
13. `uses one SubagentStop continuation and stops repeated continuation loops`

In-process behaviour context (30, all PASS): the `Test-ImplementationPath` classification cases; the
`Test-ImplementationCommand` classification cases, including
`classifies a git commit as implementation command True`, `classifies a pytest run as implementation
command True`, `classifies an unrelated command as implementation command False`, and the three
`apply_patch` cases; the delegation-classifier cases; the checkpoint-readiness cases; and the
entrypoint cases.

The `Test-ImplementationCommand` classification cases in this context are the deny-preservation pins
the spec's acceptance criteria name (`git commit` returning `$true`, `poetry run pytest` returning
`$true`, an unrelated command returning `$false`, and the `apply_patch` legs). All pass at baseline
and must still pass after the change.

Output Summary: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` reports **43
passed, 0 failed, 0 errors, 0 skipped** in 13.043 s. All four required results are green:
byte-identity PASS, pack-manifest PASS, parse PASS, 500-line-cap PASS — with the parse and line-cap
results carried by a single `It` rather than two. The mandated targeted `pwsh` invocation was refused
by the runtime worktree-isolation guard; results came from this suite's `<testsuite>` element in the
[P0-T7] run.
