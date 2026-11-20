# P3-T6 independent acceptance reconciliation

Timestamp: 2026-10-18T23-37
Command: `poetry run python SCRATCH/issue-980-p3t6-final-check.py docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t6-final-audit.2026-10-18T23-34.json 434`
EXIT_CODE: 0
Output Summary: 547 independent checks passed with zero findings. The preserved pass3 gates bind to all ten current task files. The exact 434-case forward/reverse population, 475 contract cases, and 11 composed integration checks passed; no behavioral tests were repeated during reconciliation. Six production modules cover 883/893 lines (98.880179%) and 359/370 branches (97.027027%); all 88 measured class/function ranges meet 90%, with a minimum of 92.5%. All four accepted module comparisons and all mapped changed-line checks pass without regression.

TASK_STATUS: PASS
TASK: P3-T6

## Authority and baseline

The current native SubagentStart record for `atomic-executor-c4` confirms `gpt-6-astra`, `max`, valid routing, valid launch authority, and valid provenance. Its exact profile hash matches the durable `atomic_execution_p3t6_reset_reconcile` receipt. Only task acceptance evidence and the P3-T6 checkbox are authorized for this reconciliation; source/test files, staging, commits, checkpoint updates, and subsequent tasks remain parent-owned.

The accepted predecessor is `27753e5f8b9a6cd1d85b9d1d28d2999800af209a`. Current implementation HEAD is `3bd1dadeab42799fc7afd9fa151130775417f352`. WIP commits do not replace the accepted predecessor. All 251 unaffected predecessor files and all 24 frozen compatibility paths match their recorded baselines. The only four changed predecessor modules are `path_policy.py`, `mutation_plan.py`, `mutation_io.py`, and `references.py`, previously authorized for this task. The six production and four test/helper paths form the exact task delta. Maximum physical size is 489 lines. No newly introduced suppression or missing callable docstring was found.

## Verification and retained provenance

The seven stages completed in chronological order on stable bytes: Black (10 unchanged files), Ruff, full Pyright (zero errors/warnings), six architecture checks, coverage-enabled unit tests and their exact reversed-order isolation run, contract checks, and integration. Forward testing passed 434 cases in 755.58 seconds; reverse passed the same 434 in 321.88 seconds; 475 contract cases passed in 24.33 seconds. The composed proof passed 11 exact invariants in 123.406 seconds. XML counters report zero failures, errors, or skips. The 430 earlier cases remain present, with exactly four additional isolated replica-resolution cases.

The final composed harness consumes nine task paths; the isolated replica-resolution test is not a harness input. Its omission is explicit, while forward/reverse and the whole ordered sequence bind all ten paths. Integration proves dry-run nonmutation, manifest-last creation, unchanged originals and captured staging, explicit partial failure, resumable partial import, exact-repeat no publication, and rejection after staged bytes change.

The retained 44-case independent public API proof covers source-local dependency closure, immutable revisions and hashes, absent/changed object rejection, all runtime payload references, configured roots, two target clients, foreign identities and revisions, versions, changed/missing/undeclared bundle members, no overwrite, and combined-repository identity. It is retained through exact historical source identity or verified executable AST equivalence, with the deliberately changed reference guard separately rebound by the current 13-case context proof and seven-case physical closure proof. The 98-check readiness result remains exactly bound to its nine source/fixture inputs. All those results remain qualified historical evidence; they are not represented as newly executed checks.

## Coverage

| Module | Lines | Branches | Accepted baseline delta, percentage points (line / branch) |
| --- | --- | --- | --- |
| mutation_io.py | 135/136 (99.264706%) | 35/36 (97.222222%) | +0.028065 / +0.347222 |
| mutation_plan.py | 161/163 (98.773006%) | 63/66 (95.454545%) | +0.115288 / +0.811688 |
| path_policy.py | 156/156 (100.000000%) | 84/84 (100.000000%) | +0.000000 / +0.000000 |
| references.py | 169/171 (98.830409%) | 82/84 (97.619048%) | +0.129111 / +0.250627 |
| source_snapshots.py | 150/152 (98.684211%) | 50/52 (96.153846%) | new module |
| transport_manifest.py | 112/115 (97.391304%) | 45/48 (93.750000%) | new module |

The four predecessor comparisons use the original P1-T11, P2-T2, and P3-T1 raw reports. All mapped previously covered lines remain covered. Changed executable ranges in each predecessor module are 100% line/branch covered. New `source_snapshots.py` ranges cover 150/152 lines and 50/52 branches; new `transport_manifest.py` ranges cover 112/115 lines and 45/48 branches. The raw coverage SHA-256 is `80803d7c9376fc3419bfc5c7c0293a3c2a07c5185401115e90cd65ae4c7cc9cc`. Diagnostic coverage was not merged into this result.

## Git byte reconciliation

Current working-byte hashes and canonical index-byte hashes are recorded separately for every owned path. Three predecessor production files and three test/helper files have CRLF working bytes and LF indexed bytes under `text=auto eol=lf`. Each difference was proved to be exactly CRLF-to-LF mapping; executable ASTs are equal. No normalization was applied to any source or test file. The historical API hashes for `mutation_io.py` and `mutation_plan.py` are the unchanged current working hashes; their historical Git blobs are the exact LF projection. Both hash forms are preserved.

The first prepared checker reported five bookkeeping failures because it allowed this mapping only for tests and compared historical working hashes directly with Git blob hashes. That failed result is retained in `p3t6-reconcile-initial-check.2026-10-18T23-35.json` and its Markdown receipt. The session-local checker alone was corrected to require explicit Git attributes, exact byte mapping, and executable equivalence. The rerun passed 547 checks. Earlier pass1 behavior failure and pass2 coverage-delta failure remain preserved and are not used as passing gates.

## Acceptance and limits

P3-T6 is accepted: target references use locally captured imported bytes whose contract/evidence hashes and immutable source identity match the versioned transport manifest. Source-local dependencies and payloads remain closed and verifiable. No sibling checkout, network fetch, silent replacement, broad analyst grant, or synthetic target claim is introduced. Only provenance-proven replicas coalesce; ordinary or conflicting duplicates remain invalid, local mutation identity is retained, and explicit imported physical references retain their outgoing links.

This task uses the existing guarded writer with fresh in-memory stores for the bounded composed proof. It adds no native provider. Cooperative serialized updates, optimistic freshness, and per-file publication do not provide kernel digest compare-and-swap or a multi-file transaction. Installed CLI/host grants, full native-host acceptance, analyzer work, migration, and P11 full quality/property/mutation checks remain later tasks. The task-scoped Python gates pass; this is not a claim that the whole feature or future TypeScript/PowerShell gates are complete.

No additional feature-wide AC is fully delivered by transport alone. `spec.md` and `user-story.md` each remain 11/66 checked, 55 pending; already checked reference and preservation criteria gain supporting evidence. After the exact P3-T6 checkbox update, the plan is 30/84 checked. P3-T7 remains unreleased until the parent commits accepted work.

## Evidence

- [Independent 547-check result](p3t6-executor-final-check.2026-10-18T23-37.json).
- [Native authority and exact working/index/historical bindings](p3t6-executor-normalization-binding.2026-10-18T23-37.json).
- [Task audit and exact ten-path inventory](p3t6-final-audit.2026-10-18T23-34.json).
- [Original final raw coverage](p3t6-final-raw-coverage.2026-10-18T23-34.json).
- [Forward/reverse test hashes and node identities](p3t6-final-test-bindings.2026-10-18T23-34.json).
- [Whole ordered sequence source binding](p3t6-final-ordered-sequence.2026-10-18T23-34.json).
- [Final composed integration data](../regression-testing/p3t6-final-composed.2026-10-18T23-34.json).

Individual final gate receipts:

- [p3t6-pass3-architecture.2026-10-18T18-56.md](../regression-testing/p3t6-pass3-architecture.2026-10-18T18-56.md)
- [p3t6-pass3-contracts.2026-10-18T19-14.md](../regression-testing/p3t6-pass3-contracts.2026-10-18T19-14.md)
- [p3t6-pass3-coverage-check.2026-10-18T19-09.md](../regression-testing/p3t6-pass3-coverage-check.2026-10-18T19-09.md)
- [p3t6-pass3-format.2026-10-18T18-56.md](../regression-testing/p3t6-pass3-format.2026-10-18T18-56.md)
- [p3t6-pass3-integration.2026-10-18T19-16.md](../regression-testing/p3t6-pass3-integration.2026-10-18T19-16.md)
- [p3t6-pass3-lint.2026-10-18T18-56.md](../regression-testing/p3t6-pass3-lint.2026-10-18T18-56.md)
- [p3t6-pass3-reverse.2026-10-18T19-14.md](../regression-testing/p3t6-pass3-reverse.2026-10-18T19-14.md)
- [p3t6-pass3-tests.2026-10-18T19-08.md](../regression-testing/p3t6-pass3-tests.2026-10-18T19-08.md)
- [p3t6-pass3-types.2026-10-18T18-56.md](../regression-testing/p3t6-pass3-types.2026-10-18T18-56.md)

Current phase: Phase 3, repository-local workspace operations. Next five tasks: P3-T7 v1-to-v2 draft migration; P3-T8 bounded source inspection; P4-T1 repository inventory/pipeline; P4-T2 .NET project inventory; P4-T3 C# lexical/event inventory.
