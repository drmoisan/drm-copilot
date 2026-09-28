# Code Review: parallel-orchestrator-surface (#441)

**Review Date:** 2026-08-08
**Reviewer:** `feature-review` agent
**Feature Folder:** `docs/features/active/2026-08-07-parallel-orchestrator-surface-441`
**Feature Folder Selection Rule:** Supplied by the caller and independently confirmed — it is the
only active feature folder whose suffix (`-441`) matches the issue number in the branch name
`feature/parallel-orchestrator-surface-441`, and it is the only active folder with scoping-doc
changes in the branch diff.
**Base Branch:** `epic/parallel-orchestration-integration` (merge base `ee0626e838109fe8d3fe3904fb4631c71879baa3`)
**Head Branch:** `feature/parallel-orchestrator-surface-441` @ `41633ad5e867070853e3e4501c3457b6641d1efc`
**Review Type:** Initial review (full branch-vs-base diff)

---

## Executive Summary

This branch delivers epic feature F5 — the execution half of the `parallel` orchestration surface —
as four Markdown runtime and template artifacts, three byte-identical bundled mirrors, one
`pack-manifests/core.json` registration, and one Python contract-test suite split across three
test-tree modules. 33 files changed, 3976 insertions, 92 deletions, in a single conventional commit.
No production Python, TypeScript, PowerShell, or C# source changed; no workflow, composite action,
or benchmark script changed.

The implementation quality is high and the verification approach is unusually well matched to the
subject matter. Because the deliverable is procedure text rather than executable code, the feature's
correctness guarantee has to be a document-structure contract, and the suite is built that way: every
section-scoped criterion extracts its section by heading boundary before matching, so a fragment that
drifted into a neighbouring section fails the case that owns it. Three producer/consumer seam tests
go further and parse the skill's prescribed `parallel-status.md` names out of the producer at run time
rather than restating them, so a one-sided rename of a header field, cohort column, or projection
section fails — a class of divergence that independent per-side assertions cannot detect. The frozen
epic surface is protected twice over: by an empty `git diff` across the branch and by in-process
SHA-256 content pins.

One Major finding stands between this branch and an unqualified Go. The delivered persona's `tools`
allowlist does not permit two actions the delivered skill text prescribes: the parent-side write of
an item's `remediation-inputs.<timestamp>.md` under `docs/features/active/`, and the
manifest-validation library call. Both are internal contradictions among this feature's own four
deliverables, distinct from the F7 dependency the spec explicitly and legitimately accepts.

**What changed:**

- `.claude/agents/parallel-orchestrator.md` (NEW, 225 lines) — persona with a nine-section body, a
  `tools` allowlist deliberately omitting any `pr-author` channel, and a `SubagentStop` hook bound to
  the parallel checkpoint path and artifact type.
- `.claude/skills/parallel-orchestrate/SKILL.md` (NEW, 436 lines) — the procedure. Thirteen
  F5-authored `##` sections in the spec-mandated order, then three reserved wave-4 placeholder
  sections, each carrying exactly its one reserved sentence.
- `.claude/skills/parallel-run/SKILL.md` (NEW, 56 lines) — user entry point with a single-local-path
  kickoff discovery and an explicit STOP branch naming `/parallel-plan`.
- `docs/features/templates/parallel/parallel-status.md` (NEW, 78 lines) — generated-projection
  template with a do-not-hand-author HTML banner.
- Three byte-identical bundled mirrors plus three sorted `core.json` registrations.
- `tests/scripts/dev_tools/` — 36 contract tests (457 lines), 14 pure parsers (465 lines), inert
  pinned data (253 lines).
- `spec.md`, `user-story.md`, `plan.2026-08-07T11-11.md` updated; 19 evidence artifacts added under
  the canonical `evidence/<kind>/` scheme.

**Top 3 risks:**

1. **The persona cannot perform two procedures it is instructed to perform.** The
   `## Per-Item Merge-Conflict Handling` write target (`docs/features/active/**`) and the manifest
   validation library call are both outside the delivered `tools` allowlist. Neither is caught by any
   test, because no acceptance criterion covers allowlist/procedure consistency. This surfaces at
   first live use.
2. **The content-hash pins on the frozen epic files have no expiry and a misdirecting failure
   message.** Once this branch merges, any legitimate future edit to `.claude/agents/epic-orchestrator.md`
   or `.claude/skills/epic-orchestrate/SKILL.md` fails a test whose message reads "must be
   byte-identical to its pre-feature state" — text that will be meaningless to a maintainer working
   long after this feature closed.
3. **The surface is not executable end-to-end until F7 lands.** This is an accepted, documented
   spec-level limitation rather than a defect, but it means no live-path evidence exists for the merge,
   worktree-removal, or conflict-remediation procedures. The confidence in those sections rests
   entirely on their textual fidelity to the frozen epic precedent, which this review checked by
   direct comparison.

**PR readiness recommendation:** **Conditional Go** — every toolchain gate, coverage threshold, and
acceptance criterion passes with verified evidence; merge after resolving finding CR-01, which is a
narrow, well-localized reconciliation between the persona's `tools` allowlist and two sentences of
the skill text.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.claude/skills/parallel-orchestrate/SKILL.md` / `.claude/agents/parallel-orchestrator.md` | SKILL.md:277-283 (`## Per-Item Merge-Conflict Handling` step 1) vs agent frontmatter lines 10-13 | The skill assigns **the parent** the write of the item's `remediation-inputs.<timestamp>.md` "in the item's active feature folder under `docs/features/active/`". The persona's only `Write`/`Edit` grants are `docs/features/parallel/**` and `artifacts/orchestration/**`, so the prescribed write is denied at runtime. The frozen epic precedent assigns the equivalent capture and write to the **child's** `atomic-executor`, not to the parent. | Preferred: reassign the write to the child's chain, matching the epic precedent — the parent passes the conflicted-file list and marker excerpts in the re-delegation prompt and the child writes its own `remediation-inputs`. This preserves both the tighter allowlist and the precedent's actor model. Alternative: add `Write(docs/features/active/**)` and `Edit(docs/features/active/**)` to the persona, accepting the wider blast radius. Either way, add a contract test asserting every write target the skill prescribes is covered by a persona `Write` grant. | The documented procedure is unexecutable by the agent that is documented to execute it. It is an internal contradiction among this feature's own deliverables, not the accepted F7 dependency, and no test or acceptance criterion covers it. | `.claude/skills/epic-orchestrate/SKILL.md:187-194` assigns the write to the child's `atomic-executor`; `.claude/skills/parallel-orchestrate/SKILL.md:277-283` reassigns it to the parent; agent frontmatter lines 10-13 list only two `Write` scopes. `spec.md` R2.9 carries the same reassignment, so the divergence originates in the spec. |
| Major | `.claude/skills/parallel-orchestrate/SKILL.md` | SKILL.md:75-77 (`## Parallel Manifest Consumption`) | The skill instructs "Validate by calling `validate_parallel_manifest_text` from `scripts/dev_tools/parallel_manifest_contract.py`, which is a library call and deliberately not an MCP artifact type." The persona's Bash grants are `Bash(git *)` and `Bash(gh *)` only and it holds no MCP tool for manifest validation, so it has **no** permitted mechanism to run the validation the same section makes a precondition of any kickoff. | Either grant a narrowly scoped invocation (for example `Bash(poetry run python -m scripts.dev_tools.*)`), or restate the obligation as a delegation to a component that can run it, or have F3/F4 expose the check through a surface the persona already holds. | The section makes manifest validation a hard gate ("A malformed manifest is rejected before any kickoff"), then names the only prescribed mechanism as one the persona cannot invoke. The gate is therefore documented but unenforceable, which risks a silent skip in practice — the exact outcome the section forbids. | `.claude/skills/parallel-orchestrate/SKILL.md:75-77`; `.claude/agents/parallel-orchestrator.md:14-17` (`Bash(git *)`, `Bash(gh *)`, two MCP tools, neither for manifest validation); `.claude/rules/parallel-orchestration.md` ("Manifest validation is a library call, not an MCP artifact type"). |
| Minor | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | Lines 78-90 (`PINNED_FROZEN_SURFACE_HASHES`) | The two SHA-256 pins on the frozen epic files have no expiry and their assertion message reads "must be byte-identical to its pre-feature state". After this branch merges, that phrasing is stale: a maintainer legitimately editing `epic-orchestrate/SKILL.md` in six months gets a failure telling them to restore a state that is no longer meaningful, with no pointer to what to do. | Either drop the pin after merge (the empty-`git diff` acceptance criterion already proved the freeze for this branch), or convert it to a merge-base-relative `git diff` check, or at minimum amend the message to say the digest pins issue #441's freeze and explain that a deliberate epic-surface change should update the constant. | The pin is correct and valuable *during* this feature's review, where it proves the additive-only constraint held. Its value inverts after merge: it becomes a tripwire whose diagnostic text misdirects. Recording the intended lifetime now is cheaper than rediscovering it from a confusing failure later. | `parallel_orchestrator_surface_expectations.py:78-90`; assertion message at `test_parallel_orchestrator_surface_contracts.py:454-457`. Both pins currently match (`36 passed`). |
| Minor | `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py` | Lines 151-159, 297-301 | Three defensive `ValueError` guard branches (missing frontmatter fence, unterminated fence, absent section heading) have no dedicated negative test. Because these modules are test-tree files they sit outside the coverage denominator, so the gap is invisible to every coverage metric. | Add three short negative tests asserting each guard raises with its stated message. They are three-line tests over string literals with no I/O. | The guards are the mechanism that stops a malformed document from silently satisfying a presence assertion — the suite's central fail-closed property. That property is currently unverified. Impact is bounded because the guards raise rather than return empty, so a regression degrades a message rather than producing a false pass. | `split_frontmatter` (support:151-159) and `extract_section` (support:297-301) raise; no test in the 36-item inventory exercises either raise path. |
| Minor | `docs/features/active/.../evidence/qa-gates/coverage-delta.2026-08-08T17-58.md` | Lines 25, 44-47, 79-86 | The artifact records post-change branch coverage as 83.82% (`covered_branches` 4191, partial 555) and attributes the +1 destination to this branch's new `.claude` files and `core.json` entries changing inputs traversed by existing bundle-parity helpers. An independent re-run at the same HEAD produced 83.80% (`covered_branches` 4190, partial 556) — the baseline value. | Amend the attribution sentence to state that the single-destination movement is environment-dependent and not a reproducible property of the branch content. Keep the verdict, which is unaffected. | The artifact already hedges ("an inference from the unchanged denominator rather than a directly measured per-branch attribution"), which is honest, but the comparison table presents +0.02 pp as an observed branch property. Neither value changes any verdict: both clear the 75% floor by more than 8 pp and neither is a regression. | This review's run: `poetry run coverage json` → `percent_branches_covered` 83.8, `num_partial_branches` 556, `num_branches` 5000, `percent_statements_covered` 91.82362065145136. |
| Nit | `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | Line 216 | `assert len(headings) == 16` couples any future wave-4 feature that needs a new `##` section to this test module. F6/F7/F8 appending `###` subsections inside their reserved sections is unaffected, which is the designed path. | No change required. Optionally add one sentence to the test docstring stating that a wave-4 feature adding a `##` section is expected to update this count deliberately. | The exact count is a real guard against a stray heading, and the assertion message already explains the expectation. Recording it here so a future maintainer reads the coupling as deliberate. | `test_orchestrate_skill_first_thirteen_headings_match_required_layout:208-223`; reserved-section design rationale at `parallel-orchestrate/SKILL.md:30-35`. |
| Nit | `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py` | Line 67 | `_HEADER_FIELDS = re.compile(r"Header block fields:([^.]*)\.")` terminates the capture at the first period, so a prescribed field name containing a dot would truncate the parsed list silently. | No change required for the current six field names. If a dotted field name is ever prescribed, switch the terminator to an explicit end-of-list anchor. | The seam test asserts `len(prescribed) == 6`, so a truncation would be caught rather than passing silently. Recorded for completeness. | `prescribed_header_fields` (support:358-382); guard at `test_seam_status_template_realises_header_fields_prescribed_by_skill:311-314`. |
| Info | `tests/scripts/dev_tools/` | Directory placement | The subjects under test live under `.claude/agents/` and `.claude/skills/`, while the tests live at `tests/scripts/dev_tools/`, so the mirroring rule in `general-unit-test.md` is satisfied by repo convention rather than by literal path correspondence. | No change. | The path is the one `spec.md` R4 names, matches the sibling precedent `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py`, and no `tests/.claude/` convention exists in this repository. | `spec.md` R4; `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py`; `test_legacy_discovery_skills_contracts.py`. |
| Info | `docs/features/active/.../spec.md` | Acceptance criteria items 8 and 18 | The two criteria are mutually exclusive if read literally: item 8 requires the kickoff section to "state that the kickoff prompt never carries `Preparation mode: true` or `Epic mode: true`", while item 18 forbids the literal `Epic mode: true` from appearing in any delivered runtime file. | No change to the delivered files. Optionally reword spec item 8 to describe the obligation semantically, as the implementation and its test already do. | The implementation resolved the conflict correctly, in favour of the stricter negative obligation, and made the resolution explicit rather than implicit: the skill writes "the marker whose text is `Epic mode` followed by the value `true`" and the test pins that exact paraphrase in a named constant with a comment stating why. This is the right call, well executed. | `parallel-orchestrate/SKILL.md:198-202`; `KICKOFF_NEVER_CARRIES_FRAGMENTS` with its explanatory comment at `parallel_orchestrator_surface_expectations.py:108-114`; `PRESCRIPTIVE_EPIC_LITERALS` held as test data at `parallel_orchestrator_surface_test_support.py:53-59`. |
| Info | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | Suite-wide | One test fails in this environment because the hook under test resolves the real gitignored `artifacts/orchestration/orchestrator-state.json` rather than a test-supplied checkpoint, so its outcome depends on whether an orchestrated run is in progress. | Open a separate potential-bug entry to pass the checkpoint path into the hook as a test parameter. Out of scope for this branch. | Not attributable to this branch: zero PowerShell files changed, and the suite's last modification (`72360a22`) predates the merge base. The caller's parallel claim about `codex-pretooluse-integration.Tests.ps1` did not reproduce — that suite reported zero failures. | `Invoke-Pester` over both suites: `TOTAL=52 PASSED=51 FAILED=1`; failing test `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`, message `Expected: 'allow' / But was: 'deny'`. `git diff --name-only ee0626e8..41633ad5 -- '*.ps1' '*.psm1' '*.psd1'` → empty. |

**No Blocker findings.** Two Major, three Minor, two Nit, three Info.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- **Three-layer separation with a single I/O boundary.** Assertions live only in the test module;
  pure parsers live only in `*_test_support.py`; inert pinned data lives only in `*_expectations.py`.
  The parser module is the sole filesystem toucher and declares that in a `Side effects:` docstring
  section. Dependency direction is strictly acyclic (`test_* → expectations → test_support`), with
  `expectations` importing exactly two heading constants back from `test_support` to avoid duplicating
  them — a small, correct choice that keeps one definition per heading string.
- **Producer-parsing seam tests instead of duplicated expectations.** The three
  `test_seam_status_template_realises_*` tests parse the skill's prescribed header fields, cohort
  columns, and projection section names out of the producer text at run time, then bind each parsed
  name to the shipped template. The `*_expectations` docstring states the reasoning explicitly:
  "The prescribed `parallel-status.md` names are deliberately NOT pinned here: the seam tests parse
  them from the producer skill at run time so that a producer/consumer divergence cannot pass." This
  catches one-sided renames that two independent per-side assertions would both happily pass. It is
  the strongest design decision in the diff.
- **Section extraction before matching.** Every section-scoped criterion calls
  `orchestrate_skill_section(heading)` first, so a required fragment that drifts into a neighbouring
  section fails the case that owns it rather than passing on a whole-file match. `extract_section`
  raises rather than returning empty when the heading is absent (support:297-301), which closes the
  degenerate "matched against an empty string" path.
- **Per-obligation failure attribution.** `assert_fragments` loops one fragment at a time and names
  the missing one (support:332-335), and the 11 section-obligation cases carry explicit kebab-case
  parametrize ids, so a failure reports as, for example,
  `[merge-conflict-exhaustion-and-f8-handoff]` rather than as an opaque index. Diagnostics are
  materially better than a single large section-equality assertion would give.
- **Whitespace-collapse normalization decouples the contract from line wrapping.**
  `collapse_whitespace` lets a multi-line prose obligation be pinned as adjacent string literals
  without encoding the delivered file's wrapping, so a reflow of the Markdown does not break the
  contract while a change in wording does. The docstring states this rationale.
- **Deliberate fail-closed parsing.** `split_frontmatter` raises on both a missing and an
  unterminated fence, and `parse_frontmatter` raises when the block does not parse to a mapping. The
  docstring for the first explains why: "Failing fast keeps a malformed document from silently
  satisfying a body-only assertion."
- **Path resolution independent of the working directory.** `REPO_ROOT` derives from
  `Path(__file__).resolve().parents[3]` with an inline comment explaining the hop count, so results
  do not vary with invocation directory.

#### Typing and API notes

- Every function in all three modules is fully annotated on parameters and return type; every module
  constant carries an explicit annotation, including the nested
  `SECTION_OBLIGATION_CASES: tuple[tuple[str, str, tuple[str, ...]], ...]`. All three use
  `from __future__ import annotations`.
- The untyped `yaml.safe_load` boundary is isolated in exactly one function, `parse_frontmatter`,
  which narrows to `dict[str, object]` and raises on a non-mapping result. This is precisely the
  "wrap untyped libraries behind small typed adapters" pattern `python.md` prescribes.
- `subagent_stop_hook_commands` (support:213-253) walks a two-level nested YAML structure with an
  `isinstance` check plus a `cast("...")` at each level and a `continue` on each malformed entry,
  rather than propagating `Any` or trusting the shape. `string_sequence` similarly drops non-string
  members rather than coercing them, with a docstring sentence explaining why: "a malformed entry
  cannot masquerade as a declared name."
- Zero `Any`, zero `# type: ignore`, zero `# noqa` added by this branch. `poetry run pyright` reports
  `0 errors, 0 warnings, 0 informations`.
- Public surface is minimal and internals are `_`-prefixed: the six compiled regexes are
  `_WHITESPACE_RUN`, `_BACKTICKED`, `_HEADER_FIELDS`, `_COHORT_PROJECTION`, `_PROJECTION_SECTION`,
  `_DELIMITER_ROW`.
- No new public API surface is added outside the test tree.

#### Error handling and logging

- Fails fast with specific `ValueError` at four guard points, each with a distinct message. No broad
  `except:` or `except Exception:` appears anywhere in the diff.
- `extract_section` chains context correctly with `raise ValueError(...) from exc`, preserving the
  originating `list.index` failure.
- No logging or print surface, which is correct for a test module: assertion messages are the
  diagnostic channel, and they are specific.
- Note that the guards' correctness is asserted only indirectly — see finding CR-04.

### Markdown / runtime-surface implementation audit

#### What changed well

- **Wave-4 extensibility is designed, stated, and tested.** The skill declares its own
  extension contract in prose ("A cross-reference names another section by its exact heading text,
  never by position or number, so a section can be added or extended without reflowing, reordering, or
  renumbering anything else in this file", SKILL.md:30-35), then honours it throughout: every
  cross-reference in the file names a section by exact heading text. The three reserved sections are
  last, uniquely named, and each carries exactly its one reserved sentence, with tests asserting
  position, uniqueness, and exact body separately.
- **Every delta from the frozen epic precedent is stated inline rather than left implicit.** The
  manifest section says outright "**This section is not a schema authority** … This is a deliberate
  delta from `.claude/skills/epic-orchestrate/SKILL.md`, whose manifest section carries its schema
  inline." The lifecycle section says the absence of an integration branch "is structural rather than
  an omission." This is the right way to document a near-verbatim adaptation: a reader comparing the
  two files is told which differences are intentional.
- **Durable-ground-truth discipline is consistent across all four surfaces.** The agent's
  `## Startup Protocol`, the skill's cohort barrier, merge-on-green step 2, worktree cleanup, and the
  `parallel-run` resume step all independently require re-derivation from
  `git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid`,
  and all five say "never from in-memory notifications". The checkpoint is described as "a cache of
  durable state, not the source of truth", matching `.claude/rules/parallel-orchestration.md`'s Cache
  Doctrine verbatim in substance.
- **The F7 dependency is disclosed at each affected step, not buried once.** `EPIC_MERGE_GATE_BLOCKED`
  is named in `## Per-Item Merge to Main` and `EPIC_WORKTREE_REMOVAL_BLOCKED` in
  `## Worktree Cleanup`, each with the specific reason the epic hook fails closed for a non-epic
  checkpoint, and the worktree section additionally notes that "`PreToolUse` denials are conjunctive,
  so a new allow-hook alone cannot override the existing deny" — a non-obvious mechanic that a future
  F7 planner needs. The stated intent is "That limitation is documented, not worked around."
- **Every external reference in the delivered text resolves.** This review checked each one:
  `compute_concurrency_batches` exists at `scripts/dev_tools/parallel_cohort_computation.py:419`;
  `validate_parallel_manifest_text` at `scripts/dev_tools/parallel_manifest_contract.py:274`;
  `.claude/lib/model-routing/ModelRouting.psm1` exists; all four named epic hook scripts exist;
  `parallel-planner.md` and `parallel-plan/SKILL.md` exist; and the `#452` / PR `#453` blast-radius
  citation corroborates against commit `b086cf69` ("Merge pull request #453 from
  drmoisan/bug/blast-radius-under-reporting-452"). No dangling reference was found.
- **The template realises exactly what the skill prescribes.** Six header fields, an item table whose
  `cohort_index` column replaces the epic wave column, a cohort table carrying `generation`, and the
  three read-only projection sections — each with an explicit note that an empty array renders an
  empty section rather than an omitted one, which prevents a downstream feature from mistaking
  absence for a schema change.
- **Tone policy is met throughout.** All four Markdown deliverables are neutral, literal, and
  measured, with no hyperbole, humour, or decorative metaphor.

#### Structure and constraint notes

- Line counts: 436 / 225 / 78 / 56. Markdown is exempt from the 500-line limit, and none approaches
  it regardless. The skill file remains navigable at 436 lines.
- `depends_on` appears twice in each of the two large deliverables, both times in explicit negative
  framing ("there is no `depends_on` field anywhere on this surface"), which is correct: the rule
  file makes presence of the key a rejection, and naming its absence is the documented pattern.
- None of the three forbidden prescriptive literals appears in any delivered runtime file, verified
  independently by grep as well as by the parametrized test.

#### Correctness note on the actor reassignment

The single substantive behavioural divergence from the frozen epic precedent is the actor for
conflict-remediation input authoring. The epic skill has the child's `atomic-executor` capture the
conflict data and the finding written into the child's own active folder
(`epic-orchestrate/SKILL.md:187-194`); the parallel skill reassigns both to the parent
(`parallel-orchestrate/SKILL.md:277-283`). The reassignment is coherent in itself — the parent is the
one that observes the failed `gh pr merge` — but it was not accompanied by the corresponding
`Write` grant. See findings CR-01 and CR-02.

### TypeScript / PowerShell / C# implementation audit

Not applicable. Zero changed files in each. Verified by
`git diff --name-only ee0626e8..41633ad5 -- '*.ts' '*.ps1' '*.psm1' '*.psd1' '*.cs'` → empty output.

### JSON implementation audit

`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` gains exactly three
string entries, each inserted in correct sorted position within its array. `format_json --check`
reports no change needed and `validate_json` exits 0. The three bundled mirrors are byte-identical to
their source files by SHA-256 (`94f5f08b…`, `592d0054…`, `9fc7fe3a…`), and the pre-existing
pack-manifest-completeness and resource-contract suites pass within the 3004, so the registration is
consistent with the bundle rather than merely well-formed.

---

## Test Quality Audit

The verification story is complete for what the deliverable is — a document-structure contract — and
appropriately honest about what cannot be verified locally, namely live end-to-end execution, which
the spec scopes to F7.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` — 36 tests covering
  frontmatter identity, ordered heading layouts, 11 section-scoped obligation cases, 4 negative
  assertions, 3 producer/consumer seam bindings, and 2 content-hash pins. Executed:
  `36 passed in 0.07s`. Every one of the 33 acceptance criteria across `spec.md` and `user-story.md`
  is asserted here or by a direct git verification recorded in the feature audit.
- `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py` — 14 pure parsers. Verifies
  nothing itself; its quality matters because every assertion depends on it. Reviewed line by line:
  the parsers fail closed, the regexes are anchored to the producer's actual sentence shapes, and
  `markdown_table_header_cells` correctly requires a delimiter row to confirm a header row so an
  ordinary pipe-bearing prose line is not mistaken for a table.
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` — inert pinned data. The
  comment at lines 108-109 explaining why the epic marker's value is pinned descriptively is the kind
  of note that prevents a future maintainer from "fixing" the paraphrase back into the forbidden
  literal.
- `evidence/baseline/baseline-pytest-coverage.2026-08-08T16-47.md` — pre-change baseline:
  2968 passing, 91.82% statements, 83.80% branches. Carries `Timestamp`, `Command`, `EXIT_CODE`, and
  an output summary per the evidence schema.
- `evidence/qa-gates/final-qc-{black,ruff,pyright,pytest-coverage}.2026-08-08T17-5*.md` — the four
  final clean-pass gates, each with exact command and exit code. Independently reproduced by this
  review with identical results.
- `evidence/qa-gates/coverage-delta.2026-08-08T17-58.md` — baseline-versus-post comparison with
  precise `coverage json` `totals` on both sides. Notably it does not merely assert "no regression":
  it explains that changed-line regression is structurally zero because no production Python file
  changed, and shows the identical numerator, denominator, and missing count as arithmetic proof. One
  attribution sentence is not reproducible — see finding CR-05.
- `evidence/other/frozen-surface-verification.2026-08-08T17-46.md` and
  `evidence/baseline/baseline-frozen-surface-hashes.2026-08-08T16-47.md` — the freeze proof that the
  in-process content pins were derived from.
- `evidence/other/no-hook-or-settings-change.2026-08-08T17-47.md` — 24-path changed-path enumeration
  supporting the no-hook, no-settings criterion. Independently reconfirmed by
  `git diff --stat ee0626e8..41633ad5 -- .claude/hooks/ .claude/settings.json` → empty.
- `evidence/other/bundle-parity-verification.2026-08-08T17-54.md` and
  `evidence/regression-testing/bundle-parity.2026-08-08T18-05.md` — mirror parity. Independently
  reconfirmed by SHA-256 on all three pairs.
- `evidence/regression-testing/contract-tests-pass.2026-08-08T17-43.md` — the contract-suite run.
- `evidence/other/ac-status-summary.2026-08-08T17-52.md` and
  `evidence/other/f7-coordination-note.2026-08-08T17-48.md` — AC roll-up and the wave-4 coordination
  note.

All 19 evidence artifacts sit under the canonical `<FEATURE>/evidence/<kind>/` scheme;
`validate_evidence_locations --root .` exits 0.

### Quality assessment prompts

- **Determinism:** Strong. No clock read, no RNG, no `sleep`, no network, no subprocess, no temporary
  file — asserted in both module docstrings and confirmed by inspection. The only inputs are files
  committed to the checkout, and `REPO_ROOT` is derived from `__file__` rather than the working
  directory. Two independent full-suite runs produced identical results.
- **Isolation:** Strong. 36 tests, one obligation each, no shared mutable state, no fixture wider than
  function scope, no ordering dependency. The 11 section-obligation cases are parametrized so each
  criterion reports independently rather than being bundled into one assertion.
- **Speed:** Strong. `36 passed in 0.07s` (≈2 ms/test); collection 0.05 s; full repo suite 10.61 s for
  3004 tests.
- **Diagnostics:** Strong. `assert_fragments` names the specific missing obligation; the seam tests
  print the parsed producer prescription alongside the observed consumer state and the template's
  actual header rows; the heading tests print both expected and found tuples; the hash test prints
  both digests. One diagnostic weakness: the frozen-surface message will misdirect after merge
  (finding CR-03).
- **Scenario completeness:** Good, with one gap. Positive, negative, exact-set, exact-count,
  position, uniqueness, and seam scenarios are all covered. The three defensive guard branches in the
  parsers are the one uncovered error path (finding CR-04).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff contains no credential, token, key, or URL with embedded auth. The only literals are repo-relative paths, Markdown heading strings, and two SHA-256 content digests of committed files. |
| No unsafe subprocess or command construction | ✅ PASS | Zero subprocess invocations in the added Python. No `os.system`, `subprocess`, `shell=True`, or dynamic command construction. The delivered Markdown prescribes `git`/`gh` commands as procedure text for an agent to run under an allowlist, not as constructed strings. |
| Input validation at boundaries | ✅ PASS | The single untyped boundary (`yaml.safe_load`) is validated: `parse_frontmatter` raises on a non-mapping result, `string_sequence` rejects non-list values and drops non-string members, and `subagent_stop_hook_commands` `isinstance`-checks every nesting level. `yaml.safe_load` is used rather than `yaml.load`. |
| Error handling remains explicit | ✅ PASS | Four specific `ValueError` guards with distinct messages; correct `raise ... from exc` chaining; no broad catch anywhere in the diff. |
| Configuration / path handling is safe | ✅ PASS | All paths are repo-root-relative `Path` constants resolved against a `REPO_ROOT` derived from `__file__`. No path is built from user input, environment variable, or argument. No path traversal surface. |
| No file writes from test code | ✅ PASS | Every filesystem call in the added Python is a read (`read_text`, `read_bytes`). No write, no temp file, no directory creation. |
| Privilege scope of the delivered persona | ⚠️ PARTIAL | The `tools` allowlist is appropriately narrow and correctly omits any `pr-author` channel. The concern runs the other way: it is narrower than the procedures the same feature prescribes, so two documented actions are denied. Findings CR-01 and CR-02. Note that the narrowness itself is the safer failure direction — the agent will be blocked rather than silently over-reaching. |
| Frozen-surface integrity | ✅ PASS | Empty `git diff` for `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, and `.claude/skills/orchestrate/SKILL.md` across the branch, plus two matching in-process SHA-256 pins. |
| No enforcement-surface change | ✅ PASS | Empty `git diff` for `.claude/hooks/` and `.claude/settings.json`, so this branch cannot weaken any existing gate. |

---

## Research Log

No external research was required. Every claim in this review is grounded in files in the checkout,
in git history, or in the output of the commands recorded in Appendix B of
`policy-audit.2026-08-08T18-12.md`.

Two verification steps are worth naming because they are not obvious from the diff alone:

1. **Epic-precedent comparison for the actor reassignment.** The frozen
   `.claude/skills/epic-orchestrate/SKILL.md` was read at lines 183-202 to establish which component
   authors conflict-remediation inputs on the epic surface. This is what distinguishes finding CR-01
   from an inherited pattern: the epic surface assigns the write to the child, so the parallel
   surface's reassignment to the parent is this feature's own choice, and the missing `Write` grant is
   a new gap rather than a pre-existing one. The same comparison established that finding CR-02's
   third instance (the unexecutable `python -m` CLI fallback) *is* inherited —
   `epic-orchestrate/SKILL.md:279` carries the identical fallback under the identical allowlist —
   which is why that instance is graded advisory.
2. **Independent re-measurement rather than evidence transcription.** The full toolchain and coverage
   run were executed fresh rather than read from the executor's QA artifacts. This confirmed the
   headline figures and surfaced the one non-reproducible value behind finding CR-05, which
   transcription would have propagated.

**Note on unavailable tooling.** No MCP tool surface (`mcp__drm-copilot__*`) was present in this
agent's allowlist, so `resolve_policy_audit_template_asset` and `validate_orchestration_artifacts`
could not be invoked. Templates were resolved by the canonical bundled paths that
`extensions/drm-copilot/src/policy-audit-template-assets.ts` maps each selector to, which are the
same paths the tool returns. MCP-based validation of the three review artifacts was therefore not
run; this is recorded as an assumption rather than as a pass.

---

## Verdict

**Conditional Go.** This is a carefully built, well-documented feature whose verification approach is
well matched to a Markdown deliverable. Every gate the branch is responsible for passes on
independently re-run evidence: Black clean over 372 files, Ruff clean, Pyright 0/0/0, 3004 tests
passing with the count reconciling exactly against the recorded baseline, Python line coverage 91.82%
against an 85% floor and branch coverage 83.80% against a 75% floor with zero regression, JSON
governance clean, all 19 evidence artifacts in canonical locations, three bundled mirrors
byte-identical, and the frozen epic surface provably untouched by both an empty `git diff` and two
content-hash pins. All 22 `spec.md` and 11 `user-story.md` acceptance criteria evaluate to PASS. The
producer-parsing seam tests and the section-extraction-before-matching discipline are notably better
than a naive whole-file grep contract would have been, and the inline documentation of every delta
from the frozen epic precedent will materially help the three wave-4 features that must extend this
file.

Merge should follow one narrow correction. Findings CR-01 and CR-02 are Major because the delivered
persona's `tools` allowlist does not permit two actions the delivered skill text makes mandatory: the
parent-side write of an item's `remediation-inputs.<timestamp>.md` under `docs/features/active/`, and
the manifest-validation library call that the same section makes a precondition of any kickoff. These
are internal contradictions among this feature's own four deliverables, not the accepted F7
dependency, and no acceptance criterion or test covers allowlist/procedure consistency, so they would
otherwise surface only at first live use. The preferred fix for CR-01 reassigns the write to the
child's chain, matching the frozen epic precedent, which resolves the contradiction without widening
the parent's write scope. Both are routed through `remediation-inputs.2026-08-08T18-12.md`.

The remaining findings do not gate merge. CR-03 (frozen-surface pin lifetime), CR-04 (three untested
guard branches), and CR-05 (one non-reproducible coverage attribution) are Minor and can be addressed
in this cycle or tracked; CR-06 and CR-07 are Nits recorded for future maintainers; the three Info
items document a spec self-inconsistency the implementation already resolved correctly, an
established test-location convention, and a pre-existing out-of-diff Pester test-isolation defect
that this branch cannot have caused and should be tracked separately.
