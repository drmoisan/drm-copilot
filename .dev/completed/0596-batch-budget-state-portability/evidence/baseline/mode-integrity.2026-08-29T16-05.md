# [P0-T4] Work-mode integrity check

Timestamp: 2026-08-29T20-33

Command: `Read` of `issue.md` lines 1-20; `Grep` for `^## Acceptance Criteria` in `spec.md`;
`pwsh -NoProfile -Command "$lines = Get-Content -LiteralPath 'docs/features/active/2026-08-29-batch-budget-state-portability-596/spec.md'; $sel = $lines[679..779] | Where-Object { $_ -match '^- \[ \] ' }; 'checkbox_count=' + $sel.Count"`;
`cd docs/features/active/2026-08-29-batch-budget-state-portability-596 && ls -1 && test -e user-story.md && echo "EXISTS" || echo "ABSENT"`

EXIT_CODE: 0

Output Summary: All three mode-integrity conditions hold. The work-mode marker is `full-bug` on
line 12 of `issue.md`; `spec.md` carries a `## Acceptance Criteria` section at line 680 with exactly
17 unchecked checkbox items; and `user-story.md` does not exist in the feature folder.

## 1. Work-mode marker

`docs/features/active/2026-08-29-batch-budget-state-portability-596/issue.md` line 12 reads verbatim:

```
- Work Mode: full-bug
```

Under `atomic-plan-contract` mode-source precedence this resolves to `full-bug`, for which `spec.md`
is the sole acceptance-criteria source and `user-story.md` is absent by default.

## 2. Acceptance-criteria section in spec.md

`## Acceptance Criteria` is the heading at `spec.md:680`. It is the only match for that heading in
the file. The checkbox count over the section body (file lines 680 through 780, i.e. up to the next
heading `## Risks & Mitigations` at line 781) is:

```
checkbox_count=17
```

The 17 criteria are at spec.md source lines 688, 693, 695, 701, 704, 711, 721, 725, 732, 738, 741,
745, 747, 753, 759, 771, and 773. That set matches the phase-to-acceptance-criteria map in the plan
exactly.

All 17 are currently `- [ ]` (unchecked), which is the expected pre-implementation state.

## 3. user-story.md absence

Feature-folder listing:

```
evidence/
issue.md
plan.2026-08-29T16-05.md
research/
spec.md
```

Existence test for `user-story.md`:

```
ABSENT
```

`docs/features/active/2026-08-29-batch-budget-state-portability-596/user-story.md` does not exist,
which is correct for `full-bug` mode. It must not be created.
