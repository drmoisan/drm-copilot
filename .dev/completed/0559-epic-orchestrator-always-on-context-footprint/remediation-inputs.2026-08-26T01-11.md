# Remediation Inputs — Issue #559 (epic-orchestrator always-on context footprint)

- Timestamp: 2026-08-26T01-11
- Reviewer: `feature-review`
- Branch: `bug/epic-orchestrator-always-on-context-footprint-559`
- HEAD: `aeac89a7`
- Merge base: `b36179b2`

## Source Artifacts

- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/policy-audit.2026-08-26T01-11.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/code-review.2026-08-26T01-11.md`
- `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/feature-audit.2026-08-26T01-11.md`

## Blocking Count

**Total Blocking findings: 1**

## Remediation-Required Findings

### B1 — New test is non-deterministic with respect to machine state

- **Severity:** Blocking
- **File:** `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`
- **Lines:** `37` (`EXCLUDED_CLAUDE_SUBDIRS`), `307-327` (`claude_markdown_files`),
  `479-499` (`test_no_unqualified_spec_section_citation_under_claude`)
- **Violated rule:** `.claude/rules/general-unit-test.md` — core principle 4 (Determinism: "Given
  the same inputs and environment, tests must produce the same results. Avoid flakiness.") and the
  External Dependencies rule ("Tests must not rely on mutable global state or external configuration
  that can change between runs.")

**Defect.** `claude_markdown_files()` enumerates `.claude/` with `CLAUDE_ROOT.rglob("*.md")` and
skips only the subdirectory named in `EXCLUDED_CLAUDE_SUBDIRS = frozenset({"agent-memory"})`. It
does not skip `.claude/worktrees/`, which is this repository's standard agent-worktree location
(`.gitignore:21`) and currently holds sixteen full repository copies, nor `.claude/state/`
(`.gitignore:68`). `test_no_unqualified_spec_section_citation_under_claude` therefore scans every
nested worktree's `docs/features/**` and reports their `spec.md §` occurrences as offenders.

**Reproduction.** Verified empirically against a synthetic tree using the module's own helpers with
`REPO_ROOT`/`CLAUDE_ROOT` repointed:

```
scanned files: ['.claude\\worktrees\\agent-x\\docs\\spec.md']
offenders:     ['.claude\\worktrees\\agent-x\\docs\\spec.md']
WOULD_FAIL: True
```

The offending content exists in the real tree. `git grep -c -F "spec.md §" -- 'docs/**/*.md'`
returns eight matching files, including this feature's own `spec.md` (4 occurrences) and `issue.md`
(2 occurrences) — both of which `spec.md:613-615` explicitly places out of the criterion's scope.
`git worktree list` confirms sixteen worktrees under
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/`.

**Impact.**

1. The test passes when run from inside a worktree and fails when run from the primary checkout at
   `C:/Users/DanMoisan/repos/drm-copilot`. The result depends on machine state that is not an input
   to the test. CI is unaffected, because a CI checkout has no nested worktrees, which is why the
   executor's own runs did not surface it.
2. The scan cost scales with the number of live worktrees rather than with the repository.

**Why this is Blocking rather than deferred.**

- The exclusion list already demonstrates awareness of the problem class: it excludes
  `agent-memory` precisely because that subtree "is gitignored and machine-local, so its content
  varies per workstation" (lines 35-36). `.claude/worktrees` and `.claude/state` are gitignored on
  adjacent lines of the same `.gitignore` and were not excluded.
- This change's own evidence
  (`evidence/baseline/baseline-pytest-coverage.2026-08-26T00-00.md`) correctly diagnoses the
  tolerated failing test as an instance of exactly this defect — "`list_scoped_files` enumerates the
  filesystem rather than consulting git, so a gitignored, untracked, machine-local state file enters
  the repo-side set" — and defers it as out of scope. Deferring that instance is defensible;
  shipping a new instance of the same class in the same change is not.

**Required fix (either is sufficient; the first is preferred).**

1. Enumerate the scan set from git so untracked and gitignored trees cannot enter it:

   ```
   git ls-files -- .claude
   ```

   filtered to `*.md`. This removes the defect class rather than one instance, and it makes the
   test's input identical to the set the criterion is actually about (committed `.claude/` content).

2. Minimal alternative — extend the existing exclusion set:

   ```python
   EXCLUDED_CLAUDE_SUBDIRS = frozenset({"agent-memory", "worktrees", "state"})
   ```

   Update the adjacent comment to state the general reason (gitignored, machine-local subtrees whose
   content varies per workstation) rather than naming only agent memories.

**Acceptance for the fix.**

- `poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py` exits 0 when run from
  the primary checkout `C:/Users/DanMoisan/repos/drm-copilot` with worktrees present, and exits 0
  when run from inside a worktree. Record both runs as separate evidence artifacts under
  `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/regression-testing/`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- The fix does not weaken `test_no_unqualified_spec_section_citation_under_claude`: it must still
  fail if an unqualified `spec.md §` citation is reintroduced into any committed `.claude/`
  Markdown file. Demonstrate this with a fail-before style probe rather than asserting it.
- `black --check`, `ruff check --no-fix`, and `pyright` remain clean over the module.
- The module remains at or under 500 lines (`.claude/rules/general-code-change.md`). It is currently
  at 499, so the fix must not add net lines without a compensating removal, or must split the module.
  See N8.

**Scope constraint for the fix.** Do not fix the pre-existing `list_scoped_files` defect in
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` as part of this remediation.
That module is outside the declared blast radius and its deferral is sound (see Adjudication 1 in
the feature audit). Record it as a follow-up instead. Do not delete or modify
`.claude/state/python-batch-budget.default.json`; the registered hook regenerates it and deleting it
mutates the developer's environment.

**Do not touch `spec.md` line 644 under any circumstance.**

## Non-Blocking Findings — Not Remediation Triggers

These do not gate the remediation loop. They are carried for a follow-up decision.

| ID | Summary | Location | Suggested disposition |
|---|---|---|---|
| N1 | Three evidence artifacts lack `Command:`/`EXIT_CODE:`; one also lacks `Output Summary:`. Two sit under `qa-gates/`. | `evidence/other/ac-reconciliation.*`, `evidence/qa-gates/coverage-delta.*`, `evidence/qa-gates/not-applicable-gates.*` | Add the schema fields, or move the two non-command records to `evidence/other/`. Fix in this branch if the remediation loop reopens the folder. |
| N2 | `CLAUDE.md` names two different authoritative tone sources in adjacent paragraphs. | `CLAUDE.md:11,13` | One-line precedence statement. Line 13 is pre-existing, so this may belong to a separate change. |
| N3 | The consuming digest test's assertion message still reads "pre-feature state" after the #559 re-baseline. | `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:482-485` | Leave to feature 441, which owns that file. Record as a follow-up on #441. |
| N4 | `spec.md:623` is unsatisfiable as written; its single exclusion clause does not cover gitignored runtime-generated artifact paths. | `spec.md:623-625` | Amend the criterion. Already recorded as follow-up 7 in `evidence/other/ac-reconciliation.2026-08-26T00-00.md`. |
| N5 | The tolerance branch of `[P2-T13]`, `[P3-T18]`, `[P6-T4]` is selected by a verdict the executing agent authors and amended mid-run. Substance independently verified correct. | `plan.2026-08-25T22-07.md` | Future plans: condition a tolerance branch on an independently checkable fact, e.g. that the failure reproduces at the merge base. |
| N6 | `[P6-T12]` checked `[x]` while two criteria are unchecked; holds only on a narrow reading of "unchecked and blocked". Fully disclosed. | `plan.2026-08-25T22-07.md:901-916` | No action. Resolved once N4's spec amendment lands. |
| N7 | Python branch coverage is not collected repo-wide (`BRF=0`; no `--cov-branch`), so the uniform 75% floor is unevaluated for Python. | `pyproject.toml:113-126` | Separate change. Out of this blast radius; this change adds zero production Python. |
| N8 | New test module is 499 lines against the 500-line ceiling. | `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` | Consider splitting the agent-preload tests into a sibling module during the B1 fix. |
| N9 | The newly scoped `parallel-orchestration.md` is no longer auto-injected for the epic surface that now cites it for the cache doctrine. | `.claude/skills/epic-orchestrate/SKILL.md:143-149` | No action. Deliberate and consistent with the change's intent; recorded so it is not later mistaken for an oversight. |
| N10 | Defaulted test parameter motivated only by line length. | `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py:237-254` | Optional cleanup during the B1 fix. The rejected alternatives (retaining an unauthorized suppression, dropping the return annotation) were correctly rejected. |

## Acceptance Criteria Left Unchecked

| Spec line | Status | Action for remediation |
|---|---|---|
| 623 | PARTIAL — correctly unchecked | **No code change.** Amend the criterion per N4, then re-evaluate. Do not check it on the current wording. |
| 644 | BLOCKED by design | **Do not touch.** Remaining unchecked is the mandated and expected outcome. |

Two criteria are recorded as checked `[x]` but evaluated PARTIAL (spec lines 681-685 and 702-705).
Both stem from the single tolerated out-of-scope pytest failure. This review did not reverse either
check-off. If the remediation loop chooses to fix the underlying `list_scoped_files` defect as well,
both become unambiguous PASS; otherwise the gaps stand as documented in Adjudication 1.
