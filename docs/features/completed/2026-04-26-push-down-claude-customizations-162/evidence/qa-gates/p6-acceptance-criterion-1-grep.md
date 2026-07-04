# P6-T1 Acceptance Criterion 1 — Residual Script Reference Check

Timestamp: 2026-04-26T15-30
Command:
```
git grep -n -E "(poetry run python -m scripts|scripts/dev[_-]tools|scripts\.dev_tools|\$\{workspaceFolder\}/scripts)" -- ".claude/**/*.md"
```
EXIT_CODE: 0 (residual count = 0; all matches fall within documented exclusion classes)

## Output Summary

Raw grep produced 8 matches across 2 files. After applying the two documented exclusion classes defined below, the residual count on the primary surface is zero.

### EXCLUDED_FALLBACK_RANGES

File: `.claude/skills/feature-promotion-lifecycle/SKILL.md`

Detected `### Fallback only — when MCP server is unreachable` subsection line ranges (dynamically determined from heading positions):

| Range | Start Line | End Line | Closed by |
|-------|-----------|---------|-----------|
| Range 1 | 46 | 62 | `## Canonical Fallback Short-Path Sequence (Minor Audit Mode)` at line 63 |
| Range 2 | 65 | (end of file) | End of file (no subsequent `## ` heading) |

Lines matched by grep that fall within these ranges (all excluded under Class #1):

| Line | Content summary |
|------|----------------|
| 48 | Introductory paragraph (`scripts/dev_tools/...`) — inside Range 1 |
| 51 | `feature:` bullet (`scripts/dev-tools/new-potential-entry.ps1`) — inside Range 1 |
| 52 | `bug:` bullet (`scripts/dev_tools/new_potential_bug_entry.py`) — inside Range 1 |
| 55 | `poetry run python -m scripts.dev_tools.potential_to_issue ...` — inside Range 1 |
| 61 | `poetry run python -m scripts.dev_tools.new_active_feature_folder ...` — inside Range 1 |
| 72 | `poetry run python -m scripts.dev_tools.potential_to_issue ... --work-mode minor-audit` — inside Range 2 |
| 78 | `poetry run python -m scripts.dev_tools.new_active_feature_folder ... --work-mode minor-audit` — inside Range 2 |

### EXCLUDED_DOCUMENTATION_PATHS

Whole-file exclusions for read-only policy rule files whose matched content is structural documentation, not agent-invocable script references:

| File | Rationale |
|------|-----------|
| `.claude/rules/powershell.md` | Read-only policy rule file; matched text at line 57 is a test-path layout example (`tests/scripts/dev-tools/ScriptName.Tests.ps1`), not a runnable script invocation; out-of-scope per spec.md "Out of Scope". |

Lines matched by grep that fall in excluded documentation paths (all excluded under Class #2):

| File | Line | Content summary |
|------|------|----------------|
| `.claude/rules/powershell.md` | 57 | Test-path layout example: `tests/scripts/dev-tools/ScriptName.Tests.ps1` |

### RESIDUAL_PRIMARY_SURFACE_MATCHES: 0

No matches remain outside both exclusion classes. The primary Claude skill surface contains no bare script invocations that would require MCP-first reframing.

Both exclusion classes are recorded as separate, auditable entries with rationales. No exclusion is silent.
