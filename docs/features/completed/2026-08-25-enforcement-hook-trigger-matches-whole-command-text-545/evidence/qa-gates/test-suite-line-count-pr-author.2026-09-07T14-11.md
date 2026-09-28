# Test-suite line counts — the two pr-author trigger-scoping suites

Timestamp: 2026-09-07T14-11

Task: [P7-T10]

TOOLCHAIN_SUBSTITUTION: the plan's `@(Get-Content -LiteralPath $path).Count` form requires `pwsh`,
which is not invocable in this session. `wc -l` was used instead. The two differ only when a file's
final line lacks a terminating newline, in which case `wc -l` reports one fewer. Both files below end
with a terminating newline, verified by `tail -c 1 | xxd`, which printed `0a` for each, so the two
measures agree exactly here.

Command: `wc -l tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1`

EXIT_CODE: 0

## Result

| File | Created by | Lines | At or under 500? | 450-line threshold crossed? |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | [P7-T3] | **281** | yes | no |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | [P7-T7] | **57** | yes | no |

Neither file crossed the 450-line threshold, so neither needs a split and no follow-up split task is
raised. Headroom remaining: 219 lines and 443 lines respectively against the 500-line hard cap.

Measurement note: the batch B10 gate artifact records this suite at 280 lines with SHA-256
`9da8f61550250eff076d79f1db9222072411ed06c0246182d8bf97d0ed3c250d`, which was its state when that
gate ran. This task then measured the sibling suite at 447 rather than the 482 the file's own
docstring asserted, and the docstring was corrected in place to state the measured value. That
one-line correction is comment text only — it changes no case, no fixture, and no assertion — and it
takes the file to 281 lines and SHA-256
`e4ae6f4baaaf2c0cc54980d52535510c50be719d6144ae7e18f2a231734275c9`. The 281-line value above is the
current one. The correction is re-verified by the batch B12 gate, which reruns format, analyze, and
Pester over `tests/scripts/claude-hooks` after it.

For context, the two existing sibling suites these files were split away from are unchanged by this
phase and were measured in the same command: `enforce-pr-author-skill.Tests.ps1` at **447** lines and
`enforce-pr-author-skill.epic-base-branch.Tests.ps1` at **113** lines. Adding the 280-line matrix in
place would have taken the first suite to 727 lines, well past the cap, which is why both new files
are siblings. Note that the `482` figure quoted in the docstring of
`enforce-pr-author-skill.epic-base-branch.Tests.ps1` describes that suite's state when it was
authored and is stale against the current tree; the measured value above supersedes it and no plan
assertion depends on the stale number.

Output Summary: both new suites are under the 500-line hard cap.
`enforce-pr-author-skill.TriggerScoping.Tests.ps1` measures **280** lines and
`enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` measures **57** lines. Neither
crossed the 450-line threshold.
