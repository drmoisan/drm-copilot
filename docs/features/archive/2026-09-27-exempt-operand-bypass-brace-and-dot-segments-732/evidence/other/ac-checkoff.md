# Acceptance-criteria check-off record (issue #732)

Timestamp: 2026-10-09T05-00
Tasks: [P8-T2] to [P8-T31]
Command: sh <SCRATCHPAD>/c1b732/p8.sh (evaluates each task's named-artifact condition and, only when it holds, changes exactly one `- [ ]` to `- [x]` under `## Acceptance Criteria` in spec.md, matched by a unique key)
EXIT_CODE: 0

```text
P8-T2: CHECKED spec line 313
P8-T3: CHECKED spec line 314
P8-T4: CHECKED spec line 315
P8-T5: CHECKED spec line 316
P8-T6: CHECKED spec line 317
P8-T7: CHECKED spec line 318
P8-T8: CHECKED spec line 319
P8-T9: CHECKED spec line 320
P8-T10: CHECKED spec line 324
P8-T11: CHECKED spec line 325
P8-T12: CHECKED spec line 326
P8-T13: CHECKED spec line 327
P8-T14: CHECKED spec line 328
P8-T15: CHECKED spec line 329
P8-T16: CHECKED spec line 330
P8-T17: CHECKED spec line 334
P8-T18: CHECKED spec line 335
P8-T19: CHECKED spec line 336
P8-T20: CHECKED spec line 337
P8-T21: CHECKED spec line 338
P8-T22: CHECKED spec line 339
P8-T23: CHECKED spec line 343
P8-T24: CHECKED spec line 344
P8-T25: CHECKED spec line 345
P8-T26: CHECKED spec line 349
P8-T27: CHECKED spec line 350
P8-T28: CHECKED spec line 351
P8-T29: CHECKED spec line 352
P8-T30: CHECKED spec line 353
P8-T31: CHECKED spec line 354
```

[P8-T10] detail: R (latest commit that changed evidence/other/c1a-api-verification.md, `git log -n 1 --format=%H -- <FEATURE>/evidence/other/c1a-api-verification.md`) = d379899e070f5dba5d311e7cd85477a0ab434d06; T (commit that added the targets file, `git log -n 1 --format=%H --diff-filter=A -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`) = 22c313556e95e58eda9914800b8c0729ab5b1f0d; `git merge-base --is-ancestor R T` exit 0; R differs from T. c1a-api-verification.md has no line beginning `C1A-API-BLOCKER:`; targets-calls-and-manifests.md reports `TOKEN_SPLIT: 0` and `DISALLOWED_EXTERNAL_CALLS: 0`. (The script's own printed detail line was corrupted by a case-insensitive variable reuse after the condition was evaluated; the values above were recorded by direct `git` commands in this session.)

[P8-T22] read: spec Decisions row `D5` reads "Heredoc-fed commit messages are deferred. They remain documented as not admitted." with its rationale (shell-specific heredoc syntax, undetermined executing shell under D1, `<` already denied outside quotes, admitted forms already carry trailers, limited helpers headroom).

[P8-T23] read: `research/research.2026-10-08T14-00.md` carries the heading `## Q1. #735: Which shell OpenAI Codex uses to execute commands on Windows` and evidence-table rows E1 to E12.

[P8-T27]: final-pytest-contracts.md records `KNOWN_ISSUE_510: not observed`; no pending-CI item.

Output Summary: 30 of 30 acceptance criteria checked off, each after its plan-named artifact condition was evaluated as met; no criterion left unchecked.
