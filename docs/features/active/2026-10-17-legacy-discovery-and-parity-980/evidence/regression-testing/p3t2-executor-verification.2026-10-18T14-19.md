# P3-T2 independent executor verification

Timestamp: 2026-10-18 14:19:29 UTC

Command: `poetry run python SCRATCH/issue-980-verify-p3t2.py 2026-10-18T14-12`

EXIT_CODE: 0

## Output Summary

Accepted P3-T2 against original task baseline `a74cb240a7698c1454a8e6018ac23862cd91dab0`, including both intermediate WIP commits. All 18 authored and seven generated paths match the final recorded working-file SHA-256 values and staged Git objects. Six test files have only the configured CRLF-to-LF index normalization. The other 215 accepted paths and all 24 frozen v1/export paths remain unchanged. The complete 39-resource manifest agrees with canonical bytes, packaged bytes, sizes and hashes.

The [independent numerical proof](p3t2-executor-checks.2026-10-18T14-19.json) recomputes raw module coverage, all 42 executable class/callable ranges, physical lengths, Python 3.10 parsing, required docstrings and package import separation. Raw coverage is 451/456 lines and 141/146 arcs. Every measured new range meets 90%; the minimum is 94.444444%. Maximum physical length is 481. The thin compatibility adapter retains 100% line coverage.

## Task acceptance

- Explicit caller identity, repository role, roots or an honest draft configuration produce deterministic v2 projections. Source, target and combined role tests use the actual planner and complete structural/completion validators, assert exact five/six-file sets, role-specific null draft pins and all configured directories. Default online mode is projected consistently; offline/mobile are not made mandatory.
- Initialization keeps the virtual proposed profile separate from physical absence and captured identities. The complete projected graph passes structural validation before effects and remains incomplete. The real combined commit publishes the parity matrix and configured empty directories.
- Partial recovery preserves compatible existing bytes, including formatting, and unrelated content. Repetition reports skipped outputs without changing bytes or adding authority invalidations. Deprecated force does not restore overwrite behavior.
- Malformed existing artifacts, incompatible identity, unsafe paths, concurrent collision, changed directory identities and changed bootstrap-to-artifact captures fail explicitly. The typed conflict reports exact path, status and findings before writes where possible. Partial effects and uncertainty remain explicit rather than being reported as a clean rollback.
- Dry-run validates the proposal while creating no files, directories, activation records or receipts and performing no authority invalidation.
- The legacy import remains a thin adapter. Legacy calls without explicit v2 identity/configuration and trusted I/O receive actionable migration guidance; unchecked legacy filesystem writes are not used. Public CLI integration and AC-15 remain pending.

The three consolidated bootstrap defects are corrected: opened directory identity remains bound through postcapture; the exact physical bootstrap result is compared before ordinary mutation; malformed existing content receives typed conflict reporting. Five additional missing-ID cases cover scope, ledger, unspecified behaviors, decisions and parity before ID extraction. The [final AST/source binding](p3t2-executor-comment-binding.2026-10-18T13-48.json) retains the nine earlier bootstrap/handoff checks plus these five cases against the final three production hashes. Comment-only changes and the separately tested pre-ID validation guard are distinguished; the historical stale-import diagnostic is not relabeled as current proof.

## Quality gates and actual provider evidence

The [specialist handoff](../other/p3t2-initialization-handoff.2026-10-18T14-14.md), [final inventory](../other/p3t2-final-inventory.2026-10-18T14-14.json) and individual command receipts establish a clean ordered pass 14: Black, Ruff, full repository Pyright, architecture, task tests and order independence, contract/schema checks, then native integration. The verifier checks each recorded exit code and start/end chronology. Results are 92 forward tests, 92 tests in reversed module order in one process, 334 compatibility/contract tests and 39 exact packaged resources. All command stages pass.

The six existing architecture tests cover the original extracted modules. Separate direct import/I/O structural review and the final AST inspection cover the new initialization modules; the six existing cases are not described as an exhaustive new-module harness. The exhaustive new-T2 pure-function property inventory and mutation trend remain P11-T5 obligations, not N/A.

[Final raw coverage](../qa-gates/p3t2-raw-coverage-final.2026-10-18T14-12.json) equals the captured pass-14 coverage. [Final metrics](../qa-gates/p3t2-coverage-audit-final.2026-10-18T14-12.json) agree: init_flow is 134/136 lines and 34/36 arcs; init_io is 137/140 and 47/50; init_projection is 178/178 and 60/60; the old adapter is 2/2 lines. All measured ranges meet the required threshold. No dependency or suppression was added. Six inherited ARG001 lines match the original baseline; one separate inherited CLI-test suppression was removed.

The [actual Windows provider proof](p3t2-windows-initialization.2026-10-18T14-11.json) follows the contract stage and passes all eight checks through InitializationIO.local in a unique SCRATCH workspace: dry-run absence; first combined creation with empty directories; honest null pin; structural success; completion failure; repeat/force byte preservation; typed prewrite conflict; and released handle/lock/stage cleanup. Its source hashes match the final production bytes. This is native provider integration, not the later installed CLI or coding-agent host proof.

## Limitations and policy disposition

The covered task suite took 738.59 seconds and the uninstrumented reversed suite 298.48 seconds. Actual Windows dry-run, first creation and repeat took 10.565, 74.481 and 46.038 seconds respectively. These measurements establish material ordinary runtime cost, not only coverage overhead. The slow composed cases intentionally verify the full planner/validator/writer workflow and are identified as workflow integration proof within the mixed pytest suite; they are not claimed to be fast isolated units. Required isolated failure cases, full behavior assertions and coverage were preserved. No current-task functional acceptance criterion or defined initialization latency gate remains unmet on this evidence. No optimization, waived gate or controlled performance benchmark is claimed.

The publication guarantee remains cooperative serialization of authorized writers, complete-input freshness, retained verified parents, exclusive creation and atomic individual publication. It does not provide a multi-file transaction or kernel digest-conditioned replacement against arbitrary processes bypassing the guard. Later integration must provide authenticated root context and grants, a trusted common external lock, configured read limits and real authority invalidation; consumers cannot select unchecked collaborators.

Earlier failed and interrupted runs remain recorded, including the stale-import diagnostic, missing-ID guard failure, two callable coverage gaps, the test reconstruction fixture and the SCRATCH-only audit/handoff decoding corrections. The [initial independent checker failure](p3t2-executor-check-initial.2026-10-18T14-17.md) rejected removal of a suppression because it required exact old/new lists. Its bounded verifier correction permits removals, rejects additions or alterations, and does not change product bytes or rerun product gates. The inherited baseline command's ignored lcov output incident remains documented without inventing prior bytes or restoration.

Python task gates pass. No TypeScript, PowerShell or C# code changed in this task. Repository-wide final QA, real non-Windows execution, CLI/native-host integration, publication and feature review remain later requirements.

## Checkoff and continuation

[AC-16 through AC-19](../other/p3t2-ac16-19-verification.2026-10-18T14-19.md) are individually supported. AC-15 remains unchecked until the command is integrated. Only P3-T2 is accepted; expected synchronized progress is 26/84 tasks and 10/66 feature criteria in each requirement source after the checkbox update.

Current phase: Phase 3. Next tasks: P3-T3, P3-T4, P3-T5, P3-T6, P3-T7. No next task is released before the coordinator's accepted-task commit and push.
