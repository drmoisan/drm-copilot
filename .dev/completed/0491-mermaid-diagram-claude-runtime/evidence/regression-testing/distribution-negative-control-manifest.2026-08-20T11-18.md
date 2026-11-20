# Distribution Negative Control: Manifest Completeness (issue #491, [P5-T8], [expect-fail])

Timestamp: 2026-08-20T11-18

This is an `[expect-fail]` task. Both suites are required to fail here: that is what proves the
completeness gates can fail for this change, and it is what makes the green runs at [P5-T11] and
[P7-T6]/[P7-T8] evidence rather than a vacuous pass.

State at the time of the runs: every mirror under
`extensions/drm-copilot/resources/claude-customizations/.claude/` exists and is byte-identical
([P5-T3], [P5-T5], [P5-T6], [P5-T7] complete), and NO `pack-manifests/core.json` entry has been
added yet.

## TypeScript suite

Command: `cd extensions/drm-copilot && npx jest test/lib/push-down/claude-pack-manifest-completeness.test.ts`
EXIT_CODE: 1
Output Summary: `Test Suites: 1 failed, 1 total; Tests: 1 failed, 14 passed, 15 total`. The failing
test is "lists every bundled .claude agent, skill, and hook file in some pack manifest" at
`test/lib/push-down/claude-pack-manifest-completeness.test.ts:213`. The reported `missing` array
holds seven paths:

```text
.claude/hooks/enforce-mermaid-validation.ps1
.claude/lib/mermaid/MermaidGrammar.psm1
.claude/lib/mermaid/MermaidLineScanner.psm1
.claude/lib/mermaid/MermaidMarkdownFences.psm1
.claude/lib/mermaid/MermaidValidation.psm1
.claude/rules/mermaid.md
.claude/skills/mermaid-diagram/SKILL.md
```

This matches the predicted split: the TypeScript walker enumerates `rules/*.md` and recursive
`lib/**` in addition to hooks and `skills/<name>/SKILL.md`.

## Python suite

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q`
EXIT_CODE: 1
Output Summary: `1 failed, 1 passed in 0.07s`. The failing test is
`test_bundled_claude_files_are_listed_in_some_pack_manifest` at
`tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py:157`, with:

```text
AssertionError: Bundled .claude files missing from every manifest:
['.claude/hooks/enforce-mermaid-validation.ps1', '.claude/skills/mermaid-diagram/SKILL.md']
```

Two paths only, matching the prediction: the Python enumerator covers `agents/*.md`, `hooks/*`, and
`skills/<name>/SKILL.md`, and does NOT cover `rules/` or `lib/`.

## The unguarded class (D5), confirmed empirically

Neither failing list contains a single
`.claude/skills/mermaid-diagram/references/*.md` path. Nine such files exist on disk and are
mirrored, and no suite in either language notices that they are absent from every manifest. That is
the issue #279 silent-drop failure mode, unguarded for this file class, and it is the reason
[P5-T10] adds one explicit `core.json` entry per reference file and verifies each by search rather
than relying on a suite to catch an omission.

Verdict: both completeness gates are shown capable of failing; the reference-file class is confirmed
to be guarded by neither. AC-21 partial.
