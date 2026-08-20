# Evidence Location Audit [P7-T13]

Timestamp: 2026-08-20T20-48

Authority: `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` is the single source of truth for evidence paths. The canonical scheme is `<FEATURE>/evidence/<kind>/`, and the clause is non-overridable.

---

## Positive Check — every artifact is under the canonical root

SearchScope: `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/`, searched recursively.

SearchPatterns: `find <scope> -type f` (all files, no filter).

SearchResult: **46 files, all under `<FEATURE>/evidence/<kind>/`**, distributed across four canonical kinds:

| Canonical kind | Count | Produced by |
| --- | --- | --- |
| `evidence/baseline/` | 13 | Phase 0 (P0-T6 through P0-T20) |
| `evidence/regression-testing/` | 6 | Phase 1 fail-before (P1-T10, P1-T11, P1-T12), Phase 2 and 3 post-fix (P2-T6, P3-T6), Phase 4 post-fix (P4-T8) |
| `evidence/qa-gates/` | 20 | Phase 7 final QC (P7-T1 through P7-T13), including multiple loop iterations |
| `evidence/other/` | 7 | Phase 2 (P2-T7), Phase 5 (P5-T5), Phase 6 (P6-T1, P6-T2, P6-T4, P6-T7), plus one pre-existing planning-phase artifact |

`baseline/`, `regression-testing/`, `qa-gates/`, and `other/` are all canonical kinds per the skill. No artifact was written outside `<FEATURE>/evidence/`.

One of the seven `evidence/other/` files, `promotion-lifecycle-probe.2026-08-17T15-02.md`, predates this execution: it was produced during the research/planning cycle and was already committed on the branch. It is included in the count for completeness and is likewise in a canonical location.

The `qa-gates/` count exceeds the number of P7 tasks because the toolchain loop restarted: the TypeScript loop ran 3 iterations and the Python loop ran 4, and each iteration's outcome is recorded separately as the loop ledger requires. Multiple artifacts per task are expected, not an anomaly.

---

## Negative Check — no artifact in any forbidden location

SearchScope: `artifacts/` at the workspace root.

SearchPatterns: the eight forbidden sub-paths named in the plan and in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` — `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`, `artifacts/regression-testing/`, `artifacts/post-change/`.

SearchResult: **none present.** A `find` over `artifacts/` at depth 1 for all eight directory names returned no output and exited 0. Every one of the eight is confirmed absent.

The `artifacts/` tree contains exactly two subdirectories:

```
artifacts/orchestration/
artifacts/python/
```

`artifacts/orchestration/` is the one explicitly allowed non-evidence `artifacts/` sub-path. `artifacts/python/` is a pre-existing tooling output directory, not an evidence location, and this execution wrote nothing to it. Neither was created or modified by this plan.

---

## Evidence-Location Override Record

`EVIDENCE_LOCATION_OVERRIDE_REJECTED: <FEATURE>/evidence/coverage/ and <FEATURE>/evidence/qa/ (named in spec.md Test Strategy, AC-7, AC-11, and Rollout & Follow-up) replaced with docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/`

`spec.md` names `<FEATURE>/evidence/coverage/` and `<FEATURE>/evidence/qa/` in several places. Neither is a canonical evidence kind; the canonical set is `baseline/`, `regression-testing/`, `qa-gates/`, `issue-updates/`, `other/`, and `remediation-baseline/`. All coverage and post-fix QA evidence was therefore written under `evidence/qa-gates/`. This substitution was declared in the approved plan and is restated here as the required override record.

A second declared deviation concerns AC-7's fail-before location: `spec.md` names `<FEATURE>/evidence/baseline/`, while this execution wrote fail-before evidence to `evidence/regression-testing/`, which the skill designates as the canonical fail-before search scope and the canonical home for a fail-before exception dossier.

---

## Artifact Schema Spot-Check

Every command-step artifact carries the four required fields. Verified across the baseline, regression-testing, and qa-gates sets:

- `Timestamp:` — present in all 46 artifacts, in `yyyy-MM-ddTHH-mm` form. The literal string `<ISO>` appears in no filename and in no artifact body.
- `Command:` — present in every artifact that records a command execution.
- `EXIT_CODE:` — present with a **numeric** value in every command-step artifact. `SKIPPED` appears as a value nowhere. The two intentionally non-zero values are the P1-T10 and P1-T11 fail-before captures (both `1`, expected), plus the recorded Python loop iteration-2 failure (`1`, remediated).
- `Output Summary:` — present in every command-step artifact, carrying the essential result signal (pass/fail, counts, coverage headline, or the primary diagnostic).

Negative-claim artifacts additionally carry `SearchScope:`, `SearchPatterns:`, and `SearchResult:` as the skill requires: `baseline-quality-tiers-absence`, `baseline-depcruise-config-absence`, `final-ts-architecture`, `fail-before-exception-not-required`, and this artifact.

---

## Verdict

**PASS.** All 46 artifacts produced under this plan reside under `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/<kind>/`. None was written to `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`, `artifacts/regression-testing/`, or `artifacts/post-change/` — all eight are confirmed absent from the repository.
