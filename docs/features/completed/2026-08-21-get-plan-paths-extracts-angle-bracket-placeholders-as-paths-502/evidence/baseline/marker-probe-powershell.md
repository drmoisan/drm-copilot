# Baseline — Five-Marker Probe, PowerShell Runtime — [P0-T13]

Timestamp: 2026-08-23T01-03

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T13]
State captured: PRE-CHANGE baseline

Command: `pwsh -NoProfile -File <probe script>` where the probe script imports
`.claude/lib/blast-radius/BlastRadiusConfig.psm1` and
`.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, reads the blast-radius truth table for its
root-surface set via `Get-ConfigRootSurface`, and classifies one probe per marker with
`Get-PathTokenKind`.

EXIT_CODE: 0

The probe script was written outside the repository tree (session scratchpad). It is not a Pester
test file and adds nothing to the tracked tree.

## Single-quote constraint — stated explicitly

**No double-quoted string was used for any probe literal in this probe.** Every probe literal is
either single-quoted or built by character concatenation. The two marker literals that PowerShell
would otherwise expand are built by concatenation specifically so their content cannot be
misread:

```text
$markerDollarBrace = '$' + '{'
$markerDollarParen = '$' + '('
```

The constraint is recorded in the script itself as a leading comment stating the rule and the
reason for it: a double-quoted PowerShell string expands the `$(` subexpression form and the
`${` variable form before the classifier ever sees them, so a double-quoted probe silently
classifies a *different* token than the one written. That is precisely the mis-measurement the
plan's design constraint exists to prevent.

## Literal-content assertion before classification

Each case asserts its probe's literal content before classification. The assertion is an ordinal
`IndexOf` for the case's own marker, which throws if the marker is absent, plus the probe's
character length recorded in the output. The lengths below are the independent check that no
expansion occurred:

| Probe | Expected length | Recorded length |
| --- | --- | --- |
| `docs/features/active/<feature/plan.md` | 37 | 37 |
| `docs/features/active/feature>/plan.md` | 37 | 37 |
| `.claude/state/${session_id}.json` | 32 | 32 |
| `.claude/state/$(session).json` | 29 | 29 |
| `.claude/state/%SESSION%.json` | 28 | 28 |

An expanded `${session_id}` would have collapsed to the empty string and yielded length 19; an
expanded `$(session)` would have thrown or collapsed. Every recorded length matches the written
literal exactly.

## Isolated single-marker probes

Root-surface set size: 3, read from the same truth table the production entry points use.

| Marker | Probe literal | Returned classification |
| --- | --- | --- |
| `<` | `docs/features/active/<feature/plan.md` | `'concrete'` |
| `>` | `docs/features/active/feature>/plan.md` | `'concrete'` |
| `${` | `.claude/state/${session_id}.json` | `'concrete'` |
| `$(` | `.claude/state/$(session).json` | `'concrete'` |
| `%` | `.claude/state/%SESSION%.json` | `'concrete'` |

Raw output, verbatim:

```text
root_surface count: 3
=== ISOLATED SINGLE-MARKER PROBES ===
marker=< literal_len=37 probe=docs/features/active/<feature/plan.md -> 'concrete'
marker=> literal_len=37 probe=docs/features/active/feature>/plan.md -> 'concrete'
marker=${ literal_len=32 probe=.claude/state/${session_id}.json -> 'concrete'
marker=$( literal_len=29 probe=.claude/state/$(session).json -> 'concrete'
marker=% literal_len=28 probe=.claude/state/%SESSION%.json -> 'concrete'
```

**All five markers are accepted as concrete repository paths**, identical to the Python runtime's
result recorded in `evidence/baseline/marker-probe-python.md`. No marker is already rejected, so
the Phase 3 marker array remains the full five-member set.

## Dominant corpus tokens

```text
=== DOMINANT CORPUS TOKENS ===
probe=<FEATURE>/evidence/baseline/phase0-instructions-read.md -> 'concrete'
probe=<FEATURE>/spec.md -> 'concrete'
probe=<FEATURE>/issue.md -> 'concrete'
probe=<FEATURE>/user-story.md -> 'concrete'
probe=.claude/state/powershell-batch-budget.<session_id>.json -> 'concrete'
probe=.claude/skills/<name>/SKILL.md -> 'concrete'
probe=.claude/agents/<name>.md -> 'concrete'
probe=docs/features/parallel/<slug>/parallel.md -> 'concrete'
probe=docs/features/parallel/<slug>/parallel-kickoff.md -> 'concrete'
```

All nine accepted, matching the Python result exactly.

## Marker-free controls

```text
=== MARKER-FREE CONTROLS ===
probe=scripts/dev_tools/_blast_radius_extraction.py -> 'concrete'
probe=.claude/** -> 'glob'
probe=package-lock.json -> 'concrete'
```

Identical to the Python runtime's control results, confirming cross-runtime parity of the
pre-change classifier on marker-free input as well.

## Output Summary

All five markers (`<`, `>`, `${`, `$(`, `%`) are currently accepted by `Get-PathTokenKind` as
`'concrete'` repository paths, as are all nine dominant corpus placeholder tokens. The results
match the Python runtime exactly. No double-quoted probe string was used; every probe's literal
content was asserted before classification and its character length is recorded as independent
proof that no PowerShell expansion occurred.
