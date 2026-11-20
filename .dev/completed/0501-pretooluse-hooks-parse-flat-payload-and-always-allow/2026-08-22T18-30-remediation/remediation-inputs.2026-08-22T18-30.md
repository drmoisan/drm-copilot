# Remediation inputs — cycle 2 (#501)

- **Cycle trigger:** CI failure on PR #503 at head `0a383439`. Converted to a synthetic Blocking finding per the orchestrate skill's CI-failure handling.
- **Pull request:** https://github.com/drmoisan/drm-copilot/pull/503
- **Entry timestamp:** 2026-08-22T18:30Z
- **Source:** `gh pr checks 503` plus `gh run view --log-failed` against the failing runs.

## Failing required checks

| Check | Conclusion |
| --- | --- |
| `quality-checks7 / Code Quality & Tests (3.11)` | FAILURE |
| `Extension Tests (ubuntu-latest)` | FAILURE |
| `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` | FAILURE |
| `root-typescript-tests / Root TypeScript Tests (ubuntu-latest)` | FAILURE |

The windows-latest counterparts and the 3.10/3.12/3.13 matrix legs were CANCELLED by the fail-fast cascade rather than failing on their own; they are not independent failures.

## Blocking finding to remediate

Severity: Blocking

**New files added to the bundled `.claude` tree are not registered in any pack manifest.**

Both runtimes assert the same contract and both fail on it:

- Python — `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest`:

  ```
  AssertionError: Bundled .claude files missing from every manifest:
  ['.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1',
   '.claude/hooks/enforce-pr-author-skill-helpers.ps1']
  ```

  Result: 1 failed, 4061 passed, 5 skipped.

- TypeScript — `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`, test `lists every bundled .claude agent, skill, and hook file in some pack manifest`, at the assertion commented `// Assert: no bundled file is silently dropped from every manifest.` Result: 1 failed, 2670 passed, 197 suites passed.

The two runtimes report different counts because they scope differently; the TypeScript suite also covers `.claude/lib/`.

### Files requiring registration

Three files introduced by this branch:

1. `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` — extracted from `enforce-parallel-cohort-barrier.ps1` to stay under the 500-line ceiling.
2. `.claude/hooks/enforce-pr-author-skill-helpers.ps1` — extracted from `enforce-pr-author-skill.ps1` for the same reason.
3. `.claude/lib/hook-payload/HookPayload.psm1` — the shared payload reader, the core of the fix.

Three further files are unregistered but pre-existing and already tolerated by both suites as documented exceptions; they are **not** in scope and must not be registered as a side effect: `.claude/agents/pr-author.md`, `.claude/hooks/enforce-completion-helpers.ps1`, `.claude/hooks/validate-pr-author-output.ps1`.

### Why local gates did not catch this

This is the actionable part, and it should shape the fix rather than only the patch.

- The local QA loop ran the **targeted** parity test `test_push_down_claude_resource_contracts.py -k test_bundled_claude_payload_contains_all_repo_runtime_contracts`, which asserts **byte parity** between `.claude/**` and the bundle. It passed, correctly — the files are mirrored byte-for-byte. Registration in a pack manifest is a *different* contract, asserted by a *sibling* file in the same directory that the targeted selector excluded.
- The full `pytest` suite would have caught it. The plan's final QA never ran it, only the single selected test.
- The TypeScript suite is not part of the PowerShell QC loop at all, so no local stage could have surfaced the TS failure.

The remediation should therefore consider whether the final-QA phase of a plan touching `.claude/**` ought to run the full Python suite and the extension suite, not only targeted selectors. A byte-parity gate that passes while a registration gate fails is precisely the kind of partial verification this feature exists to eliminate.

## Verification commands

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py
poetry run pytest
npx jest --config extensions/drm-copilot/jest.config.cjs test/lib/push-down/claude-pack-manifest-completeness.test.ts
```

## Exit condition

Both named tests pass, the full Python suite passes, the extension suite passes, and a fresh CI run against the branch head reports every required check green.
