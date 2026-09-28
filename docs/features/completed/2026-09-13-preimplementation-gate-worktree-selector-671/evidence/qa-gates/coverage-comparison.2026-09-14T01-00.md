# Coverage Comparison (issue #671)

Timestamp: 2026-09-17T08-28
Task: [P6-T4]
Command: `[xml](Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml')` from the [P6-T3] run (LastWriteTime 2026-09-17T08:26:50). Selection: the `sourcefile` named `enforce-orchestration-preimplementation-gate-helpers.ps1` under the `package` whose forward-slash-normalized name ends with `.claude/hooks`, and its `line` children whose `nr` is in the [P5-T4] `Changed-line set:`. Also `(Get-FileHash -LiteralPath .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1).Hash`. Run by a scratchpad parser under pwsh 7.6.6.
EXIT_CODE: 0

Output Summary:
- Stale-set check: current helpers hash 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 equals the [P5-T4] `Helpers hash at capture:` value, so the changed-line set is current and no [P5-T4] re-run was needed.
- Baseline line coverage: covered=8914, missed=422 -> 95.48% (same pair as recorded in [P0-T8]).
- Post-change line coverage: covered=8970, missed=432 -> 95.41% (same pair as recorded in [P6-T3]). 95.41 >= 85.
- Changed-line coverage of `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`: 29 / 33 = 87.88%. Of the 87 changed lines, 33 have a `line` child in the report; 29 of those have `ci` > 0, 4 have `ci` = 0, and 54 have no `line` child (not instrumented).
- The `sourcefile` selection matched exactly one node; package names are directory-qualified.
- Pester measures command and line coverage only, so no branch-coverage value is recorded.

## Instrumented changed lines

`43:ci=1 243:ci=1 244:ci=1 245:ci=1 246:ci=1 248:ci=4 249:ci=1 250:ci=1 252:ci=1 253:ci=0 254:ci=0 256:ci=1 257:ci=1 258:ci=0 259:ci=0 262:ci=1 263:ci=1 264:ci=2 265:ci=1 266:ci=1 268:ci=1 269:ci=1 270:ci=1 271:ci=1 273:ci=3 274:ci=1 275:ci=1 276:ci=1 278:ci=1 309:ci=1 310:ci=2 311:ci=1 315:ci=4`

## Changed lines with `ci` = 0

- **253** (`Write-Debug 'PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value.'`): the suites never reach it. Its only fixtures, L3a (`git -C C:/repo/wt`) and L3b (`git -C C:/repo/wt -- ...`), carry no `add`/`commit`, so the gate trigger never classifies them and the exemption predicate is never called.
- **254** (`return $false` after line 253): unreached for the same reason as line 253.
- **258** (`Write-Debug 'PREIMPL_SELECTOR_MALFORMED: the selector value is empty.'`): unreachable through the gate. An empty selector token fails parameter binding of `Test-ExemptOrchestrationSegmentToken` at line 221, which has no `[AllowEmptyString()]`, before the selector predicate can be called (the L8 finding).
- **259** (`return $false` after line 258): unreached for the same reason as line 258.

## Changed lines with no `line` child (not instrumented)

Each of these lines is non-executable, so Pester places no breakpoint on it:

- 39, 40, 41, 42: comment lines of the selector-constant block.
- 44: blank line after the constant.
- 45, 46, 47, 48, 49, 50, 51, 52, 53: the `Accepted widening` comment block.
- 54: blank line.
- 222: the `function Test-ExemptOrchestrationSelector {` declaration line.
- 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238: comment-based help.
- 239: the `[CmdletBinding()]` attribute.
- 240: the `[OutputType([bool])]` attribute.
- 241: the `param(...)` declaration.
- 242: blank line.
- 247, 251, 255, 260, 267, 272, 277, 279: closing braces.
- 261: blank line.
- 280: blank line after the function.
- 302, 303, 304, 305: the reworded row-14 comment.
- 312, 316: closing braces.
- 313, 314: comment lines inside the absorption block.

## Related observation (outside the changed-line set)

The per-file line coverage fell from 112/118 (94.92%) to 140/151 (92.72%). Besides the four changed lines above, one unchanged line is now unreached: post-change line 319 (pre-change line 235, `return $false` when the subcommand is neither `add` nor `commit`). Every non-`add`/`commit` token at index 1 now goes to the selector predicate, so line 319 is reached only when a `-C` selector is followed by another subcommand (for example `git -C C:/x status`) inside a trigger-matching line, and no suite has such a row. The other six uncovered lines (180, 299, 348, 354, 406, 423) correspond to the six lines uncovered at baseline.
