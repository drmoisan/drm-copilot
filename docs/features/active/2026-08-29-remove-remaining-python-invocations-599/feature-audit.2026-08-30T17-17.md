# Feature Audit — remove-remaining-python-invocations (Issue #599)

- Timestamp: 2026-08-30T17-17
- Branch: `feature/remove-remaining-python-invocations-599-r2`
- Base branch: `main`, merge base `8b94217e198a484956a20297922db211d51d3faa`
- Scope: full branch diff against `main` (114 files, +6294 / -221)

## Work Mode and AC Source Resolution

The work-mode marker was read directly from the source file and independently confirmed:
`issue.md:13` reads `- Work Mode: full-feature`.

Under `full-feature`, the authoritative acceptance-criteria sources are **`spec.md` and
`user-story.md`**. The early-draft criteria in `issue.md:61-76` are not an AC source in this
mode and were not evaluated as such; they are superseded by `spec.md`, which states at lines
10-13 that the research artifact's corrected citations govern where `issue.md` disagrees.

- `spec.md` `## Acceptance Criteria`: 20 checkbox items (lines 556-639).
- `spec.md` `## Definition of Done`: 4 checkbox items (lines 643-649). Evaluated separately
  below; these are completion gates, not acceptance criteria.
- `user-story.md` `## Acceptance Criteria`: 13 checkbox items (lines 119-187).

All 33 AC items arrived at review already marked `[x]`. Every one was re-verified independently
against the branch head; none was accepted on the strength of its checkbox.

## spec.md Acceptance Criteria (20 items)

| # | Criterion (abbreviated) | Verdict | Independent verification |
| --- | --- | --- | --- |
| S1 | Both new bash files exist; `shell-qc.sh check` exits 0 with both in scan scope | PASS | Both files present at 495 and 169 lines. `evidence/qa-gates/final-bash-check.2026-08-30T20-45.md` records exit 0 with empty output, run twice across the P6-T5 loop restart. `.claude/lib/bash/` is a discovery root per `shell.md`, so both are in scope by construction |
| S2 | Unit suite passes; contains self-directory, `pc_enforce_c_locale`-ordering, and `set -euo pipefail` cases | PASS | Cases read at `parallel_lane_assertion.bats:245`, `:255`, `:268`. The self-directory case runs from `/` so a cwd-relative source would fail. Suite green in the 290-case bats run |
| S3 | Case pinning `--keys` exits 2 with usage text on stderr | PASS | `parallel_lane_assertion.bats:307-320`. Asserts exit 2, the usage first line, and empty stdout under `2>/dev/null` |
| S4 | Case pinning divergence class 3 (four forms); interior whitespace pinned as a corpus convergence case | PASS | `parallel_lane_assertion.bats:395-429` covers `0101`, `+101`, `1_01`, and Arabic-Indic `١٠١` written as explicit UTF-8 bytes, plus a well-formed control. Convergence half at `parallel_lane_assertion_parity.bats:176`. Note: the class is asserted exhaustive and is not — see the Gap section |
| S5 | Case: out-of-subset manifest yields the refusal line and exit 0; input absent from the shared corpus | PASS | `parallel_lane_assertion.bats:363-393`. Asserts exit 0, the refusal prefix and suffix, that the line is *not* the unparseable line, and that `items: [101, 202]` appears in no corpus file |
| S6 | Both parity lanes pass over the corpus; each declares and asserts `MINIMUM_FIXTURE_COUNT`; bats lane asserts `python3` availability | PASS | `MINIMUM_FIXTURE_COUNT=20` at `parallel_lane_assertion_parity.bats:70` and at `test_parallel_lane_assertion_bash_parity.py:82`; asserted at `:81` and `:169`. 23 fixtures present. `python3 is available` case at `:86`. 79 pytest cases passed |
| S7 | Parity-lane case asserts each of the four `kind` tokens appears in some fixture's `expected_stdout` | PASS | `parallel_lane_assertion_parity.bats:118-138`, iterating all four tokens with a per-token failure message |
| S8 | Parity-lane case asserts `expected_status` is 0 for every fixture; bats compares subprocess status; at least one ADVISORY fixture | PASS | `parallel_lane_assertion_parity.bats:141-158` asserts status 0 for every fixture and requires at least one ADVISORY record so the assertion is not vacuous. Subprocess status compared at `:104-113` |
| S9 | Case pinning no production consumer of either new file | PASS | `parallel_lane_assertion.bats:431-457`. Walks every `.sh` in `.claude/lib/bash/`, checks both directions, and includes a control proving the grep pattern matches somewhere |
| S10 | `parallel_payload_only.bats` passes with a case invoking the entry point from the bundle root under the four-shim `PATH` | PASS | New case added at the tail of `parallel_payload_only.bats`, asserting exit 0 and the exact header `Lane assertion: 2 derived conflict component(s); 0 disagreement(s).` The shim `PATH` carries only `cat`, `cut`, `dirname`, `sort`; the entry point uses `cat`, `sort`, `dirname` only |
| S11 | `python -m scripts.dev_tools.` returns exactly 1 match; `poetry run python` exactly 2; MCP literal non-zero in both skills | PASS | Re-run at review: 1 match (`parallel-orchestrate/SKILL.md:817`), 2 matches (`:817` and `parallel-remove/SKILL.md:112`), MCP count 1 in each of the two skills |
| S12 | No executable `parallel_lane_assertion` invocation in `parallel-plan/SKILL.md`; the bash literal is present in the seeding step | PASS | `git grep -n -F "parallel_lane_assertion" -- .claude/skills/parallel-plan/SKILL.md` returns **no match at all**. The bash literal is at `:321`, inside step 2 of the seeding procedure |
| S13 | Planner `tools:` grant present; `## Upstream Library Invocation` documents the entry point; no changed line in the PowerShell paragraph 147-156 | PASS | Grant at `parallel-planner.md:20`. Documentation block added at `:185-192`. The file diff shows no hunk touching 147-156, so Feature C's contended region is intact |
| S14 | `checkpoint-validator CLI fallback` no longer appears in `parallel-orchestrator.md`; rationale names only surviving consumers | PASS | Grep returns no match. The rewritten paragraph at `:92-97` names only the drift-detection CLI, which still exists at `parallel-orchestrate/SKILL.md:817` |
| S15 | Push-down `.claude` payload parity pytest passes | PASS | `cmp -s` confirms byte identity for all 7 mirrored files, which is the stronger of the two guards. Test recorded green in `evidence/qa-gates/final-python-coverage.2026-08-30T20-45.md` (`test_push_down_claude_resource_contracts.py` in the 79-case run) |
| S16 | `core.json` lists both new paths; membership bats passes with `MINIMUM_LIB_FILE_COUNT` 9 -> 11 | PASS | `core.json:144` and `:148`. `parallel_bash_manifest_membership.bats:21` = 11; the entry-point case was widened from three to four names |
| S17 | Both TypeScript push-down enumerations include `report-lane-assertion.sh`; both suites pass | PASS | `claude-pack-manifest-completeness.test.ts:245`, `claude-config-carriage.test.ts:454`, and the hermetic tree seed at `config-carriage.test-helpers.ts:149,163`. 203 suites / 2735 tests passed, exit 0 |
| S18 | Bash line coverage >= 85%; per-file rows for both new files in `cov.xml`; neither excluded | PASS | Repo-wide 92.3%. Per-file `line-rate` 0.989 and 0.949 read directly from `cov.xml` lines 1268 and 1717. Exclusion set verified as `tests` only. Output recorded under `evidence/qa-gates/` as required |
| S19 | `wc -l` <= 500 for both new bash files | PASS | 495 and 169 |
| S20 | No changed line in the three non-goal locations; hook Pester suite passes with an empty allowlist | PASS | `git diff --stat main...HEAD` returns empty for `.claude/rules/parallel-orchestration.md` and `.claude/skills/parallel-remove/SKILL.md`. The `parallel-orchestrate/SKILL.md` diff contains zero occurrences of `drift_detection`. PowerShell suite recorded 27 passed / 0 failed |

**spec.md AC result: 20 PASS, 0 PARTIAL, 0 FAIL, 0 UNVERIFIED.**

## user-story.md Acceptance Criteria (13 items)

| # | Criterion (abbreviated) | Verdict | Independent verification |
| --- | --- | --- | --- |
| U1 | Planner at a Python-free destination can complete the seeding step | PASS | Same evidence as S10. The payload-only case runs the entry point from the bundle tree with no interpreter on `PATH` |
| U2 | Ported diagnostic matches the reference over the shared corpus, both lanes, with floors and a `python3` guard | PASS | Same evidence as S6. Independently spot-checked by running both implementations on the same manifest and `--edges "101:202"`: identical four-line report from each |
| U3 | Corpus exercises the full reporting surface, including a no-`expected_conflict_components` manifest | PASS | Same evidence as S7. Fixtures `assertion_free_two_items.json` and `assertion_free_empty_items.json` cover the no-assertion manifest |
| U4 | Advisory-only semantics pinned by tests, not prose | PASS | Same evidence as S8 and S9. Structural pin (nothing sources either file) plus behavioral pin (status 0 on an ADVISORY-bearing fixture) |
| U5 | Planner procedure and grants agree | PASS | Same evidence as S12 and S13. The former contradiction between `parallel-plan/SKILL.md:316` and `parallel-planner.md:185-186` is resolved in both files in the same change |
| U6 | Orchestrator offered only runnable spellings | PASS | Same evidence as S11 |
| U7 | Grant rationale no longer names a deleted consumer | PASS | Same evidence as S14 |
| U8 | Everything the maintainer must mirror is mirrored | PASS | Same evidence as S15, strengthened by direct `cmp -s` on all 7 pairs |
| U9 | Both new files survive a manifest-scoped push-down | PASS | Same evidence as S16 |
| U10 | Entry-point enumerations current in both TS suites | PASS | Same evidence as S17 |
| U11 | The deliberate behavior difference is observable rather than indistinguishable from a defect | PASS | Same evidence as S4. The pinning case exists and includes a control. The criterion as written is satisfied; the separate finding is that the divergence *set* is incomplete, not that this pin is missing |
| U12 | New modules meet the shell quality bar, coverage recorded under `evidence/qa-gates/` | PASS | Same evidence as S1 and S18 |
| U13 | Non-goals stay untouched; hook Pester suite passes with an empty allowlist | PASS | Same evidence as S20 |

**user-story.md AC result: 13 PASS, 0 PARTIAL, 0 FAIL, 0 UNVERIFIED.**

## Definition of Done (spec.md:643-649, 4 items, all unchecked)

These are completion gates rather than acceptance criteria and are evaluated for information.

| # | Item | Assessment |
| --- | --- | --- |
| D1 | Every AC checked off with named evidence | Satisfied. 33/33 checked and independently re-verified above |
| D2 | Seven-stage toolchain completes in a single pass, shell and Python lanes | Satisfied. Shell format / check / test all exit 0 on the final run; the loop was correctly restarted from stage 1 after the P6-T5 test addition and both passes are recorded. Python `black`, `ruff`, `pyright` clean, 79 passed |
| D3 | Both new files and all five edited `.claude/**` files mirrored; both guards pass | Satisfied. `cmp -s` byte-identical on all 7 pairs |
| D4 | Residual reported to the epic owner as a manifest-wording action, no implementation change | Satisfied. `evidence/other/known-residual.2026-08-30T20-45.md` records the disposition; `epic-status.md:79-83` carries it as an explicit epic-owner action item. No implementation change was made for it |

The four DoD checkboxes remain `- [ ]` in `spec.md`. Under the acceptance-criteria-tracking
protocol a reviewer checks off AC items, not DoD items, so these were left unchanged. Their
substance is nonetheless satisfied and is recorded here.

## Baseline Comparison

Regression posture against `main` was assessed from the branch diff and the baseline evidence
captured at `2026-08-30T06-22`:

- **Behavior removed:** three CLI spellings. Two had an MCP equivalent already offered beside
  them and `require_complete` is confirmed available on the MCP call, so no capability is lost.
  The third is replaced by a functionally equivalent bash entry point.
- **Behavior added:** one new advisory CLI surface. Additive; removes no existing surface.
  `scripts/dev_tools/parallel_lane_assertion.py` is unchanged and remains the repository
  authority.
- **Coverage movement:** bash 91.8% -> 92.3% (upward, attributable to the 14 added dispatch
  cases). TypeScript identical to baseline to the digit and to the covered/total counts, which
  is consistent with zero production TypeScript changed. Python reference module at 100%. No
  regression in any language.
- **Test count movement:** bats 276 -> 290. Jest 2735 passed. Pytest 79 passed. PowerShell 27
  passed. No suite lost cases.
- **Non-goal boundaries:** confirmed intact by diff, not by assertion.

## Gap Against the Feature's Own Claim

One gap was found, and it concerns the completeness of a claim rather than any listed criterion.

`spec.md:328-366` enumerates five divergence classes from the Python reference and frames
class 3 as having "exactly these four members", using the argument at `:352-358` that the port
"consumes the same whitespace-separated token stream, so it cannot observe interior whitespace
either". That argument holds for space and tab but not for newline. `pla_parse_edges` tokenizes
with `read -ra tokens <<<"$text"`, which consumes one line; `str.split()` in the reference does
not. Verified by running both lanes on the same manifest with
`--edges $'999:998\n101:202'`: bash reports 2 derived components, Python reports 1.

No listed acceptance criterion asserts newline handling, so no AC verdict changes. The gap is
recorded as a remediation-required finding in `policy-audit.2026-08-30T17-17.md` (PA-1) and
`code-review.2026-08-30T17-17.md` (CR-1) because the spec's divergence enumeration is presented
as exhaustive and is relied on by future readers to distinguish a deliberate difference from a
porting defect — which is the exact purpose the spec assigns it at `:484-485`.

Behavioral risk is bounded: the diagnostic is advisory-only, always exits 0, feeds nothing, and
both documented invocation forms are single-line. The same tokenizing pattern is pre-existing in
the sibling entry point `compute-cohorts.sh`, which was probed and exhibits the same class of
behavior, so this is not a regression this feature introduces.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/spec.md`
  and `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/user-story.md`
- Total AC items: 33 (20 in `spec.md`, 13 in `user-story.md`)
- Checked off (delivered): 33
- Remaining (unchecked): 0
- Items remaining: none
- Newly checked off by this review: none — all 33 were already `[x]` and every one was
  independently re-verified as PASS against the branch head. No checkbox required correction.
- Separately: the 4 `## Definition of Done` items in `spec.md` remain `- [ ]`. They are
  completion gates, not acceptance criteria, and are outside the reviewer check-off protocol.
  Their substance is satisfied; see the Definition of Done table.

## Verdict

**Feature delivery: PASS on all 33 acceptance criteria**, verified independently rather than
accepted from the pre-existing check-off state. The feature's core claim — that no executable
Python invocation remains in the in-scope `.claude` payload and that the lane-assertion
diagnostic runs on a destination runtime with no interpreter — is verified by direct query and
by the payload-only suite case.

One remediation-required finding exists against the spec's exhaustive divergence claim. It does
not fail any acceptance criterion and does not block merge on its own; it is documentation and
test debt against a claim the spec makes about itself.
