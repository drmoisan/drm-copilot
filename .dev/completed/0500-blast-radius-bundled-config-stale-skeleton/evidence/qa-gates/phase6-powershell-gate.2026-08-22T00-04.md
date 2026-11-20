# Phase 6 PowerShell drift gate (Issue #500)

Timestamp: 2026-08-22T00:04:00Z
Issue: #500
Task: [P6-T14]

Command:

```
mcp__drm-copilot__run_poshqc_test (workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-16)
```

Results read from `artifacts/pester/pester-junit.xml` and
`artifacts/pester/powershell-coverage.koverage.xml`.

EXIT_CODE: 0

Output Summary:

- The MCP function returned `"ok": true`.
- `testsuites`: `tests=3119 failures=0 errors=0 time=171.699`
- passed: **3119**
- failed: **0**
- Total `//failure` nodes across the whole JUnit document: **0**.

The test count rose from the Phase 0 baseline of 3116 to 3119, which is the three `It` blocks this
phase adds. The umbrella block was renamed rather than added, so it does not contribute to the
delta.

## The `Committed blast-radius truth table shape` Describe, 17 cases, all passing

The three added by this phase:

| Case | Task | Mirrors |
| --- | --- | --- |
| `Module map.declares only payload modules in the bundled copy` | [P6-T10] | `test_class_three_bundled_modules_are_payload_modules_only` |
| `Shared surfaces.gives every separator-free bundled shared surface no wildcard` | [P6-T11] | `test_every_separator_free_bundled_shared_surface_is_wildcard_free` |
| `Cross-copy key partition.declares equal values for the runtime-describing keys in both copies` | [P6-T9] | `test_class_one_keys_are_equal_across_both_committed_copies` |

The one extended by this phase:

| Case | Task | Change |
| --- | --- | --- |
| `Module map.declares no removed umbrella module in either committed copy` | [P6-T10], [P6-T12] | Was `...in the repository truth table`. Now iterates both committed copies. Its comment no longer claims the bundled module map describes the destination repository's subsystems, and instead records that the key is never read and that `PAYLOAD_MODULES` is the live source. |

Every comparison is ordinal (`-ccontains`, `-cne`), matching the case-sensitive semantics of the
Python reference.

## Coverage

| Counter | Covered | Missed | Percentage |
| --- | --- | --- | --- |
| LINE | 5792 | 228 | **96.21%** |
| INSTRUCTION | 8115 | 334 | 96.05% |
| METHOD | 491 | 25 | 95.16% |
| CLASS | 70 | 0 | 100.00% |

Line coverage is unchanged from the Phase 0 baseline of 96.21%, which is expected: this phase adds
only test code, and test files are outside the coverage denominator. Pester measures no branch
coverage, so no branch threshold applies.

## Toolchain stages run for this phase, in order

| Stage | Command | Exit code |
| --- | --- | --- |
| Format | `mcp__drm-copilot__run_poshqc_format` | 0 (no file rewritten) |
| Analyze | `mcp__drm-copilot__run_poshqc_analyze` | 0 (zero diagnostics) |
| Test | `mcp__drm-copilot__run_poshqc_test` | 0 |

Type checking is not applicable to PowerShell. No stage failed and no stage rewrote a file, so no
restart of the loop was required. The formatter left
`tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` at 353 lines, unchanged
from the count taken before the formatter ran.
