# Claude Bundle Parity After Remediation

Timestamp: 2026-08-29T13:23:00-04:00

Command: For each path below, run `git hash-object -- <canonical-path>` and `git hash-object -- extensions/drm-copilot/resources/claude-customizations/<canonical-path>`, then compare the two hashes.

EXIT_CODE: 0

Output Summary: all 14 changed canonical Claude runtime paths have byte-identical published mirrors. P7-T2 changed only the repository test; no production hook copy was required.

| Canonical path | Canonical hash | Mirror hash | Result |
| --- | --- | --- | --- |
| `.claude/agents/task-researcher.md` | `8af526884ac717f10b0e2f3b9bf0d4d7beab32ae` | `8af526884ac717f10b0e2f3b9bf0d4d7beab32ae` | Match |
| `.claude/skills/research-issue/SKILL.md` | `28bb908304a0e3b5f961eae51d703027cee71e0e` | `28bb908304a0e3b5f961eae51d703027cee71e0e` | Match |
| `.claude/agents/prd-feature.md` | `6ebc4a618bdc449325e9f767f73d9834f17f1bdd` | `6ebc4a618bdc449325e9f767f73d9834f17f1bdd` | Match |
| `.claude/skills/fill-feature-docs/SKILL.md` | `bbbcc78f562ec7e7bd18aedec0ab8a448ad7d366` | `bbbcc78f562ec7e7bd18aedec0ab8a448ad7d366` | Match |
| `.claude/hooks/validate-task-researcher-output.ps1` | `d2d21fe025da605bb8ccf402b3547374b440a870` | `d2d21fe025da605bb8ccf402b3547374b440a870` | Match |
| `.claude/hooks/validate-prd-feature-output.ps1` | `a197242f2932bd328648b59b141e55abb279ef12` | `a197242f2932bd328648b59b141e55abb279ef12` | Match |
| `.claude/skills/atomic-plan-contract/SKILL.md` | `4bf3fa70ede44fd9de459cf1b97b353fd9c60f39` | `4bf3fa70ede44fd9de459cf1b97b353fd9c60f39` | Match |
| `.claude/agents/atomic-planner.md` | `0eb23b25823c0ca80e87ff7e528876d97b628ab8` | `0eb23b25823c0ca80e87ff7e528876d97b628ab8` | Match |
| `.claude/hooks/validate-planner-output.ps1` | `5d399cefa4aeed11aff9f2b3b0b785f11d0641e3` | `5d399cefa4aeed11aff9f2b3b0b785f11d0641e3` | Match |
| `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | `a6a0db7d05df2a356ab44450fe62ee1f387fdd72` | `a6a0db7d05df2a356ab44450fe62ee1f387fdd72` | Match |
| `.claude/skills/acceptance-criteria-tracking/SKILL.md` | `3a9b2fbf4a9d09547e210d15f5bd46900638793c` | `3a9b2fbf4a9d09547e210d15f5bd46900638793c` | Match |
| `.claude/lib/requirements/GeneratedDocumentCounters.psm1` | `cff91f0159a853b6ea840c877af9d9208ecc4bf0` | `cff91f0159a853b6ea840c877af9d9208ecc4bf0` | Match |
| `.claude/skills/parallel-plan/SKILL.md` | `48b9a401fe725e738e2aedfe167006780870573c` | `48b9a401fe725e738e2aedfe167006780870573c` | Match |
| `.claude/skills/parallel-add/SKILL.md` | `2dc3d89953887302ab73b33ff84ff93f19dd8bd2` | `2dc3d89953887302ab73b33ff84ff93f19dd8bd2` | Match |
