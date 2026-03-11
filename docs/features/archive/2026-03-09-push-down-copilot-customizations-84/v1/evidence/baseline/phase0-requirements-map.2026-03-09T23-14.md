Timestamp: 2026-03-09T23:22:00Z
Sources:
- docs/features/active/2026-03-09-push-down-copilot-customizations-84/issue.md
- docs/features/active/2026-03-09-push-down-copilot-customizations-84/user-story.md
- docs/features/active/2026-03-09-push-down-copilot-customizations-84/spec.md
- artifacts/research/20260309-push-down-copilot-customizations-implementation-research.md

Requirements Map:
- overwrite same-path files
  - issue.md: destination files at the same relative path must be overwritten.
  - user-story.md: push-down run overwrites same-path destination files.
  - spec.md: local source copy should overwrite existing destination files.
- rewrite supported script references
  - issue.md: rewrite repo-local script references to packaged extension references.
  - user-story.md: copied guidance should reference packaged extension commands.
  - spec.md: rewrite supported script references inside copied text files.
- placeholder command references
  - issue.md: uncovered script references should become placeholder extension commands.
  - user-story.md: copied guidance should reference explicit placeholders for uncovered scripts.
  - spec.md: replace uncovered references with canonical textual placeholder-command references.
- deterministic not-implemented error
  - issue.md: placeholders must fail with an explicit not-implemented error.
  - user-story.md: placeholders should surface a deterministic not-implemented message.
  - spec.md: placeholder error text must be stable enough for deterministic assertions.
- preserve current scripts/dev_tools/agentic_sync.py two-way sync behavior
  - issue.md: preserve existing bidirectional sync behavior.
  - user-story.md: leave the current bidirectional contract unchanged unless only tiny shared helpers are extracted.
  - spec.md: add a new one-way entry point instead of overloading the existing sync contract.
- unmatched references left unchanged and reported
  - issue.md: unknown references should not be guessed and should be reported.
  - user-story.md: file content remains unchanged and the run summary reports unmatched references.
  - spec.md: leave unknown references unchanged and report them in the run summary.
