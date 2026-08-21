# Promotion-lifecycle instrumentation: Probe A / Probe B (Issue #487)

Timestamp: 2026-08-17T15-02
Command: see per-step entries below
EXIT_CODE: see per-step entries below
Output Summary: The loss REPRODUCED. The promoted lifecycle record survived `potential_to_issue` and survived `git checkout -b`, and was absent immediately after `new_active_feature_folder`. `docs/features/potential/promoted` and the newly created active feature folder carry the identical mtime to the nanosecond. No hand repair was performed.

This orchestration run's own preparation exercises the code path under investigation, so the run was instrumented as a controlled reproduction. This artifact records the raw probe output verbatim.

## Environment

- OS: Windows 11 Pro 10.0.26200
- Worktree: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-abfc86b76ed919bd8`
- Branch at Probe A: `worktree-agent-abfc86b76ed919bd8` (at `44663643`, equal to `origin/main`)
- Branch at Probe B: `bug/promotion-lifecycle-loses-promoted-record-487` (created from `origin/main` at `44663643`)
- Source path: `docs/features/potential/2026-08-17-promotion-lifecycle-loses-promoted-record.md`
- Reported destination path: `docs/features/potential/promoted/2026-08-17-promotion-lifecycle-loses-promoted-record.md`

## Step T0 — pre-promotion baseline

Timestamp: 2026-08-17T19:00:52.893347300Z
Command: `stat -c '%n | %s bytes | %y' <source>; stat -c '%n | %y' docs/features/potential/promoted; ls -1 docs/features/potential/promoted | wc -l; test -f <destination>`
EXIT_CODE: 0

```
docs/features/potential/2026-08-17-promotion-lifecycle-loses-promoted-record.md | 8261 bytes | 2026-08-17 15:00:41.426902700 -0400
docs/features/potential/promoted | 2026-08-17 14:58:21.071779900 -0400
26
ABSENT
```

Output Summary: Source present at 8261 bytes. Destination absent. Promoted directory holds 26 entries.

## Step T1 — `mcp__drm-copilot__potential_to_issue`

Timestamp: 2026-08-17T19:01:04Z (destination mtime)
Command: `mcp__drm-copilot__potential_to_issue` with `potential_path=docs/features/potential/2026-08-17-promotion-lifecycle-loses-promoted-record.md`, `promotion_type=bug`, `work_mode=full-bug`
EXIT_CODE: 0

```
{"ok":true,"tool":"potential_to_issue","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-abfc86b76ed919bd8","summary":"Promoted 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-abfc86b76ed919bd8/docs/features/potential/2026-08-17-promotion-lifecycle-loses-promoted-record.md' as a bug workflow in full-bug mode.","artifacts":["https://github.com/drmoisan/drm-copilot/issues/487"],"destination_path":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-abfc86b76ed919bd8/docs/features/potential/promoted/2026-08-17-promotion-lifecycle-loses-promoted-record.md"}
```

Output Summary: Promotion reported `ok: true`, issue #487 created, `destination_path` reported.

## Step T2 — PROBE A (immediately after `potential_to_issue`)

Timestamp: 2026-08-17T19:01:22Z
Command: `ls -la --time-style=full-iso <destination>` ; `ls -la --time-style=full-iso <source>` ; `stat -c '%n | %y' docs/features/potential/promoted` ; `ls -1 docs/features/potential/promoted | wc -l`
EXIT_CODE: 0 for destination and directory probes; 2 for the source probe (expected absence)

```
-rw-r--r-- 1 DanMoisan 197121 8446 2026-08-17 15:01:04.704909100 -0400 docs/features/potential/promoted/2026-08-17-promotion-lifecycle-loses-promoted-record.md
```

```
ls: cannot access 'docs/features/potential/2026-08-17-promotion-lifecycle-loses-promoted-record.md': No such file or directory
```

```
docs/features/potential/promoted | 2026-08-17 15:01:04.704909100 -0400
27
```

Output Summary: Destination PRESENT at 8446 bytes (the 8261-byte source plus the promotion header). Pre-promotion source correctly ABSENT. Promoted directory grew from 26 to 27 entries. The move succeeded. This contradicts the original attribution recorded in the potential entry and confirms the fourth observation.

## Step T3 — PROBE A-prime (after branch creation, before `new_active_feature_folder`)

Timestamp: 2026-08-17T19:01:40Z (approximate; between T2 and T4)
Command: `git checkout -b bug/promotion-lifecycle-loses-promoted-record-487 origin/main` then `ls -la --time-style=full-iso <destination>`
EXIT_CODE: 0

```
Switched to a new branch 'bug/promotion-lifecycle-loses-promoted-record-487'
branch 'bug/promotion-lifecycle-loses-promoted-record-487' set up to track 'origin/main'.
```

```
-rw-r--r-- 1 DanMoisan 197121 8446 2026-08-17 15:01:04.704909100 -0400 docs/features/potential/promoted/2026-08-17-promotion-lifecycle-loses-promoted-record.md
```

Output Summary: Destination still PRESENT, byte size and mtime unchanged. `git checkout -b` removed nothing. This isolates the branch operation as a non-cause.

## Step T4 — `mcp__drm-copilot__new_active_feature_folder`

Timestamp: 2026-08-17T19:01:50Z (folder mtime)
Command: `mcp__drm-copilot__new_active_feature_folder` with `feature_name=2026-08-17-promotion-lifecycle-loses-promoted-record`, `type=bug`, `work_mode=full-bug`, `issue_number=487`
EXIT_CODE: 0

```
{"ok":true,"tool":"new_active_feature_folder","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-abfc86b76ed919bd8","summary":"Created a new active bug feature folder for '2026-08-17-promotion-lifecycle-loses-promoted-record'.","artifacts":["C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-abfc86b76ed919bd8/docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/issue.md"],"destination_path":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-abfc86b76ed919bd8/docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487"}
```

Output Summary: Active feature folder created and reported `ok: true`.

## Step T5 — PROBE B (immediately after `new_active_feature_folder`)

Timestamp: 2026-08-17T19:02:00Z
Command: `ls -la --time-style=full-iso <destination>` ; `ls -la --time-style=full-iso <source>` ; `stat -c '%n | %y' docs/features/potential/promoted docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487 docs/features/potential` ; `ls -1 docs/features/potential/promoted | wc -l`
EXIT_CODE: 2 for both file probes (absence); 0 for the directory probes

```
ls: cannot access 'docs/features/potential/promoted/2026-08-17-promotion-lifecycle-loses-promoted-record.md': No such file or directory
```

```
ls: cannot access 'docs/features/potential/2026-08-17-promotion-lifecycle-loses-promoted-record.md': No such file or directory
```

```
docs/features/potential/promoted | 2026-08-17 15:01:50.613026300 -0400
docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487 | 2026-08-17 15:01:50.613026300 -0400
docs/features/potential | 2026-08-17 15:01:04.704909100 -0400
26
```

Output Summary: Destination ABSENT. Source ABSENT. The promoted directory entry count returned from 27 to 26 — a net removal of the record created at T1. `docs/features/potential/promoted` and the newly created active feature folder carry the IDENTICAL mtime to the nanosecond (`2026-08-17 15:01:50.613026300 -0400`), while `docs/features/potential` retained its earlier T1 mtime and was not touched. The nanosecond-identical pair indicates one operation touched both directories.

## Step T6 — `git status` control

Timestamp: 2026-08-17T19:02:10Z
Command: `git status --short`
EXIT_CODE: 0

```
?? docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/
```

Output Summary: No deletion entry appears for the promoted record. The record was created and removed within one session and was never committed, so its disappearance is invisible to `git status`. This confirms that `git status` is not a valid probe for this defect and that direct filesystem listing is required.

## Verdict

The loss REPRODUCED.

- The removing operation is `new_active_feature_folder`. The record was verified present after `potential_to_issue` (Probe A) and after `git checkout -b` (Probe A-prime), and verified absent immediately after `new_active_feature_folder` (Probe B), with no other command executed in between.
- The nanosecond-identical mtimes on `docs/features/potential/promoted` and the new active feature folder are consistent with a single operation touching both, and are inconsistent with an unrelated removal.
- `potential_to_issue` behaved correctly in this run: it moved the source to the reported `destination_path`, and the destination was present and larger than the source by the size of the injected promotion header.
- This is the sixth recorded observation of the defect and the second with clean two-sided bracketing. It corroborates the fourth observation (issue #479) and refutes the original attribution to `potential_to_issue`.

## Deliberate non-repair

The missing promoted record was NOT recreated by hand. Prior runs repaired it manually, which is what caused the committed tree to show the record as present and obscured the defect (see the "Current repository state (2026-08-17)" section of `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/issue.md`). The absence is retained here as evidence.

## Negative evidence claim

SearchScope: `docs/features/potential/`, `docs/features/potential/promoted/`
SearchPatterns: `2026-08-17-promotion-lifecycle-loses-promoted-record.md`
SearchResult: none, at both paths, at Probe B
