# Remediation Inputs — prd-feature gate target resolution (Issue #672)

- Timestamp: 2026-09-17T12-29
- Feature folder: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672`
- Work mode: `full-bug`; acceptance-criteria source is `spec.md` only
- Head reviewed: `03dfdc84fa7fd6107545d4b52f34247961d306f5`
- Base: `epic/worktree-scoped-state-resolution-integration` @ `d039e89b2b2569151e9170e1bbefb9f974419f87`

Source artifacts:

- `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/policy-audit.2026-09-17T12-29.md`
- `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/code-review.2026-09-17T12-29.md`
- `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/feature-audit.2026-09-17T12-29.md`

Blocking findings: 1. Non-blocking findings requiring action: 3.

## R1 (Blocking) — the repo-relative citation path is unchanged by the fix

**Affected acceptance criteria:** 6 (PARTIAL), 10 (PARTIAL).

**Files:** `.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 219-223, 242-245, 365-370; and the
bundled mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`.

**Condition.** `Get-PrdFeatureCallTarget` returns `$null` unless the combined prompt and description text
matches the absolutely-placed-token pattern at line 243. For a repo-relative citation the hook therefore
derives no target, keeps the bare repo-relative probe path, and resolves it against the process working
directory exactly as the pre-change hook did. The folder-absent guard at line 368 is conditioned on
`$probeFolder -ne $folderNormalized`, so it cannot fire on that path either.

**Observed behaviour (review diagnostic D2, executed against the delivered hook).**

- Input: envelope `cwd` set to a coordinating session root; `tool_input.prompt` =
  `Plan the work in docs/features/active/2026-09-13-synthetic-target-672 now.`; `Get-PrdFeatureIssueContent`
  mocked to answer only for the path composed under the item worktree.
- Output: `deny`, with reason
  `PRD_FEATURE_BLOCKED: resolved feature folder 'docs/features/active/2026-09-13-synthetic-target-672', but its work mode could not be determined from 'docs/features/active/2026-09-13-synthetic-target-672/issue.md' (the '- Work Mode:' marker is absent, unreadable, or unrecognized). Confirm that is the intended feature folder, then add or correct the '- Work Mode:' marker in that file so the prerequisite set can be derived.`

That reason string is identical to the pre-change behaviour recorded in the branch's own
`evidence/regression-testing/fail-before.2026-09-17T11-20.md`, final section.

**Secondary observation (review diagnostic D3).** Adding a branch signal (`branch: feature/2026-09-13-x-672`)
to the same repo-relative prompt produces the identical deny, because the pre-filter runs before
`Resolve-WorktreeCallTarget` and therefore suppresses F1's `Branch` and relative `FilePath` signals.

**Secondary observation (review diagnostic D5).** With the same repo-relative prompt and a feature folder
present under the session root, the gate returns `allow`, even though the prompt names another worktree in
prose. This is unchanged from the pre-change hook and is not covered by any acceptance criterion, but it is
the false-approval mode the spec names as risk R1, and the ambiguity guard that would catch it is armed
only when an absolutely-placed token is present.

**Why this is blocking.** It is the first row of the verified decision matrix in `issue.md`
(`names its own feature folder | orchestrator session root | DENY`) and the shape the originating run
`bugs-2026-09-11` item 839 actually used. `issue.md` also records the anti-pattern ruling that prompt
construction must not be changed, so the repo-relative form cannot be designed away by requiring callers to
emit absolute paths. Acceptance criterion 6 exists specifically to stop the gate prescribing a remedy that
would edit the wrong repository's `issue.md`, and that remedy is still prescribed on this path.

**Remediation options (choose one and record the choice).**

*Option A — widen the derivation.* Delete the absolutely-placed-token pre-filter at lines 242-245 and hand
the call text to `Resolve-WorktreeCallTarget` unconditionally, letting F1 return `NoTarget` for a call it
cannot place and `Ambiguous` for a signal that places in several worktrees. This restores F1's `Branch` and
`FilePath` signals, which are the only channels that can place a repo-relative call. Verify that the
existing `allows when the modelled cwd is the item worktree` row and the `preserved gate behavior` `Context`
still pass, since they depend on the no-target path.

*Option B — narrow the reason, keep the derivation.* Keep the pre-filter, but change the folder-absent
handling so that a resolved folder whose `issue.md` cannot be read emits the ambiguity reason code rather
than the marker-is-broken reason whenever the folder itself is absent, regardless of whether a target root
was composed. This repairs the misleading remedy without changing which calls are allowed. It does not
repair the false denial, so criterion 10 would still need re-wording.

*Option C — declare the repo-relative form out of scope.* If the epic's position is that only absolute
citations are supported, amend `spec.md` to say so explicitly in `## Scope & Non-Goals`, re-word criteria 6
and 10 to name the absolute form, and add the same statement to the hook's `.DESCRIPTION`. This closes the
audit gap by contract rather than by code, and it must be an explicit decision rather than an implicit one.

**Required regression rows, whichever option is chosen.** Add to
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`:

1. A repo-relative citation with the modelled session root distinct from the target and the document present
   only under the target root. Assert the chosen outcome explicitly.
2. A repo-relative citation with the modelled session root distinct from the target and the folder absent
   from both. Assert the reason is not like `*work mode could not be determined*`.
3. A repo-relative citation carrying a branch signal, asserting whether `Resolve-WorktreeCallTarget` is
   invoked, with `Should -Invoke ... -Exactly`.

Both bundled mirrors must be re-synchronised after any hook edit, and SHA-256 equality re-verified.

## R2 (Non-blocking, Major) — stale comment-based help on the parent hook

**Affected acceptance criteria:** none directly; policy: `.claude/rules/general-code-change.md`.

**File:** `.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 14-34, and the bundled mirror.

The `.DESCRIPTION` resolution-order block still documents behaviour this change set removed. Step 2 states
"otherwise the earliest-occurring candidate in the prompt wins" — the positional tie-break that criterion 5
removed. Step 3 states "If no candidate was found in the prompt, read the feature-folder field from
artifacts/orchestration/orchestrator-state.json" with no qualification — the unconditional fallback that
criterion 4 removed. Neither the derived-target disambiguator nor the ambiguity branch is described at all.

**Remediation.** Rewrite steps 2 and 3 to match the delivered branch order, add a step for the ambiguity
deny, and state the condition under which the checkpoint may still stand in. Re-mirror and re-verify hash
equality. No test change is required, but re-run `Invoke-Formatter` and `Invoke-ScriptAnalyzer` afterwards.

## R3 (Non-blocking, Major) — derivation policy living in the hook narrows the F1 contract

**Affected acceptance criteria:** 24 (PASS on its literal terms; the finding concerns its intent).

**File:** `.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 219-223 and 242-245.

The absolutely-placed-token predicate is a local decision about which calls are eligible for derivation.
`spec.md` non-goal 2 places target derivation in the F1 module and forbids local re-implementation. The
predicate does not duplicate F1's derivation algorithm, so the criterion's literal terms hold, but it does
duplicate the decision about derivation's input contract, and it is invisible to F1's own suites.

**Remediation.** Fold the eligibility decision into `Resolve-WorktreeCallTarget` (or into a new exported F1
predicate) so a single owner decides what counts as a placeable signal, and cover it in F1's suites. If R1
Option A is taken, this finding is resolved by the same edit.

## R4 (Non-blocking, Minor) — two documentation statements that no longer match the code

1. `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` lines 12-13 state the file "declares no
   file-scope parameter block, no requires directive, and no entrypoint. It is loaded for its declarations
   only." The file executes one file-scope statement, the unguarded `Import-Module` at line 21. Amend the
   sentence to name that statement and its fail-closed rationale. The import itself is correct; only the
   description is not.

2. `spec.md` criterion at line 655 states the new suite "derives no absolute path from the environment, the
   current directory, the script file location, or a source-control query". The suite necessarily derives
   the paths of the files under test from `$PSScriptRoot` at lines 99, 100, 109, and 110. Narrow the wording
   to the synthetic or modelled paths, which is the intent stated in the criterion's own following sentence.
   The delivered suite satisfies that intent fully.

## Not remediation for this branch — recorded so it is not re-diagnosed

**The two repository-wide Pester failures are pre-existing and environment-coupled.** They must not be
treated as a regression of this branch and must not be remediated inside it.

- `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
  fails because `Test-EpicBaseBranchOverride` (check 6 in `.claude/hooks/enforce-pr-author-skill-helpers.ps1`)
  calls `Get-PrAuthorCheckpointContent`, which the test's `BeforeEach` does not mock, so it reads the real
  `artifacts/orchestration/orchestrator-state.json`. That checkpoint carries `epic_mode`, and the test's
  payload carries no `--base`, so the decision is `deny` with `EPIC_BASE_BRANCH_MISMATCH`. The sibling
  `gh pr edit` case in the same `Context` passes because check 6 applies to `gh pr create` only.
- `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`
  fails because `enforce-epic-wave-barrier.ps1` denies with
  `EPIC_WAVE_BARRIER_BLOCKED: '672' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint`,
  which is ambient epic-checkpoint state.

Neither failing suite, nor `.claude/hooks/enforce-pr-author-skill.ps1`, nor
`.claude/hooks/enforce-epic-wave-barrier.ps1`, nor any `.codex/` path appears in the 50-file branch diff.
Failure 1 reproduces when its suite is run alone, with none of this feature's suites loaded.

**Suggested follow-up outside this branch.** File a separate issue against the two suites for the shared
defect: both reach live orchestration state through a seam their own `BeforeEach` leaves unmocked, so their
result depends on the worktree they run in. The fix is to mock `Get-PrAuthorCheckpointContent` in the
`allowed commands` `Context` of `enforce-pr-author-skill.Tests.ps1`, and to supply a synthetic epic
checkpoint to the Codex integration suite rather than letting it read the ambient one.

## Acceptance-criteria check-off action requested

- Criterion 37 is correctly unchecked. Leave it unchecked until the two suites above are repaired, or until
  the criterion is re-worded to compare the observed failure set against the recorded baseline pair rather
  than requiring an absolute zero.
- Criteria 6 and 10 are currently checked. If R1 Option A or Option B is taken, revert both to `- [ ]`
  before re-delivery and re-check them only after the new regression rows pass. If Option C is taken, amend
  their wording and leave them checked.

## Gate for accepting remediation

1. `Invoke-Formatter` reports zero drift and `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`
   reports zero findings for every changed `.ps1` file, repository copy and bundled mirror alike.
2. The three prd-feature suites pass with zero failures, and the new regression rows listed under R1 are
   present and passing.
3. `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` still passes unedited, and the 17-suite
   must-not-regress batch (`enforce-orchestration-preimplementation-gate*` and `enforce-epic-merge-gate*`,
   Claude and Codex) still reports 556 of 556.
4. SHA-256 equality holds for both repository-to-bundle hook pairs.
5. Per-file line coverage stays at or above 85 percent for both delivered production files, read from
   `artifacts/pester/powershell-coverage.xml`. No branch figure is required; Pester does not measure branch
   coverage.
6. The repository-wide JUnit failure set is exactly the two nodes named above, and `errors` is 0. A third
   failing node is a genuine regression of the remediation.
7. `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exits 0.
