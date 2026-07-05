# Reference Resolution Check — Issue #312

Timestamp: 2026-07-05T13-15
Command: grep -rn "Get-ComplexityFloor|Resolve-DelegationModel|ModelRouting.psm1" and path-existence checks across the source `.claude/` tree and the `extensions/drm-copilot/resources/claude-customizations/.claude/` byte-mirror tree; plus grep for retained Python validator-authority citations.
EXIT_CODE: 0

Output Summary:
- Module presence: `.claude/lib/model-routing/ModelRouting.psm1` exists in BOTH the source tree and the byte-mirror tree.
- Orchestrator-runs citations repointed (source + mirror, byte-identical):
  - `.claude/skills/orchestrate/SKILL.md` lines 32, 34 (resume-step block) and 86, 87 (Model Selection bullets) name `.claude/lib/model-routing/ModelRouting.psm1` with `Get-ComplexityFloor` / `Resolve-DelegationModel`.
  - `.claude/skills/epic-orchestrate/SKILL.md` lines 118-120 name the PowerShell module and both functions.
- No dangling orchestrator-runs reference remains: the two `scripts/dev_tools/*formula*.py` files are no longer cited as the reference the orchestrator is instructed to run. The only remaining `.py` mention in `orchestrate/SKILL.md` (line 89) is the intentional clarifying sentence that names the two Python files as the repository VALIDATOR authority (both files exist in the repo), not as a runtime reference; it is mirrored byte-identically.
- Validator-authority split intact (retained Python citations, unchanged):
  - `orchestrate/SKILL.md` line 65, 98, 102 still reference `scripts/dev_tools/validate_orchestrator_state.py` and `scripts/dev_tools/_orchestrator_state_model_routing_gate.py` (offsets shifted +2 from the plan's cited lines 96/100 because a clarifying sentence was added; content and target paths unchanged).
  - `.claude/rules/orchestrator-state.md` lines 47 and 61 still point at `scripts/dev_tools/compute_complexity_floor.py` and `scripts/dev_tools/resolve_delegation_model.py` (the Python reference implementations the validator recomputes against).
- Result: no dangling orchestrator-runs reference; the destination-runtime PowerShell reference and the repo Python validator authority are both resolvable and correctly separated.
