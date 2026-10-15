# File Sizes (Issue #890, AC-2 500-line clause)

Timestamp: 2026-10-12T20-29
Task: P1-T30
Command: `wc -l <path>` over every new or edited non-Markdown file (one invocation listing all paths), then `wc -l` over the four edited Markdown documents, and `git show 85ffd5aaecd9004b7d82e9db6ab0f18a4add02f6:.claude/skills/parallel-orchestrate/SKILL.md | wc -l` for the merge-base size.
EXIT_CODE: 0
Output Summary: every non-Markdown file is at or under 500 lines (largest: `tests/scripts/dev_tools/test_parallel_mutation_run_bash_parity.py`, 481).

Note: `tests/scripts/dev_tools/test_parallel_mutation_run_bash_parity.py` was 475 lines as first written; a read-only `black --check` before this task reported it would be reformatted, so Black was applied to that one new file to complete its authoring (P1-T8), after which it is 481 lines and still passes `25 passed` and the 5-test count. No other file was reformatted.

## Non-Markdown files

| Path | Lines | At or under 500 |
| --- | --- | --- |
| `.claude/lib/bash/parallel-mutation.sh` | 322 | yes |
| `.claude/lib/bash/remove-parallel-item.sh` | 146 | yes |
| `.claude/lib/bash/parallel-mutation-cli.sh` | 152 | yes |
| `.claude/lib/bash/parallel-mutation-ops.sh` | 193 | yes |
| `.claude/lib/bash/mutate-parallel-run.sh` | 191 | yes |
| `tests/shell/parallel_mutation_run.bats` | 341 | yes |
| `tests/shell/parallel_mutation_run_parity.bats` | 103 | yes |
| `tests/shell/parallel_mutation_remove.bats` | 295 | yes |
| `tests/shell/parallel_mutation_remove_parity.bats` | 102 | yes |
| `tests/shell/parallel_payload_only.bats` | 189 | yes |
| `tests/shell/parallel_bash_manifest_membership.bats` | 89 | yes |
| `scripts/dev_tools/_parallel_mutation_errors.py` | 253 | yes |
| `tests/scripts/dev_tools/test_parallel_mutation_errors.py` | 114 | yes |
| `tests/scripts/dev_tools/test_parallel_mutation_run_bash_parity.py` | 481 | yes |
| `tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py` | 369 | yes |
| `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` | 255 | yes |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | 229 | yes |
| `.claude/settings.json` | 292 | yes |

The bundled mirrors of the five bash files and of `.claude/settings.json` are byte-identical to the repository files (see `evidence/other/mirror-hashes-890.md`), so their line counts equal those above. The 21 fixtures under `tests/fixtures/parallel_mutation_run/` are 10 lines each.

## Markdown (exempt)

`.claude/rules/general-code-change.md` (File Size Limit) exempts Markdown documentation files from the 500-line limit. Recorded for completeness:

| Path | Lines |
| --- | --- |
| `.claude/skills/parallel-add/SKILL.md` | 219 |
| `.claude/skills/parallel-close/SKILL.md` | 106 |
| `.claude/skills/parallel-orchestrate/SKILL.md` | 1209 |
| `.claude/agents/parallel-orchestrator.md` | 307 |

`.claude/skills/parallel-orchestrate/SKILL.md` is 1200 lines at the merge base (85ffd5aae) and is edited in place only (+9 lines).
