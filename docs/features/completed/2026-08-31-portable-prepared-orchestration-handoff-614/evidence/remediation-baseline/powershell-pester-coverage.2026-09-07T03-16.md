# PowerShell Pester and Coverage Baseline — [P0-T5]

Timestamp: 2026-09-07T11-02
Task: [P0-T5]

Command: MCP tool `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29` and no other argument; then `Select-String -LiteralPath artifacts/pester/pester-junit.xml -Pattern '^<testsuites '` and `Select-String -LiteralPath artifacts/pester/powershell-coverage.xml -Pattern '^  <counter type="LINE"'`
EXIT_CODE: 0

## MCP tool result (verbatim)

```
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29","summary":"Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29'."}
```

The tool prints no counts, so the counts below are read from the files it wrote.

## Root testsuites element (verbatim)

```
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="3940" errors="0" failures="0" disabled="9" time="215.772">
```

- tests: 3940
- errors: 0
- failures: 0
- disabled: 9

## Report-level LINE counter (verbatim)

```
  <counter type="LINE" missed="411" covered="7447" />
```

- missed: 411
- covered: 7447
- line coverage = covered / (covered + missed) = 7447 / 7858 = 94.7697%

Output Summary: The baseline Pester run recorded `failures="0"` and `errors="0"` over `tests="3940"` with `disabled="9"`. The report-level line counter recorded `missed="411"` and `covered="7447"`, giving a line-coverage percentage of 94.7697%, above the uniform 85.00% floor. The floors for [P2-T9] are therefore: failures 0, errors 0, tests at least 3940, and line coverage at least 94.7697%.
