# Mode and requirements-source integrity (remediation cycle 1)

Timestamp: 2026-08-30T00-45

Task: [P0-T2]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Command (plan text is worktree-relative; executed under the absolute prefix `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5/`):

```
grep -n "Work Mode" docs/features/active/2026-08-29-batch-budget-state-portability-596/issue.md
ls -la docs/features/active/2026-08-29-batch-budget-state-portability-596/spec.md
ls docs/features/active/2026-08-29-batch-budget-state-portability-596/user-story.md
pwsh -NoProfile -Command "Import-Module ./.claude/lib/requirements/GeneratedDocumentCounters.psm1 -Force; $doc = Get-Content -LiteralPath 'docs/features/active/2026-08-29-batch-budget-state-portability-596/spec.md' -Raw; 'total={0}' -f (Get-NamedSectionCheckboxCount -Document $doc -Heading 'Acceptance Criteria')"
```

EXIT_CODE: 0

## Findings

### Work Mode marker

`docs/features/active/2026-08-29-batch-budget-state-portability-596/issue.md` line 12 carries the marker verbatim:

```
- Work Mode: full-bug
```

Under `atomic-plan-contract` and `acceptance-criteria-tracking`, `full-bug` resolves the acceptance-criteria source to `spec.md` only. `user-story.md` is optional and absent by default in this mode.

### `spec.md` presence and Acceptance Criteria section

`docs/features/active/2026-08-29-batch-budget-state-portability-596/spec.md` exists (56334 bytes). It carries an explicit `## Acceptance Criteria` heading.

Checkbox counts are section-scoped, produced by `.claude/lib/requirements/GeneratedDocumentCounters.psm1::Get-NamedSectionCheckboxCount` with the named section `Acceptance Criteria`. The section-scoped count is required rather than a whole-file `- [ ]` count, because `spec.md` carries checkbox blocks outside the Acceptance Criteria section that a whole-file count would fold in.

- Total checkbox items in the `## Acceptance Criteria` section: **17**
- Checked (`- [x]`): **16**
- Unchecked (`- [ ]`): **1**

This matches the value the plan states for [P0-T2].

The single unchecked item is at `spec.md:773-779`:

```
- [ ] `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and
      `mcp__drm-copilot__run_poshqc_test` all pass in a single consecutive run with no file
      modifications, and the Pester line coverage for
      `.claude/hooks/enforce-powershell-batch-budget.ps1`,
      `.claude/hooks/enforce-python-batch-budget.ps1`, and `.claude/hooks/persist-session-id.ps1` is
      >= 85% for each file, compared against the pre-change baseline stored under
      `docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/baseline/`.
```

### `user-story.md` absence

`docs/features/active/2026-08-29-batch-budget-state-portability-596/user-story.md` does not exist. `ls` reported `No such file or directory`. This is the expected state for `full-bug`, and the plan prohibits creating it.

### Acceptance-criteria checkbox state in this remediation

**This remediation changes no `## Acceptance Criteria` checkbox state in `spec.md`.** The plan's scope section fixes this: findings B-1 and B-2 are conformance defects against criteria already recorded and already checked, and B-3 closes a `## Test Strategy` edge case that carries no acceptance criterion. The one unchecked criterion at `spec.md:773-779` requires a consecutively clean unscoped PoshQC run, which the plan states is unsatisfiable in this worktree for two independently verified pre-existing reasons unrelated to this remediation, so it remains unchecked at the end of this cycle as well.

## Output Summary

Mode marker `- Work Mode: full-bug` present at `issue.md:12`. `spec.md` present with a `## Acceptance Criteria` section carrying 17 checkbox items, 16 checked and 1 unchecked. `user-story.md` absent, as required for `full-bug`. No acceptance-criteria checkbox changes state in this remediation cycle. All four acceptance conditions for [P0-T2] hold.
