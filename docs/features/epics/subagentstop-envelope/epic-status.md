# Epic Status: subagentstop-envelope

Generated projection of `artifacts/orchestration/epic-orchestrator-state.json` `features[]`. Do not hand-edit.

- Epic issue: #904
- Integration branch: `epic/subagentstop-envelope-integration`
- Current wave: 1
- Next step: `WAIT_FOR_GO then E4 896 (reconcile exec-896-local into item branch, resume one subtree)`
- Last updated: 2026-10-12T09:39:00Z

## Waves

| wave | status | features |
| --- | --- | --- |
| 0 | merged | subagentstop-envelope-core-897 |
| 1 | in_progress | subagentstop-envelope-artifact-gates-905, subagentstop-envelope-feature-review-coverage-896, subagentstop-envelope-orchestrator-family-903 |

## Features

| feature_folder | issue_num | wave_number | merge_status | pr | merge_commit_sha | worktree_created_at | pr_opened_at | merge_confirmed_at | worktree_removed_at |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| subagentstop-envelope-core-897 | 897 | 0 | merged | [#906](https://github.com/drmoisan/drm-copilot/pull/906) | 039e53339103ced2ccc89471c67754cc311852c3 | 2026-10-11T16:26:00Z | 2026-10-11T18:18:17Z | 2026-10-11T18:33:08Z | - |
| subagentstop-envelope-artifact-gates-905 | 905 | 1 | merged | [#908](https://github.com/drmoisan/drm-copilot/pull/908) | 8450a90445f2f355fecc3c0d2ff0810f5c97946c | 2026-10-11T18:45:00Z | 2026-10-12T09:15:00Z | 2026-10-12T09:37:00Z | - |
| subagentstop-envelope-feature-review-coverage-896 | 896 | 1 | worktree_created | - | - | 2026-10-11T18:45:00Z | - | - | - |
| subagentstop-envelope-orchestrator-family-903 | 903 | 1 | merged | [#907](https://github.com/drmoisan/drm-copilot/pull/907) | 47a4175f4ffca994d2e3343a3a49e5153010beda | 2026-10-11T18:45:00Z | 2026-10-12T08:45:01Z | 2026-10-12T09:02:54Z | - |

## Integration PR

- Not opened.

## Child Starts and Throttle Log

- 2026-10-11T16:26Z: started E1 (897) execution.
- 2026-10-11T17:54Z: started E1 (897) resume from S6; merged as PR 906 at 18:33Z.
- 2026-10-11T18:45Z: started E2 (903), E3 (905), E4 (896) execution; all three died on an account weekly limit.
- 2026-10-12T02:42Z: started E3, E4, E2 resumes in their existing worktrees (before the throttle directive arrived).
- 2026-10-12: THROTTLE received: one child subtree at a time, order E2, E3, E4. Coordinator asked to stop the E3 and E4 resumes; E2 continues.
- 2026-10-12T03:03Z: THROTTLE: no new child or agent-launching step until GO; the running child finishes.
- 2026-10-12T04:28Z: COMMIT NOW: checkpoint and status committed; child remote tips 905 642050f8, 896 f32cfc84, 903 5e695d73; no PRs open; waiting for GO after the ~07:30Z reset.
- 2026-10-12T07:36Z: GO. Started E2 (903) resume in its original worktree after fast-forwarding the item branch to aa17afdb5 (no other child running; integration not behind main).
- 2026-10-12T08:46Z: E2 (903) PR 907 opened and waiting on CI. Started E3 (905) resume from S6 in its resume worktree.
- 2026-10-12T09:03Z: E2 (903) PR 907 merged (47a4175f, 20/20 checks). E3 (905) running.
- 2026-10-12T09:07Z: THROTTLE: no new starts until GO. E3 (905) already running since 08:50Z (only active subtree); E4 (896) held.
- 2026-10-12T09:37Z: E3 (905) PR 908 merged (8450a904, 20/20 checks). E4 (896) held until GO.
