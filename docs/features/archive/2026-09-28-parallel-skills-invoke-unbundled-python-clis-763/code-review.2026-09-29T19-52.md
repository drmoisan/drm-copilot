# Code Review: parallel-skills-invoke-unbundled-python-clis (#763)

- Branch: `bug/parallel-skills-invoke-unbundled-python-clis-exec-763`
- Review range: `12db46245ba7683b5d6ccb676312a4b22a39b0ce..416327768ff7cefe83c7f22bdfbad84971ddc90b` (13 commits, 153 files)
- Timestamp: 2026-09-29T19-52

## Executive Summary

The change replaces two Python CLI invocations in pushed-down skills with destination-runtime entry points and binds each port to its retained Python reference through a shared committed corpus exercised by two lanes. The design follows the #447 and #462 precedents: the PowerShell drift port reuses the existing blast-radius library rather than adding a third implementation, JSON is read through `System.Text.Json` so timestamp strings and the integer/boolean distinction survive, and the bash abandon port preserves the hook tokens so the gate logic is unchanged.

Code quality is consistent with repository conventions: pure functions are separated from I/O, every function carries help and output-type declarations, errors name the offending field, refusals precede side effects, and every new file is under 500 lines. Tests use seams and checked-in shims rather than temporary files, and both parity lanes fail on an empty or incomplete corpus.

No blocking finding was identified. Eleven non-blocking findings are listed below; most are declared divergences or follow-ups that the spec already scopes out.

Blocking findings: 0. Non-blocking findings: 11.

## Files Reviewed

- `.claude/lib/parallel-drift/ParallelDrift.psm1` (467 lines), `ParallelDriftHalt.psm1` (388), `Invoke-ParallelDriftDetection.ps1` (336)
- `.claude/lib/bash/abandon-parallel-item.sh` (176)
- `.claude/hooks/enforce-parallel-abandon-gate.ps1` (comment-only diff)
- `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/parallel-remove/SKILL.md`, `.claude/agents/parallel-orchestrator.md`
- `scripts/dev_tools/skill_bundle_contract.py`, `scripts/dev_tools/skill_bundle_contract_cli.py`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, both `pester.runsettings.psd1`, all bundle mirrors (byte identity confirmed with `cmp`)
- All new and modified tests, fixtures, and shims listed in the policy audit Appendix A

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking (Medium) | `.claude/skills/parallel-remove/SKILL.md` | lines 77, 121 (steps 2, 3, 6) | The skill still directs callers to `decide_removal`, `recolor_unstarted`, and `build_remove_entry` in `scripts/dev_tools/parallel_mutation_protocol.py`, so `/parallel-remove` still needs Python in a consumer repository even though step 5 is now portable. | Prioritize the spec D7 follow-up and track it as an issue linked to #763. | The defect class this issue fixes (skill steps that depend on unbundled Python) remains for three steps of the same skill. Scoped out by spec D7. | Reviewer grep of the SKILL for `parallel_mutation_protocol`. |
| Non-blocking (Medium) | `scripts/dev_tools/skill_bundle_contract.py` | invocation regex (plan DV9) | The guard's first invocation pattern `(?:bash\|sh\|source)\s+` can match a fence info string and consume the interpreter word on the next line, hiding the invocation from `extract_script_references`. The branch works around it by changing the `parallel-remove` fence to `shell`. | File FU-763-5 as an issue and anchor the pattern to non-fence text or disallow newline spans. | Other skills that place a `bash` invocation inside a ```` ```bash ```` fence are not checked by the guard. The new `test_bundle_guard_extracts_the_skill_invocation` pins only this SKILL. | Plan DV9; `test_parallel_abandon_token_seam.py::test_bundle_guard_extracts_the_skill_invocation`. |
| Non-blocking (Low) | `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` | `Invoke-ParallelDriftCli`, lines 301-304 | Any remaining argument beginning with `-` is reported as an unrecognized parameter, so a changed path whose name begins with `-` cannot be passed. | Document the limitation in the SKILL argument-surface paragraph, or accept an explicit end-of-parameters marker. | Declared as DV7 in the parity suite header but not stated in the SKILL, which is what the orchestrator reads. | Parity suite header lines 24-26; SKILL.md lines 900-906. |
| Non-blocking (Low) | `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` | param block | A named parameter given with no value (for example a trailing `-ItemKey`) is rejected by the PowerShell binder and exits 1 without the usage prefix, while the spec lists a missing `-ItemKey` as a usage error (exit 2). | Note the binder case in the SKILL exit-code sentence, or accept it as the declared divergence. | The orchestrator distinguishes data errors (1) from usage errors (2); a binder rejection is reported as a data-error code. | Plan DV7; spec "Error handling and logging updates". |
| Non-blocking (Low) | `tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1` | lines 156-175 | The test rewrites `$script:CheckpointText` in place and restores it in `finally`. | Build the variant text in a local variable and supply it through a test-local `Mock Read-ParallelDriftJsonText`. | Shared mutable test state is restored correctly here but is fragile if a later edit changes the replaced substring. | Reviewer read. |
| Non-blocking (Low) | `tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1` | `ConvertFrom-EmittedJson`, lines 40-43 | The helper returns `RootElement` of a `JsonDocument` that is never disposed. | Parse into a document inside each test and dispose it, as the parity suite does. | Pooled buffers are not returned; negligible in a test host but inconsistent with the parity suite pattern. | Reviewer read; `ParallelDrift.Parity.Tests.ps1` lines 133-139 dispose correctly. |
| Non-blocking (Low) | `tests/shell/parallel_abandon.bats`, `tests/shell/parallel_abandon_parity.bats` | `setup()` | `chmod +x` is applied to checked-in shims on every test. The shims are already committed as mode 100755, so the call is a working-tree no-op on a normal checkout. | Keep, or drop once CI confirms modes survive checkout. | Pre-existing pattern from `parallel_payload_only.bats`; mutates file metadata, not content. | `git ls-files -s tests/fixtures/parallel_abandon_path*`. |
| Non-blocking (Low) | `.claude/skills/parallel-orchestrate/SKILL.md` | line 943 | The stderr prefix is written in double quotes rather than a code span, because the permission-seam parser in `tests/scripts/dev_tools/parallel_orchestrator_permission_seam_support.py` reads any multi-word lowercase code span as a command. | Accept; consider narrowing the seam parser to spans that begin with a known executable. | Executor deviation 2. The workaround is correct, but the parser heuristic will constrain future prose. | `evidence/qa-gates/python-regression.2026-09-29T19-13.md` loop pass 3. |
| Non-blocking (Low) | `.claude/agents/parallel-orchestrator.md` | frontmatter lines 16-17 | `Bash(poetry run python -c *)` and `Bash(poetry run python -m *)` remain although the prose now states that no skill step names a `poetry run` consumer. | Resolve the spec D4 follow-up (remove or re-justify the grants). | Unused grants widen the persona's permission surface. | Agent diff lines 96-108. |
| Non-blocking (Low) | `.claude/settings.json` (not changed) | n/a | No allow entry exists for `bash .claude/lib/bash/abandon-parallel-item.sh`, so consumers may see a permission prompt before the abandon command. | Resolve the spec D6 follow-up. | Fail-safe behavior; recorded for completeness. | Spec D6. |
| Non-blocking (Low) | `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` | lines 330-336 | The guarded process entry block (stdout/stderr write and `exit`) is not executed by any automated test; its behavior under `pwsh -NoProfile -NonInteractive -File` is recorded by a one-time smoke run. | Add a process-level smoke case to an integration lane when one is available for `.claude/lib` entry points. | The in-process parity lane asserts the returned record, not the process exit code or stream routing. | `evidence/regression-testing/drift-process-smoke.2026-09-29T18-00.md`; JaCoCo 91/96 lines. |

## Positive Observations

- Reuse of the blast-radius library is asserted by a test (`ParallelDrift.Tests.ps1` "imports the blast-radius library and defines none of its functions"), which prevents a later drift into a third implementation.
- `ConvertFrom-ParallelDriftJsonElement` builds ordinal hashtables, converts integral numbers to `Int64` and others to `Double`, and preserves booleans, which keeps the `is_positive_integer` distinction and case-sensitive keys that `ConvertFrom-Json` would lose.
- Array emission is explicit (`Write-ParallelDriftJsonValue` and unary-comma returns), and tests assert that one-element `escaped_paths` and `halted_item_keys` remain JSON arrays.
- The abandon script resolves executables through `command -v` and reports `-1` when one is absent, stops at the first failure, and refuses before any side effect. Case variants of the hook tokens (for example `--disposition ABANDON`) are rejected by the script as usage errors, so a command that the case-insensitive hook admits cannot reach a side effect with an unrecognized disposition.
- The token seam test now binds four artifacts (bash constants, Python constants, hook assignments, SKILL line) and asserts each extraction is non-empty before comparing.
- `skill_bundle_contract_cli.main` materializes the injected registry once so both finders read the same entries.

## Executor Deviations Evaluated

| Deviation | Assessment |
|---|---|
| 1. Single `Co-Authored-By` trailer after `b9fc1594` | Matches the current harness attribution instruction. Accepted. |
| 2. Double-quoted stderr prefix in the orchestrate SKILL | Required by the permission-seam parser; meaning unchanged. Accepted (see findings). |
| 3. Two `PSUseLiteralInitializerForHashtable` suppressions | Localized, justified, and necessary for case-sensitive keys. Accepted. |
| 4. Glob pathspec spellings in evidence commands | Avoids a text-match false positive in the worktree isolation guard; read-only; each glob matched one file. Accepted. |
| 5. Extra batch-budget reset in P8 | Evidence recorded; batch-budget hook and tests are not in the diff. Accepted. |

## Verdict

No blocking finding. The change is ready to merge from a code-quality perspective.
