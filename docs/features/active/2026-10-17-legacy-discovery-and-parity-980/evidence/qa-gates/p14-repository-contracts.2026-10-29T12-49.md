# P14-T13 Repository and publication contracts on the final tree

Timestamp: 2026-10-29T12-49
Task: [P14-T13] Re-run repository and publication contracts under the tiered file-size policy, discharging [P13-T6].
Command: the command-step records in this directory stamped `2026-10-29T12-49`: `p14-generator-check`, `p14-mirror-and-publication-contracts`, `p14-tier-classification`, `p14-architecture-boundaries`, `p14-packaging-closure`, `p14-source-neutrality`, `p14-file-size`, `p14-test-io`
EXIT_CODE: 0 for every command step (the neutrality greps exit 1 because nothing matches)
Output Summary: On the final tree, every repository and publication contract passes.
- Generation and mirrors: zero generated drift (786 mirrored files identical, 13 pre-existing orphans) and no Codex variant drift.
- Contract suites: 9547 passed (6 pre-existing skips) over `tests/scripts/dev_tools` and `tests/schemas`; 1053 routing, runtime-contract, bundle-probe and file-size-gate Pester tests passed.
- Tier classification: 28 of 28 projects classified.
- Packaging: the committed build manifest is current and the P14-T12 VSIX, npm tarball and wheel report zero closure defects.
- Architecture boundaries: 5 boundary and packaging Jest suites pass (29 tests).
- Source neutrality: no consumer-specific name in core sources or the brief.
- File size (tiered policy): `FileSizePolicy.RepoGate.Tests.ps1` passes; no branch file exceeds 800 logical lines, none is at or above 700 (no advisory Warning to list), none exceeds 500, and the four Phase 14 code files are at 399, 353, 421 and 477.
- The six execution-environment brief copies are byte-identical.
- Test I/O: no forbidden I/O in any changed test.

The committed P13-T6 evidence (`p13-*.2026-10-29T02-34.md`) predates the catalog correction and the latest rebase; it is retained and is not cited as final proof. [P13-T6] is discharged by this task.
Run window 2026-10-29T12-46 to 12-49 UTC on the final tree (`git status --porcelain` empty at start and end).
Result: PASS
