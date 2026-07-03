# update-extension-icon-description (Issue #285)

- Date captured: 2026-07-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-07-03-update-extension-icon-description-285/ (Issue #285)

- Issue: #285
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/285
- Last Updated: 2026-07-03
- Work Mode: minor-audit

## Problem / Why

The VS Code extension package currently has a generic manifest description and no configured Marketplace icon. The extension should present a clearer package description and use the provided branded icon asset.

## Proposed Behavior

Update the extension package metadata to reference a bundled icon asset and describe the extension in terms of its repository automation, customization publishing, and MCP bridge behavior. Review the repository README before writing the extension description so the package metadata aligns with the documented project purpose.

## Acceptance Criteria

- [x] The `drm-copilot` VS Code extension manifest references a bundled icon asset that matches the provided branded extension artwork.
- [x] The extension manifest description is updated from the generic bundled-utilities wording to a concise description aligned with the README.
- [x] The extension README description is updated to match the new manifest description and the repository README's documented purpose.

## Constraints & Risks

- Keep the change limited to extension metadata, documentation, and the icon asset unless validation identifies a required packaging adjustment.
- Preserve existing command registrations and runtime behavior.

## Test Conditions to Consider

- [ ] Extension manifest JSON remains valid.
- [ ] The extension package validation/build path accepts the icon reference.
- [ ] Documentation still accurately describes the extension and MCP bridge.

## Next Step

- [ ] Create and validate the small-route implementation plan.
