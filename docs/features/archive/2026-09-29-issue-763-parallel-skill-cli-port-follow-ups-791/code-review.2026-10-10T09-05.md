# Code Review: parallel-skill CLI port follow-ups (#791)

**Review Date:** 2026-10-10
**Branch:** `bug/issue-763-parallel-skill-cli-port-follow-ups-791` @ `a00195532`
**Base:** `origin/main` @ `7bbd0b9b9` (full branch diff, `git diff --merge-base origin/main HEAD`)

## Executive Summary

The change set is small in production surface and well bounded. The guard fix is a two-token regex change with fail-before/pass-after evidence. The bash port separates a pure library (`parallel-mutation.sh`: no I/O, no clock, results in `PM_RESULT`/`PM_ERROR`) from a CLI entry point (`remove-parallel-item.sh`: strict option parsing, one clock read, exit-code contract 0/1/2). Parity with the Python engine is pinned by a shared 15-fixture corpus asserted from both sides, each lane with a count floor. Permission-surface edits are narrow and mirrored byte-for-byte. Documentation in the skill and agent files matches the implemented behavior.

No blocking or high-severity findings. Six Low or Info observations are listed below; none requires remediation before merge.

Files reviewed in full: `.claude/lib/bash/parallel-mutation.sh`, `.claude/lib/bash/remove-parallel-item.sh`, `tests/shell/parallel_mutation_remove.bats`, `tests/shell/parallel_mutation_remove_parity.bats`, `tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py`, and the diffs of `scripts/dev_tools/skill_bundle_contract.py`, `.claude/skills/parallel-remove/SKILL.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/settings.json`, `core.json`, the payload and membership bats suites, the TriggerScoping Pester file, and the two guard test modules.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low | `.claude/lib/bash/parallel-mutation.sh` | lines 121, 170, 231, 286-293 | Public library functions evaluate caller arguments in bash arithmetic (`((item_key <= 0))`, `((current_cohort < 0))`, `$((generation + 1))`). Bash arithmetic expands array subscripts, so a non-integer string passed by a direct library caller (not the entry point) could be evaluated as an expression. The header states that integers are expected in canonical form and the entry point validates every integer with `^-?(0|[1-9][0-9]*)$` before calling. | Keep the documented precondition; when the follow-up FU-791-1 adds more callers of this library, consider a shared integer guard inside the library so the precondition does not depend on each caller. | Defense in depth for a library intended for reuse by later ports. | Read of `parallel-mutation.sh:26-27` and `remove-parallel-item.sh:100-111`. |
| Low | `.claude/lib/bash/remove-parallel-item.sh` | `rpi_integer`, line 110 | Integers are converted with `$(($1))`, which uses 64-bit signed arithmetic. A token above 2^63-1 passes the regex and wraps, whereas the Python reference uses unbounded integers. This range difference is not in the three declared divergences. | Either add a digit-length bound to the validation regex or list the 64-bit range as a fourth declared divergence in the script header and both parity lanes. | Item keys and generations are small in practice, so impact is limited to documentation accuracy of the parity contract. | Read of `remove-parallel-item.sh:107-110`; declared divergences at lines 34-39. |
| Info | `.claude/lib/bash/remove-parallel-item.sh` | `rpi_decide` line 175 vs `rpi_entry` line 213 | `decide` treats an out-of-enum `--state` as a usage error (exit 2), while `entry` accepts any `[A-Za-z_]+` `--prior-state` and rejects an out-of-enum value as a rule rejection (exit 1). | No change required. | The asymmetry matches spec Technical Specifications (decide: usage error; entry: `MutationEntry` rejection) and is tested for both paths. | bats cases "decide treats an out-of-enum state as a usage error" and "entry rejects an out-of-enum prior state". |
| Info | `tests/shell/parallel_mutation_remove_parity.bats` | `fixture_field`, lines 43-49 | The harness evaluates a Python expression with `eval` and opens the fixture without a context manager. The expression text is a literal in the test file, not fixture-supplied, and the interpreter is a harness dependency only. | No change required; optionally use `with open(...)` for tidiness. | Harness-only code; no production impact. | Read of the file. |
| Info | `.claude/lib/bash/parallel-mutation.sh`, `remove-parallel-item.sh` | lines 37-38, 44-45 | `# shellcheck disable=SC1091` has no reason text on its own line; the adjacent `# shellcheck source=` directive supplies the context. `.claude/rules/shell.md` asks for an inline reason. | Optionally append a short reason (for example, "resolved at runtime from the script directory"). | Matches existing precedent in `parallel-cohorts.sh:30`; CI shellcheck passes. | `.claude/rules/shell.md:85-86`. |
| Info | `scripts/dev_tools/skill_bundle_contract.py` | line 51 | The updated comment uses the contraction "can't" and is compressed to fit the zero-net-line constraint. | No change required. | Content is accurate; the line budget (486/500) motivated the brevity. | Diff of the file. |

## Positive Observations

- The guard fix is minimal and its regression tests were shown to fail before the change (`evidence/regression-testing/fail-before.2026-10-10T08-16.md`, 10 failed) and pass after.
- The library's check order (overlap, negative base, pinned barrier, coloring) and the entry's field-order validation are documented in comments and match the Python reference ordering, so the first reported violation is identical across implementations.
- The option name `--removal-disposition` avoids the abandon-gate token pair `--disposition abandon`; R791-O1 asserts both the gate decision and the pure scope function.
- The parity lanes cannot pass vacuously: both enforce a floor of 15, the bats lane also counts checked fixtures, and the Python lane asserts the exact required-case set and a success plus a rejection per subcommand.
- The payload cases run the bundled copy with `env -i` and a PATH that exposes no Python interpreter.

## Verdict

PASS. No remediation required.
