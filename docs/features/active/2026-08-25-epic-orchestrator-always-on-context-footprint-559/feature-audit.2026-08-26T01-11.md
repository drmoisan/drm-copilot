# Feature Audit — Issue #559 (epic-orchestrator always-on context footprint)

- Timestamp: 2026-08-26T01-11
- Reviewer: `feature-review`
- Branch: `bug/epic-orchestrator-always-on-context-footprint-559`
- HEAD: `aeac89a7`
- Merge base: `b36179b2`
- Work mode: `full-bug` (marker read from `issue.md:12`)

## Acceptance-Criteria Source Resolution

Per `.claude/skills/acceptance-criteria-tracking/SKILL.md`, work mode `full-bug` resolves the
acceptance-criteria source to **`spec.md` only**. `user-story.md` is present but carries no
acceptance criteria under this mode and was read for narrative context only. `issue.md`'s
`## Proposed Fix / Validation Ideas` checkboxes are not acceptance criteria under this mode; they
are reported at the end of this document as supplementary information.

`spec.md` carries 42 checkboxes. Four of them — lines 56-59 (`Blocker`, `High`, `Medium`, `Low`) —
are inherited severity markers from the bug template and are excluded, leaving **38 acceptance
criteria at lines 559-706**. This partition matches the one `[P6-T12]` prescribes.

## Verdict Summary

| Verdict | Count |
|---|---|
| PASS | 34 |
| PARTIAL | 3 |
| FAIL | 0 |
| UNVERIFIED | 0 |
| BLOCKED by design (correctly undeliverable) | 1 |
| **Total** | **38** |

## Acceptance Criteria Evaluation

### F1 — startup protocol no longer instructs re-reading injected content

| # | Spec line | Criterion (abridged) | Verdict | Evidence |
|---|---|---|---|---|
| 1 | 559-561 | `## Startup Protocol` has exactly three contiguous steps, none instructing a read of `CLAUDE.md` or `.claude/rules/` | **PASS** | `.claude/agents/epic-orchestrator.md:50-58` read directly: ordinals `1.`, `2.`, `3.`; step 1 is the checkpoint read. The two read instructions are removed in the diff. |
| 2 | 562-564 | No `## Prerequisites` heading in `epic-orchestrate/SKILL.md` | **PASS** | `git grep -n -F "## Prerequisites" -- .claude/skills/epic-orchestrate/SKILL.md` -> EXIT 1 (no matches). |
| 3 | 565-567 | Exactly one blank line before `## Epic Dependency Manifest`; no double blank introduced | **PASS** | `sed -n '14,28p' ... \| cat -A` shows a single `$` line between the preceding paragraph and the heading. |

### F2 — preloaded skill set reduced from six to three

| # | Spec line | Criterion (abridged) | Verdict | Evidence |
|---|---|---|---|---|
| 4 | 571-572 | `skills:` contains exactly `policy-compliance-order`, `epic-orchestrate`, `acceptance-criteria-tracking` | **PASS** | Diff removes exactly three entries; `test_epic_orchestrator_preloads_exactly_three_skills` asserts tuple equality and passes. |
| 5 | 573-575 | The three removed skill names appear nowhere in either epic file | **PASS** | `git grep -n -F -e feature-promotion-lifecycle -e atomic-plan-contract -e evidence-and-timestamp-conventions -- <both files>` -> EXIT 1. |
| 6 | 576-577 | `config/orchestration-routing.json` unmodified | **PASS** | `git diff --stat b36179b2..aeac89a7 -- config/orchestration-routing.json` -> empty. Additionally verified that the `epic` route's `required_skills` obligation is independent of preloads: `orchestrate`, `pr-context-artifacts`, and `pr-base-branch-merge-base` are already required without ever having been preloaded. |

### F3 — all nineteen rules files carry scoped frontmatter

| # | Spec line | Criterion (abridged) | Verdict | Evidence |
|---|---|---|---|---|
| 7 | 581-583 | All nineteen `.claude/rules/*.md` carry parseable frontmatter with a non-empty `paths:` list and non-empty `description:` | **PASS** | `ls .claude/rules/*.md \| wc -l` -> 19. `test_every_claude_rule_carries_parseable_paths_and_description` passes. |
| 8 | 584-586 | The `"**"` set is exactly the four named files | **PASS** | `grep -l '"\*\*"' .claude/rules/*.md` returns exactly `general-code-change.md`, `general-unit-test.md`, `quality-tiers.md`, `tonality.md`. `test_unconditional_rule_set_is_exactly_the_four_deliberate_files` passes and treats an absent frontmatter block as unconditional, which is the stricter and correct reading. |
| 9 | 587-596 | `orchestrator-state.md` `paths:` names all ten checkpoint-writer surfaces | **PASS** | All ten appear as literal entries in the inserted frontmatter. `test_orchestrator_state_rule_paths_reach_every_checkpoint_writer` resolves each of the ten and passes. |
| 10 | 597-600 | `plan-acceptance-gates.md` `paths:` includes the two dispatchers and `docs/features/**/remediation-plan.*.md` | **PASS** | All three present in the inserted block. `test_plan_acceptance_gates_rule_paths_cover_both_dispatchers` passes. |
| 11 | 601-602 | `parallel-orchestration.md` `paths:` covers `config/blast-radius.json` | **PASS** | Present as a literal entry (and again as `**/config/blast-radius.json` for the bundled copy). `test_parallel_orchestration_rule_paths_cover_blast_radius_config` passes. |
| 12 | 603-606 | The plan records in prose that the `benchmark-baselines.md` glob set matches zero current files, and no test asserts a non-empty match | **PASS** | `plan.2026-08-25T22-07.md:568-571` (`[P2-T7]`) records it; `evidence/other/f3-glob-justification.2026-08-26T00-00.md` carries the full record. Confirmed independently: `scripts/benchmarks/` does not exist and no tracked `baseline*.json` exists. No test asserts a match for that rule. |
| 13 | 607-609 | Each of the five edited rules files retains its body unchanged; the only hunk per file is the top insertion | **PASS** | `git diff b36179b2..aeac89a7 -- .claude/rules/` shows exactly one hunk per file, each `@@ -1,3 +1,N @@`, each removing zero original lines. |

### F4 — no unqualified section citation remains under `.claude/`

| # | Spec line | Criterion (abridged) | Verdict | Evidence |
|---|---|---|---|---|
| 14 | 613-615 | `git grep -n -F "spec.md §" -- .claude/` returns no matches | **PASS** | EXIT 1 (no matches). |
| 15 | 616-618 | Line 136's replacement names `validate_epic_orchestrator_state_text` and the module exists | **PASS** | `.claude/agents/epic-orchestrator.md:131-133` names both the function and `scripts/dev_tools/validate_epic_orchestrator_state.py`; the module exists on disk. |
| 16 | 619-622 | Line 107's replacement names two headings that exist in `epic-orchestrate/SKILL.md` | **PASS** | Replacement names `## Merge-on-Green Kickoff Parameter` and `## Context Handoff to Dependent Features`; both exist, at lines 113 and 178. |
| 17 | 623-625 | Every non-placeholder path-like token in the two epic files resolves to an existing file | **PARTIAL** | 23 of 24 non-placeholder tokens resolve; see adjudication below. Correctly left unchecked. |

### F5 — mechanical half

| # | Spec line | Criterion (abridged) | Verdict | Evidence |
|---|---|---|---|---|
| 18 | 629-630 | `## Policy Compliance Reading Order` byte-identical | **PASS** | The `CLAUDE.md` diff contains a single hunk confined to the `## Tone Policy` section (lines 8-14); the reading-order section is not in any hunk. |
| 19 | 631-632 | `## Tone Policy` no longer restates the bullet list and names `.claude/rules/tonality.md` | **PASS** | Four bullets removed; `CLAUDE.md:11` names `.claude/rules/tonality.md` as the runtime-loaded authoritative source. |
| 20 | 633-634 | The `CLAUDE.md` diff contains no added or removed line matching `80%`, `85%`, `75%`, `90%`, `four-step`, `four steps`, `seven-stage`, `seven stages` | **PASS** | `git diff b36179b2..aeac89a7 -- CLAUDE.md \| grep -E ...` -> EXIT 1. |
| 21 | 635-636 | `.claude/rules/csharp.md` unmodified | **PASS** | Empty diffstat. |
| 22 | 637-638 | `AGENTS.md` unmodified | **PASS** | Empty diffstat. |
| 23 | 639-640 | No file under `.github/instructions/` modified | **PASS** | Empty diffstat over the directory (17 tracked files). |

### F5 — decision half

| # | Spec line | Criterion (abridged) | Verdict | Evidence |
|---|---|---|---|---|
| 24 | 644 | **BLOCKED — DO NOT CHECK.** Human selection of the authoritative coverage floor and toolchain loop, applied to `AGENTS.md` | **BLOCKED by design — not a finding** | The criterion states in its own text that it "cannot be satisfied by this change" and that remaining unchecked "is the expected outcome". It was not evaluated as a delivery obligation and was not touched by this review. See the note below. |
| 25 | 652-655 | The checkpoint carries a `human_interaction.requirements[]` entry with `response: "halt"` stating both open questions with file-and-line evidence and no recommendation, and validates | **PASS** | The entry is present, `response` is `halt`, it cites `AGENTS.md` lines 117-118 and 44-51, `.claude/rules/general-unit-test.md:23-24`, `quality-tiers.md:33-34`, and `general-code-change.md:33,43`, states neither option as preferable, and links the full record. `validate_orchestration_artifacts orchestrator-state` -> validation passed. |

**Note on line 644.** This criterion was not raised as a finding. The maintainer ruling on issue 559
was premised on the contradicting statements living in `CLAUDE.md`; this feature's preparation
research disproved that premise — `CLAUDE.md` is 59 lines (56 after this change) with no coverage
figure and no toolchain-loop statement, and the contradictions are in `AGENTS.md` lines 117-118 and
44-51, which the declared blast radius excludes. The untouched `AGENTS.md` is therefore correct
scope discipline, not an omission. The reasoning is recorded at
`evidence/other/f5-reserved-human-decision.2026-08-26T00-00.md` and the invariance guard at
`evidence/qa-gates/f5-threshold-invariance.2026-08-26T00-00.md`, which this review independently
re-ran across the whole branch: 37 threshold-bearing tracked files, all unmodified.

### F6 — bounded child return contract

| # | Spec line | Criterion (abridged) | Verdict | Evidence |
|---|---|---|---|---|
| 26 | 659-661 | `## Bounded Child Return Contract` exists, after `## Merge-on-Green Kickoff Parameter` and before `## Model Selection` | **PASS** | Heading order in `epic-orchestrate/SKILL.md`: 113 (kickoff) < 126 (bounded) < 151 (model selection). Asserted by `test_epic_skill_documents_bounded_child_return_contract_section`. |
| 27 | 662-664 | The section names all six required fields | **PASS** | The section names eight fields, a superset containing all six. `test_bounded_return_shape_names_every_required_field` checks each as an inline-code token and passes. The two extra fields are justified in place and explicitly declared non-authoritative. |
| 28 | 665-667 | The section states the discard rule and names the three re-derivation commands | **PASS** | "Content beyond these eight fields is **discarded**"; the three commands appear verbatim at `epic-orchestrate/SKILL.md:143-145`. |
| 29 | 668-669 | The epic-mode kickoff line carries the child-facing constraint, asserted by a placeholder-free literal-fragment test | **PASS** | `epic-orchestrate/SKILL.md:118` carries the appended constraint. `test_epic_mode_kickoff_line_carries_child_facing_constraint` collects the whole contiguous blockquote run and asserts on normalized text, so it is wrap-tolerant rather than line-oriented. |
| 30 | 670-671 | `orchestrate/SKILL.md` carries the matching child-side statement in ten lines or fewer | **PASS** | `## Epic Mode Bounded Return` at `orchestrate/SKILL.md:99-108`: 10 total lines, 6 non-blank body lines. The cap is asserted by `test_orchestrate_skill_carries_matching_child_side_statement`. |
| 31 | 672-674 | `epic-orchestrator.md` `## Prepared-Epic Execution` unchanged; `test_epic_run_kickoff_discovery_contract.py` passes | **PASS** | That section is in no diff hunk. The module ran in this review's selection and all its tests passed. |

### Cross-cutting

| # | Spec line | Criterion (abridged) | Verdict | Evidence |
|---|---|---|---|---|
| 32 | 678-680 | Every `skills:` entry in every `.claude/agents/*.md` resolves to an existing `SKILL.md` | **PASS** | `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file` scans all agent files and passes. |
| 33 | 681-685 | The eight bundled mirrors are byte-identical to their originals, verified by `test_push_down_claude_resource_contracts.py` passing | **PARTIAL** | The substantive claim is TRUE and independently verified: `diff -q` reports no difference for all eight pairs, and the module's byte-identity test passes. The named verification command does **not** pass: the module exits 1 on one unrelated test. See adjudication below. |
| 34 | 686-692 | The pinned digests are consistent with the committed contents of the two epic files, and `test_parallel_orchestrator_surface_contracts.py` passes; the plan records the chosen resolution | **PASS** | Both pins equal the SHA-256 of the committed blobs and of the worktree bytes. All 27 tests in that module pass. Decision 1 of the plan records re-baseline-in-place with its reasoning, mirrored in the module's block comment. |
| 35 | 693-698 | A before/after always-on line-count artifact exists with per-component breakdown; the before total is 2,158 | **PASS** | Three artifacts under `evidence/baseline/`. Recomputed independently: before = 59 + 162 + 936 + 316 + 685 = **2,158**; after = **984**; reduction 1,174 lines (54.40%). |
| 36 | 699-701 | The new structural test has recorded fail-before and pass-after results | **PASS** | Four artifacts under `evidence/regression-testing/`; both fail-before artifacts carry `ExpectedExitCode: 1` and record `EXIT_CODE: 1` with each failing test named. |
| 37 | 702-705 | The full applicable toolchain passes in a single pass: `black --check`, `ruff check`, `pyright`, `pytest`; gate output recorded | **PARTIAL** | Re-run by this review: black PASS, ruff PASS, pyright PASS (0 errors), pytest **exits 1** with one tolerated out-of-scope failure. Gate output is recorded under `evidence/qa-gates/`. PoshQC correctly not applicable (zero PowerShell files changed). |
| 38 | 706-708 | No file under `.agents/`, `.codex/`, or `codex-and-agents-customizations/` modified | **PASS** | Empty diffstat over all three paths across the whole branch. |

## Adjudications

### Adjudication 1 — the tolerated `pytest` failure (criteria 33 and 37)

**Question posed:** verify the failure is genuinely disjoint from this change rather than accepting
the claim, and judge whether the out-of-scope disposition is sound.

**Reproduced.** The failure reproduces exactly as recorded:

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
E   AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
```

**Disjointness verified on five independent grounds, none of which relies on the executor's claim:**

1. The failing test's module is unmodified by this branch:
   `git diff --name-only b36179b2..aeac89a7 -- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` -> empty.
2. The mechanism, `list_scoped_files`
   (`test_push_down_claude_resource_contracts.py:34-43`), uses `scoped_path.rglob("*")` and is
   likewise unmodified. It enumerates the filesystem rather than consulting git, so any untracked
   file under `.claude/` enters the repo-side set.
3. The producing hook, `.claude/hooks/enforce-python-batch-budget.ps1`, is unmodified.
4. The offending path is untracked (`git ls-files --error-unmatch` -> "did not match any file(s)
   known to git") and gitignored (`git check-ignore -v` -> `.gitignore:68: .claude/state/`), and
   appears in **zero** entries of the branch diff.
5. The eight files this change actually did write into the bundle were proven byte-identical by a
   method that does not involve the failing test at all: `diff -q` on each of the eight pairs
   reports no difference, and the module's own byte-identity test
   (`test_bundled_claude_payload_matches_repo_runtime_contracts`) passes.

**The failure is genuinely disjoint.** It is triggered by running any agent session in a fresh
worktree — the hook fires on the first `Write|Edit` and creates the state file — but it is *caused*
by the pre-existing `list_scoped_files` defect, not by anything this change did. It would fail
identically at the merge base once the hook had fired.

**Is the out-of-scope disposition sound? Yes, with one qualification.**

Sound, because: the defect is in a module owned by neither this feature nor its blast radius; fixing
it means changing an unrelated test's enumeration strategy, which is scope creep on a
context-reduction bug fix; deleting the gitignored file is not a fix, since the registered hook
regenerates it on the next write, and it would mutate the developer's environment; and CI is
unaffected, since a CI checkout has no `.claude/state/`. The plan's tolerance branch is narrowly
constructed — exactly one named failure, any second failure fails the task — rather than an open
exemption. The `[P0-T11]` verdict correction from `ABSENT` to `PRESENT` preserves both readings with
their timestamps and gives a verified causal explanation (the file's birth time, 23:48:01, is eight
minutes after the Phase 0 baseline read, and Phase 0 performs no write).

The qualification: the disposition is sound *for this instance*, but the change simultaneously
introduces a **new instance of the identical defect class** in its own new test module — see
Blocking finding B1. Deferring the pre-existing instance is defensible; shipping a second one is
not. The two should be fixed together, and the B1 fix should prefer the git-backed enumeration that
also removes the class.

**Consequences for the criteria:** criterion 37 is PARTIAL, because `pytest` did not exit 0 and the
criterion says the toolchain "passes". Criterion 33 is PARTIAL, because its substantive claim is
true and independently verified while its named verification command does not pass. Neither is a
delivery defect; both are recorded so the audit trail is accurate.

### Adjudication 2 — `spec.md` line 623 (criterion 17)

**Question posed:** is declining to check it correct, or is the criterion satisfied on a defensible
reading?

**Finding of fact.** Twenty-four distinct path-like inline-code tokens appear across the two epic
files. Excluding template placeholders (`<epic-slug>`, `<basename>`, `<integration_branch>`) and git
refspecs (`origin/main`, `epic/<epic-slug>-integration`), twelve concrete file tokens and three
directory tokens were resolved against the tree — all fifteen exist. Exactly one non-placeholder
token does not resolve: `artifacts/orchestration/epic-orchestrator-state.json`. It is gitignored
(`.gitignore:6: /artifacts`), runtime-generated, present in the pre-change text, and untouched by
F4.

**Adjudication: the executor's decision to decline was correct, and I endorse it.** Three reasons.

1. **The criterion admits exactly one exclusion, and widening it at delivery time is the failure
   mode the repository's own gate doctrine forbids.** `.claude/rules/plan-acceptance-gates.md` exists
   because an acceptance condition that is reshaped to fit the delivered result stops gating
   anything. An executor who adds a second exclusion class in order to check its own box has done
   exactly that. Declining and disclosing puts the widening decision where it belongs — with the
   spec author or a reviewer — and preserves the audit trail. The disclosure in
   `evidence/other/ac-reconciliation.2026-08-26T00-00.md` is prominent and states the deviation from
   `[P6-T12]`'s expected count rather than concealing it.
2. **The substantive goal of F4 is nevertheless fully met.** F4 targets *unqualified cross-references
   a reader cannot resolve*. Every cross-reference in both files resolves. The one non-resolving
   token is not a cross-reference at all; it is an output specification naming where the agent writes
   its checkpoint, and it names it correctly. Criteria 14, 15, and 16 — which express F4's actual
   defect — all PASS.
3. **The criterion as written is unsatisfiable in principle, which makes it a criterion defect rather
   than a delivery defect.** Because `/artifacts` is gitignored, no change to any file can make that
   path resolve in a clean checkout. In the vocabulary of the gate doctrine this is the mirror image
   of the usual failure: not a gate that cannot fail, but a gate that cannot pass. That is a defect
   in the criterion, and the correct remedy is a spec amendment, not code.

Recorded as Non-blocking finding N4. Recommended amendment: extend line 623's exclusion clause from
"is not a template placeholder" to "is not a template placeholder and is not a gitignored,
runtime-generated artifact path", or name `artifacts/orchestration/epic-orchestrator-state.json`
explicitly. `evidence/other/ac-reconciliation.2026-08-26T00-00.md` already records this as its
follow-up 7, which is the right disposition.

**On `[P6-T12]`'s count.** The task's condition reads "exactly one criterion of the 38 is recorded as
unchecked **and blocked**". Only line 644 is blocked; line 623 is unchecked but not blocked. On that
reading the condition holds and the `[x]` is defensible, though the wording is doing more work than
it was probably meant to. Recorded as Non-blocking finding N6. It is a process nit, not a delivery
gap, and it is fully disclosed.

## Check-Off Actions Taken

**None.** All 34 criteria evaluated PASS were already checked `[x]` in `spec.md`. The three PARTIAL
criteria and the one BLOCKED criterion required no change:

- Criterion 17 (line 623) is already unchecked, which matches its PARTIAL verdict.
- Criteria 33 and 37 are already checked `[x]`. This review did **not** uncheck them. The
  acceptance-criteria-tracking protocol directs a reviewer to leave unmet items unchecked and
  document the gap; it does not authorize a reviewer to reverse a check-off already recorded by the
  executor. Both gaps are documented above and carried into remediation inputs.
- Line 644 was not read for evaluation, not modified, and not raised as a finding.

`spec.md` is byte-unchanged by this review.

## Baseline Comparison

The change is measured against the merge base `b36179b2`, not against `HEAD` alone.

| Dimension | Baseline (`b36179b2`) | Head (`aeac89a7`) | Delta |
|---|---|---|---|
| Always-on lines, epic-orchestrator surface | 2,158 | 984 | **-1,174 (-54.40%)** |
| `.claude/rules/*.md` loading unconditionally | 9 of 19 | 4 of 19 | -5 |
| `epic-orchestrator` preloaded skills (lines) | 6 (936) | 3 (452) | -3 (-484) |
| Unqualified `spec.md §` citations under `.claude/` | 3 | 0 | -3 |
| Python line coverage (repo-wide) | 92.65% | 92.65% | **+0.00 pp** |
| Python statements measured | 15,014 | 15,014 | 0 |
| pytest collected | 4,141 | 4,156 | +15 (the two new modules add 8 + 7 tests) |
| pytest passed | 4,136 | 4,150 | +14 |
| pytest skipped | 5 | 5 | 0 |
| pytest failed | 0 | 1 | +1 (environmental — see below) |

**The failure count is not zero-delta, and this audit does not claim it is.** The Phase 0 baseline
at 23:40 recorded 0 failed because `.claude/state/python-batch-budget.default.json` did not yet
exist: Phase 0 performs no `Write` or `Edit`, so the repository's own `Write|Edit` PreToolUse hook
had not fired. The file's birth timestamp is 23:48:01, in Phase 1. A baseline taken after any write
in any worktree would have recorded the same 1 failure.

The disjointness argument therefore does not rest on a zero delta. It rests on the five independent
grounds in Adjudication 1 — the failing test, its enumeration function, and the producing hook are
all unmodified by this branch; the offending path is untracked, gitignored, and absent from every
diff entry; and the eight files this change did write into the bundle were proven byte-identical by
a method that does not involve the failing test.

## Evidence Completeness

29 evidence artifacts declared, 29 present, all under canonical `<FEATURE>/evidence/<kind>/` paths.
`validate_evidence_locations.py --root .` exits 0.

Schema conformance is **not** complete, contrary to the executor's summary:

| Field | Artifacts missing it |
|---|---|
| `Timestamp:` | 0 of 29 |
| `Command:` | 3 — `other/ac-reconciliation`, `qa-gates/coverage-delta`, `qa-gates/not-applicable-gates` |
| `EXIT_CODE:` | the same 3 |
| `Output Summary:` | 1 — `other/ac-reconciliation` |

The three are analysis and derivation records rather than command-run records, so the omission is
understandable, but two of the three sit under `qa-gates/` where the schema is expected. Recorded as
Non-blocking finding N1.

Both fail-before artifacts carry `ExpectedExitCode: 1` with the exact case-sensitive spelling the
convention requires, and both record `EXIT_CODE: 1`, so both normalize to `pass`.

## Findings Carried Forward

**Total Blocking findings: 1**

| ID | Severity | Summary | Location |
|---|---|---|---|
| B1 | **Blocking** | New test scans `.claude/` by filesystem recursion and does not exclude `.claude/worktrees/`, so it fails on the primary development checkout and passes from inside a worktree | `tests/scripts/dev_tools/test_claude_rules_frontmatter.py:37,307-327,479-499` |
| N1 | Non-blocking | Three evidence artifacts lack `Command:`/`EXIT_CODE:`; one also lacks `Output Summary:` | `evidence/other/`, `evidence/qa-gates/` |
| N2 | Non-blocking | `CLAUDE.md` names two different authoritative tone sources in adjacent paragraphs | `CLAUDE.md:11,13` |
| N3 | Non-blocking | The consuming digest test's assertion message still says "pre-feature state" after the re-baseline | `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:482-485` |
| N4 | Non-blocking | `spec.md:623` is unsatisfiable as written; amend its exclusion clause | `spec.md:623-625` |
| N5 | Non-blocking | Tolerance-branch selector is a value the executing agent authors and amended mid-run | `plan.2026-08-25T22-07.md` `[P2-T13]`, `[P3-T18]`, `[P6-T4]` |
| N6 | Non-blocking | `[P6-T12]` checked `[x]` while two criteria are unchecked; holds only on a narrow reading of "unchecked and blocked" | `plan.2026-08-25T22-07.md:901-916` |
| N7 | Non-blocking | Python branch coverage not collected repo-wide; the 75% floor is unevaluated | `pyproject.toml:113-126` |
| N8 | Non-blocking | New test module is 499 lines against the 500-line ceiling | `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` |
| N9 | Non-blocking | The scoped `parallel-orchestration.md` is no longer auto-injected for the epic surface that now cites it | `.claude/skills/epic-orchestrate/SKILL.md:143-149` |
| N10 | Non-blocking | Defaulted test parameter motivated only by line length | `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py:237-254` |

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/spec.md
- Total AC items: 38
- Checked off (delivered): 36
- Remaining (unchecked): 2
- Items remaining:
  1. [spec line 623] Every path-like token in the two epic files that is not a template placeholder
     resolves to an existing file in the repository. — PARTIAL. One pre-existing, gitignored,
     runtime-generated path (`artifacts/orchestration/epic-orchestrator-state.json`) does not
     resolve. Correctly left unchecked; the criterion needs amendment (N4), not code.
  2. [spec line 644] BLOCKED — DO NOT CHECK. Human selection of the authoritative coverage floor and
     toolchain loop. Reserved human decision; mandated to remain unchecked at delivery. Not a
     finding and not touched by this review.
- Reviewer check-off actions: none. All PASS criteria were already checked; no criterion was
  checked or unchecked by this review.
- Note on the two criteria recorded as checked but evaluated PARTIAL (spec lines 681-685 and
  702-705): both are checked `[x]` in the source file. This review did not reverse either
  check-off; the gaps are documented in Adjudication 1 and carried into remediation inputs.
```

## Supplementary — `issue.md` checkboxes (not AC under `full-bug`)

Reported for completeness only. `issue.md:68-72` carries five validation-idea checkboxes, three
checked and two unchecked. The two unchecked ones are consistent with this audit: line 70 is the
`issue.md` counterpart of `spec.md:623`, and line 71 ("Markdown and PowerShell gates run for the
files actually changed") is correctly unchecked because the repository has no Markdown lint or
format gate (verified: no `.markdownlint*` config, no `markdownlint`/`remark` dependency, and
`_docs-validation.yml` checks only README/LICENSE/instruction-doc existence) and PoshQC is not
applicable with zero PowerShell files changed. Checking either would assert something untrue.
