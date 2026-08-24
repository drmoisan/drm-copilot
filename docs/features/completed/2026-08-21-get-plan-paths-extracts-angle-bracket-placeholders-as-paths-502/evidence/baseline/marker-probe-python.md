# Baseline — Five-Marker Probe, Python Runtime — [P0-T12]

Timestamp: 2026-08-23T00-58

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T12]
State captured: PRE-CHANGE baseline

Command: `poetry run python <probe script>` where the probe script imports
`classify_path_token` from `scripts/dev_tools/_blast_radius_extraction.py` and
`config_root_surfaces` from `scripts/dev_tools/_blast_radius_validation.py`, reads the
blast-radius truth table for its root-surface set, and classifies one probe per marker.

EXIT_CODE: 0

The probe script was written outside the repository tree (session scratchpad) and is not a test
file, so it creates no runtime temporary file inside any test and adds nothing to the tracked tree.

## Probe construction

Every probe literal is a Python single-quoted or double-quoted string with no interpolation
syntax evaluated by Python: the marker characters appear inside plain string literals, so the
literal content reaching the classifier is exactly the text shown. The classifier received the
configured root-surface set (3 entries) so that the root-surface membership branch is exercised
exactly as in production.

## Isolated single-marker probes

Each probe carries exactly one of the five markers under repair, so a per-marker determination is
possible rather than inferred from a token carrying several.

| Marker | Probe literal | Returned classification |
| --- | --- | --- |
| `<` | `docs/features/active/<feature/plan.md` | `'concrete'` |
| `>` | `docs/features/active/feature>/plan.md` | `'concrete'` |
| `${` | `.claude/state/${session_id}.json` | `'concrete'` |
| `$(` | `.claude/state/$(session).json` | `'concrete'` |
| `%` | `.claude/state/%SESSION%.json` | `'concrete'` |

Raw output, verbatim:

```text
=== ISOLATED SINGLE-MARKER PROBES ===
marker=<   probe=docs/features/active/<feature/plan.md              -> 'concrete'
marker=>   probe=docs/features/active/feature>/plan.md              -> 'concrete'
marker=${  probe=.claude/state/${session_id}.json                   -> 'concrete'
marker=$(  probe=.claude/state/$(session).json                      -> 'concrete'
marker=%   probe=.claude/state/%SESSION%.json                       -> 'concrete'
```

**All five markers are accepted as concrete repository paths.** No marker is already rejected, so
the marker tuple is not narrowed in Phase 2: it remains the full five-member set
`<`, `>`, `${`, `$(`, `%`.

## Dominant corpus tokens

The nine tokens the plan identifies as the corpus's dominant placeholder shapes were probed for the
same determination against real citation text rather than constructed probes.

```text
=== DOMINANT CORPUS TOKENS ===
probe=<FEATURE>/evidence/baseline/phase0-instructions-read.md      -> 'concrete'
probe=<FEATURE>/spec.md                                            -> 'concrete'
probe=<FEATURE>/issue.md                                           -> 'concrete'
probe=<FEATURE>/user-story.md                                      -> 'concrete'
probe=.claude/state/powershell-batch-budget.<session_id>.json      -> 'concrete'
probe=.claude/skills/<name>/SKILL.md                               -> 'concrete'
probe=.claude/agents/<name>.md                                     -> 'concrete'
probe=docs/features/parallel/<slug>/parallel.md                    -> 'concrete'
probe=docs/features/parallel/<slug>/parallel-kickoff.md            -> 'concrete'
```

All nine are accepted as concrete paths. Each therefore becomes a `paths` entry in every radius
derived from a plan that cites it, and two items citing the same token acquire a `path_overlap`
conflict edge on a string that names no file.

## Marker-free controls

Recorded so the probe is shown to discriminate rather than to accept everything.

```text
=== MARKER-FREE CONTROLS ===
probe=scripts/dev_tools/_blast_radius_extraction.py                -> 'concrete'
probe=.claude/**                                                   -> 'glob'
probe=package-lock.json                                            -> 'concrete'
```

The recognized-extension rule, the known-segment subtree-glob rule, and the configured-root-surface
rule each resolve as expected, so the classifier is functioning normally on marker-free input.

## Output Summary

The code-trace determination is converted to a measurement: all five markers
(`<`, `>`, `${`, `$(`, `%`) are currently accepted by `classify_path_token` as `'concrete'`
repository paths, as are all nine dominant corpus placeholder tokens. No marker is already
rejected, so the Phase 2 marker tuple stays at five members. The three marker-free controls
classify correctly, confirming the probe discriminates.
