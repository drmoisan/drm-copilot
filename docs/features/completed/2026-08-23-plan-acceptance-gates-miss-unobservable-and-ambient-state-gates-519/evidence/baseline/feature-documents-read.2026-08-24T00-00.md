# Feature Documents Read — [P0-T2]

Timestamp: 2026-08-26T07-49
Task: [P0-T2]
Command: Read (five feature and policy documents), plus the acceptance-criteria count command reproduced below
EXIT_CODE: 0

## Files read (all five)

1. `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/spec.md` — 54172 bytes, 400 lines. Work Mode `full-bug`; sole acceptance-criteria source. Sections: Context, Repro & Evidence, Scope & Non-Goals, Root Cause Analysis, Proposed Fix (design summary, boundaries and invariants, dependencies, implementation strategy, technical specifications), Assumptions/Constraints/Dependencies, Data/API/Config Impact, Test Strategy, Acceptance Criteria, Risks & Mitigations, Rollout & Follow-up.
2. `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/issue.md` — 11192 bytes, 96 lines. Carries the metadata marker `- Work Mode: full-bug` on line 12. Five defect classes enumerated in Actual Behavior; the write-mode inventory that the register is drawn from sits under Suspected Cause / Notes.
3. `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/research/2026-08-23T23-45-unobservable-and-ambient-state-gates-research.md` — 50617 bytes, 471 lines. Q1 through Q9 plus effect-on-existing-output, testing implications, automation feasibility, recommended approach, and rejected alternatives.
4. `.claude/rules/plan-acceptance-gates.md` — 129 lines. Rules G1 through G6, the Scope-of-Invocation argument against grandfathering, the attribution window, graceful degradation, the G5 and G6 severity decisions, the checkable-literal definition and placeholder guard, the message-formatting prohibition, authoring guidance, and enforcement.
5. `.claude/skills/atomic-plan-contract/SKILL.md` — 205 lines. Canonical plan format, short-path contract, Phase 0 requirements, the non-overridable evidence-path clause, the coverage evidence contract, the final QA loop, the No-SKIPPED rule, expect-fail tasks, preflight validation, the validator gate, the Wrap-Tolerant Assertion Authoring section (lines 162-173) that new authoring bullets attach to, plan-path continuity, and mode precedence.

## Acceptance-criteria count

The `## Acceptance Criteria` section of `spec.md` begins at line 303. Counting the checkbox items from that line onward:

```
$ awk 'NR>=303' spec.md | grep -c -E '^- \[[ x]\] '
37
$ awk 'NR>=303' spec.md | grep -c -E '^- \[ \] '
37
```

**Acceptance criteria found in `spec.md`: exactly 37.** All 37 are currently unchecked, which is the expected pre-execution state; [P8-T13] is the only task authorized to change any of those checkboxes.

The 37 group into six blocks matching the plan's AC1-AC37 mapping table: rule behaviour (14 criteria, AC1-AC14), invariants and parity (7, AC15-AC21), severity discipline (5, AC22-AC26), regression against the measured defects (3, AC27-AC29), policy documentation (4, AC30-AC33), and delivery quality (4, AC34-AC37).

## Observations carried forward

- The research document records at Q7 that the issue #502 plan path named in `issue.md` and `spec.md` is stale: the feature was archived, so the file now sits under `docs/features/completed/...`. [P5-T1] extracts from the active-tree path as it stood at each of the six commits, which is the correct handling of a moved file.
- The research document records at Q7 that it could **not** verify the six commits are readable, because the researching agent had no shell tool. [P0-T14] performs that verification.
- `.claude/rules/plan-acceptance-gates.md` line 58 carries the stale G5 corpus-measurement citation under `docs/features/active/...`; [P7-T4] corrects it to the completed tree. Confirmed present at baseline.
- The Wrap-Tolerant Assertion Authoring section of `.claude/skills/atomic-plan-contract/SKILL.md` runs from line 162 to line 173 and currently carries six bullets. [P7-T5] appends to this section.

## Output Summary

All five documents read in full. `spec.md` carries exactly 37 acceptance criteria under its `## Acceptance Criteria` heading, all unchecked at baseline, matching the plan's AC1-AC37 mapping table. `issue.md` carries the `- Work Mode: full-bug` marker. The research document's two unverified items (commit readability, tier-map absence) are both resolved by other Phase 0 tasks. The stale G5 citation that [P7-T4] repairs is confirmed present in `.claude/rules/plan-acceptance-gates.md` at baseline.
