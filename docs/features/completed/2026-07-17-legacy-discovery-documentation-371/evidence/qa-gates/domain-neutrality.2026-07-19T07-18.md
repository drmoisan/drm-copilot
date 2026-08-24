# P2-T3 — Domain-Neutrality Invariant Verification

- Timestamp: 2026-07-19T07-18
- Command: `grep -ni -E "TaskMaster|TMW|Outlook|VSTO|email|task-management" docs/engineering/legacy-discovery-and-parity/*.md`
- EXIT_CODE: 0 (matches found; grep exits 0 when matches are found)

## Output Summary

18 matching lines across four files. Every match is classified below. Zero matches
describe TaskMaster/TMW/Outlook/email/task-management-specific *business behavior* as
framework behavior.

| File | Line(s) | Match | Classification |
|---|---|---|---|
| `README.md` | 17, 20 | `TaskMaster/TMW/Outlook/VSTO/email/task-management` | invariant-statement — the literal invariant sentence under `## Domain-Neutrality Invariant`, naming these terms specifically to state they are *not* framework behavior. |
| `README.md` | 45 | `TaskMaster and TMW` | example — index-table description of `consumer-onboarding.md`'s worked-example content. |
| `domain-profile.md` | 40 | `TaskMaster's profile and TMW's profile` | example — an illustrative cross-reference to the dedicated onboarding page's worked example, immediately followed by "two independent instances of the same domain-neutral contract." |
| `consumer-onboarding.md` | 5, 72, 74, 77, 78, 79, 80, 81, 83 | `TaskMaster` / `TMW` | example — all nine occurrences are inside the page's introduction (scoping TaskMaster/TMW to the labeled example section) or the `## Worked Example: Onboarding TaskMaster and TMW` section itself. |
| `running-the-workflow.md` | 32, 60, 86 | `VSTO` (as `dev.discovery.vsto`, `run_discovery_vsto_analyzer`, `drmCopilotExtension.runDiscoveryVstoAnalyzer`) | generic-technology-analyzer naming, not domain-specific business behavior — these name the .NET/VSTO stack analyzer, a technology-detection capability (delivered by `legacy-discovery-dotnet-vsto-analyzers`, #369) selected generically by the domain profile's `technology_stack` field for any consumer whose stack includes it, analogous to naming a ".NET analyzer." #369's own spec documents this analyzer as domain-neutral with its own consumer-neutrality contract test; no TaskMaster- or Outlook-business-specific behavior (mail items, task hierarchy, etc.) is described. |
| `workflow.md` | 29, 30 | `VSTO` (as "the VSTO/Office analyzer", `dev.discovery.vsto`) | generic-technology-analyzer naming — same reasoning as above; the surrounding sentence names it alongside "the .NET analyzer" as one of two stack-specific analyzers selected by profile configuration. |

Zero matches describe a domain-specific *business* behavior as framework behavior. Every
`TaskMaster`/`TMW` occurrence outside the invariant statement itself is confined to
labeled example sections. The `VSTO` occurrences name a generic, profile-selected
technology analyzer rather than domain-specific business behavior, consistent with #369's
own domain-neutrality framing. Satisfies spec AC 7 and user-story AC 5.
