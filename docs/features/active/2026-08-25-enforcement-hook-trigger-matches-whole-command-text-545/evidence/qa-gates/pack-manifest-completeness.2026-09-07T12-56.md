# Pack-manifest completeness — the mechanisms that observe the [P4-T7] registration

Timestamp: 2026-09-07T12-56

Task: [P4-T13]

Both suites enumerate the bundled `.claude` tree from disk and require every bundled file to appear in
some pack manifest, so they are what actually observes the [P4-T7] registration. If
[P4-T1] and [P4-T2] had added the two bundle mirrors without [P4-T7] adding their manifest entries,
these suites would fail.

## Python suite

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q`

EXIT_CODE: 0

Result: **2 passed, 0 failed** in 0.05s.

Per-case results, from the `-v` run:

| Test node ID | Result |
| --- | --- |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest` | **PASSED** |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_documented_exceptions_remain_absent_from_every_manifest` | **PASSED** |

The first is the case the task names. The second is its complement and is recorded because it is the
case that would fail had a path been registered that is documented as deliberately unregistered; both
being green means the two new entries were added to the manifest and neither collided with an
exception.

## TypeScript twin

Command: `npx jest --runTestsByPath test/lib/push-down/claude-pack-manifest-completeness.test.ts`,
run from `extensions/drm-copilot`

EXIT_CODE: 0

Result: **Test Suites: 1 passed, 1 total. Tests: 16 passed, 16 total.** 0 failed. Time 0.363s.

The TypeScript twin's titles, read from
`extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`:

| Suite / test title | Line | Result |
| --- | --- | --- |
| `describe("claude pack manifest completeness (real filesystem)")` | 198 | — |
| `it("lists every bundled .claude agent, skill, and hook file in some pack manifest")` | 199 | **passed** |
| `it("lists every bundled config/ file in some pack manifest")` | 216 | **passed** |

The first of those two is the direct twin of
`test_bundled_claude_files_are_listed_in_some_pack_manifest`: it is the real-filesystem case that walks
the bundled `.claude/hooks` directory, so it is the case that observes
`hook-command-scanner.ps1` and `hook-command-invocation.ps1` arriving in
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.

The reported total of 16 tests against 2 titles in the `describe` block above is not a discrepancy: the
file also contains unit-level cases outside that real-filesystem block, and the aggregate count covers
the whole file. What the task requires is the named case's result, and it passed, as did every other
case in the file.

Recorded for audit: `--verbose` produced no per-test lines in this environment; the reporter emitted
only the aggregate block. The per-title results above are therefore attributed by reading the test
file for its titles and pairing them with a suite-level result of 16 passed and 0 failed, under which
no individual case can have failed.

## Coverage of the Codex side

Neither suite covers `extensions/drm-copilot/resources/codex-and-agents-customizations/`; both are
scoped to the bundled `.claude` tree by name. The [P4-T8] Codex manifest registration is observed
instead by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, whose pack-manifest leg
iterates `$script:StaticCheckNames` — which [P4-T9] extended to include both new files — against
`extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`. That suite
runs at [P4-T15]. This is recorded so the absence of a Codex assertion here is not read as an
unobserved registration.

Output Summary: both mechanisms report zero failed tests.
`test_bundled_claude_files_are_listed_in_some_pack_manifest` **PASSED** and
`test_documented_exceptions_remain_absent_from_every_manifest` **PASSED** (2 passed, 0 failed). The
TypeScript twin `lists every bundled .claude agent, skill, and hook file in some pack manifest` passed
within a suite result of **16 passed, 0 failed**. The two Claude bundle parser mirrors are therefore
registered in a pack manifest as [P4-T7] requires.
