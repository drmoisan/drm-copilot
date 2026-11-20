# Code Review: parallel-planner-time-based-edge-rule (#1164)

**Review Date:** 2026-11-11
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/parallel-planner-time-based-edge-rule-1164`
**Feature Folder Selection Rule:** named by the caller; matches the branch issue number 1164
**Base Branch:** `main` (merge base `228e6f8c4606e53f36963dc9aa57d71b4882b49e`, equal to `origin/main` at review time)
**Head Branch:** `feature/parallel-planner-time-based-edge-rule-1164` (head `35e8a26275d7f89e559449f2437dfc18aa654b0f`)
**Review Type:** Initial feature review (the executor's correction cycle `remediation-plan.2026-11-10T02-18.md` came from its own self-review, not from a feature review)

---

## Executive Summary

The branch converts the parallel scheduler's committed weights and band durations to integer minutes, so the existing rule `cost * 100 > benefit * tolerance_percent` at `tolerance_percent` 100 reads as "merge time exceeds parallel gain". It adds three things:
- access-aware path pricing: a path one side only reads costs 0, and a path both sides declare separable costs `separable`;
- a precedence gate that rejects an unjustified `--after` flag;
- recorded per-pair estimates, validated on checkpoints in Python and TypeScript and on the manifest in Python and bash.

The rule text is pinned on twelve planning surfaces.

**What changed:**
- PowerShell: `BlastRadiusAccess.psm1` (242 lines), `ParallelAdmissionPrecedenceGate.psm1` (128), `ParallelDriftAccess.psm1` (53); two subcommands in `Invoke-ParallelAdmission.ps1`; `separable` support in `BlastRadiusScheduling.psm1`.
- Python: `ItemAccess` and access-aware `_path_pair_weight` in `_blast_radius_scheduling.py`; M9 in `parallel_manifest_contract.py`; the B10.1 checks in `_parallel_state_records.py`.
- TypeScript: the same checks in `parallel-state-records.ts`.
- Bash: `parallel-manifest-pairs.sh`.
- Tests: seven new test files and 37 corpus fixtures. All mirrors are byte-identical at head.

**Top 3 risks:**
1. Default scheduling behaviour changes for every run planned after merge (owner-directed, OD-1164-1). The committed minutes rest on a small sample (spec D2). Recorded estimates make each verdict auditable, and destinations can override weights.
2. `access-paths` classifies a path as read-only from task-title words. A title such as "Run the generator that writes `x.json`" is read-only, because inflected forms (`writes`, `updates`) and verbs outside the list (`Regenerate`) are not write verbs. Spec B5.2 defines the rule this way, and drift detection reports a resulting write as an escape (spec D7). The heuristic can under-price a pair until drift is observed.
3. Cross-runtime error strings diverge for apostrophe-bearing values at the new `repr` sites, through the unchanged shared `pythonRepr` helper (finding row 1).

**PR readiness recommendation:** **Go.** No Blocker or Major finding. CI on the PR head and the PR-body statements of US-AC13 remain with the orchestrator.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `extensions/drm-copilot/src/lib/validate/parallel-state-records.ts` | `read_paths`/`separable_paths` membership error (line 575) and `tolerated_overlaps[].reasons` error (line 471) | For a value containing `'`, Python `repr` prints double quotes (`"it's.md"`), while the shared `pythonRepr` of `parallel-state-shared.ts` always single-quotes and escapes (`'it\'s.md'`). The two runtimes therefore emit different strings for such inputs at these new sites. The helper is unchanged by the branch, and the same class affects the pre-existing `repr` sites. | Optional within the item: make `pythonRepr` select double quotes when the string contains `'` and no `"`, as CPython does. Add one apostrophe case to `tests/fixtures/parallel_state_scheduling/`. Otherwise accept as the documented, pre-existing helper limitation. | US-AC6 asks for byte-identical strings; the committed corpus is identical, and the divergence is limited to apostrophe-bearing paths or reasons. Changing the helper changes strings of other validators, so it is not graded blocking. | Reviewer probe: esbuild bundle of `orchestration-artifacts.ts` against `validate_parallel_planner_state_text` on mutated `accept-planner-fields-valid.json`. Two DIFF cases (apostrophe read path, apostrophe reason); fractional and boolean cost, mis-cased `kind`, and non-list `separable_paths` SAME. |
| Minor | `tests/scripts/dev_tools/test_blast_radius_access_weights.py` | line 21 | `_path_pair_weight` is imported with `# pyright: ignore[reportPrivateUsage]`. This form is not among the pre-authorized patterns of `.claude/rules/python-suppressions.md`, which names `# noqa` and `# type: ignore`. 39 earlier test-file uses exist in `tests/scripts/dev_tools`. | Prefer testing rows through the public `pair_cost` with single-path radii, or accept per repository precedent. | Keeps suppression use within policy. | `grep -rn reportPrivateUsage tests/scripts/dev_tools` (39 files). |
| Info | `.claude/lib/blast-radius/BlastRadiusAccess.psm1` | `$script:WriteTitleVerb`, `Test-ReadOnlyWindowSet` | Write verbs match as whole words (case-insensitive), so inflected forms such as `writes`, `updates`, `adds` and unlisted verbs such as `Regenerate` or `Overwrite` do not mark a write. With a read first word (`Run`, `Execute`), such a title yields a read-only path. | Optional: extend the list with common inflections, or match on stems. | The spec permits the rule as written; the drift backstop exists. | Code inspection; real-process `access-paths` probe on the item's plan returned only `scripts/powershell/PoshQC/PoshQC.psd1`, which is named only by `Run` tasks. |
| Info | `.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1` | lines 147-150 | A tolerated overlap passed without `cost`/`benefit` is cast to 0 and the rejection reads "merge time 0 min does not exceed parallel gain 0 min". The engine always returns both estimates, so the case needs a hand-written entry. | None required. | Message quality only. | Code inspection. |
| Info | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | `Invoke-ParallelAdmissionPrecedenceTest` | `test-precedence` reads `config/blast-radius.json` relative to the current location, the helper's existing convention (`Resolve-ParallelAdmissionPath`). Run from a subdirectory, it exits 1 with `parallel admission failed: ... Could not find a part of the path`. It does not fail silently. | None required; the documented invocation uses a root-relative script path. | Fails loudly and matches the convention. | Real-process probe from `docs/` and from the user profile directory. |
| Info | `.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1` | line 96 | The one uncovered changed line (null band for an absent item key). | Optional test: a `kind: "cost"` entry naming a key absent from `items`. | File at 97.62%, above thresholds. | `artifacts/pester/powershell-coverage.xml` missed `nr=96`. |

No Blocker or Major finding. No covered file reaches 700 logical lines, so no file-size Warning row applies.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well

- `ItemAccess` is a frozen dataclass with empty defaults, and `NO_ACCESS` keeps every existing caller unchanged (B2.2 fail-closed).
- `_read_int_map(optional=...)` admits `separable` only when present and leaves every other unknown name rejected.
- The B10.1 checks in `_parallel_state_records.py` collect pairs from both lists and report a pair present in both.

#### Typing and API notes

- New parameters are keyword-only with defaults; `__all__` gains `ItemAccess`.
- Pyright 0 errors on the 17 changed files; Google-style docstrings with Args/Returns/Raises.

#### Error handling and logging

- Configuration errors keep the existing failure classes (`TypeError`, `ValueError`) and labels.

### PowerShell implementation audit (if applicable)

#### What changed well

- The new modules are pure and import siblings with `-ErrorAction Stop`; the CLI wrappers read through the existing seams.
- `Get-BlastRadiusAccessPathPairWeight` follows the Python row order exactly (read-only, append-only, separable when configured, same file, possible overlap). The shared scheduling corpus is run by both runtimes.

#### API and safety notes

- `$script:AdmissionRejectionCode` gains `precedence_not_justified`; the mutation rejection set is unchanged.
- A mis-cased `kind` (`Correctness`) is tested as a cost entry and rejected, the fail-closed direction; the validators also reject it.

#### Error handling and logging

- Rejections throw `precedence_not_justified: <detail>`, converted by the entry script into exit 1 and one `PARALLEL_ADMISSION_REJECTED:` line.

### TypeScript implementation audit (if applicable)

- `parallel-state-records.ts` ports the Python checks with the same message templates; no escape hatch was added.

### Bash implementation audit (if applicable)

- `parallel-manifest-pairs.sh` is a sourced file with the existing `shellcheck source=` pattern; the CI shellcheck and shfmt step reports 0 findings, and kcov reports 68 of 68 lines.

---

## Test Quality Audit

The new suites test behavior through shared corpora, so a runtime divergence on a corpus case fails a test. Every spec B4 row is a corpus case with expected edges at tolerance 100 and 0.

### Reviewed test and QA artifacts

- `evidence/qa-gates/pester-gate.2026-11-10T04-34.md`, `pytest-gate.2026-11-10T04-06.md`, `jest-gate.2026-11-10T04-06.md`, `shell-ci.2026-11-10T03-17.md`
- `evidence/qa-gates/coverage-comparison.2026-11-10T02-09.md`, `self-review.2026-11-10T03-18.md`, `commenting-sweep.2026-11-10T02-42.md`
- `evidence/other/main-merge.2026-11-10T04-08.md`, `recalibration-basis.2026-11-09T23-45.md`

### Quality assessment prompts

- Do the tests discriminate? The parity corpus compares full ordered error lists in both runtimes, and the scheduling corpus pins exact `cost` and `benefit` per pair.
- Are legacy inputs covered? `accept-without-fields.json`, the unchanged `seed-scheduling-record.json` pin, and the reviewer's real-checkpoint probe (8 checkpoints, identical results on `main` and the branch).

---

## Security / Correctness Checks

- No absolute path or host name in committed artifacts (spot check of the new fixtures and evidence).
- Declared radii are never narrowed: the access lists sit beside `blast_radius` and must be members of `blast_radius.paths` (validator rule, B10.1).
- Hard classes stay edges at every tolerance (corpus rows for `shared_surface_overlap` and `contract_dependency`).
- No agent `tools:` frontmatter line changed (0 `+tools:`/`-tools:` lines in the diff of `.claude/agents/`).

---

## Research Log

- Read the PR context summary and appendix at head `35e8a2627`.
- Parsed the three canonical coverage artifacts and compared them with the post-merge gate records.
- Ran real-process probes of `test-precedence` (9 shapes, including from a subdirectory and from outside the repository) and `access-paths`.
- Ran the branch and `main` Python validators over 8 real checkpoints.
- Bundled the worktree TypeScript validator with esbuild and compared it with the Python validator on 8 mutated documents.

---

## Verdict

**Go.** Zero blocking findings; two Minor and four Info observations, none requiring a remediation cycle.
