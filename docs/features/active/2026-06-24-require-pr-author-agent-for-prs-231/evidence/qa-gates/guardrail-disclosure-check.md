# Guardrail-Not-Cryptographic Disclosure Check (AC8)

- Timestamp: 2026-06-24T16-47
- Issue: #231

Every documentation artifact produced or modified by this feature states the guardrail-not-cryptographic limitation and records the forgeability of the sentinel. No artifact describes the sentinel as tamper-proof or a security boundary; the only "tamper-proof" occurrences are explicit negations.

## Files and quoted disclosure text

### `.claude/agents/pr-author.md`
> The authorization sentinel is a **policy guardrail, not a cryptographic or security control.** Any actor with `Write(/artifacts/**)` access can forge `artifacts/pr_author_authorization.json` ... It is not tamper-proof and is not a security boundary.

### `.claude/hooks/enforce-pr-author-skill.ps1` (.NOTES header)
> Enforcement strength: the authorization sentinel is a policy guardrail, not a cryptographic or security control. Any actor with Write access to artifacts/ can forge artifacts/pr_author_authorization.json ... It MUST NOT be described as tamper-proof or as a security boundary.

(Also restated in the `Test-PrAuthorAuthorization` function `.DESCRIPTION`.)

### `.claude/hooks/validate-pr-author-output.ps1` (.NOTES header)
> Enforcement strength: this validator is a policy guardrail, not a cryptographic or security control ... the output text is forgeable by any actor that controls the agent transcript. It MUST NOT be described as tamper-proof or as a security boundary.

### `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pr-author.toml`
> The authorization sentinel is a policy guardrail, not a cryptographic or security control. Any actor with write access to `artifacts/` can forge ... It is not tamper-proof and is not a security boundary.

### `extensions/drm-copilot/resources/customizations/.github/agents/pr-author.agent.md`
> The authorization sentinel is a **policy guardrail, not a cryptographic or security control.** Any actor with write access to `artifacts/` can forge ... It is not tamper-proof and is not a security boundary.

## Bundled Claude mirrors

The bundled `.claude` copies of `pr-author.md`, `enforce-pr-author-skill.ps1`, and `validate-pr-author-output.ps1` are byte-identical to root (cross-ecosystem-equality.md), so they carry the identical disclosure text.

## Verification

- `grep -c "policy guardrail, not a cryptographic"` returns >= 1 for each of the five documentation files.
- Every `tamper-proof` occurrence is a negation ("It is not tamper-proof" / "MUST NOT be described as tamper-proof").

## Conclusion

The guardrail-not-cryptographic disclosure is present in every documentation artifact, the forgeability limitation is recorded, and no artifact characterizes the sentinel as tamper-proof or a security boundary. AC8 satisfied.
