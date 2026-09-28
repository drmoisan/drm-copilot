# Remediation Inputs — Issue #673 Feature Review

Timestamp: 2026-09-19T19-56
Produced by: feature-review
Branch: `bug/false-approval-elimination-673`; base `main` at merge base `b7c11616`; head `4b45ca7f`

## Gate Status

**No finding is merge-blocking.** Blocking findings: **0**. All three review verdicts are PASS:

| Artifact | Verdict |
| --- | --- |
| `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/policy-audit.2026-09-19T19-56.md` | PASS |
| `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/code-review.2026-09-19T19-56.md` | PASS |
| `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/feature-audit.2026-09-19T19-56.md` | PASS |

This artifact exists because two Important findings warrant remediation, not because any gate failed.
The orchestrator may proceed to PR authoring and dispose of these items as follow-ups.

## Remediation-Required Findings

### R-1 (from I-1) — Important. Propagate the delegation-identity contract to the two other surfaces that issue receipt-gated delegations

**What is wrong.** The model-routing gate now denies any delegation to one of six receipt-gated
subagent types whose prompt carries neither a canonical issue-number line nor a branch signal. The
prompt contract that satisfies it is stated only in `.claude/skills/orchestrate/SKILL.md` under
`## Issue Number Consistency`. Two other surfaces issue delegations to a gated type without stating
it:

- `.claude/skills/cleanup-merged-worktrees/SKILL.md`, step 4, which delegates PR creation to the
  `pr-author` agent and explicitly contemplates a run with no GitHub issue number.
- `.claude/skills/epic-orchestrate/SKILL.md`, the paragraph near line 166 describing the coordinator
  spawning the `pr-author` agent. Its new checkpoint-hygiene paragraph describes the resolution
  mechanism but does not state the requirement on the prompt as a contract line.

**Impact.** Those two flows can be denied until their prompts are amended. The failure is fail-closed
and self-describing: the deny reason names exactly the two lines to add. No false approval is
possible.

**Required change.** Add one sentence to each of the two skill documents requiring the canonical
issue-number line where an issue number exists, and a branch label naming the item's branch in every
case, cross-referencing `## Issue Number Consistency` in the orchestrate skill rather than restating
it. Do not restate the gated-agent list in either document; the orchestrate skill owns it and a test
already couples that list to the gate.

**Suggested verification.** Extend the existing drift-coupled row in
`tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` — the one that reads
`Get-ModelRoutingGatedAgent` from the dot-sourced gate — so that any skill document containing an
agent-invocation reference to a gated type must also state the identity requirement or reference the
owning section. That converts a documentation obligation into an enforced one and prevents the same
gap recurring when a seventh gated type is added.

**Scope estimate.** Two documentation files, one test file. No production code.

### R-2 (from I-2) — Important. Scope the planned coverage follow-up to the arms this change re-pointed

**What is wrong.** The follow-up already being filed for direct coverage of
`Get-PrdFeatureCheckpointFolder` should be scoped to the specific code paths this change altered,
rather than to raising a whole-file ratio. Recomputed from `artifacts/pester/powershell-coverage.xml`:

- `.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 173, 174, 177, 180, 181, 183 are
  uncovered. These are the read, parse, parse-failure and field-extraction arms of
  `Get-PrdFeatureCheckpointFolder`. Its absent-file early return at line 168 **is** covered. This is
  the function whose `-CheckpointPath` parameter this change made mandatory and whose input this
  change changed from a process-relative literal to an absolute resolved path.
- `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` lines 132 and 144 are uncovered,
  inside `ConvertTo-PrdFeatureFolderToken` — the function `Select-PrdFeatureFolderByCheckpoint` now
  calls with the checkpoint value rather than with a target's signal value.

In **both** regressed files the uncovered lines sit on code paths this change re-pointed. That is why
the follow-up is a genuine verification gap rather than cosmetic ratio repair.

**Required change.** Drive `Get-PrdFeatureCheckpointFolder` directly against the three committed
fixture checkpoints that already exist for exactly these shapes — valid JSON carrying the
feature-folder field, invalid JSON, and valid JSON without the field — and call
`ConvertTo-PrdFeatureFolderToken` directly for its two uncovered arms. While adding those rows,
consider adding the payload-shape guard the function lacks (see A-7 below): the new library module
guards its parsed payload against a non-object shape before reading a property and this function does
not, which is safe today only because no hook file sets strict mode.

**Placement constraint, important.** Do **not** add rows to
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`,
`.FolderResolution.Tests.ps1`, or `.IdentityResolution.Tests.ps1`. The first two are pinned to an
exact changed-line and touched-region set by acceptance conditions already recorded as met, and the
third states, and a task verifies, that it derives no path from the script file location — which
reaching a committed fixture requires. A new suite is the right home. The executor's coverage-delta
artifact reaches the same conclusion and estimates the gate file at roughly 96.8% afterwards, which
clears its baseline.

**Scope estimate.** One new test file, optionally one production guard line. No behavioural change.

## Advisory Findings — No Remediation Required

Recorded for disposition, not for action before merge. Full statements are in
`code-review.2026-09-19T19-56.md`.

| ID | Statement | Suggested disposition |
| --- | --- | --- |
| A-1 | The consumed branch-signal pattern, defined in `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` at line 61 and read by the function at lines 164-185 of that file, accepts a short-word-plus-colon label anywhere in free text and takes the first match, so a prose phrase naming a base branch is a valid match. This change promotes that pattern to a primary worktree selector on two gates that read prose prompts. Mitigated twice: the orchestrate contract requires the item's label to be the first such occurrence, and a branch-versus-issue disagreement denies with the ambiguity code. Residual exposure is a prompt carrying a false branch signal earlier than the intended label and carrying no issue number. | Follow-up issue against the owning module: require line-start or list-item position for the label form, and add a row asserting a prose base-branch mention is not read as a signal. |
| A-2 | The prd gate's document probe stays process-directory-relative for a session-root target, so a hook process whose directory is a subdirectory of the item worktree resolves session-root and then probes relative to the subdirectory. Spec-sanctioned at resolution step 7; pre-existing; fails toward a false denial, never a false approval; the checkpoint read is unaffected. | Optional: join the probe to the resolved root unconditionally, which is a no-op in the session-root case now that the resolved root is always populated for both resolved states. |
| A-3 | `$script:OrchestratorStateCheckpointPath` moved from a script-scope constant to script-scope state assigned in `Get-PrAuthorBypassReason` at helpers line 338 and read at line 353, where the local `$resolution.CheckpointPath` was already in scope. `.claude/rules/powershell.md` asks to pass data explicitly. No defect follows: both blocks are guarded by the identical condition. | Optional tidy-up. Keep the null initialisation at `.claude/hooks/enforce-pr-author-skill.ps1` line 51 — AC-4 requires that form. |
| A-4 | The in-scope file list at `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` lines 120-126 names five files; `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` is absent. The file is currently clean, but a reintroduced checkpoint literal there would not be caught. | One-line addition, which the file's own comment anticipates. Pair with R-2 if convenient. |
| A-5 | Three #672 criteria have token-level or signature-level wording that delivered files now contradict while the criteria remain checked: the test-hygiene criterion's ban on deriving an absolute path from the script file location (the target-resolution suite derives four, at lines 99, 100, 109 and 110, to locate its subject); the seam-signature criterion (one seam's parameter became mandatory); and the library-consumption criterion's token list (the gate now contains one `Get-Location`, at line 253, inside the resolution seam, where it had none at the merge base). In all three cases #673's AC-37 authorises the delivered form and the supporting evidence artifact is explicit about the narrowed reading. | Amend the three criteria in the #672 spec so each forbids the behaviour rather than the token: no absolute path for use as a synthetic root or probe target; no worktree *discovery* in the gate or its sibling; seam *names* and payload shapes unchanged. |
| A-6 | AC-9, AC-10, AC-13, AC-14 and AC-17 say "the ambiguity reason code" where the delivered rows assert the no-target code. The spec's restated-conditions table reconciles every instance, but the AC preamble promises each criterion is checkable without re-deriving the document's reasoning. | Amend the five criteria in place to name the code each row asserts, keeping the restated-conditions entries as the record of why the wording moved. |
| A-7 | `Get-WorktreeItemCheckpointText` (new module lines 146-148) and `Get-WorktreeItemCheckpointIssue` (lines 168-176) return `$null` for both an absent and an unreadable-or-unparseable checkpoint, without a distinguishing diagnostic. Fail-closed, so no failure becomes an allow; the cost is that an operator sees a detail clause saying the issue is recorded in no live worktree when the real cause may be a permission error or a partial write. | Distinguish the unreadable case in the detail clause. Fold the related payload-shape guard note into R-2. |
| A-8 | Two redundancies: a dead conjunct testing `$null -ne $target` in the prd gate's probe-anchoring guard, unreachable because the earlier unresolved-identity block already returned; and `Find-WorktreeResolutionRoot` called twice on the same session path per resolved call, already deferred behind an equality test. | No action. Recorded for completeness. |

## Coverage Remediation Triggers

**None.** PowerShell coverage is PASS against every applicable threshold, recomputed from
`artifacts/pester/powershell-coverage.xml` by this reviewer: repo-wide 95.77%; every in-scope file at
or above 90.32%; changed-line coverage 100% on all six hooks and 99.06% on the new module; no branch
threshold applicable to PowerShell. Python is PASS with no production Python file changed on the
branch; the literal-rule note about the absent Python coverage artifact is recorded in
`policy-audit.2026-09-19T19-56.md` under section 1.2 and is not a remediation trigger,
because the Python coverage denominator is provably unchanged and the one changed test-support file
was verified directly by recomputing both of its pinned digests and re-executing the four suites that
consume it. TypeScript and C# have zero changed files.

## Evidence Location Remediation Triggers

**None.** `scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no output, and the
147-path branch diff contains zero files under `artifacts/baselines/`, `artifacts/qa/`,
`artifacts/evidence/`, or `artifacts/coverage/`.

## Artifact Paths

- `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/policy-audit.2026-09-19T19-56.md`
- `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/code-review.2026-09-19T19-56.md`
- `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/feature-audit.2026-09-19T19-56.md`
- `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/remediation-inputs.2026-09-19T19-56.md`
