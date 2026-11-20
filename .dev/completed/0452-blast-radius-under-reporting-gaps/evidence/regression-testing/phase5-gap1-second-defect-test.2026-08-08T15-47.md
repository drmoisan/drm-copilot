# [P5-T5] Gap 1 second defect-asserting test — pre-inversion failing run

Timestamp: 2026-08-08T15-47

Command: `pwsh -NoProfile -Command "$c = New-PesterConfiguration; $c.Run.Path = 'tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1'; $c.Output.Verbosity = 'Detailed'; $c.Run.PassThru = $true; $r = Invoke-Pester -Configuration $c"`

EXIT_CODE: 1

Output Summary:

Pre-inversion state. `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1:248-262` holds
`It 'cannot reach a separator-free repository-root surface from plan text'`, which asserts
`@($radius['shared_surfaces']).Count | Should -Be 0` for the plan text
`- [ ] [P1-T1] Touch \`poetry.lock\`.` under `$script:TestConfig` whose `shared_surfaces` list is
`@('poetry.lock', 'config/orchestration-routing.json')` (line 35).

Result: `Tests Passed: 34, Failed: 1, Skipped: 0`.

The single failure is the target block:

```
[-] cannot reach a separator-free repository-root surface from plan text 20ms
  at @($radius['shared_surfaces']).Count | Should -Be 0, BlastRadius.Tests.ps1:261
  Expected 0, but got 1.
```

This is the expected `[expect-fail]` outcome. The completed Gap 1 fix ([P3-T1]..[P4-T9],
[P5-T1], [P5-T2]) makes `Get-BlastRadius` pass `-RootSurface (Get-ConfigRootSurface -Config $Config)`
to `Get-PlanPaths`, so the configured separator-free surface `poetry.lock` is now reached from
plan text and the derived radius carries exactly one shared surface. The old assertion encoded the
Gap 1 defect as intended behaviour.

This is the second of the two authorized existing-assertion changes named in `spec.md` invariant 3
(lines 214-218) and `spec.md` line 671. The first is `BlastRadiusGlob.Tests.ps1:309-316`, inverted
at [P7-T1].

Every other assertion in the file is unaffected: 34 of 35 tests pass, including
`'expands a surface named in the literal truth-table list'`,
`'expands a surface matched only by a shared-surface glob'`, and
`'never expands a glob path into a shared surface'`.
