# Acceptance-criteria status summary (issue #643)

Timestamp: 2026-09-07T19-46

Evidence paths below are relative to
`docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/`.

`EVIDENCE_LOCATION_OVERRIDE_REJECTED: docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa/ replaced with docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/` — criterion S39 names `evidence/qa/`, which is not a canonical kind under `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. The criterion text was not modified (no phantom or edited criteria); the QA gate artifacts it refers to are the ones listed below under `evidence/qa-gates/`.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/spec.md`
- Total AC items: 51
- Checked off (delivered): 51
- Remaining (unchecked): 0
- Items remaining: none

### Acceptance Criteria Status
- Source: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/user-story.md`
- Total AC items: 11
- Checked off (delivered): 11
- Remaining (unchecked): 0
- Items remaining: none

The 51 `spec.md` items are its three checkbox sections combined: 39 under `## Acceptance Criteria`
(S1-S39), 7 under `## Definition of Done` (D1-D7), and 5 under
`## Seeded Test Conditions (from potential)` (T1-T5). 39 + 7 + 5 = 51. The 11 `user-story.md` items
are all under its `## Acceptance Criteria` heading (U1-U11).

## `spec.md` — evidence path per checked item

| ID | Subject | Evidence |
| --- | --- | --- |
| S1 | both truth-table copies carry `mergeable_paths`, byte-equal | `evidence/qa-gates/phase1-python-parity.2026-09-07T15-45.md` |
| S2 | key optional and fail-closed | `evidence/qa-gates/phase3-pester-blast-radius.2026-09-07T16-20.md` |
| S3 | readers reject non-list and blank | `evidence/qa-gates/phase2-python-contention.2026-09-07T16-02.md` |
| S4 | `.csproj`-only overlap yields no edge | `evidence/qa-gates/phase3-python-parity.2026-09-07T16-24.md` |
| S5 | declared glob entry still contends | `evidence/qa-gates/phase3-python-parity.2026-09-07T16-24.md` |
| S6 | `**/` matches the root-level file | `evidence/qa-gates/phase2-python-contention.2026-09-07T16-02.md` |
| S7 | exclusion applied only in the contention relation | `evidence/qa-gates/phase2-python-contention.2026-09-07T16-02.md` |
| S8 | drift recomputation inherits the exclusion | `evidence/qa-gates/phase2-python-contention.2026-09-07T16-02.md` |
| S9 | `BlastRadiusConflict.psm1` exists with the named exports | `evidence/qa-gates/phase3-pester-blast-radius.2026-09-07T16-20.md` |
| S10 | three PowerShell procedural consumers state the change | `evidence/qa-gates/phase6-documentation-contracts.2026-09-07T18-00.md` |
| S11 | `mergeable_paths` carried through `CARRIED_KEYS` | `evidence/qa-gates/phase4-typescript-unit.2026-09-07T17-12.md` |
| S12 | rule file documents the mergeable path class | `evidence/qa-gates/phase6-documentation-contracts.2026-09-07T18-00.md` |
| S13 | rule file key-partition sentence updated | `evidence/qa-gates/phase6-documentation-contracts.2026-09-07T18-00.md` |
| S14 | `claude-blast-radius-derive-manifests.ts` split | `evidence/qa-gates/phase4-typescript-unit.2026-09-07T17-12.md` |
| S15 | .NET layout derives exactly `config` | `evidence/qa-gates/phase4-typescript-unit.2026-09-07T17-12.md` |
| S16 | nested `.sln` or `.slnx` yields no module | `evidence/qa-gates/phase4-typescript-unit.2026-09-07T17-12.md` |
| S17 | `assembleModules` and `PAYLOAD_MODULES` unchanged | `evidence/qa-gates/phase4-typescript-unit.2026-09-07T17-12.md` |
| S18 | three project-file-merge files exist and are mirrored | `evidence/qa-gates/phase5-surface-and-push-down.2026-09-07T17-50.md` |
| S19 | keyed union per MSBuild item type | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| S20 | `packages.config` union and version selection | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| S21 | `app.config` binding-redirect union | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| S22 | unparseable version and same-key attribute drift escalate | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| S23 | both hunk grammars parsed; unknown line escalates | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| S24 | never-drop post-condition holds | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| S25 | BOM, encoding, and terminators preserved | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| S26 | non-mergeable path in the conflict set escalates | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| S27 | script prints exactly one JSON object; no staging | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| S28 | skill documents the .NET verification step | `evidence/qa-gates/phase5-surface-and-push-down.2026-09-07T17-50.md` |
| S29 | skill documents the escalate path | `evidence/qa-gates/phase5-surface-and-push-down.2026-09-07T17-50.md` |
| S30 | agent carries exactly the four scoped allowlist entries | `evidence/qa-gates/phase5-surface-and-push-down.2026-09-07T17-50.md` |
| S31 | `mergeable_conflicts_resolved` tolerated by both validators | `evidence/qa-gates/phase7-python-cohort-and-tolerance.2026-09-07T18-08.md` |
| S32 | rule file declares the field; two sentences narrowed | `evidence/qa-gates/phase6-documentation-contracts.2026-09-07T18-00.md` |
| S33 | status template gains the projection section | `evidence/qa-gates/phase5-surface-and-push-down.2026-09-07T17-50.md` |
| S34 | zero-edge single cohort | `evidence/qa-gates/phase7-python-cohort-and-tolerance.2026-09-07T18-08.md` |
| S35 | cohort-barrier surfaces unmodified | `evidence/qa-gates/phase7-unmodified-surfaces.2026-09-07T18-16.md` |
| S36 | key-partition registries extended in both copies | `evidence/qa-gates/phase1-pester-key-partition.2026-09-07T15-47.md` |
| S37 | truth-table shape case and non-vacuity assertion | `evidence/qa-gates/phase3-pester-blast-radius.2026-09-07T16-20.md` |
| S38 | every file under 500 lines | `evidence/qa-gates/file-size-compliance.2026-09-07T18-22.md` |
| S39 | seven-stage toolchain passes with coverage thresholds | `evidence/qa-gates/final-qa-loop-outcome.2026-09-07T19-32.md` and `evidence/qa-gates/coverage-delta.2026-09-07T19-35.md` |
| D1 | acceptance criteria mapped to tests or demos | this artifact, `evidence/issue-updates/ac-status-summary.2026-09-07T19-46.md` |
| D2 | behavior matches acceptance criteria | `evidence/qa-gates/final-qa-loop-outcome.2026-09-07T19-32.md` |
| D3 | tests updated or added | `evidence/qa-gates/final-python-pytest-coverage.2026-09-07T18-40.md` |
| D4 | edge cases and error handling covered | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| D5 | docs updated | `evidence/qa-gates/phase6-documentation-contracts.2026-09-07T18-00.md` |
| D6 | telemetry or logging, if applicable | `evidence/qa-gates/scope-verification.2026-09-07T19-38.md` |
| D7 | toolchain pass completed | `evidence/qa-gates/final-qa-loop-outcome.2026-09-07T19-32.md` |
| T1 | unit coverage of the key and the no-edge case | `evidence/qa-gates/phase2-python-contention.2026-09-07T16-02.md` |
| T2 | module-derivation fixture with nine `.csproj` directories | `evidence/qa-gates/phase4-typescript-unit.2026-09-07T17-12.md` |
| T3 | merge-step fixtures per item type; escalation case | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| T4 | key-partition parity in three languages | `evidence/qa-gates/phase3-push-down-parity.2026-09-07T16-28.md` |
| T5 | zero-edge single-cohort run | `evidence/qa-gates/phase7-python-cohort-and-tolerance.2026-09-07T18-08.md` |

D6 is the "if applicable" telemetry item. This feature adds no telemetry surface and no logging
channel; the scope-verification artifact is the record that no telemetry or logging file is in the
change set, which is what makes the item satisfied rather than skipped.

## `user-story.md` — evidence path per checked item

| ID | Subject | Evidence |
| --- | --- | --- |
| U1 | empty conflict-edge list for mergeable-only overlaps | `evidence/qa-gates/phase7-python-cohort-and-tolerance.2026-09-07T18-08.md` |
| U2 | those items share a single cohort | `evidence/qa-gates/phase7-python-cohort-and-tolerance.2026-09-07T18-08.md` |
| U3 | the project file stays in the declared radius | `evidence/qa-gates/phase2-python-contention.2026-09-07T16-02.md` |
| U4 | no per-assembly module at the destination | `evidence/qa-gates/phase4-typescript-unit.2026-09-07T17-12.md` |
| U5 | delivered by push-down, no manual consumer edit | `evidence/qa-gates/phase3-push-down-parity.2026-09-07T16-28.md` |
| U6 | conflict confined to project files resolved in place | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| U7 | higher version selected and reported | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| U8 | non-mergeable path or unknown line escalates with paths | `evidence/qa-gates/phase5-pester-project-file-merge.2026-09-07T17-40.md` |
| U9 | formatter check and analyzer build before re-confirming CI | `evidence/qa-gates/phase5-surface-and-push-down.2026-09-07T17-50.md` |
| U10 | resolution cited in projection, PR body, commit, evidence | `evidence/qa-gates/phase5-surface-and-push-down.2026-09-07T17-50.md` |
| U11 | absent key behaves exactly as today | `evidence/qa-gates/phase7-unmodified-surfaces.2026-09-07T18-16.md` |

## Reconciliation statement

Every artifact named above exists on disk under
`docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/`. No item was left
unchecked, so the [P8-T17] contingency clause (checked counts lower by the number left unchecked,
each named here) does not apply.
