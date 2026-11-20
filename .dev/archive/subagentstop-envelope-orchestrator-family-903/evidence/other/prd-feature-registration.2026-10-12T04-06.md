# prd-feature Registration Edit ([P5-T9], Amendment A)

Timestamp: 2026-10-12T04-06
Command: Edit tool on .claude/agents/prd-feature.md line 18; rg -c -F "RequiredArtifact 'user-story-path" .claude/agents/prd-feature.md; rg -c -F "RequiredArtifact 'spec-path|" .claude/agents/prd-feature.md; rg -n -o -F -e '-RequiredArtifact' .claude/agents/prd-feature.md
EXIT_CODE: 0
Output Summary: AGENT_EDIT_OUTCOME: LANDED. The second -RequiredArtifact argument was removed from line 18; the user-story-path search exits 1 with no output, the spec-path search prints 1, and -RequiredArtifact occurs once (line 18).

PRE_EDIT_LINE_18:           command: pwsh -NoProfile -File .claude/hooks/validate-required-artifact-output.ps1 -AgentName prd-feature -RequiredArtifact 'spec-path|^docs/features/active/.+/spec\.md$|feature spec artifact' -RequiredArtifact 'user-story-path|^docs/features/active/.+/user-story\.md$|feature user story artifact'
POST_EDIT_LINE_18:           command: pwsh -NoProfile -File .claude/hooks/validate-required-artifact-output.ps1 -AgentName prd-feature -RequiredArtifact 'spec-path|^docs/features/active/.+/spec\.md$|feature spec artifact'

Search 1: rg -c -F "RequiredArtifact 'user-story-path" .claude/agents/prd-feature.md
  EXIT_CODE: 1
  Output: (none)
Search 2: rg -c -F "RequiredArtifact 'spec-path|" .claude/agents/prd-feature.md
  EXIT_CODE: 0
  Output: 1
Search 3: rg -n -o -F -e '-RequiredArtifact' .claude/agents/prd-feature.md
  EXIT_CODE: 0
  Output:
    18:-RequiredArtifact
LINE18_REQUIRED_ARTIFACT_COUNT: 1

AGENT_EDIT_OUTCOME: LANDED

Edit note: the first Edit call (deleting the substring with an empty replacement) also removed the LF that ended line 18, which joined lines 18 and 19. A second Edit call restored that LF. After the correction, `git diff --stat HEAD -- .claude/agents/prd-feature.md` reports 1 insertion and 1 deletion, the file has 48 lines before and after, and line 39 (`user-story-path: docs/features/active/<feature>/user-story.md`) is unchanged. Both edits used the Edit tool only.

Rationale: `pwsh -File` cannot bind a repeated `[string[]]` parameter, so the registration failed at parameter binding ("parameter 'RequiredArtifact' is specified more than once") on every run and has never validated anything. `spec.md` is required in both full-feature and full-bug mode, while `user-story.md` is absent by design in full-bug mode, so requiring it would block valid full-bug prd-feature runs once the hook binds and blocks with exit 2. The hook's parameter contract is unchanged.
