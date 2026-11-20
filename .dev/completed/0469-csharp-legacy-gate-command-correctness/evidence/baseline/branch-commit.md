# Baseline — Working-Context Binding (Issue #469)

Timestamp: 2026-08-13T17-28

Command:
```
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
sed -n '12p' docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/issue.md
ls docs/features/active/2026-08-13-csharp-legacy-gate-command-correctness-469/
```

EXIT_CODE: 0

Output Summary:
- Branch: `bug/csharp-legacy-gate-command-correctness-469`
- Baseline HEAD SHA: `fe0413d4aca1e76b2d02d05701fba79a887d5405`
- `issue.md` line 12 reads exactly `- Work Mode: full-bug` (confirmed).
- `spec.md` is present in the feature folder and is the sole acceptance-criteria source for `full-bug` mode.
- `user-story.md` is absent. Feature-folder contents are `evidence/`, `issue.md`, `plan.2026-08-13T16-26.md`, `research/`, `spec.md`. The absence of `user-story.md` is expected for `full-bug` mode and is not a blocker.
