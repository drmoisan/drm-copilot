# PowerShell Test and Coverage Gate — [P2-T9]

Timestamp: 2026-09-07T12-09
Task: [P2-T9]

Command: MCP tool `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29` and no other argument; then `Select-String -LiteralPath artifacts/pester/pester-junit.xml -Pattern '^<testsuites '`, `Select-String -LiteralPath artifacts/pester/powershell-coverage.xml -Pattern '^  <counter type="LINE"'`, and `Select-String -LiteralPath artifacts/pester/pester-junit.xml -Pattern 'exactly without changing checkpoint bytes' -SimpleMatch`
EXIT_CODE: 0

The counts are read from the artifacts the tool writes, exactly as [P0-T5] did, because the tool itself prints no counts.

## MCP tool result (verbatim)

```
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29","summary":"Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29'."}
```

## Root testsuites element (verbatim)

```
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="3940" errors="0" failures="0" disabled="9" time="180.597">
```

- failures: 0 (required: 0)
- errors: 0 (required: 0)
- tests: 3940 versus the [P0-T5] baseline 3940 (required: at least baseline)

## Byte-identity cases

`Select-String` for `exactly without changing checkpoint bytes` returned 6 matches (required: at least 6). Each of the six distinct expanded case names named in [P1-T16] is present in the JUnit report, and none of the six `testcase` elements carries a `failure` child:

```
Codex epic preparation, wave, merge, and worktree gates.preparation route.denies malformed MCP id exactly without changing checkpoint bytes | FAILURE_CHILD=False
Codex epic preparation, wave, merge, and worktree gates.preparation route.denies unrelated MCP server exactly without changing checkpoint bytes | FAILURE_CHILD=False
Codex epic preparation, wave, merge, and worktree gates.preparation route.denies unregistered MCP operation exactly without changing checkpoint bytes | FAILURE_CHILD=False
Codex epic preparation, wave, merge, and worktree gates.preparation route.denies approximate MCP operation exactly without changing checkpoint bytes | FAILURE_CHILD=False
Codex epic preparation, wave, merge, and worktree gates.preparation route.denies shell edit exactly without changing checkpoint bytes | FAILURE_CHILD=False
Codex epic preparation, wave, merge, and worktree gates.preparation route.denies production patch exactly without changing checkpoint bytes | FAILURE_CHILD=False
CASE_COUNT=6
```

## Report-level line coverage

```
  <counter type="LINE" missed="411" covered="7447" />
```

Line coverage = 7447 / (7447 + 411) = 7447 / 7858 = 94.7697%.

| Metric | [P0-T5] baseline | This run | Verdict |
| --- | --- | --- | --- |
| failures | 0 | 0 | meets requirement |
| errors | 0 | 0 | meets requirement |
| tests | 3940 | 3940 | at least baseline |
| missed | 411 | 411 | — |
| covered | 7447 | 7447 | — |
| line coverage | 94.7697% | 94.7697% | at least baseline, and at least 85.00% |

Output Summary: The Pester run reports `failures="0"` and `errors="0"` over `tests="3940"`, equal to the [P0-T5] baseline count. All six byte-identity case names are present in the JUnit report and none carries a `failure` child, so the retargeted cases pass under the full PoshQC suite as well as under the direct `Invoke-Pester` run of [P1-T16]. Report-level line coverage is 94.7697%, identical to the baseline and above the 85.00% floor. Pester does not measure branch coverage, so no branch threshold applies.
