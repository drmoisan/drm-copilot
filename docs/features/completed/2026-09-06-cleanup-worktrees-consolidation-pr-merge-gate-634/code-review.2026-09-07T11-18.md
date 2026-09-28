# Code Review — 2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate (Issue #634)

- Timestamp: 2026-09-07T11-18 (UTC)
- Reviewer: feature-review agent
- Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` @ `a36b6dca`
- Overall verdict: **PASS**
- Blocking findings: **0**

## What Changed

Twenty-three added lines across three sections of one Markdown skill document, mirrored
byte-identically into the bundled extension payload. No executable code changed anywhere on the
branch.

| Location | Lines added | Purpose |
|---|---|---|
| End-to-End Workflow step 5 (lines 107–120) | +11, -2 | Names the human as the merge actor, states three independent reasons the agent cannot perform the merge, defines the handoff boundary, and discloses the unbounded wait. |
| `## Prohibited Shortcuts` (lines 261–265) | +5 | Forbids issuing the merge command and forbids writing or editing an orchestration checkpoint to satisfy the gate, naming the specific shape-1 evasion. |
| `## Cross-References` (lines 279–283) | +5 | Adds the gate hook with an explanation of why a cleanup run matches none of its three checkpoint shapes. |

Reviewed against the five design edits (a)–(e) specified in `spec.md` `## Proposed Fix`. All five
are present and each is implemented where the spec places it.

## Design Assessment

**The chosen design is the right one, and the rejection of the alternative is well-argued.**
`spec.md` `## Decision` selects Option A (document the human step) over Option B (add a fourth
checkpoint shape). The decisive reason, R1, is that the repository ruleset already enforces the
safety property server-side, so Option B would have purchased nothing while adding a new
trusted-input surface: a self-recorded `ci_gate.conclusion` inside a gitignored `artifacts/`
document. This reviewer independently re-queried the ruleset and confirms R1's factual premise
holds as of today, including `strict_required_status_checks_policy: true`.

This aligns with the "simplicity first" priority in `.claude/rules/general-code-change.md`: the
zero-code option was selected, and the option that would have widened an enforcement surface's
allow side was rejected with its reasoning recorded for a later reader.

**The three stated blockers are independent, which makes the explanation robust.** Step 5 gives
three reasons the agent cannot merge: the command is absent from the skill's `allowed-tools`; it
is absent from `permissions.allow`; and the gate hook would deny it. These are separate
mechanisms at separate layers, so the documented conclusion survives a change to any one of them.
Documenting all three rather than only the gate is a deliberate strength, not redundancy — a
reader who later widens the gate still finds two remaining blockers named here.

**The handoff boundary is stated concretely.** "the agent reports the consolidation pull
request's URL or number to the operator and stops" gives an executing agent an unambiguous
terminal action. Compare this to the alternative of merely omitting the merge step, which would
leave the agent to invent a handoff. The explicit "and stops" is the load-bearing phrase.

**The pre-existing verification invariant is preserved verbatim.** The git-native ancestry check
survives unchanged in both text and meaning:

```
`git merge-base --is-ancestor documentationandmemories main`. Exit 0 confirms every
consolidated commit is now reachable from `main`; that is the only state that unlocks
deletion of branches whose unique content was consolidated.
```

The diff shows these as context lines, not modified lines. The new prose was inserted *before*
this invariant, so the safety property that gates step 6's destructive deletion is untouched. This
was the single highest-risk aspect of editing step 5 and it was handled correctly.

## Correctness of Factual Claims

Every checkable assertion in the added prose was re-derived from primary sources. All six are
accurate; the detailed verification table is in `policy-audit.2026-09-07T11-18.md`. Summary:

- `allowed-tools` contains no merge entry (only `Bash(gh issue view *)`). Confirmed by reading
  the frontmatter.
- `permissions.allow` has 62 entries and none contains `gh` or `merge`. Confirmed by parsing
  `.claude/settings.json` as JSON.
- The hook denies with `EPIC_MERGE_GATE_BLOCKED` and is wired as `PreToolUse` with matcher `Bash`.
  Confirmed by reading both the hook and the settings wiring — and demonstrated live when the
  hook denied one of this reviewer's own commands.
- The three-checkpoint-shape summary matches the hook implementation term for term.
- The shape-1 evasion really is PR-number-agnostic: `Test-ChildCheckpointAllowsEpicMerge` takes no
  PR-number parameter, unlike the epic and parallel accept paths. The Prohibited Shortcuts entry
  therefore names a real hole rather than a hypothetical one, which is what makes the prohibition
  worth stating.
- `strict_required_status_checks_policy: true` on `main`. Re-queried against the live API.

**Precision note (non-blocking, carried as O-1 in the policy audit).** Three passages say "the
command" or "the consolidation merge command" without qualification, but the hook's scope filter
requires the merge-commit flag to be present alongside the merge invocation; a squash- or
rebase-flavoured invocation would pass the hook. Since the ruleset permits all three merge
methods, the gate-based reason is narrower than the prose implies. The conclusion still holds
because the other two blockers are flag-independent. A future edit could qualify the phrase as
the merge-commit form. Not required by any acceptance criterion.

## Documentation Quality

| Aspect | Assessment |
|---|---|
| Placement | Correct. Each token lands in the section the spec designates, and the exclusivity requirements hold: the human-actor token appears **only** in step 5 (1 match), and the two checkpoint-field tokens appear **only** in `## Prohibited Shortcuts` (1 match each). |
| Internal consistency | No contradiction found. Reviewed all 27 occurrences of "merge" in the document. Line 35 ("running the destructive apply pass only after the consolidation PR has merged") and line 125 ("The now-merged `documentationandmemories` branch") remain consistent with a human-performed merge. No passage anywhere in the document implies the agent performs the merge. |
| Structure | Markdown structure intact; the ordered list renumbering is unaffected because the edit stays inside item 5. Both new bullets match the existing bullet style of their sections. |
| Reasoning density | The added prose states *why* at each point rather than only *what*. "This is why:" followed by three named mechanisms is more useful to a future reader than an unexplained prohibition would be. |
| Tone | Complies with `.claude/rules/tonality.md`. Declarative, evidence-matched, no hyperbole, no metaphor, no humor. |
| Spelling consistency | "honour" (line 264) is British spelling, but it matches existing usage elsewhere in `.claude/skills/` (`parallel-orchestrate/SKILL.md`, `parallel-plan/SKILL.md`, `.claude/lib/blast-radius/BlastRadiusGlob.psm1`). Consistent with the surrounding corpus; not a finding. |
| Line width | One line (111) at 98 characters against a document convention of <= 90. Cosmetic; carried as O-2. |

## Bundled-Payload Parity

**PASS, verified independently rather than accepted from the executor's report.**

```
sha256  4189bd77094e98f8e589dddf282e21508d2b9db64adde837606805d64eb4d716  (repo copy)
sha256  4189bd77094e98f8e589dddf282e21508d2b9db64adde837606805d64eb4d716  (bundled copy)
cmp     no difference
size    17707 bytes / 283 lines, both
```

The contract test
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
was executed by this reviewer and passed (`1 passed in 0.10s`).

Note for downstream consumers, not a defect in this change: a repo-side edit under
`.claude/` and its mirrored bundle copy do not alter what an installed extension serves until the
extension is rebuilt and reinstalled. This change is correct at the repository layer, which is
the layer it targets.

## Blast Radius

Minimal and well-bounded.

- No executable code path changed; no runtime behaviour changes for any script, hook, or test.
- No public API, contract, schema, or configuration key changed.
- No dependency added or version moved.
- The behavioural change is entirely in agent guidance: an agent running the cleanup skill will
  now stop at step 5 and hand off, rather than attempting a merge that would have been denied at
  three layers. This converts an undisclosed failure into a documented handoff, which is the
  stated intent in `issue.md` `## Expected Behavior`.
- Out-of-scope surfaces owned by sibling epic children (issue #545 and others) carry zero diff,
  confirmed by an empty `git diff` over `.claude/hooks`, `.claude/settings.json`, `scripts/bash`,
  and `tests/scripts/claude-hooks`. There is no merge-conflict surface with sibling children on
  the shared integration branch beyond the single skill document.

## Test Adequacy

The one automated gate that can meaningfully constrain this change — bundled-payload parity —
exists, is required, and passes. The remaining verification is necessarily assertion-based
(token presence and placement), and each acceptance criterion in `spec.md` specifies an
executable `rg` assertion with an explicit section-boundary condition rather than relying on
prose judgment. That is an appropriate design for a documentation change: the criteria are
mechanically checkable and this reviewer re-ran all of them.

The absence of a failing-test-first record is explained rather than skipped, in
`evidence/regression-testing/fail-before-exception.2026-09-07T11-02.md` under a
`WhyFailingRunImpossible` heading: the defect is an omission in prose, so no automated test could
have failed before the edit. The exception is documented at the canonical evidence location, which
is the correct handling.

## Recommendations

All are optional and none blocks merge.

1. **R-1 (minor, future edit).** Qualify the three unqualified references to "the command" as the
   merge-commit form, so the gate-based reason matches the hook's actual substring filter. See O-1.
2. **R-2 (cosmetic).** Rewrap line 111 to <= 90 characters to match the document convention.
3. **R-3 (housekeeping, for the epic).** The substring-match behaviour of
   `enforce-epic-merge-gate.ps1` observed in O-4 of the policy audit — a documentation write whose
   content merely quotes the matched tokens is denied — may be worth considering in issue #545's
   scope. Out of scope here; the hook carries zero diff in this feature.

## Verdict

**PASS.** The change delivers exactly the five specified edits, in the specified locations, with
factually accurate prose that this reviewer verified against primary sources rather than against
the executor's report. The high-risk element — the pre-existing git-native ancestry invariant —
is preserved intact. Bundled-payload byte-identity is confirmed by hash. No blocking findings.
