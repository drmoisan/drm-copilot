# Bundle Copies

Timestamp: 2026-10-31T15-54
Command: poetry run python SCRATCH/issue-1013-bundle-copy.py --copy (byte copy of each source to `extensions/drm-copilot/resources/claude-customizations/<source>`, then SHA-256 of both files)
EXIT_CODE: 0
Output Summary: twelve sources copied; EQUAL_PAIRS=12/12.

| Source | Source SHA-256 | Bundle SHA-256 | Result |
|---|---|---|---|
| `.claude/rules/parallel-orchestration.md` | `8dc56ae265ec41a15ddd40ab00792cfa658b60c2f790a22e8177d93ea617e91f` | `8dc56ae265ec41a15ddd40ab00792cfa658b60c2f790a22e8177d93ea617e91f` | equal |
| `.claude/skills/parallel-plan/SKILL.md` | `7da4953f3bdc8832a3f67746ea0e080fac291f12cb6994831a7e7f0b973ce59c` | `7da4953f3bdc8832a3f67746ea0e080fac291f12cb6994831a7e7f0b973ce59c` | equal |
| `.claude/skills/parallel-add/SKILL.md` | `ead846a6f80a39dae0887a2b14544be57a00b3b2596df6079f10a892a004e94d` | `ead846a6f80a39dae0887a2b14544be57a00b3b2596df6079f10a892a004e94d` | equal |
| `.claude/skills/parallel-orchestrate/SKILL.md` | `d6b6ee3067058100ba6f514dd39122eff11bc7b0b9b17a8cea09f278ff2753a8` | `d6b6ee3067058100ba6f514dd39122eff11bc7b0b9b17a8cea09f278ff2753a8` | equal |
| `.claude/skills/orchestrate/SKILL.md` | `d054b694bb28c83873450aa50332395aeb0fd25b44a0d919821f9287966c70e5` | `d054b694bb28c83873450aa50332395aeb0fd25b44a0d919821f9287966c70e5` | equal |
| `.claude/skills/pr-author/SKILL.md` | `225a60ee501512db98e6b7154d4985c61bea098330218c2a8cecb16974585de7` | `225a60ee501512db98e6b7154d4985c61bea098330218c2a8cecb16974585de7` | equal |
| `.claude/agents/parallel-planner.md` | `4a5afdda7b06f145dbf5f59c2a0f07ccc9d6c673dbce16111e4d24f0522bc256` | `4a5afdda7b06f145dbf5f59c2a0f07ccc9d6c673dbce16111e4d24f0522bc256` | equal |
| `.claude/agents/parallel-orchestrator.md` | `4d0ac383db218a75979d1922efa2f8b7f02d1bbb7e772b2dbcdbbf21a27c73fe` | `4d0ac383db218a75979d1922efa2f8b7f02d1bbb7e772b2dbcdbbf21a27c73fe` | equal |
| `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | `23d2dd0aaeb1d19baebb6718943ac60b03c87989d2d936cd1328529982f812f0` | `23d2dd0aaeb1d19baebb6718943ac60b03c87989d2d936cd1328529982f812f0` | equal |
| `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` | `eba9f297b2536531b5d3916a23e9d10c431076b27dc2ed8652ae726b89cf2b7a` | `eba9f297b2536531b5d3916a23e9d10c431076b27dc2ed8652ae726b89cf2b7a` | equal |
| `.claude/lib/blast-radius/BlastRadiusCombination.psm1` | `6e3d44ce777a7c95f036b59c85185357fdf5988c4d39f6c64e9b848eb34b60ad` | `6e3d44ce777a7c95f036b59c85185357fdf5988c4d39f6c64e9b848eb34b60ad` | equal |
| `.claude/lib/blast-radius/BlastRadius.psm1` | `49cc50d4124597e5b81454e8fbe279cf101effee46ffe6845e40b8d7a6b7b538` | `49cc50d4124597e5b81454e8fbe279cf101effee46ffe6845e40b8d7a6b7b538` | equal |

The new test files are not bundled.
