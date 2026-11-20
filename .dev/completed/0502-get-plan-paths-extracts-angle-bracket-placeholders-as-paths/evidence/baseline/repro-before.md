# Baseline — Defect Reproduction, Both Runtimes — [P0-T16]

Timestamp: 2026-08-23T01-18

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T16]
State captured: PRE-CHANGE baseline

Commands:

- Python: `poetry run python <repro script>` — derives two radii from structured plan text and
  evaluates the conflict relation.
- PowerShell: `pwsh -NoProfile -File <repro script>` — the same construction through
  `Get-BlastRadius` and `Test-BlastRadiusConflict`.

EXIT_CODE: 0 for both.

## Construction

Two plan documents are built whose **only shared inline-code token is a placeholder
feature-document token**. Their real file citations are disjoint (`alpha_only_module.py` versus
`beta_only_module.py`) and their feature folders differ, so no other overlap is possible at any of
the four conflict levels.

The shared token is the feature spec document shape, built by concatenating the angle-bracketed
segment with the `/spec.md` tail so that no placeholder shape appears as a literal in either
script's source in a form a shell or PowerShell parser could expand. The PowerShell script asserts
the token survived string construction before any classification runs.

The negative control is the identical pair with the placeholder citation removed and nothing else
changed.

## Python runtime

```text
placeholder token under test: <FEATURE>/spec.md
--- PLACEHOLDER-ONLY OVERLAP ---
  a.paths: ['<FEATURE>/spec.md', 'docs/features/active/2026-08-23-alpha-item-9001/**', 'scripts/dev_tools/alpha_only_module.py']
  b.paths: ['<FEATURE>/spec.md', 'docs/features/active/2026-08-23-beta-item-9002/**', 'scripts/dev_tools/beta_only_module.py']
  conflict: True
    reason kind=path_overlap detail=<FEATURE>/spec.md ~ <FEATURE>/spec.md
--- NEGATIVE CONTROL (placeholder removed) ---
  a.paths: ['docs/features/active/2026-08-23-alpha-item-9001/**', 'scripts/dev_tools/alpha_only_module.py']
  b.paths: ['docs/features/active/2026-08-23-beta-item-9002/**', 'scripts/dev_tools/beta_only_module.py']
  conflict: False
```

| Case | Conflict verdict | Reason |
| --- | --- | --- |
| placeholder-only overlap | **true** | `path_overlap` on the placeholder token |
| negative control | **false** | none |

## PowerShell runtime

```text
placeholder token under test: <FEATURE>/spec.md
--- PLACEHOLDER-ONLY OVERLAP ---
  a.paths: <FEATURE>/spec.md | docs/features/active/2026-08-23-alpha-item-9001/** | scripts/dev_tools/alpha_only_module.py
  b.paths: <FEATURE>/spec.md | docs/features/active/2026-08-23-beta-item-9002/** | scripts/dev_tools/beta_only_module.py
  conflict: True
    reason kind=path_overlap detail=<FEATURE>/spec.md ~ <FEATURE>/spec.md
--- NEGATIVE CONTROL (placeholder removed) ---
  a.paths: docs/features/active/2026-08-23-alpha-item-9001/** | scripts/dev_tools/alpha_only_module.py
  b.paths: docs/features/active/2026-08-23-beta-item-9002/** | scripts/dev_tools/beta_only_module.py
  conflict: False
```

| Case | Conflict verdict | Reason |
| --- | --- | --- |
| placeholder-only overlap | **true** | `path_overlap` on the placeholder token |
| negative control | **false** | none |

## Cross-runtime parity

Both runtimes produce identical path lists, identical conflict verdicts, and an identical
`path_overlap` reason detail. The defect is therefore a shared-classifier defect and not a
runtime-specific one, which is why the fix requires the same guard in both classifiers.

## Note on the PowerShell probe construction

The first attempt at the PowerShell script produced a truncated `a.paths` list because a
single-quoted continuation fragment contained two literal backticks where one was intended,
unbalancing the inline-code spans and hiding the real-file citation. The fragment was corrected to
a single backtick and the run repeated, after which the two runtimes agree exactly. The incident is
recorded because it is an instance of the same class of defect the plan's single-quote design
constraint guards against: a probe whose literal content differs from what the author wrote
measures a different thing than intended.

## Output Summary

The defect reproduces in both runtimes. Two radii whose only shared entry is a placeholder
feature-document token report **conflict true** with a `path_overlap` reason naming that token, in
both Python and PowerShell. The negative control with the placeholder removed reports **conflict
false** in both runtimes. The reproduction is exact across runtimes.
