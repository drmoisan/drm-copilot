# P16-T8 Repository and publication contracts on the remediated tree

Timestamp: 2026-10-30T01-55
Task: [P16-T8] Run the repository and publication contracts under the tiered file-size policy.
Command: the command-step records in this directory stamped `2026-10-30T01-55`: `p16-generator-check`, `p16-mirror-and-publication-contracts`, `p16-tier-classification`, `p16-architecture-boundaries`, `p16-packaging-closure`, `p16-source-neutrality`, `p16-file-size`, `p16-test-io`, `p16-evidence-locations`
EXIT_CODE: 0 for every command step (the neutrality greps exit 1 because nothing matches)
Output Summary: On the remediated tree, every repository and publication contract passes.
- Generation and mirrors: zero generated drift (792 mirrored files identical, 13 pre-existing orphans) and no Codex variant drift; zero unsupported references.
- Contract suites: 9581 passed (6 pre-existing skips) over `tests/scripts/dev_tools` and `tests/schemas`; 1053 routing, runtime-contract, bundle-probe and file-size-gate Pester tests passed.
- Tier classification: 28 of 28 projects classified.
- Packaging: the committed build manifest is current and the P16-T6 VSIX, npm tarball and wheel report zero closure defects.
- Architecture boundaries: 5 boundary and packaging Jest suites pass (29 tests).
- Source neutrality: no consumer-specific name in core sources or the brief.
- File size (tiered policy): `FileSizePolicy.RepoGate.Tests.ps1` passes; no branch file exceeds 800 logical lines and no baselined file grew; no file is at or above 700 (no advisory Warning to list); `extensions/drm-copilot/jest.config.cjs` is recorded at 531 logical lines, below 700.
- The six execution-environment brief copies are byte-identical.
- Test I/O: no forbidden I/O in any changed test.
- Evidence locations: the validator exits 0.

Run window 2026-10-30T01-53 to 01-55 UTC on the remediated tree (`git status --porcelain` empty at start and end).
Result: PASS
