<!-- markdownlint-disable-file -->

# Task Research Notes: Dev 3 Create Active Folder bug-mode potential copy and work-mode marker persistence

## Research Executed

### File Analysis

- `.vscode/tasks.json`
  - Verified `Dev: 3 Create Active Folder` passes user prompt inputs directly (`--feature-name`, `--type`, `--issue-number`, `--work-mode`) and does not derive `--feature-name` from the active promoted file.
- `scripts/dev_tools/new_active_feature_folder_flow.py`
  - Verified potential-file move to `issue.md` only happens when `find_potential_file(...)` returns a match; verified `- Work Mode: full` marker is only written in the fallback branch (`work_mode == minor-audit` + fallback), not in normal full mode.
- `scripts/dev_tools/new_active_feature_folder_io.py`
  - Verified matching logic uses substring inclusion (`normalized in file.name`) against files in both `docs/features/potential/` and `docs/features/potential/promoted/`.
- `docs/features/potential/promoted/2026-02-22-testing-missing-mock-injections.md`
  - Verified promoted bug file exists and includes `- Issue: #42` metadata.

### Code Search Results

- `Dev: 3 Create Active Folder|--work-mode|new_active_feature_folder`
  - Found task wiring and flow implementation points proving current path/parameter handling.
- `upsert_work_mode_marker|Work Mode: full|fallback`
  - Found full-marker write behavior only in minor-audit fallback branch.
- `find_potential_file|potential/promoted`
  - Found lookup implementation and candidate matching behavior for promoted files.

### External Research

- #githubRepo:"drmoisan/drm-copilot Dev: 3 Create Active Folder new_active_feature_folder work mode"
  - Repository-local evidence used from checked-out workspace files; no additional public upstream variant was required for root-cause confirmation.
- #fetch:https://github.com/drmoisan/drm-copilot/issues/42
  - Fetch returned HTTP 404 in this environment; external issue body could not be retrieved from tool context.

### Project Conventions

- Standards referenced: `.github/instructions/general-code-change.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/skills/feature-promotion-lifecycle/SKILL.md`, `.github/skills/policy-compliance-order/SKILL.md`
- Instructions followed: Task-research-only constraint (no source edits), evidence-backed findings only, single recommended solution path.

## Key Discoveries

### Project Structure

The creation flow is split as:
- Task input wiring in `.vscode/tasks.json`
- Orchestration in `scripts/dev_tools/new_active_feature_folder_flow.py`
- Potential-file lookup and template IO in `scripts/dev_tools/new_active_feature_folder_io.py`
- Marker transformation in `scripts/dev_tools/new_active_feature_folder_markdown.py`

### Implementation Patterns

1. Potential-to-issue move contract:
   - For non-minor path, the code moves the matched potential file to `<active-folder>/issue.md` after template/doc updates.
   - If no match is found, no `issue.md` move occurs.

2. Work-mode marker persistence:
   - `minor-audit` eligible path writes `- Work Mode: minor-audit`.
   - `minor-audit` fallback-to-full writes `- Work Mode: full`.
   - Explicit `full` mode path does **not** currently write `- Work Mode: full`.

3. Task UX contract gap:
   - `Dev: 3 Create Active Folder` depends on manually entered `ActiveFeatureName`; if user enters a value not contained in promoted filename, lookup misses.
   - Task does not enforce or suggest the canonical promoted-file-derived name and does not infer from active file.

### Complete Examples

```python
# scripts/dev_tools/new_active_feature_folder_flow.py (observed behavior)
if potential_file:
    potential_issue_path = target_dir / "issue.md"
    filesystem.move(potential_file, potential_issue_path)
    if work_mode == "minor-audit" and fallback_reason:
        moved_content = filesystem.read_text(potential_issue_path)
        filesystem.write_text(
            potential_issue_path,
            upsert_work_mode_marker(moved_content, "full"),
        )

# No equivalent marker write when work_mode == "full" directly.
```

### API and Schema Documentation

- CLI args for active-folder creation:
  - `--feature-name`
  - `--type`
  - `--issue-number`
  - `--work-mode` (`minor-audit` | `full`)
- `find_potential_file(feature_name, workspace, fs)` selects candidates by substring match on filename from both potential roots.

### Configuration Examples

```json
{
  "label": "Dev: 3 Create Active Folder",
  "args": [
    "run", "python", "-m", "scripts.dev_tools.new_active_feature_folder",
    "--feature-name", "${input:ActiveFeatureName}",
    "--type", "${input:ActiveWorkType}",
    "--issue-number", "${input:ActiveIssueNumber}",
    "--work-mode", "${input:ActiveWorkMode}"
  ]
}
```

### Technical Requirements

- To guarantee promoted bug file move, the `--feature-name` value must match the promoted filename matching heuristic in `find_potential_file`.
- To satisfy deterministic mode persistence requirements from repo skill/docs, `issue.md` must contain exactly one marker line (`- Work Mode: full` or `- Work Mode: minor-audit`) for all selected-mode outcomes, including explicit full mode.

**Mandatory unachievable objective callout**:
- **Not all user-intended promoted-file selections are currently achievable via task defaults alone**, because `Dev: 3 Create Active Folder` does not resolve `ActiveFeatureName` from the active promoted file path and cannot infer intent when mismatched input is provided.

## Recommended Approach

Use a two-part fix (single selected approach):

1. **Flow fix (authoritative):** In `create_active_folder`, after moving potential file for non-minor path, always upsert `- Work Mode: full` when selected mode is full (explicit full or fallback full). This closes the marker persistence gap.
2. **Task robustness fix (input/source-of-truth):** Update `Dev: 3 Create Active Folder` to derive `--feature-name` from current active file (or add a resolver input task) so promoted docs like `2026-02-22-testing-missing-mock-injections.md` are reliably discovered without fragile manual name entry.

Rejected alternatives (brief):
- Expanding filename matching to fuzzy/regex-only heuristics was rejected as primary fix because it masks input-source ambiguity and can select wrong potential files.
- Relying on users to manually type exact names was rejected because behavior is non-deterministic and already caused this defect report.

## Implementation Guidance

- **Objectives**: Ensure bug-type active-folder creation moves promoted issue file to `issue.md` and persists selected work mode marker in all full/minor paths.
- **Key Tasks**:
  - Add regression test for explicit `work_mode="full"` + potential file asserting `- Work Mode: full` in moved `issue.md`.
  - Add regression test covering task/CLI path where feature name is derived from active promoted file (or resolver output).
  - Implement minimal flow and task wiring updates.
- **Dependencies**: `scripts/dev_tools/new_active_feature_folder_flow.py`, `.vscode/tasks.json`, tests under `tests/scripts/dev_tools/`.
- **Success Criteria**:
  - Running create-active-folder for issue #42 bug case moves promoted file into new active folder as `issue.md`.
  - `issue.md` contains exactly one `- Work Mode: full` marker when full mode is selected.
  - Existing minor-audit behavior and fallback messaging remain intact.