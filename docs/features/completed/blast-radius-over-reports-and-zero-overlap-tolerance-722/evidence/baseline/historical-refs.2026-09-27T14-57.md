# Historical-run Plan-home Refs (P0-T23)

Timestamp: 2026-09-27T14-57
Command: for each slug S in epic-655-followups, backlog-2026-09-26, followups-2026-09-27: git fetch origin parallel/S-plan ; git rev-parse origin/parallel/S-plan:docs/features/parallel/S/parallel.md ; git rev-parse origin/parallel/S-plan (nine separate invocations)
EXIT_CODE: 0
Output Summary: All nine commands exited 0. Each ref was fetched; each plan-home commit is a 40-hexadecimal SHA and each manifest blob SHA was resolved. A cross-check with git ls-remote confirmed each remote-tracking ref equals the remote head. Stop condition not reached.

## Per-run record

| Run | Ref | Plan-home commit | Manifest blob |
| --- | --- | --- | --- |
| epic-655-followups | origin/parallel/epic-655-followups-plan | 76ff7f4809106371bf972f8a3ca77d10fadbe14f | 397ac058aed2c65df7217666e3b46f16c6114eed |
| backlog-2026-09-26 | origin/parallel/backlog-2026-09-26-plan | 141bf50f3530e481559716514bddc2d361549574 | cf4be5ee3c0a9ab61ac98a9a70be73f7643d3f58 |
| followups-2026-09-27 | origin/parallel/followups-2026-09-27-plan | ed9b595935e811be5e6405def9c962c8b901bc8b | 4d0ae3053a65e070c4e37bfe9a40ff8350393e4d |

Manifest path per run: docs/features/parallel/S/parallel.md, with S the run slug.

## Per-command results

| Command | EXIT_CODE | Output |
| --- | --- | --- |
| git fetch origin parallel/epic-655-followups-plan | 0 | branch parallel/epic-655-followups-plan -> FETCH_HEAD |
| git rev-parse origin/parallel/epic-655-followups-plan:docs/features/parallel/epic-655-followups/parallel.md | 0 | 397ac058aed2c65df7217666e3b46f16c6114eed |
| git rev-parse origin/parallel/epic-655-followups-plan | 0 | 76ff7f4809106371bf972f8a3ca77d10fadbe14f |
| git fetch origin parallel/backlog-2026-09-26-plan | 0 | branch parallel/backlog-2026-09-26-plan -> FETCH_HEAD |
| git rev-parse origin/parallel/backlog-2026-09-26-plan:docs/features/parallel/backlog-2026-09-26/parallel.md | 0 | cf4be5ee3c0a9ab61ac98a9a70be73f7643d3f58 |
| git rev-parse origin/parallel/backlog-2026-09-26-plan | 0 | 141bf50f3530e481559716514bddc2d361549574 |
| git fetch origin parallel/followups-2026-09-27-plan | 0 | branch parallel/followups-2026-09-27-plan -> FETCH_HEAD |
| git rev-parse origin/parallel/followups-2026-09-27-plan:docs/features/parallel/followups-2026-09-27/parallel.md | 0 | 4d0ae3053a65e070c4e37bfe9a40ff8350393e4d |
| git rev-parse origin/parallel/followups-2026-09-27-plan | 0 | ed9b595935e811be5e6405def9c962c8b901bc8b |

## Cross-check (git ls-remote origin for the three heads)

```text
141bf50f3530e481559716514bddc2d361549574	refs/heads/parallel/backlog-2026-09-26-plan
76ff7f4809106371bf972f8a3ca77d10fadbe14f	refs/heads/parallel/epic-655-followups-plan
ed9b595935e811be5e6405def9c962c8b901bc8b	refs/heads/parallel/followups-2026-09-27-plan
```

Each value equals the plan-home commit recorded above.
