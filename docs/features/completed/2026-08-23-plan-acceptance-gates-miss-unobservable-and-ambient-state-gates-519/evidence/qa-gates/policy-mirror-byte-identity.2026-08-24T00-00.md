# Policy-File Bundled-Mirror Byte Identity — [P7-T7]

Timestamp: 2026-08-26T10-02
Task: [P7-T7]
Command: `cp .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`, then `Get-FileHash -Algorithm SHA256` with `Get-Item .Length` over the four policy files, then `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 1
ExpectedExitCode: 1

The recorded exit code is that of the pytest run, which is the last command of the task. The copy exited 0 and the digest-and-length command exited 0. Every exit code was captured directly with `echo "EXIT=$?"` immediately after the redirect; no pipe stands between any command and its capture.

## (a) SHA-256 digests of the four policy files — both pairs now equal

Computed with `Get-FileHash -Algorithm SHA256`, all four in a single invocation.

| File | SHA-256 |
| --- | --- |
| `.claude/rules/plan-acceptance-gates.md` | `FFD4EAE4D7D5816694AB634FB4A390D1E7E39A24DF2C3C1172066F759B547689` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` | `FFD4EAE4D7D5816694AB634FB4A390D1E7E39A24DF2C3C1172066F759B547689` |
| `.claude/skills/atomic-plan-contract/SKILL.md` | `203D11BD19B19131CB2AB7E4E405596AD91EDD33880394D84BDAE5BB6FE8905A` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | `203D11BD19B19131CB2AB7E4E405596AD91EDD33880394D84BDAE5BB6FE8905A` |

**Both pairs are equal.**

- The rules file equals its mirror: `FFD4EAE4D7D5816694AB634FB4A390D1E7E39A24DF2C3C1172066F759B547689` on both sides. This is unchanged from [P7-T6], which established it.
- The skill file equals its mirror: `203D11BD19B19131CB2AB7E4E405596AD91EDD33880394D84BDAE5BB6FE8905A` on both sides. [P7-T6] recorded the mirror at `B6C1472EFEFD9BB6F1DE76B9D68EECD78E4A09B1731560420CA36289E8DD9D89`, the pre-Phase-7 value, because the copy this task performs had not yet run. It has now run and the inequality is resolved.

## (b) Byte length of each of the four files

Read with `Get-Item .Length` in the same invocation as the digests.

| File | Bytes |
| --- | --- |
| `.claude/rules/plan-acceptance-gates.md` | 35412 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` | 35412 |
| `.claude/skills/atomic-plan-contract/SKILL.md` | 18857 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | 18857 |

Each repository file and its mirror carry the same length: 35412 for the rules pair and 18857 for the skill pair. The length is recorded alongside the digest because it is an independent quantity — two files of differing length cannot be byte-identical, so agreement on both is a stronger record than agreement on either alone.

## (c) The full push-down contract test file

Full output of `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, reproduced verbatim:

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a2c2e891a6977ab65
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 10 items

tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py .F.. [ 40%]
......                                                                   [100%]

================================== FAILURES ===================================
_______ test_bundled_claude_payload_contains_all_repo_runtime_contracts _______

    def test_bundled_claude_payload_contains_all_repo_runtime_contracts() -> None:
        """Require every non-memory repo `.claude` file to exist in the bundle.

        Excludes settings.local.json and the `.claude/agent-memory/**` subtree.
        Agent memories are distributed by scope (general memories live in the
        bundle but not at the gitignored root), so they are not subject to the
        byte-identical mirror assertion.
        """

        bundled_files = list_scoped_files(BUNDLED_ROOT)
        # Enumerate repo .claude files, excluding the local-only settings file and
        # the scope-filtered agent-memory subtree.
        repo_runtime_files = [
            f
            for f in list_scoped_files(REPO_ROOT)
            if f != Path(".claude/settings.local.json") and not _is_agent_memory_path(f)
        ]

        for relative_path in repo_runtime_files:
>           assert (
                relative_path in bundled_files
            ), f"Repo file missing from bundle: {relative_path}"
E           AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
E           assert WindowsPath('.claude/state/python-batch-budget.default.json') in [WindowsPath('.claude/agent-memory/epic-orchestrator/feedback_commit_push_memory_before_pr.md'), WindowsPath('.claude/..._unmerged_pr_deps.md'), WindowsPath('.claude/agent-memory/orchestrator/feedback_commit_push_memory_before_pr.md'), ...]

tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:120: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
========================= 1 failed, 9 passed in 0.26s =========================
```

**The only failing test in the run is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`**, the test named in [P7-T6]. The run collected 10 items and reports `1 failed, 9 passed`. No other test in the file failed.

**Every path the test reports as missing from the bundle, reproduced verbatim:**

```text
.claude\state\python-batch-budget.default.json
```

That is the complete reported list; it carries exactly one entry. Its prefix is `.claude\state\`, which is the Windows path-separator rendering of `.claude/state/` — the assertion message interpolates a `WindowsPath`, and the same object is printed in its forward-slash form on the following line as `WindowsPath('.claude/state/python-batch-budget.default.json')`. The reported path therefore begins with the prefix `.claude/state/`, and **no reported path carries any other prefix**.

This run reaches the missing-from-bundle assertion, whereas the [P7-T6] run aborted earlier on a content-difference assertion against the skill file. The difference is the copy this task performed: with the skill mirror byte-identical, the loop proceeds past it and reaches the `.claude/state/` file. The `.claude/state/` enumeration [P7-T6] anticipated is therefore observed here directly.

## (d) Issue-#510 attribution and the `.gitignore` evidence, reproduced

Reproduced from [P7-T6], `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/rules-mirror-byte-identity.2026-08-24T00-00.md`.

The `.claude` scope this test enumerates includes `.claude/state/python-batch-budget.default.json`, a gitignored counter file. It is not a runtime contract and is not part of the bundled payload. It regenerates whenever the Python toolchain runs: it was absent during Phase 0, regenerated during Phase 2, and is present now. CI is unaffected, because the file does not exist in a clean checkout — nothing in the repository tracks it, so a fresh clone has no `.claude/state` directory at all and the test enumerates nothing under that prefix. The failure is local-only, is the subject of open issue #510, and is not caused by this change.

Line 68 of `.gitignore`, quoted exactly:

```text
.claude/state/
```

Confirmed against git itself:

```text
$ git check-ignore -v .claude/state/python-batch-budget.default.json
.gitignore:68:.claude/state/	.claude/state/python-batch-budget.default.json
EXIT=0
```

`git check-ignore` names `.gitignore` line 68 as the rule that ignores the file, which is the same line quoted above. The enumerated file is untracked by that rule.

`ExpectedExitCode: 1` is carried in the header because the observed exit code of the recorded run is 1.

## Why the digest comparison is the gate and not the test

This task's byte-identity property is gated by the digest comparison in condition (a), not by the contract test's overall pass or fail. The test cannot carry the gate on its own because it fails for a reason unrelated to this change — the gitignored, regenerating counter file of issue #510 — so a pass/fail reading of it would report a parity failure that does not exist. The test is nonetheless recorded and constrained: its reported missing-path list is required to carry only `.claude/state/`-prefixed entries, so a genuine parity regression, which would report a path under `.claude/rules/` or `.claude/skills/`, still fails this task.

## Output Summary

The skill file was copied over its bundled mirror. **Both policy pairs are now byte-identical**: the rules pair digests to `FFD4EAE4D7D5816694AB634FB4A390D1E7E39A24DF2C3C1172066F759B547689` at 35412 bytes on both sides, and the skill pair to `203D11BD19B19131CB2AB7E4E405596AD91EDD33880394D84BDAE5BB6FE8905A` at 18857 bytes on both sides. The full push-down contract test file reports `1 failed, 9 passed`; the single failing test is the bundled-payload contract test named in [P7-T6], and the single path it reports as missing from the bundle is `.claude\state\python-batch-budget.default.json`, which begins with the `.claude/state/` prefix. No reported path carries any other prefix and no other test in the file failed. The issue-#510 attribution and the `.gitignore` line-68 evidence are reproduced and were re-confirmed with `git check-ignore`.
