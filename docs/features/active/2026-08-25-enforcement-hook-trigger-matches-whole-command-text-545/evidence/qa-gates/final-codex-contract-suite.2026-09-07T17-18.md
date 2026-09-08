# [P13-T6] Final run of the legacy Codex hook contract suite

Timestamp: 2026-09-07T17-18

Mandated command (attempted first, refused by the runtime worktree-isolation guard):
`pwsh -NoProfile -Command "Invoke-Pester -Path 'tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1'"`

Command:

```
mcp__drm-copilot__run_poshqc_test    # workspace_root: the worktree root, scan_folders: ["tests/scripts/codex-hooks"]
# suite result read from artifacts/pester/pester-junit.xml
```

EXIT_CODE: 1

The exit code belongs to the folder-scoped invocation, not to the target suite. The folder contains
one ambient-state failure in a different file, named below. `legacy-codex-hook-contracts.Tests.ps1`
itself reports **0 failures**.

TOOLCHAIN_SUBSTITUTION: `pwsh` is not invocable anywhere in this session, so `Invoke-Pester` could
not be called against a single file path. The MCP PoshQC test runner accepts a folder scope rather
than a file path, so the suite was run inside the smallest scope that contains it,
`tests/scripts/codex-hooks`, and the per-suite result was read from the emitted
`artifacts/pester/pester-junit.xml` by matching the `testsuite` element whose `name` ends with
`legacy-codex-hook-contracts.Tests.ps1`. That element carries its own `tests`, `errors`, and
`failures` attributes, so the suite's result is isolated from the rest of the folder.

## Suite result

`testsuite` element attributes, verbatim from the report:

```
name="...\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1" tests="43" errors="0" failures="0" skipped="0" disabled="0" time="17.127"
```

| Measure | Value |
|---|---|
| Tests | 43 |
| Errors | 0 |
| **Failures** | **0** |
| Skipped | 0 |
| Wall time | 17.127 s |

**Zero failed tests.** The same suite reported 43 tests and 0 failures in the [P13-T3] whole-suite
run 7 minutes earlier, so the result is reproduced across two independent invocations at two
different scopes.

## The four required results, by name

| Required result | Case name | Observed |
|---|---|---|
| Byte identity | `keeps the canonical hooks byte-identical to their bundled copies` | **Passed** |
| Pack manifest | `lists every shared hook module in the core pack manifest` | **Passed** |
| Parse | `parse-checks each root and bundled hook and keeps every file within 500 lines` | **Passed** |
| 500-line cap | `parse-checks each root and bundled hook and keeps every file within 500 lines` | **Passed** |

The parse check and the 500-line cap are asserted by one case in this suite; the case name states
both obligations, and it is recorded against both rows rather than a second case being invented for
the table. Its pass is therefore the observed result for each.

The byte-identity result is the mechanism that guards the Codex bundle mirrors, which the [P13-T4]
per-file coverage gate records as outside the coverage denominator. Its pass here is what makes that
exclusion sound, and it is corroborated independently by the [P12-T4] SHA-256 pair table.

The pack-manifest result here covers the shared hook modules. The two bundled-tree pack-manifest
completeness suites are separate mechanisms and are re-run in [P13-T10].

## The folder-scoped run's one failure, which is not in this suite

- Suite file: `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`
- It: `allows every registered handler for every tool name its own matcher admits`

This is baseline failure 2 from [P0-T7], driven by `enforce-epic-wave-barrier.ps1` reading this
worktree's gitignored epic checkpoint. It is in a different file, it is recorded in the [P0-T7]
baseline as failing before any task in this plan ran, and it is green on the clean CI checkout
(run `34145103168`). It is the sole reason the folder-scoped invocation exits 1.

## Output Summary

`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`: **43 tests, 0 failures, 0 errors,
0 skipped**, 17.127 s. All four required results pass by name — byte identity, pack manifest, parse,
and the 500-line cap. The folder-scoped invocation exits 1 solely because of one ambient-state
failure in `codex-pretooluse-integration.Tests.ps1`, which is a [P0-T7] baseline failure in a
different file and is green on CI.
