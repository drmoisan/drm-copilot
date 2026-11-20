# Pre-Fix Consumer Fixture Coverage Check (P2-T7) [expect-fail]

Timestamp: 2026-10-02T07-55
Command: MCP-satisfiable deviation DEV-P2-T7 (replaces FX args 'tests/fixtures/poshqc-consumer'): rule FX evaluated by inspection of tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml (Read tool) produced by the P2-T6 MCP run
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: SOURCEFILES=1 SAMPLE_PRESENT=0 SAMPLE_LINE_COVERED=0 STANDIN_PRESENT=1 CLAUDE_KEYS=1 OUTSIDE_PACKAGES=0
- FX exit is 1 because SAMPLE_PRESENT != 1 (the consumer's production file scripts/Sample.psm1 is not measured).
- The plan's expected SAMPLE_PRESENT=0 and STANDIN_PRESENT=1 reproduced: the pushed-down stand-in .claude/hooks/validate-bash.ps1 is the only measured file, and Sample.psm1 is absent. This reproduces issue #623 item 1 with the pre-fix (installed) PoshQC copy.
- Acceptance: FX line shows SAMPLE_PRESENT=0 and STANDIN_PRESENT=1. Met.

## Derivation by inspection (FX field by field)

The coverage XML holds one `package` element, name `<ROOT>/tests/fixtures/poshqc-consumer/.claude/hooks` (forward slashes; `<ROOT>` contains a `.claude/worktrees` segment, which FX strips before matching), containing one `sourcefile` name="validate-bash.ps1" with `<counter type="LINE" missed="1" covered="0" />` and one `<line nr="24" mi="1" ci="0" />`. Report-level LINE counter: missed=1 covered=0.

| FX field | Value | Basis |
| --- | --- | --- |
| SOURCEFILES | 1 | one `sourcefile` element across all packages |
| SAMPLE_PRESENT | 0 | no `sourcefile` whose leaf name is `Sample.psm1` |
| SAMPLE_LINE_COVERED | 0 | SAMPLE_PRESENT is not 1, so FX sets 0 |
| STANDIN_PRESENT | 1 | one `sourcefile` named `validate-bash.ps1` |
| CLAUDE_KEYS | 1 | the package name made fixture-root-relative is `.claude/hooks`, which matches `(^|/)\.(claude|codex)(/|$)` |
| OUTSIDE_PACKAGES | 0 | the root-relative package name `.claude/hooks` is not rooted |

FX exit expression: `-not (SAMPLE_PRESENT -eq 1 -and SAMPLE_LINE_COVERED -gt 0)` = true, so exit 1.

## Coverage XML package element (root replaced)

```text
<package name="<ROOT>/tests/fixtures/poshqc-consumer/.claude/hooks">
  <sourcefile name="validate-bash.ps1">
    <line nr="24" mi="1" ci="0" mb="0" cb="0" />
    <counter type="LINE" missed="1" covered="0" />
  </sourcefile>
</package>
```
