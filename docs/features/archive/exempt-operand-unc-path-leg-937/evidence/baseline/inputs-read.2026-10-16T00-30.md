# Inputs Read (issue #937)

Timestamp: 2026-10-16T00-30
Task: P0-T2

Files Read:

1. `docs/features/active/exempt-operand-unc-path-leg-937/issue.md`
2. `docs/features/active/exempt-operand-unc-path-leg-937/spec.md`
3. `docs/features/active/exempt-operand-unc-path-leg-937/research/research.2026-10-15T17-46.md`
4. `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/code-review.2026-10-09T05-42.md` (located by Glob `docs/features/**/*732*/code-review.*.md`; one hit, under `docs/features/active/`)

CR-1 finding line (line 24 of the #732 code review), quoted verbatim:

> | Medium (Non-blocking) | `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (all 4 copies) | `$script:OrchestrationTargetAbsolutePattern` (line 31); path-leg loop in `Get-OrchestrationCommandTarget` (line 201) | **CR-1.** A path-leg input spelled as UNC (`\\server\share\...`) or extended-length (`\\?\C:\...`) normalizes to `//...`, fails the absolute pattern `^([A-Za-z]:/|/(?!/))`, and is treated as relative, so it contributes the session root instead of its own target. FR-3 rule 1 states that an absolute `file_path` contributes its own path; plan rule R1 narrowed "absolute" to the R0 pattern. In an epic-scope session whose root is ready, a Write into another, not-ready epic worktree spelled this way is evaluated against the session root. | Treat a path-leg input that begins with `//` as unresolved (for example rule token `path-not-absolute`, reason code `target-unresolvable`) rather than as relative, and add one row per spelling to the targets suite and to `EpicScopeTargets.Tests.ps1`. If deferred, record it as a follow-up candidate (FU-6) next to FU-1. | Fail-closed is the stated norm for an unresolvable target (spec D3). The current behavior equals the pre-change behavior for every path leg, so this is an incomplete closure, not a regression. | Reviewer probe: `UNC Write path | Resolved=True | Targets=C:/wt/coordinator`; `extended-length Write path | Resolved=True | Targets=C:/wt/coordinator`; `drive Write path | Resolved=True | Targets=C:/wt/other/src/x.ps1`. |

Notes:

- `spec.md` AC-9 does not contain the phrase `session root returned` (relevant to P3-T13).
