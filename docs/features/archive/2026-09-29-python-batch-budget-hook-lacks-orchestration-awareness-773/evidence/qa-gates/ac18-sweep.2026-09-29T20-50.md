# AC-18 Phrase Sweep (P10-T1)

Timestamp: 2026-09-29T20-50
Command: git grep -n -i -F -e 'per-batch' -e 'per batch' -e 'batch cap' -e 'smaller batches' -e 'split the work' -e 'new batch' -e 'three-test' -e 'in-flight batch' -e 'budget: prod=' -e 'budget override' -e 'seek an override' -- '.claude/*python*' '.agents/*python*' '.codex/*python*' '.github/agents/*python*' '.github/skills/*python*' '.github/prompts/*python*' 'extensions/drm-copilot/resources/claude-customizations/.claude/*python*' 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/*python*' 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/*python*' 'extensions/drm-copilot/resources/customizations/.github/agents/*python*' 'extensions/drm-copilot/resources/customizations/.github/skills/*python*' 'extensions/drm-copilot/resources/customizations/.github/prompts/*python*' ':(exclude).github/agents/python-execution-only-typed.agent.md' ':(exclude)extensions/drm-copilot/resources/customizations/.github/agents/python-execution-only-typed.agent.md'
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Exit 1 with no output. The same sweep matched 96 lines across 28 files at baseline (ac18-sweep.2026-09-29T19-13.md), so the search is non-vacuous. All targets are tracked and committed.
