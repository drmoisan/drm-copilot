# Follow-up candidates (issue #732)

Timestamp: 2026-10-09T05-00
Task: [P8-T1]
Source: `spec.md`, section `### Unfiled follow-up candidates`

| ID | Candidate | Source | Status |
| --- | --- | --- | --- |
| FU-1 | Path-leg `..` gap: `Test-FeatureDocumentationOrEvidencePath` (`-cmatch '(^|/)docs/features/active/'`) admits a Write/Edit `file_path` or Codex `apply_patch` marker such as `docs/features/active/../../src/x.ps1` as non-implementation on both gates. | Research Q2 scope note, Risk 5, Open Question 3 | Status: recorded, not filed (no GitHub issue created in this run) |
| FU-2 | `cmd.exe` divergence: `cmd.exe` does not treat `'` as a quote and interprets `%VAR%` and `^`; a single-quoted message containing a path can become a pathspec. | Research Q1, Risk 3, Open Question 2 | Status: recorded, not filed (no GitHub issue created in this run) |
| FU-3 | Other prefix-match idiom sites: `Test-OrchestrationReady`, `.codex/hooks/enforce-epic-planning-only.ps1`, `enforce-completion-helpers.ps1`, `validate-task-researcher-output.ps1`, `enforce-feature-folder-order.ps1`, and the `docs/features/epics/` checkpoint-field checks. | Research Q2 scope-note table | Status: recorded, not filed (no GitHub issue created in this run) |
| FU-4 | Codex `workdir`: request upstream payload support for `workdir` (and the selected shell), or add a Codex strict mode in epic scope that denies an implementation-classified git segment without an absolute `-C`. | Research Q3, Open Question 1, D4 | Status: recorded, not filed (no GitHub issue created in this run) |
| FU-5 | Single-feature `Resolve-OrchestrationGateTarget` still resolves only the first selector. | Research Open Question 6 | Status: recorded, not filed (no GitHub issue created in this run) |
| FU-6 | UNC (`\\server\share\...`) and extended-length (`\\?\C:\...`) `file_path` spellings are treated as relative and contribute the session root in epic scope; candidate fix is to deny them as `target-unresolvable`. Behavior is unchanged from the base. | S6 code review CR-1 (`code-review.2026-10-09T05-42.md`), feature audit G-A | Status: recorded, not filed (no GitHub issue created in this run) |
| FU-7 | The `GIT_DIR`-style fail-closed check matches the text anywhere in a segment, so a file name or commit message mentioning it is denied in epic scope (over-broad deny, no bypass). | S6 code review CR-2 (`code-review.2026-10-09T05-42.md`) | Status: recorded, not filed (no GitHub issue created in this run) |

Output Summary: Five follow-up candidates FU-1 to FU-5 recorded from the spec table; FU-6 and FU-7 added at S6 (2026-10-09T05-55) from Non-blocking review findings; none filed as a GitHub issue in this run.
