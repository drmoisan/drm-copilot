# Policy Audit — remove-remaining-python-invocations (Issue #599)

- Timestamp: 2026-08-30T17-17
- Branch: `feature/remove-remaining-python-invocations-599-r2`
- Base branch: `main`
- Merge base: `8b94217e198a484956a20297922db211d51d3faa`
- Scope: full branch diff `git diff main...HEAD` — 114 files, +6294 / -221
- Work mode: `full-feature` (confirmed at `issue.md:13`)

## Rejected Scope Narrowing

None. The caller prompt supplied no scope narrowing and explicitly directed the full
branch-diff audit. No plan, phase, or task subset was substituted for the branch diff.

## Per-Language Changed-File Census (derived from the branch diff)

| Language | Changed files | Production | Test / fixture |
| --- | --- | --- | --- |
| bash (`.sh`) | 4 | 4 (2 repo + 2 byte-identical bundle mirrors) | 0 |
| bats (`.bats`) | 5 | 0 | 5 |
| TypeScript (`.ts`) | 3 | 0 | 3 (all under `extensions/drm-copilot/test/`) |
| Python (`.py`) | 1 | 0 | 1 (`tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py`) |
| PowerShell (`.ps1`/`.psm1`) | 0 | 0 | 0 |
| C# (`.cs`) | 0 | 0 | 0 |
| JSON / Markdown | 101 | n/a | fixtures, manifests, docs, evidence |

## Coverage Verification

Verified by inspecting pre-existing coverage artifacts. No coverage run was re-executed.

### bash — PASS

- Artifact: `artifacts/pester/kcov/cov.xml` (67,314 bytes, present on disk).
- Repo-wide: **92.3% lines** (>= 85%). Evidence:
  `evidence/qa-gates/final-bash-coverage.2026-08-30T20-45.md`, TAP plan `1..290`, 290 `ok`,
  0 `not ok`, exit 0.
- New files, per-file `line-rate` read directly from `cov.xml`:

  | File | line-rate | Threshold | Verdict |
  | --- | --- | --- | --- |
  | `.claude/lib/bash/parallel-lane-assertion.sh` | 0.989 | >= 0.85 (and >= 0.90 new-file) | PASS |
  | `.claude/lib/bash/report-lane-assertion.sh` | 0.949 | >= 0.85 (and >= 0.90 new-file) | PASS |

- Branch coverage: not applicable. kcov emits no branch counter for bash;
  `.claude/rules/quality-tiers.md` and `.claude/rules/shell.md` apply no bash branch gate.
  This is a capability exemption, not an omitted verdict.
- Exclusions: verified none. kcov include pattern is the three discovery roots
  (`scripts/bash/shell_qc_lib.sh:335`); exclude pattern is `tests` only (`:336`). Both new
  files are inside the include set. No production file is excluded from measurement.
- Note on the remediation trail: the executor recorded an initial `line-rate="0.814"` for the
  entry point, diagnosed it as a kcov attribution limitation on `|| { ...; }` and `case`
  bodies, confirmed the diagnosis with an isolated kcov run, and remediated by adding
  `tests/shell/report_lane_assertion_dispatch.bats` (14 in-process cases) rather than by
  altering production code or excluding the file. The reasoning and the measurement are both
  recorded in `evidence/qa-gates/bash-new-file-coverage.2026-08-30T20-45.md`. This is the
  correct response under the Coverage Exclusion Policy.

### Python — PASS

- Artifact: `artifacts/python/lcov.info` (present).
- Content: one record, `scripts/dev_tools/parallel_lane_assertion.py`, `LF:143 LH:143` =
  **100% line coverage**, `FNF:12 FNH:12`.
- Repo-wide figure: the artifact is a targeted `--cov=scripts.dev_tools.parallel_lane_assertion`
  run rather than a repo-wide run
  (`evidence/qa-gates/final-python-coverage.2026-08-30T20-45.md`, 79 passed, exit 0).
- Changed-file tier: the branch changes **zero Python production files**. The only Python file
  in the diff is a new test. There is therefore no new or modified production Python file to
  hold to the new-file or modified-file threshold, and no changed production line whose
  coverage could regress.
- Branch coverage: the supplied lcov carries no `BRDA:` records, so no branch percentage is
  derivable from it. Recorded verdict is PASS on the basis that the branch threshold binds
  changed production files and this branch changes none; the absent `BRDA` data is recorded as
  an evidence-quality observation rather than a gate failure. This is a stated judgment.

### TypeScript — PASS

- Artifact: **not** at the path named in the agent definition (`coverage/lcov.info` does not
  exist at repo root). It exists at the workspace-native path Jest writes to:
  `extensions/drm-copilot/coverage/lcov.info` (present, verified on disk). The canonical path
  in the agent definition does not match this repository's monorepo layout; the artifact is
  present, so the FAIL rule for an absent artifact does not fire.
- Figures: Statements 96.72% (44234/45730), Branches 90.17% (6297/6983), Lines 96.72%,
  Functions 89.93%. Source: `evidence/qa-gates/final-ts-coverage.2026-08-30T20-45.md`,
  exit 0, 203 suites / 2735 tests passed.
- Thresholds: line 96.72% >= 85% PASS; branch 90.17% >= 75% PASS.
- Changed-file tier: all 3 changed `.ts` files are under `extensions/drm-copilot/test/` and are
  legitimately outside the coverage denominator. Zero production TypeScript changed, which the
  evidence corroborates: every percentage and every covered/total pair is byte-identical to the
  Phase 0 baseline (`evidence/baseline/ts-coverage.2026-08-30T06-22.md`). No regression.

### PowerShell — not applicable (zero changed files)

Zero `.ps1`/`.psm1` files in the branch diff, confirmed by
`git diff --name-only main...HEAD | grep -Ec "\.(ps1|psm1|cs)$"` returning `0`. `N/A` is the
correct verdict here under the Scope Invariant, which permits it only for languages with zero
changed files. `artifacts/pester/powershell-coverage.xml` is absent; that absence is not a
finding because the language has no changed files. A PowerShell regression run (27 passed,
0 failed) is nonetheless recorded in the evidence tree as a non-regression check.

### C# — not applicable (zero changed files)

Zero `.cs` files in the branch diff. `artifacts/csharp/coverage.xml` is absent; not a finding.

## Evidence Location Compliance — PASS

- `git diff --name-only main...HEAD | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"`
  returns **no matches**. No branch file is written under a non-canonical evidence path.
- `python scripts/dev_tools/validate_evidence_locations.py --root .` exits **0**.
- All 47 evidence artifacts are under the canonical
  `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/evidence/<kind>/`
  with `<kind>` in `{baseline, qa-gates, regression-testing, other}`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events: no delegation instruction in scope specified
  a non-canonical path.

## Policy Compliance Findings

| # | Policy | Requirement | Verdict | Evidence |
| --- | --- | --- | --- | --- |
| 1 | `general-code-change.md` | File size <= 500 lines | PASS | `wc -l`: 495 and 169 for the two new bash files; largest new test file 458 lines; the bundle mirrors are byte-identical so identical counts |
| 2 | `general-code-change.md` | Simplicity, separation of concerns | PASS | Pure library (`pla_`) / I/O entry point (`rla_`) seam mirrors the two existing sibling ports and the Python reference's own declared boundary |
| 3 | `general-code-change.md` | Fail fast, no silent error swallowing | PASS with note | Malformed edges and malformed manifest entries are skipped by design; this is a specified advisory contract (`spec.md:117-118`), documented at every site, not silent swallowing. Usage errors do fail fast with exit 2 |
| 4 | `general-code-change.md` | Naming descriptive; language conventions | PASS | `pla_`/`rla_` prefixes, `PLA_`/`RLA_` globals, snake_case functions consistent with sibling modules |
| 5 | `general-code-change.md` | No new dependencies | PASS | External-utility budget respected: `cat`, `sort`, `dirname` only, all inside the four-shim `PATH` of `tests/shell/parallel_payload_only.bats` |
| 6 | `shell.md` | `set -euo pipefail` first executable line | PASS | `report-lane-assertion.sh:29`; pinned by the bats case at `parallel_lane_assertion.bats:268` |
| 7 | `shell.md` | Self-directory resolution before sourcing | PASS | `report-lane-assertion.sh:32`, `parallel-lane-assertion.sh:34`; pinned by the `cd /` case at `parallel_lane_assertion.bats:245` |
| 8 | `shell.md` | `pc_enforce_c_locale` before work | PASS | `report-lane-assertion.sh:37`; pinned by `parallel_lane_assertion.bats:255` |
| 9 | `shell.md` | shfmt clean, no rewrite | PASS | `evidence/qa-gates/final-bash-format.2026-08-30T20-45.md`: `BEFORE=` and `AFTER=` digests byte-identical, `FORMAT_RC=0` |
| 10 | `shell.md` | shellcheck clean; suppressions justified inline | PARTIAL | `check` exits 0 with empty output. The single suppression is `SC2034` declared **file-wide** at `parallel-lane-assertion.sh:26-30` with a stated reason. The reason is sound (cross-file global reads) but the scope is broader than per-line. See CR-3 |
| 11 | `shell.md` | Quote all expansions | PASS | shellcheck clean; manual read of both files found no unquoted expansion |
| 12 | `general-unit-test.md` | Test file location mirrors source | PASS | `tests/shell/*.bats`, `tests/scripts/dev_tools/*.py`; no colocation in `.claude/lib/bash/` |
| 13 | `general-unit-test.md` | No temporary files in tests | PASS | `grep -n "mktemp\|/tmp\|BATS_TMPDIR\|BATS_TEST_TMPDIR"` across all four new/changed suites returns no matches; every input is a file literal or a checked-in fixture |
| 14 | `general-unit-test.md` | Determinism; no clock, RNG, or sleep | PASS | `grep -n "date +\|RANDOM\|sleep "` returns no matches. The port reads no clock and no randomness (`spec.md:133`) |
| 15 | `general-unit-test.md` | Independence and isolation | PASS | Each bats `setup()` re-sources the library and resets state; the parity lanes are data-driven over checked-in JSON |
| 16 | `general-unit-test.md` | Scenario completeness (positive, negative, edge, error) | PASS | 16 unit cases + 14 dispatch cases + 8 parity cases; covers all four finding classes, the four usage-error arms, unreadable / unparseable / out-of-subset manifests, self-loop, undeclared endpoint, reversed and duplicate edges, empty and whitespace `--edges`, and the 13-lane / 69-item scale |
| 17 | `general-unit-test.md` | Coverage Exclusion Policy — no production file excluded | PASS | Verified against `scripts/bash/shell_qc_lib.sh:335-336`; no `exclude` entry matches a production path; no `exclude` entry added by this branch |
| 18 | `quality-tiers.md` | Uniform line >= 85%, branch >= 75% where measurable | PASS | See Coverage Verification |
| 19 | `policy-compliance-order` skill | No policy document modified | PASS | `git diff --stat main...HEAD -- .claude/rules/` returns empty; no file under `.github/instructions/` in the diff |
| 20 | `tonality.md` | Professional, evidence-first tone in authored docs | PASS | Sampled `spec.md`, `user-story.md`, and 8 evidence artifacts; measured, citation-backed phrasing throughout; no hyperbole or humor observed |
| 21 | `general-code-change.md` | Seven-stage toolchain loop to a single clean pass | PASS | Format, lint, and test evidence all exit 0 on the final Phase 6 run; the loop was correctly restarted from stage 1 after the P6-T5 test addition and both runs are recorded |
| 22 | Feature-specific | Bundle mirror byte-identity | PASS | `cmp -s` on all 7 mirrored `.claude/**` files (2 new bash + 5 edited markdown) reports IDENTICAL for every pair |
| 23 | Feature-specific | Parity with the Python reference over the documented input surface | **FAIL** | An undeclared divergence exists for a newline-bearing `--edges` value. See PA-1 |

## Detailed Findings

### PA-1 (FAIL, remediation required) — undeclared parity divergence on a newline-separated `--edges` value

`pla_parse_edges` tokenizes with `read -ra tokens <<<"$text"` (`parallel-lane-assertion.sh:86`).
`read` consumes one line, so every edge token after the first newline is silently discarded.
The Python authority uses `str.split()` (`parallel_lane_assertion.py:425`), which treats `\n`
as a separator like any other whitespace. The two implementations therefore disagree.

Reproduced directly against both lanes on the same manifest and the same input:

```
--edges $'999:998\n101:202'   bash port -> "Lane assertion: 2 derived conflict component(s); 0 disagreement(s)."
--edges $'999:998\n101:202'   Python    -> "Lane assertion: 1 derived conflict component(s); 0 disagreement(s)."
```

This is not a member of any of the five divergence classes declared in `spec.md:328-366`. It is
material because `spec.md:352-358` asserts the opposite as its justification for excluding
whitespace from divergence class 3: "The port specified here consumes the same
whitespace-separated token stream, so it cannot observe interior whitespace either." That claim
holds for spaces and tabs but not for newlines, and the spec's exhaustive framing — class 3 "has
exactly these four members" — makes the omission a documented-completeness failure rather than a
silent oversight.

Impact assessment, stated at the strength of the evidence:

- Behavioral risk is low. The diagnostic is advisory-only, always exits 0, feeds nothing, and
  the documented invocation form in both `parallel-plan/SKILL.md:321` and
  `parallel-planner.md:189` is a single-line space-separated string.
- The same `read -ra <<<` pattern is pre-existing precedent in the sibling entry points.
  `compute-cohorts.sh` was probed with the same class of input and also mishandles it
  (`--keys "101 202 303" --edges $'101:202\n202:303'` yields `[[101,303],[202]]`, which is not
  a correct partition of that graph). This finding is therefore about an undeclared divergence
  in this feature's exhaustive parity claim, not a regression this feature introduces.
- No corpus fixture and no unit case covers the newline case in either direction, so the gap is
  currently invisible to the suites.

Two acceptable remediations, either sufficient:

1. Declare it. Add a divergence class 6 to `spec.md`, correct the class-3 whitespace paragraph
   to scope its claim to space and tab, and pin the behavior with a bash-only unit case, exactly
   as class 3 is pinned. This matches how the feature already handles known divergences.
2. Close it. Split on all whitespace, for example by reading the here-string in a loop or by
   normalizing newlines to spaces before `read -ra`, and add a convergence fixture to the shared
   corpus.

Option 1 is the smaller change and is consistent with the sibling entry points' existing
behavior; option 2 changes the port's behavior away from its siblings and should not be taken
without also considering `compute-cohorts.sh`.

### PA-2 (PASS) — no executable Python invocation remains in the in-scope payload

The feature's core claim is verified by direct query against the branch head:

- `git grep -n -F "python -m scripts.dev_tools." -- .claude/skills/` returns exactly **one**
  match, `.claude/skills/parallel-orchestrate/SKILL.md:817` (drift-detection CLI, declared
  non-goal). The pre-feature count was four.
- `git grep -n -F "poetry run python" -- .claude/skills/` returns exactly **two** matches,
  line 817 above and `.claude/skills/parallel-remove/SKILL.md:112` (mutation-abandon CLI,
  declared non-goal).
- `git grep -n -F "parallel_lane_assertion" -- .claude/skills/parallel-plan/SKILL.md` returns
  **no match at all**, so no executable invocation and no residual citation remain in that file.
- `git grep -c -F "mcp__drm-copilot__validate_orchestration_artifacts"` reports a non-zero
  count for both `epic-orchestrate/SKILL.md` and `parallel-orchestrate/SKILL.md`.
- `git grep -n -F "checkpoint-validator CLI fallback" -- .claude/agents/parallel-orchestrator.md`
  returns no match; the rewritten paragraph names only the drift-detection CLI, which still
  exists.

The two remaining sites are the declared non-goals with recorded rationale
(`spec.md:491-510`), and the Known Residual against epic manifest line 14 is documented and
routed to the epic owner (`evidence/other/known-residual.2026-08-30T20-45.md`, and
`epic-status.md:79-83`).

### PA-3 (PASS) — non-goals untouched

`git diff --stat main...HEAD -- .claude/rules/parallel-orchestration.md
.claude/skills/parallel-remove/SKILL.md` returns empty. The `parallel-orchestrate/SKILL.md`
diff contains zero occurrences of `drift_detection`, so line 817 is unchanged. No discovery-gate
hook file appears in the diff.

### PA-4 (PASS) — documented invocation matches the shipped calling convention

Verified by reading both sides rather than by inference:

- Shipped surface: `rla_main` accepts exactly `--manifest`, `--edges`, `--help`/`-h`; every
  other token is a usage error returning 2 (`report-lane-assertion.sh:96-128`).
- `parallel-plan/SKILL.md:321` documents
  `bash .claude/lib/bash/report-lane-assertion.sh --manifest <path> --edges "<a>:<b> ..."`.
- `parallel-planner.md:189` documents the identical form.
- `parallel-planner.md:20` grants `"Bash(bash .claude/lib/bash/report-lane-assertion.sh*)"`,
  whose prefix matches the documented invocation exactly.
- Absence of `--keys` is pinned by a dedicated negative case
  (`parallel_lane_assertion.bats:307`), which asserts exit 2 and empty stdout.
- The persona's arithmetic was checked and is correct: 11 files under `.claude/lib/bash/`,
  4 entry points, 7 sourceable libraries, matching the rewritten sentence at
  `parallel-planner.md:164-169`.
- Feature C's contended region is intact: the diff of `parallel-planner.md` shows no changed
  line in the PowerShell paragraph at 147-156.

### PA-5 (PASS) — mirror parity and manifest registration

`cmp -s` confirms byte identity for all seven mirrored files. `core.json` lists both new bash
paths (lines 144, 148). `MINIMUM_LIB_FILE_COUNT` raised 9 -> 11 in
`tests/shell/parallel_bash_manifest_membership.bats:21`, and the entry-point enumerations in
both TypeScript push-down suites and in `config-carriage.test-helpers.ts` include
`report-lane-assertion.sh`.

## Verdict Summary

| Area | Verdict |
| --- | --- |
| Scope integrity (full branch diff audited) | PASS |
| Evidence location compliance | PASS |
| bash coverage | PASS |
| Python coverage | PASS |
| TypeScript coverage | PASS |
| PowerShell coverage | N/A (zero changed files) |
| C# coverage | N/A (zero changed files) |
| Cross-language code-change policy | PASS |
| Cross-language unit-test policy | PASS |
| Shell rules | PARTIAL (finding CR-3, non-blocking) |
| Payload Python removal (core claim) | PASS |
| Parity claim completeness | **FAIL** (finding PA-1) |

**Overall: PARTIAL.** One remediation-required finding (PA-1). All gates, thresholds, mirror
guards, and non-goal boundaries are otherwise satisfied with direct evidence.
