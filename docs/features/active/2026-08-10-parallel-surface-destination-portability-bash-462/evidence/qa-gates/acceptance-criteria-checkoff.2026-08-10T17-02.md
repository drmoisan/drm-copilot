# Acceptance-Criteria Check-Off — Issue #462

Timestamp: 2026-08-10T17-02

Task: [P7-T14]
Command: (traceability review against the recorded evidence artifacts and green test runs)
EXIT_CODE: 0

Work mode is `full-feature`, so per `.claude/skills/acceptance-criteria-tracking/SKILL.md` both
`spec.md` and `user-story.md` are AC sources and are tracked independently. Both carry the same 17
criteria; each row below is recorded twice, once per source file.

## Evaluation — `spec.md` (`## Acceptance Criteria`)

| # | Criterion (abbreviated) | Tasks | Evidence | Verdict |
| --- | --- | --- | --- | --- |
| AC1 | Bash cohort entry point, corpus parity in both lanes, fixture floor | P2-T1, P2-T3, P2-T5, P3-T5, P3-T6, P3-T13, P3-T14, P3-T17 | 30-fixture corpus `tests/fixtures/parallel_cohorts/` (floor 20); `test_parallel_cohort_bash_parity.py` 31 passed (`evidence/regression-testing/python-parity-suites.2026-08-10T15-13.md`); `parallel_cohorts_parity.bats` green in run 31410402606 | PASS |
| AC2 | Bash batching with the exact rejection message, both lanes | P2-T1, P2-T3, P3-T5, P3-T7, P3-T13, P3-T14, P3-T17 | 9 batching fixtures incl. `max_concurrency` 0 and -3; both parity suites green; `parallel_cohorts.bats` asserts `max_concurrency must be >= 1; received 0.` verbatim | PASS |
| AC3 | Bash manifest validator, M1-M7 byte parity, M1 divergence scoped | P2-T2, P2-T4, P2-T5, P3-T1..T4, P3-T8, P3-T12, P3-T15, P3-T17 | 41-fixture corpus (floor 24); `test_parallel_manifest_bash_parity.py` 83 tests; `parallel_manifest_parity.bats` green; the `M1_YAML_PARSE` fixture asserts prefix + single-element shape only, and the divergence class is stated in all four suite headers | PASS |
| AC4 | Default-resolving accessors with present/absent/invalid cases | P2-T2, P3-T4, P3-T8, P3-T12 | `parallel_manifest_validate.bats` cases: present (`open`/8), absent (`closed`/4), invalid non-string mode, invalid string mode, boolean cap, non-integer cap, out-of-range cap | PASS |
| AC5 | Byte-identical bundled mirrors plus a membership test | P3-T16, P5-T3, P7-T13 | `evidence/qa-gates/bundle-parity.2026-08-10T16-58.md` — 16/16 identical; `parallel_bash_manifest_membership.bats` green with a nine-file floor and a reverse-direction check | PASS |
| AC6 | Push-down publishes both config files, including pack-scoped | P4-T1, P4-T2, P4-T3, P4-T5, P5-T1 | `claude-config-carriage.test.ts` — plain publish, pack-scoped publish (R11 proof), enumeration order, three-copy byte pin; 15/15 green | PASS |
| AC7 | Routing merge: copy, merge, overwrite, preserve, idempotent, fail-fast | P4-T4, P4-T6 | Six Jest cases in `claude-config-carriage.test.ts`, one per behavior, including byte-stability across a second push and untouched bytes on an unparseable destination | PASS |
| AC8 | Generic blast-radius default; repo-root file unchanged | P4-T2, P4-T7, P7-T12 | Jest asserts the published document equals the pinned generic content and contains none of `scripts/dev_tools`, `packages/mcp-server`, `poetry.lock`, `package-lock.json`; `evidence/qa-gates/schema-freeze.2026-08-10T16-55.md` shows `config/blast-radius.json` unchanged | PASS |
| AC9 | Copilot and Codex published sets unchanged | P4-T8 | Two Jest non-regression cases: neither entry point publishes a `config/` file, and their `ROOT_FOLDERS` constants are asserted unchanged | PASS |
| AC10 | `core.json` lists the rule, bash paths, and config files | P5-T1, P5-T5 | `core.json` gained 13 entries; the manifest union now covers every bundled `rules/*.md` and `lib/**` file; seven parametrized Jest cases pin the specific paths | PASS |
| AC11 | Completeness test enumerates `rules/*.md`, `lib/**`, bundled `config/` | P5-T2, P5-T5 | `claude-pack-manifest-completeness.test.ts` extended with a recursive `lib/**` walk, a `rules/*.md` walk, and a second `BUNDLE_ROOT`-anchored `config/` walk behind a two-file floor; proven non-vacuous by removing `config/blast-radius.json`, which failed two cases, then restoring it | PASS |
| AC12 | Shell-QC discovery and kcov cover `.claude/lib/bash/**`; prose; bats | P1-T1..T5, P3-T17 | Third search root and third include-pattern root in `scripts/bash/shell_qc_lib.sh`; both prose sections of `.claude/rules/shell.md` updated; discovery bats extended to 6 entries with `.claude/lib/bash/lib_entry.sh` pinned first; the CI coverage report measures the new library, which is why line coverage rose 0.9 points while 2,043 lines entered the denominator | PASS |
| AC13 | shfmt/shellcheck/bats green, bash coverage >= 85%, evidence recorded | P1-T6, P3-T17, P7-T10, P7-T15 | `evidence/qa-gates/shell-gate-phase3.2026-08-10T16-22.md`, `final-shell-gate.2026-08-10T16-50.md`, and the head-SHA-matched `final-shell-gate-head.*.md`; both steps green, 245 bats tests, `Bash coverage (lines): 92.4%` | PASS |
| AC14 | Destination-runtime references repointed; no `poetry run` on the path | P6-T1..T5, P6-T8 | `evidence/qa-gates/poetry-grep.2026-08-10T17-05.md` — zero in-scope invocations; the two matches are an allowlist entry and prose about it; three residual out-of-scope CLIs enumerated with dispositions | PASS |
| AC15 | Allowlist entries in two agents and `settings.json`; PR callout | P6-T4, P6-T5, P6-T6, P6-T9 | `Bash(bash .claude/lib/bash/*)` added to all three files and mirrored; `evidence/other/permission-surface-callout.2026-08-10T17-08.md` holds the verbatim PR text | PASS |
| AC16 | Payload-only workspace clears all four blockers | P4-T9, P5-T4, P7-T10 | Jest payload-content case asserts the rule, all three bash entry points, and both config files are published; `parallel_payload_only.bats` runs all three entry points from the bundle root on `ubuntu-latest` under a PATH exposing only `sort`, `cut`, `cat`, `dirname`, and asserts positively that `python`, `python3`, and `poetry` are unreachable | PASS |
| AC17 | No schema, enum, or validator change | Binding constraint 6, P7-T12 | `evidence/qa-gates/schema-freeze.2026-08-10T16-55.md` — empty match set against a 158-file diff | PASS |

**Result: 17 of 17 PASS.** All 17 checkboxes in `spec.md` are now `[x]`.

## Evaluation — `user-story.md` (`## Acceptance Criteria`, line 95)

`user-story.md` mirrors the same 17 criteria verbatim. Each was evaluated independently against
the same evidence and reaches the same verdict.

| # | Criterion | Verdict |
| --- | --- | --- |
| AC1 | Bash cohort entry point with corpus parity | PASS |
| AC2 | Bash concurrency batching with the exact rejection message | PASS |
| AC3 | Bash manifest validator with M1-M7 byte parity | PASS |
| AC4 | Default-resolving accessors | PASS |
| AC5 | Byte-identical bundled mirrors plus membership test | PASS |
| AC6 | Push-down publishes both config files | PASS |
| AC7 | Routing merge semantics | PASS |
| AC8 | Generic blast-radius default; root file unchanged | PASS |
| AC9 | Copilot and Codex sets unchanged | PASS |
| AC10 | `core.json` completeness | PASS |
| AC11 | Completeness test enumeration extended | PASS |
| AC12 | Shell-QC discovery and kcov reach | PASS |
| AC13 | Shell toolchain green and coverage >= 85% | PASS |
| AC14 | Destination-runtime references repointed | PASS |
| AC15 | Allowlist entries plus PR callout | PASS |
| AC16 | Payload-only workspace clears all blockers | PASS |
| AC17 | No schema change | PASS |

**Result: 17 of 17 PASS.** All 17 checkboxes in `user-story.md` are now `[x]`.

## Other Checkbox Sections in `spec.md`

- **`## Definition of Done` — 7 of 7 checked.** Each is satisfied: AC mapped to tests and CI
  evidence above; behavior verified in both the pytest/Jest lanes and the CI shell lane; bats,
  pytest, Jest, and the membership test added; edge cases covered (validation ordering, CRLF and
  CR frontmatter, merge fail-fast, leading-zero and negative keys); `.claude/rules/shell.md`
  prose, skill wiring, and agent wiring updated; shell CI evidence under `evidence/qa-gates/`;
  and the full toolchain pass recorded for Python and TypeScript locally with the shell surface
  via CI dispatch.

- **`## Seeded Test Conditions (from potential)` — 5 of 6 checked.** One bullet is left
  **unchecked deliberately** and is not claimed as delivered:

  > bats unit coverage for the bash cohort computation: empty graph, single item, disjoint
  > items, fully connected items, deterministic tie-breaking, and **generation handling**.

  Five of its six clauses are delivered by `tests/shell/parallel_cohorts.bats`. The sixth,
  "generation handling", is not deliverable by this feature: `generation` (the
  `recolor_generation` counter) is caller-owned execution state that the cohort library never
  produces, increments, or accepts. `scripts/dev_tools/parallel_cohort_computation.py` states this
  explicitly in its "Caller-owned fields" section, and the bash port mirrors that contract exactly.
  Adding a generation parameter would be a schema and contract change, which binding constraint 6
  and AC17 forbid. The clause was seeded from the potential entry before the design fixed
  generation as caller-owned. Recording it as an unmet item rather than checking it keeps the
  check-off evidence-first.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/spec.md
- Total AC items: 17
- Checked off (delivered): 17
- Remaining (unchecked): 0
- Items remaining: none

- Source: docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/user-story.md
- Total AC items: 17
- Checked off (delivered): 17
- Remaining (unchecked): 0
- Items remaining: none
```
