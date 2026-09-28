# Coverage XML Structure (observed)

Timestamp: 2026-09-17T08:00:02-04:00
Command: [xml] parse of evidence/other/baseline-powershell-coverage.selfhosted.2026-09-13T22-00.xml (DocumentElement.LocalName, SelectNodes('package'), SelectNodes('sourcefile'), SelectSingleNode("counter[@type='LINE']"))
EXIT_CODE: 0
Output Summary: JaCoCo-style layout. Root element `report`; per-directory grouping `report/package` with the full forward-slash absolute directory path in `name`; per-file `report/package/sourcefile` with the BARE file name in `name`; line counters are `counter` elements with `type="LINE"` and integer attributes `covered` and `missed`. File-name comparison semantics for later tasks: bare-name equality on `sourcefile/@name`, scoped to the `package` whose `name` ends with `worktree-resolution`.

## Observed structure

1. Root element name: `report` (its `name` attribute is `Pester (09/17/2026 07:59:01)`; root children: `counter`, `package`, `sessioninfo`).
2. Element path to the per-directory grouping element: `report` -> `package`.
   Element path to the per-file element: `report` -> `package` -> `sourcefile`.
   (`package` also holds `class` elements, which carry `name` = path without extension and `sourcefilename` = bare file name; `sourcefile` holds `line` and `counter` children.)
3. Attribute carrying the directory path: `package/@name`, observed as a full absolute forward-slash path, e.g. `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c/.claude/hooks`.
4. Attribute carrying the file name: `sourcefile/@name`, observed as a **bare** file name, e.g. `check-powershell-test-purity.ps1`.
5. Line counters: element `counter` with attribute `type="LINE"`, values in attributes `covered` and `missed` (present at `report`, `package`, and `sourcefile` level).
6. One complete counter element (verbatim, first `sourcefile`): `<counter type="LINE" missed="55" covered="0" />`
   Report-level counter (verbatim): `<counter type="LINE" missed="6334" covered="3002" />`

Package count in this file: 14.

## Source-derived, not observed

`tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1:296-303` uses a fixture with a root `report` element whose
`name` is `Pester`, a `package` element carrying the directory path in `name`, and a `sourcefile` element
carrying the bare file name in `name` (`PoshQC.psm1`). That matches the observed structure. The one difference
is the root `name` attribute value (`Pester` in the fixture, `Pester (<timestamp>)` in the observed file).
Later tasks do not read that attribute.

Governing source: the **observed** structure governs where the two differ.

## Semantics for later extraction ([P4-T6], [P4-T7])

Bare-name comparison: `sourcefile/@name -eq '<Module>.psm1'`, restricted to `package` elements where
`@name` ends with `worktree-resolution`. Read `counter[@type='LINE']/@covered` and `/@missed`.
