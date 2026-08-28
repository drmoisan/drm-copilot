# Rules-File Bundled-Mirror Byte Identity — [P7-T6]

Timestamp: 2026-08-26T10-14
Task: [P7-T6]
Command: `cp .claude/rules/plan-acceptance-gates.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`, then `Get-FileHash -Algorithm SHA256` over the four policy files, then `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 1
ExpectedExitCode: 1

The recorded exit code is that of the pytest run, which is the last command of the task and the only one whose outcome is not trivially 0. The copy exited 0 and the digest command exited 0. Every exit code was captured directly with `echo "EXIT=$?"` immediately after the redirect; no pipe stands between any command and its capture.

The `ExpectedExitCode: 1` field is carried because the observed exit code of the recorded test run is 1, for the reason condition (b) analyses below.

## (a) SHA-256 digests of the four policy files

Computed with `Get-FileHash -Algorithm SHA256`, all four in a single invocation.

| File | SHA-256 |
| --- | --- |
| `.claude/rules/plan-acceptance-gates.md` | `FFD4EAE4D7D5816694AB634FB4A390D1E7E39A24DF2C3C1172066F759B547689` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` | `FFD4EAE4D7D5816694AB634FB4A390D1E7E39A24DF2C3C1172066F759B547689` |
| `.claude/skills/atomic-plan-contract/SKILL.md` | `203D11BD19B19131CB2AB7E4E405596AD91EDD33880394D84BDAE5BB6FE8905A` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | `B6C1472EFEFD9BB6F1DE76B9D68EECD78E4A09B1731560420CA36289E8DD9D89` |

**The digest of the rules file equals the digest of its mirror.** Both are `FFD4EAE4D7D5816694AB634FB4A390D1E7E39A24DF2C3C1172066F759B547689`. That equality is the gate this task carries, and it holds.

**The two skill-file digests are recorded as observed and are not equal at this point, and are not required to be.** [P7-T5] has already amended the repository skill file, which is why its digest is now `203D11BD…`, while the mirror still carries `B6C1472E…`, the digest both skill files shared before this feature's Phase 7 began. [P7-T7] is the task that performs the corresponding copy, and the equality of the two skill digests is gated there, not here. The ordering is stated explicitly so this inequality is read as the plan's own sequencing rather than as a defect.

## (b) The bundled-payload contract test

Full output of `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"`, reproduced verbatim:

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a2c2e891a6977ab65
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 1 item

tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py F    [100%]

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
            assert (
                relative_path in bundled_files
            ), f"Repo file missing from bundle: {relative_path}"
>           assert read_text(BUNDLED_ROOT, relative_path) == read_text(
                REPO_ROOT,
                relative_path,
            ), f"Bundle content differs from repo for: {relative_path}"
E           AssertionError: Bundle content differs from repo for: .claude\skills\atomic-plan-contract\SKILL.md
E           assert '---\nname: a...bligations.\n' == '---\nname: a...bligations.\n'
E
E             Skipping 9970 identical leading characters in diff, use -v to show
E               ditions.
E             -
E             - The same call additionally applies the rules G7, G8, G8b, and G9, which report a write-mode command observed only by its exit code, an unanchored `git diff`, a name-listing diff with no companion span, and a coverage command that prints no table. All four ship in the Warning channel, so they surface without failing the gate. The complete shipped set is therefore G1 through G9.
E
E               ## Wrap-Tolerant Assertion Authoring (Mandatory)...
E
E             ...Full output truncated (49 lines hidden), use '-vv' to show

tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:123: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
============================== 1 failed in 0.15s ==============================
```

**Every path this test reports as missing from the bundle, reproduced verbatim: there are none. The reported-missing list is empty.**

The condition this task states is that every path the test reports as missing from the bundle begins with the prefix `.claude/state/`, and that a reported path carrying any other prefix fails the task. **No path was reported as missing, so no path carries a different prefix, and the condition holds.**

The run nonetheless exits 1, and the reason is recorded here rather than left for a reader to reconstruct. The test's loop makes two assertions per repository file in enumeration order: first that the file exists in the bundle, then that the bundle's content equals the repository's. The assertion that fired is the **second** one — a content difference — on `.claude/skills/atomic-plan-contract/SKILL.md`. That is precisely the inequality condition (a) records and explains: [P7-T5] amended the repository skill file and [P7-T7] is the task that copies it to the mirror. The difference the test prints is the paragraph [P7-T5] added, which confirms the cause.

Because that content assertion aborts the loop, this run never reaches any `.claude/state/` file, which is why the reported-missing list is empty rather than carrying the issue-#510 path. The `.claude/state/` enumeration is observed in the full-file run recorded by [P7-T7], after the skill mirror is copied and the loop can proceed. The attribution required by condition (c) is recorded below from the tree state rather than from this run's output, and it is re-observed in [P7-T7].

## (c) Issue-#510 attribution

The `.claude` scope this test enumerates includes `.claude/state/python-batch-budget.default.json`, a gitignored counter file. It is not a runtime contract and is not part of the bundled payload. It regenerates whenever the Python toolchain runs: it was absent during Phase 0, regenerated during Phase 2, and is present now — the directory listing of `.claude/state` taken with this run contains exactly that one file.

CI is unaffected, because the file does not exist in a clean checkout: nothing in the repository tracks it, so a fresh clone has no `.claude/state` directory at all and the test enumerates nothing under that prefix. The failure is therefore local-only, is the subject of open issue #510, and is not caused by this change.

That attribution is what makes a `.claude/state/`-prefixed reported path acceptable and any other prefix a real parity failure. The distinction this task's gate rests on is the digest comparison in condition (a), not this test's overall pass or fail.

## (d) The `.gitignore` evidence that the enumerated file is untracked

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

`ExpectedExitCode: 1` is carried in the header because the observed exit code of the recorded test run is 1.

## Output Summary

The rules file was copied over its bundled mirror and the two are byte-identical: both digest to `FFD4EAE4D7D5816694AB634FB4A390D1E7E39A24DF2C3C1172066F759B547689`. That equality is the gate this task carries and it holds. The skill file digests to `203D11BD…` and its mirror to `B6C1472E…`; they are not equal at this point and are not required to be, because [P7-T7] performs that copy and gates that equality. The bundled-payload contract test exits 1, reporting **zero** paths as missing from the bundle; its single failing assertion is a content difference on `.claude/skills/atomic-plan-contract/SKILL.md`, which is the plan's own [P7-T5]-then-[P7-T7] ordering and is resolved by [P7-T7]. No reported path carries a prefix other than `.claude/state/`, because no path was reported. The issue-#510 attribution and the `.gitignore` line-68 evidence are recorded: `.claude/state/python-batch-budget.default.json` is a gitignored, regenerating counter, absent from a clean checkout, so CI is unaffected.
