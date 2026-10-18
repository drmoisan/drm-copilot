# P1-T3 independent executor verification

Timestamp: 2026-10-18T05-10
Command: poetry run python SCRATCH/issue-980-verify-p1t3.py
EXIT_CODE: 0
Output Summary: P1-T3 acceptance verified; three v2 schemas, valid/invalid fixtures, exact 15-path staged scope, ten matching packaged resources, and 35 independently rejected line-terminator cases.

## Acceptance decision

The common, domain-profile, and scope schemas satisfy P1-T3. Review against the normative specification confirms explicit profile identity/version, local roots, source/target roles and immutable pins, clients, platforms/modes/dimensions, runtime capability, analyzer configuration, exclusions, artifact roots, completion gates, decision owners, and namespaced extensions. Closed core objects preserve required fields. Status axes remain separate. Optional offline/mobile requirements are declared explicitly rather than imposed by schema defaults.

Draft profiles and scopes accept null pins without claiming completion. Configured profiles require full pins and production roots; target/combined profiles also require clients. Confirmed scopes require confirmation metadata and an immutable pin; empty confirmed scopes require an explicit no-scope rationale without required feature coverage. Typed graph validation, required-dimension unions, resolved path safety, and completion enforcement remain in the later tasks assigned to them.

## Finding and correction

The executor's initial Draft202012Validator probe showed that identifier, revision, and SHA-256 patterns accepted a trailing LF because a terminal dollar anchor can match before a final newline. The specialist corrected shared token, path, namespace, and property-name patterns and added regression cases before the final ordered gates.

The independent final probe rejects all 35 tested token/namespace cases containing LF, CR, CRLF, U+2028, or U+2029, while accepting their valid counterparts. The specialist's separate Node proof compiled nine ECMAScript patterns and rejected 40 terminator cases. This finding is resolved for the authored v2 schemas; no frozen v1 schema was edited.

## Independent checks and completed evidence

[Machine-readable checks](p1t3-executor-checks.2026-10-18T05-09.json) record exact Git blobs and byte hashes. The executor verified all three schemas against Draft 2020-12, exact schema/artifact identities, two valid examples, and two invalid fixtures with one actionable finding each. Ten canonical resources match their generated copies, manifest sizes, and digests. The staged task scope is exactly 15 paths; 38 prior-task paths retain their hashes. Only the previously authored allowlist and generated manifest change as explicitly required. Task paths have no unstaged changes, and the maximum physical size is 388 lines.

The [specialist handoff](../other/p1t3-profile-schemas.2026-10-18T05-09.md) links the completed records. The executor read the actual final ordered Black, Ruff, full Pyright, and focused Pytest outputs: three unchanged files, zero lint findings, zero type errors/warnings, and 359 tests passed. The reversed new-schema run passed 176 tests. The read-only staging check returned no changed paths and resolved all ten schema resources offline.

Raw coverage confirms unchanged resource boundaries at 103/103 lines and 34/34 arcs for resources.py, and 209/209 lines and 98/98 arcs for build_discovery_runtime.py. These are unchanged production files with zero coverage delta; this schema-only task adds no executable production lines. A first PowerShell coverage-view command rejected coverage.py's empty function-name JSON key; reading with ConvertFrom-Json -AsHashtable resolved that viewer limitation and returned the actual counters. No source correction or test rerun was required for that inspection.

Tests read immutable fixture files and use fresh objects and an offline registry. No temporary files, external processes, new suppressions, dependency changes, policy changes, or consumer-repository changes were introduced. No redundant broad gate run or new wheel build is claimed here.

## Plan and acceptance status

P1-T3 is checked off after verification. The plan now has seven of 84 tasks complete; P1-T4 is next. These shared schemas are partial delivery of the full schema catalog, so all 66 feature acceptance criteria remain unchecked. The coordinator owns checkpoint persistence and the next specialist release.
