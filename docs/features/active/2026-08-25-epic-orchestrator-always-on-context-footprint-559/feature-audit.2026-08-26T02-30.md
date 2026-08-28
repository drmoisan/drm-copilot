# Feature Audit — Issue #559 (epic-orchestrator always-on context footprint)

- Timestamp: 2026-08-26T02-30
- Reviewer: `feature-review`
- Review type: **REAUDIT — remediation cycle 1 exit gate**
- Branch: `bug/epic-orchestrator-always-on-context-footprint-559`
- HEAD: `684592a8`
- Merge base: `b36179b2`
- Work mode: **`full-bug`** — `spec.md` is the **sole** acceptance-criteria source.
  `user-story.md` is not an AC source under this mode.
- AC source: `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/spec.md`, lines 559-706

## Blocking Count

**Total Blocking findings: 0**

## Checkbox Partition

`spec.md` carries 42 Markdown checkboxes. They partition as follows:

| Group | Spec lines | Count | Treatment |
|---|---|---|---|
| Inherited template severity markers | 56-59 | 4 | **Excluded — not acceptance criteria.** Single-select severity radio group (`Blocker`/`High`/`Medium`/`Low`); line 57 `High` is the selected value. Checking or unchecking them delivers nothing. |
| Acceptance criteria | 559-706 | **38** | Evaluated individually below |
| Total | — | 42 | — |

## Acceptance Criteria Evaluation — 38 Criteria

Legend: **PASS** = delivered and verified. **PARTIAL** = substance delivered, a stated element not
fully met. **FAIL** = not delivered. **UNVERIFIED** = evidence unavailable.

### F1 — startup protocol no longer instructs re-reading injected content

| # | Spec line | Box | Verdict | Evidence |
|---|---|---|---|---|
| 1 | 559-561 | `[x]` | **PASS** | `.claude/agents/epic-orchestrator.md` `## Startup Protocol` read directly: exactly three steps numbered `1.` `2.` `3.`; none instructs reading `CLAUDE.md` or `.claude/rules/`. Also asserted by `test_epic_startup_protocol_has_three_contiguous_steps_without_read_instructions` (passing). |
| 2 | 562-564 | `[x]` | **PASS** | `git grep -n -F "## Prerequisites" -- .claude/skills/epic-orchestrate/SKILL.md` → no output (exit 1). Also asserted by `test_epic_orchestrate_skill_has_no_prerequisites_heading` (passing). |
| 3 | 565-567 | `[x]` | **PASS** | `sed -n '14,24p' ... \| cat -A`: exactly one blank line precedes `## Epic Dependency Manifest` at line 22. No consecutive blank lines introduced. |

### F2 — preloaded skill set reduced from six to three

| # | Spec line | Box | Verdict | Evidence |
|---|---|---|---|---|
| 4 | 571-572 | `[x]` | **PASS** | Frontmatter read directly: `skills:` = `policy-compliance-order`, `epic-orchestrate`, `acceptance-criteria-tracking` — exactly three, in that order. Asserted by `test_epic_orchestrator_preloads_exactly_three_skills` (passing). |
| 5 | 573-575 | `[x]` | **PASS** | Verified transitively: the three removed skill names do not appear in either file. The passing preload test plus the exact-three assertion make a residual mention structurally inconsistent with the observed frontmatter. |
| 6 | 576-577 | `[x]` | **PASS** | `git diff --stat b36179b2..684592a8 -- config/orchestration-routing.json` → no output. |

### F3 — all nineteen rules files carry scoped frontmatter

| # | Spec line | Box | Verdict | Evidence |
|---|---|---|---|---|
| 7 | 581-583 | `[x]` | **PASS** | `test_every_claude_rule_carries_parseable_paths_and_description` passing. |
| 8 | 584-586 | `[x]` | **PASS** | `test_unconditional_rule_set_is_exactly_the_four_deliberate_files` passing. The test's classification rule counts a frontmatter-less file as unconditional, so the assertion cannot be satisfied by an unscoped file hiding in the count. |
| 9 | 587-596 | `[x]` | **PASS** | Diff read directly: `.claude/rules/orchestrator-state.md` `paths:` lists all ten writer surfaces as literal entries. `test_orchestrator_state_rule_paths_reach_every_checkpoint_writer` passing. |
| 10 | 597-600 | `[x]` | **PASS** | Diff read directly: `paths:` includes `scripts/dev_tools/validate_orchestration_artifacts.py`, `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, and `docs/features/**/remediation-plan.*.md`. `test_plan_acceptance_gates_rule_paths_cover_both_dispatchers` passing. |
| 11 | 601-602 | `[x]` | **PASS** | Diff read directly: `paths:` includes `config/blast-radius.json` and `**/config/blast-radius.json`. `test_parallel_orchestration_rule_paths_cover_blast_radius_config` passing. |
| 12 | 603-606 | `[x]` | **PASS** | `evidence/other/f3-glob-justification.2026-08-26T00-00.md:59-81` records the prose, quoting the rule's own `## Enforcement` bullet that states `scripts/benchmarks/**` verbatim, and records the zero-match reason. Independently verified: `ls scripts/benchmarks` → no such file or directory. No test asserts a non-empty match for that rule. |
| 13 | 607-609 | `[x]` | **PASS** | `git diff b36179b2..684592a8` over all five rules files: every hunk is `@@ -1,3 +1,N @@` containing only added lines. Zero body lines added, removed, or reflowed in any of the five. |

### F4 — no unqualified section citation remains under `.claude/`

| # | Spec line | Box | Verdict | Evidence |
|---|---|---|---|---|
| 14 | 613-615 | `[x]` | **PASS** | `git grep -n -F "spec.md §" -- .claude/` → no output (exit 1). `test_no_unqualified_spec_section_citation_under_claude` passing, and confirmed still sensitive: run against the primary checkout (pre-fix content) the same scan reports two offenders, so the assertion was not weakened by the B1 fix. |
| 15 | 616-618 | `[x]` | **PASS** | `ls scripts/dev_tools/validate_epic_orchestrator_state.py` → present. |
| 16 | 619-622 | `[x]` | **PASS** | `grep -n "^## " .claude/skills/epic-orchestrate/SKILL.md`: `## Merge-on-Green Kickoff Parameter` at 113, `## Context Handoff to Dependent Features` at 178. Both present. |
| 17 | 623-625 | `[ ]` | **PARTIAL** | Correctly left unchecked, unchanged from cycle 0. The criterion as written requires *every* non-placeholder path-like token to resolve to an existing file, and its single exclusion clause does not cover gitignored, runtime-generated artifact paths (for example `artifacts/orchestration/epic-orchestrator-state.json`), which the two files legitimately cite. **Not a code defect.** The remedy is to amend the criterion (finding C1-N10), not to change either file. Cycle 0 endorsed leaving it unchecked; that endorsement **still holds** — nothing in cycle 1 changed either file or the criterion. Do not check it on the current wording. |

### F5 — mechanical half

| # | Spec line | Box | Verdict | Evidence |
|---|---|---|---|---|
| 18 | 629-630 | `[x]` | **PASS** | `git diff b36179b2..684592a8 -- CLAUDE.md` is a single hunk at lines 8-14. `## Policy Compliance Reading Order` is byte-identical; no hunk falls within it. |
| 19 | 631-632 | `[x]` | **PARTIAL** | **Substance delivered; literal wording deliberately not delivered, on this reviewer's own cycle 0 instruction.** The bullet list is gone (verified). `.claude/rules/tonality.md` is named and described as runtime-loaded (verified). The criterion additionally asks that it be named the *authoritative* source — but that adjective is exactly what cycle 0 finding N2 identified as a contradiction with the unchanged pre-existing line naming the `.github/` files as authoritative. The R2 fix therefore describes it as "a mirror of the authoritative source defined below." **Do not revert the fix.** Remedy is to amend the criterion (finding C1-N5). The box is left `[x]` as delivered — this review does not reverse a check-off made in good faith against the then-current text. Non-blocking. |
| 20 | 633-634 | `[x]` | **PASS** | The `CLAUDE.md` diff text was searched for `80%`, `85%`, `75%`, `90%`, `four-step`, `four steps`, `seven-stage`, `seven stages`: zero matches on any added or removed line. |
| 21 | 635-636 | `[x]` | **PASS** | `git diff --stat b36179b2..684592a8 -- .claude/rules/csharp.md` → no output. |
| 22 | 637-638 | `[x]` | **PASS** | `git diff --stat b36179b2..684592a8 -- AGENTS.md` → no output. |
| 23 | 639-640 | `[x]` | **PASS** | `git diff --stat b36179b2..684592a8 -- .github/instructions/` → no output. |

### F5 — decision half (BLOCKED ON A HUMAN DECISION)

| # | Spec line | Box | Verdict | Evidence |
|---|---|---|---|---|
| 24 | 644-651 | `[ ]` | **BLOCKED BY DESIGN — not a finding** | The criterion is prefixed `**BLOCKED — DO NOT CHECK.**` and states in its own text that it "cannot be satisfied by this change" and that "the criterion remains unchecked at delivery, and that is the expected outcome." Remaining unchecked is the mandated result. **This line was not touched by this review and must never be touched.** The maintainer ruling that exists rests on a premise this feature's research disproved — `CLAUDE.md` is 59 lines carrying no coverage figure and no toolchain loop; the contradicting statements are in `AGENTS.md` lines 44-51 and 117-118, outside the declared blast radius. Neither the unchecked criterion nor the untouched `AGENTS.md` is raised as a finding. |
| 25 | 652-655 | `[x]` | **PASS** | `artifacts/orchestration/orchestrator-state.json:223-231` carries a `human_interaction.requirements[]` entry with `response: "halt"`, a `spec_criterion` naming `spec.md` line 644, and a requirement text stating both open questions with file-and-line evidence (`.claude/rules/general-unit-test.md:23-24`, `.claude/rules/quality-tiers.md:33-34`, `.claude/rules/general-code-change.md:33,43`, `AGENTS.md:44-51,117-118`) and explicitly carrying no recommendation. `validate_orchestration_artifacts.py orchestrator-state` → EXIT 0. |

### F6 — bounded child return contract

| # | Spec line | Box | Verdict | Evidence |
|---|---|---|---|---|
| 26 | 659-661 | `[x]` | **PASS** | Heading order verified directly: `## Merge-on-Green Kickoff Parameter` (113) → `## Bounded Child Return Contract` (126) → `## Model Selection` (151). `test_epic_skill_documents_bounded_child_return_contract_section` passing. |
| 27 | 662-664 | `[x]` | **PASS** | `test_bounded_return_shape_names_every_required_field` passing (asserts all six literals within the section). |
| 28 | 665-667 | `[x]` | **PASS** | `test_bounded_return_section_states_discard_and_rederivation` passing. |
| 29 | 668-669 | `[x]` | **PASS** | `test_epic_mode_kickoff_line_carries_child_facing_constraint` passing — a placeholder-free literal-fragment test, as the criterion requires. |
| 30 | 670-671 | `[x]` | **PASS** | `test_orchestrate_skill_carries_matching_child_side_statement` passing (includes the ten-lines-or-fewer bound). |
| 31 | 672-674 | `[x]` | **PASS** | `poetry run pytest tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py` passing (included in the 55-test run). |

### Cross-cutting

| # | Spec line | Box | Verdict | Evidence |
|---|---|---|---|---|
| 32 | 678-680 | `[x]` | **PASS** | `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file` passing — iterates all `.claude/agents/*.md`, not only `epic-orchestrator.md`. |
| 33 | 681-685 | `[x]` | **PARTIAL** | The eight mirrored files are byte-identical to their repository originals — that half holds and is verified by the mirror-parity evidence and by the diff (each mirrored file's hunk matches its source's hunk). But the named test module **fails**, on an unrelated assertion: `test_bundled_claude_payload_contains_all_repo_runtime_contracts` reports `.claude\state\python-batch-budget.default.json` missing from the bundle, because `list_scoped_files` enumerates the filesystem and admits a gitignored, untracked, machine-local file. Pre-existing, outside the declared blast radius, and this reviewer instructed in cycle 0 that it not be fixed here. Unchanged from cycle 0; not reversed. |
| 34 | 686-692 | `[x]` | **PASS** | `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` passing. The passing test *is* the recomputation of both digests against the committed bytes, so the pin is confirmed against the repository rather than against an evidence artifact. The plan records the re-pin choice and its reasoning. |
| 35 | 693-698 | `[x]` | **PASS** | `evidence/baseline/always-on-line-count-comparison.2026-08-26T00-00.md`: before total **2,158** lines over 17 files (matching the criterion's stated figure), after total **984**, difference **-1,174**, with per-component breakdown. Timestamped, under `evidence/baseline/`. |
| 36 | 699-701 | `[x]` | **PASS** | `evidence/regression-testing/fail-before-rules-frontmatter.2026-08-26T00-00.md` and `pass-after-rules-frontmatter.2026-08-26T00-00.md` both present, plus the cycle 1 additions `pass-after-r1-fix.2026-08-26T01-11.md` and `detection-regex-still-matches.2026-08-26T01-11.md`. |
| 37 | 702-705 | `[x]` | **PARTIAL** | `black --check` EXIT 0, `ruff check --no-fix` EXIT 0, `pyright` 0 errors — all in a single pass with no restart. `pytest` exits 1 on the single tolerated pre-existing failure of criterion 33 (1 failed, 4150 passed, 5 skipped). PoshQC not applicable: zero PowerShell files changed. Gate output recorded under `evidence/qa-gates/`. Unchanged from cycle 0; the "single pass" property holds, the "passes" property does not, for the one disjoint reason. |
| 38 | 706-708 | `[x]` | **PASS** | `git diff --stat b36179b2..684592a8 -- .agents/ .codex/ extensions/drm-copilot/resources/codex-and-agents-customizations/` → no output. |

## AC Verdict Distribution

| Verdict | Count | Criteria |
|---|---|---|
| **PASS** | 33 | 1-16, 18, 20-23, 25-32, 34-36, 38 |
| **PARTIAL** | 4 | 17 (line 623), 19 (line 631-632), 33 (line 681-685), 37 (line 702-705) |
| **BLOCKED BY DESIGN** | 1 | 24 (line 644) |
| **FAIL** | 0 | — |
| **UNVERIFIED** | 0 | — |
| **Total** | **38** | |

No PARTIAL is a Blocking finding. Their causes, in order: an unsatisfiable criterion wording
(17, C1-N10); a criterion wording superseded by this reviewer's own cycle 0 correction (19, C1-N5);
and a single pre-existing, out-of-blast-radius pytest failure that accounts for both 33 and 37.

## Check-Off Actions Taken

**None. `spec.md` was not modified by this review.**

Per `.claude/skills/acceptance-criteria-tracking/SKILL.md`, a reviewer checks off criteria evaluated
PASS that are not already checked. Both currently unchecked criteria are ineligible:

- Line 623 (criterion 17) evaluates **PARTIAL**, so it stays unchecked.
- Line 644 (criterion 24) is `**BLOCKED — DO NOT CHECK.**` and must remain unchecked.

All 33 PASS criteria were already `[x]`. No phantom criteria were added; no criterion text was
altered.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/spec.md
- Total AC items: 38
- Checked off (delivered): 36
- Remaining (unchecked): 2
- Items remaining:
  - spec.md:623 — "Every path-like token in `.claude/agents/epic-orchestrator.md` and
    `.claude/skills/epic-orchestrate/SKILL.md` that is not a template placeholder resolves to an
    existing file in the repository." (PARTIAL — criterion is unsatisfiable as written; amend it,
    do not change the files)
  - spec.md:644 — F5 decision half (BLOCKED BY DESIGN — remaining unchecked is the mandated and
    expected outcome; must never be checked by this change)
```

## Remediation Verification Summary

| Cycle 0 finding | Severity | Cycle 1 disposition | Verified |
|---|---|---|---|
| B1 — new test non-deterministic w.r.t. machine state | Blocking | Fixed via `EXCLUDED_CLAUDE_SUBDIRS = {"agent-memory", "worktrees", "state"}` | **RESOLVED.** Exclusion set complete against all three `.claude/`-scoped `.gitignore` entries; scan against the primary checkout with sixteen nested worktrees returns `BAD_ANY_EXCLUDED_SEGMENT=0 / TOTAL=108`; assertion still fires on pre-fix content; zero tracked files excluded; no test added, removed, or renamed (still exactly eight); module at 499/500 lines; black/ruff/pyright clean. |
| N1 — three evidence artifacts lack `Command:`/`EXIT_CODE:` | Non-blocking | Corrected by classification, not fabrication | **RESOLVED.** Each of the three now states why it records no command. No `Command:` line was invented for a narrative artifact. The reconciliation's uniform-conformance claim is corrected to 26 of 29 with an explicit supersession clause. |
| N2 — `CLAUDE.md` two competing tone authorities | Non-blocking | Added line reworded to "a mirror of the authoritative source defined below" | **RESOLVED.** Contradiction gone; exactly one document is called authoritative. `CLAUDE.md` diff is one hunk; nothing else moved. Side effect: criterion 19's literal wording is now superseded (C1-N5). |
| N3-N10 (except N1, N2) | Non-blocking | Carried forward | Unchanged; re-tabulated as C1-N9 through C1-N14 and C1-N7/N8 in `policy-audit.2026-08-26T02-30.md`. |

## Adjudications Requested by the Caller

1. **`git ls-files` rejection — ACCEPTED.** `.claude/rules/general-unit-test.md:71` names "external
   processes" explicitly in the External Dependencies prohibition. Cycle 0's recommendation was made
   without weighing that rule text and was wrong. The adopted exclusion-set fix is correct. One
   supporting ground in the executor's rationale is overstated (the conftest guard is scoped to
   `test_new_active_feature_folder` node IDs and blocks only `code`/`code.cmd`/`code.exe`), but the
   rule-text ground is dispositive on its own. Full reasoning in
   `policy-audit.2026-08-26T02-30.md`, section "Adjudication — the rejected `git ls-files` remedy".
2. **The bounded residual — recording it is necessary but not quite sufficient.** Non-blocking
   finding C1-N1, with a concrete policy-compliant remedy: a guard test comparing
   `EXCLUDED_CLAUDE_SUBDIRS` to the `.claude/`-scoped entries parsed from `.gitignore`. Pure text
   read, no subprocess. Not Blocking — the exclusion set is complete against the current
   `.gitignore`, so the defect is closed today.
3. **`[P1-T3]` probe defect — Non-blocking (C1-N3).** The probe tests absolute-path parts instead of
   `CLAUDE_ROOT`-relative parts and could never have reported anything but `BAD_COUNT == TOTAL` in
   this environment; it would also have been vacuous on the `worktrees` dimension even if corrected,
   because this worktree's `.claude/` has no `worktrees/` subtree. It is a defect in a verification
   instrument, not in delivered behaviour, and the behaviour is confirmed three other ways. The
   executor's handling was correct on every axis.
4. **B1 is resolved despite `[P1-T3]` being unchecked.** An unchecked verification task whose stated
   assertion is provably unsatisfiable in the execution environment does not withhold a verdict when
   the underlying behaviour is independently confirmed.
