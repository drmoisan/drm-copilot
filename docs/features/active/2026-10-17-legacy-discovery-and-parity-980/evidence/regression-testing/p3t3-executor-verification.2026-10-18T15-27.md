# P3-T3 independent executor verification

Timestamp: 2026-10-18 15:27:15 UTC
Command: `poetry run python SCRATCH/issue-980-p3t3-final-check.py docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t3-final-audit.2026-10-18T15-24.json`
EXIT_CODE: 0
Output Summary: VERIFIED. All 426 independent evidence, staged-byte, preservation, coverage and ordering checks pass with zero findings. These are verification checks, not additional test cases.

## Scope and task acceptance

The acceptance baseline remains `639c37269ed12b0bd4b5d74d66723e2f5ce4dedd` across WIP `e0f5b74fd0217ea266db2675ec0ec919f73084db` and the bounded provider correction `3b8e3045e980961bab415ddbee92e55fdb436a36`. The [final specialist handoff](../other/p3t3-configuration-activation-handoff.2026-10-18T15-25.md) and [index audit](../qa-gates/p3t3-final-audit.2026-10-18T15-24.json) identify all eight exact paths. Working bytes and staged objects match with configured checkout newline normalization. All 238 unaffected accepted paths and 24 frozen compatibility paths are unchanged. The only two authorized prior changes are mutation_filesystem.py and its existing test module. Maximum physical size is 484 lines; no suppression was added.

The [eight retained boundary cases](p3t3-executor-boundaries-final.2026-10-18T15-03.json) remain bound to the final three configuration/activation module hashes. They cover deliberate root lifecycle, activation-required state, deletion of active configuration, denied authority, concurrent reactivation, candidate freshness, retained parent identity and truthful partial activation failure. The specialist additionally tests and fixes a candidate appearing after publication. The final checks establish default/custom profile selection, ambiguity and disagreement rejection, fail-closed malformed/missing active configuration, no-effect dry-run, explicit deactivation audit chaining and inactive local selection without provisioning state.

## Ordered quality proof

The completed final sequence is formatting, Ruff, full repository Pyright, architecture, unit/coverage plus reversed isolation, contracts, and actual native integration. Individual command receipts are enumerated in the final audit and retain commands, starts, exits and outputs. The architecture receipt separates the current-module import/I/O inspection from six existing architecture tests. Python task gates pass; TypeScript, PowerShell and C# are not touched by this task. Repository-wide final QA remains Phase 11.

- Forward tests: 134 passed; reversed tests: 134 passed; compatibility/contracts: 385 passed, with no failures or skips in these runs.
- Current raw coverage: 594/596 executable lines and 187/190 branch arcs. The three new modules cover 387/387 lines and 136/136 arcs.
- All 35 new class/function ranges are 100%. All 65 measured ranges, independently recomputed against AST locations and raw executable lines, meet 94.117647%.
- The accepted provider retains 207/209 lines and 51/54 arcs with zero numeric delta. Both corrected descriptor calls are covered. Unit tests use memory seams; the real filesystem checks are operational SCRATCH workflows.

The [raw coverage](../qa-gates/p3t3-final-raw-coverage.2026-10-18T15-24.json), [test before/after hashes](../qa-gates/p3t3-final-test-bindings.2026-10-18T15-24.json) and companion independent JSON retain the measurements. No passing suite was repeated for this final audit.

## Native correction and limitations

The initial actual Windows failure exposed text-mode descriptor translation: physical bytes differed while provider reads normalized them to the proposal. That failure and the earlier race failures remain preserved. The two-line prerequisite correction adds the platform binary flag to content reads and writes, retaining the absent-constant fallback. Historical mutation/initialization byte-fidelity receipts are not retroactively treated as passing physical-byte proof.

The corrected provider's [17-check diagnostic](p3t3-windows-binary-prerequisite.2026-10-18T15-14.json) compares independent binary reads and hashes after create/replace for LF, CRLF, Ctrl-Z and mixed bytes. The final ordered native stage then passes [12 activation checks](p3t3-windows-activation.2026-10-18T15-18.json) and [five combined-initialization checks](p3t3-windows-initialization-byte-reproof.2026-10-18T15-23.json); all six projected initialization files match physical bytes and returned hashes. This current proof closes the byte-fidelity qualification for the corrected implementation while retaining the historical failure.

Actual activation creation/replacement took 0.324/0.330 seconds. Combined initialization took 75.837 seconds uninstrumented, including 70.772 seconds in commit; this latency remains explicit. Guarantees are cooperative serialization, optimistic freshness, exclusive creation and per-file atomic publication, not kernel digest-CAS or a multi-file transaction against writers that bypass the guard. Real OS proof here is Windows; other platform-location/native-seam cases do not constitute native Linux/macOS runs. Trusted host authorization, canonical external state, grant/receipt invalidation wiring, permitted routes, installed-host proof and exhaustive property/mutation checks remain assigned later tasks.

## Checkoff disposition

P3-T3 is verified. [AC-03](../other/p3t3-ac03-verification.2026-10-18T15-27.md) is fully supported and may be synchronized individually in spec.md, user-story.md and issue.md. AC-04 remains pending native hook integration. After the documented checkbox update, progress is 27/84 plan tasks and 11/66 feature criteria in each source. No final QA, publication or feature completion is claimed. P3-T4 stays unreleased until the coordinator commits this accepted task.
