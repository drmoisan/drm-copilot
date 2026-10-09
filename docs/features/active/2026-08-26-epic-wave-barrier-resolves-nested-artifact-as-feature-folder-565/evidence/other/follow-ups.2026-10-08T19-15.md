# Follow-Ups (issue #565, child C2 of epic #852)

Timestamp: 2026-10-08T19-15
Command: Record of follow-up items (no command). P6-T4 recorded no deny, so this file was created by P10-T19.
EXIT_CODE: 0
Output Summary: One follow-up item (a). P6-T4 recorded zero deny entries, so item (b) is the single confirmation line. Issues are not created by this plan; the item is recorded here for filing at completion.

(a) Upstream-only citation gap (spec.md "Rollout & Follow-up"). A delegation prompt that cites only an upstream dependency's folder, and not the target folder, still resolves to that upstream, because no declared-target signal exists in the epic child kickoff. Proposed change: add the canonical issue-number line ("Canonical issue number for this feature is <N>.") to the epic child kickoff contract in `.claude/skills/epic-orchestrate/SKILL.md` (kickoff element at line 118), and make that line the primary target signal for the epic wave barrier and the epic leg of the preimplementation gate. Once the kickoff carries it, the epic gates can pass `-DeclaredIssueNumber` to `Select-FeatureFolderTarget` as the parallel gates already do. This is a skill-contract change outside C2's scope.

(b) P6-T4 activation observation (other/activation-probe.2026-10-08T19-09.md) recorded 52 allow and 0 deny for the timestamped plan files under docs/features/active/, so no deny entries need to be carried here. Confirmed: zero P6-T4 deny entries exist.
