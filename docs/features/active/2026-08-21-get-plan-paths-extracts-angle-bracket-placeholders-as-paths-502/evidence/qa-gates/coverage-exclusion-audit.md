# QA Gate — Coverage-Exclusion Audit — [P8-T12]

Timestamp: 2026-08-23T05-34

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T12]
Run: revision-6 re-run, over a diff that has changed by one removed fixture and two edited test files.

Command: `git add -A` (at the repository root)

Command: `git diff main`

Command: `git rev-parse main`

Resolved `main` SHA: `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`

EXIT_CODE: 0

## Why staging is required even though exclusion entries live in tracked files

An unstaged diff is an incomplete diff, and this audit's claim is negative — that no exclusion entry
was added *anywhere* in the change. A negative claim is only as broad as the diff it reads, so the diff
must contain the whole change including newly created files. `git add -A` was run at the repository
root before the diff was taken.

Ref-position note: `main` is not an ancestor of `HEAD` (`origin/main` is 27 commits ahead, `HEAD` is 9
ahead, after issue #500 merged as pull request #514), so the audit was performed against the merge base
`bee15c0660d382ed74c642d2e028fd136051046f`, a fixed commit whose diff contains exactly this branch's
changes. Both anchors were resolved and recorded. No rebase or merge was performed.

## Diff file-list completeness

The staged name-status list contains **all eight** created paths, verified per path by exact match. The
full table is at [P8-T5].

## No coverage exclusion entry matching a production source path was added

### Coverage configuration files touched by the diff

Only two, and both are the same file mirrored:

- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

Their complete diff, identical in both copies:

```text
-            # helper modules. The set is split across six files only to satisfy the
+            # helper modules. The set is split across seven files only to satisfy the
+            # Issue #502 added BlastRadiusTokenShape.psm1, the seventh file. It holds the
+            # new placeholder-marker predicate plus Test-MultipleFeatureFolderSpan
+            # relocated out of BlastRadiusExtraction.psm1, which had two lines of
+            # headroom left. CodeCoverage.Path is an explicit per-file allow-list, so
+            # without this entry the new production module and the relocated
+            # already-measured lines would both sit outside the coverage denominator,
+            # which the Coverage Exclusion Policy forbids.
+            '.claude/lib/blast-radius/BlastRadiusTokenShape.psm1'
```

The change is one **added allow-list entry** plus comment text. `CodeCoverage.Path` is an inclusion
list, not an exclusion list, so an addition to it can only widen measurement. The only removed line is
the corrected file-count word inside a comment, and no configuration key was added or removed.

### No exclusion key exists in either runsettings

A search for an actual assignment of `Exclude`, `ExcludeTests`, or `CoverageExclude` in either copy
returns **nothing**:

```text
$ grep -nE "^\s*(Exclude|ExcludeTests|CoverageExclude)\s*=" <both runsettings>
  none
```

Every occurrence of the word "exclude" in either file is prose inside a comment explaining why a file
was *added* so that it would not be excluded. Distinguishing the key from the comment is what makes this
check meaningful: a bare keyword grep matches 18 comment lines per copy and would look alarming while
proving nothing.

### Python coverage configuration untouched

`pyproject.toml` does not appear in the diff at all (fixed-string file-name match count: **0**). Its
coverage `omit` list is therefore unchanged and remains four entries — `tests/*`, `*/tests/*`,
`*/__pycache__/*`, `*/site-packages/*` — all non-production paths permitted by the Coverage Exclusion
Policy. None matches a path under a production source tree.

That the Python config is untouched is worth stating on this run specifically: [P5-T3] added a Python
test, and a test addition is exactly the circumstance under which someone might be tempted to widen an
`omit` entry. None was widened.

## Both new production modules are in their runtime's coverage denominator

| Module | Runtime | Denominator mechanism | Measured result |
| --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_token_shapes.py` | Python | `[tool.coverage.run] source` includes `scripts/dev_tools`, and no `omit` entry matches it | Stmts 14, Miss **0**, Branch 4, BrPart **0** — 100% line, 100% branch ([P8-T4]) |
| `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | PowerShell | added to `CodeCoverage.Path` in both runsettings copies by [P4-T4] and [P4-T5] | LINE missed **0**, covered 19 — 100% line ([P8-T9]) |

The Python module needed no registration: the source root already covers `scripts/dev_tools` and it
appeared in the [P8-T4] coverage table automatically. The PowerShell module needed registration because
`CodeCoverage.Path` is an explicit per-file allow-list, and it received it.

One boundary is recorded rather than glossed: the MCP-driven Pester run reads a runsettings copy from
the published npm package rather than from the repository, so its coverage output does not yet list the
new module. That is a publish-cadence boundary, not an exclusion — both in-repository allow-lists name
the file, and a direct measurement on this tree shows it measured at 100%. Root-cause evidence is at
[P8-T8]. Nothing in this change excludes the file from measurement.

## Output Summary

`git add -A` was run at the repository root and the whole-tree anchored diff was taken; the file list
contains **all eight** created paths. The only coverage configuration touched is the Pester allow-list,
and the only change to it is **one added inclusion entry** plus comment text. Neither runsettings copy
contains an exclusion key at all. `pyproject.toml` is untouched. No exclusion entry of any kind, in any
configuration file, matching any production source path was added. Both new production modules are in
their runtime's coverage denominator and both measure 100% line coverage.
