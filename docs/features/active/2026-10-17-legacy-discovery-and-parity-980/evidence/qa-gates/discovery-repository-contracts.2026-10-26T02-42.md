# P11-T8 Repository and publication contracts on the final implementation

Timestamp: 2026-10-26T02-42
Task: [P11-T8] Run complete repository and publication contracts on the final implementation.
Command: the command-step records in this directory stamped `2026-10-26T02-42`: `p11t8-generator-check`, `p11t8-mirror-and-publication-contracts`, `p11t8-tier-classification`, `p11t8-architecture-boundaries`, `p11t8-packaging-closure`, `p11t8-source-neutrality`, `p11t8-file-size-and-test-io`
EXIT_CODE: 0 (every command step)
Output Summary: On the final task-owned branch file set (HEAD of `feature/legacy-discovery-and-parity-980` after the P11-T7 acceptance, plus the staged `test_gateway.py` split of this task) every repository and publication contract passes: the canonical-source conversion and the three bundle mirrors report zero drift (781 files identical, thirteen pre-existing seed-memory orphans), the Codex variant generator reports no drift, the `tests/scripts/dev_tools` and `tests/schemas` populations pass (9523 passed, 6 pre-existing skips) including the three bundle/pack completeness and closure checks, the Set L routing suites, the publication and documentation contracts (every documentation link resolves) and the schema catalog (every reference resolves), the Set L and runtime-contract Pester suites pass (1024), the tier classification reports 27 of 27 projects classified, the staged resource hashes and the wheel identity reproduce, the VSIX, npm tarball and wheel closures report zero defects with their metadata and digests recorded, the architecture-boundary and packaging Jest suites pass (5 suites, 29 tests), no consumer-specific core content exists outside the declared optional adapter and case study exceptions, and no changed test performs forbidden I/O.
Result: PASS with one recorded deviation on file size

## Deviation

- `scripts/dev_tools/agentic_sync.py` (820 lines) and `tests/scripts/dev_tools/test_agentic_sync.py` (598 lines) exceed the 500-line limit. Both were already above the limit at the merge base of `origin/main` and `HEAD` (819 and 586 lines) and this branch extended them by one and twelve lines in P8-T9. No new or discovery-owned file exceeds the limit (the P11-T7 growth of `test_gateway.py` to 512 lines was repaired in this task by moving the two entrypoint binding tests into `test_gateway_binding.py`). Splitting the 820-line publisher is outside this plan's design; the deviation is carried to the P11-T9 self-review and the handoff.

## Carried notes

- The three bundle copies of the P11-T7 repairs were produced by direct copy and are confirmed byte-identical by the conversion check and the resource-contract suites.
- The P10-T2 and P10-T3 package digests are superseded by the artifacts built in P11-T7 and inspected here; P11-T10 reconciles the publication record.
