"""Regression tests for escape-safe active-feature-folder markdown updates."""

from __future__ import annotations

from scripts.dev_tools import new_active_feature_folder as mod
from scripts.dev_tools import new_active_feature_folder_markdown as markdown_mod


def test_set_section_preserves_backslashes_in_replacement_body() -> None:
    """Ensure Windows-style paths do not crash regex-backed section updates.

    The historical bug used a replacement string in ``re.sub`` directly, which
    caused bodies containing sequences like ``\\O`` to raise ``re.PatternError``.
    This test locks in the expectation that such text is preserved verbatim.
    """
    content = "## Overview\nold\n\n## Next\nkeep\n"
    body = r"Outlook object path: C:\Outlook\Objects"

    updated = mod.set_section(content, "Overview", body)

    assert body in updated
    assert "## Next\nkeep" in updated


def test_update_section_body_preserves_backslashes_in_updated_body() -> None:
    """Ensure updater-generated content with backslashes stays literal.

    ``update_section_body()`` used the same replacement-string pattern as
    ``set_section()``, so it needs the same escape-safe behavior when an updater
    emits Windows-style paths or other backslash-rich content.
    """
    content = "## Overview\nold\n\n## Next\nkeep\n"
    expected_body = r"Updated path: C:\Outlook\Objects"

    updated, changed = markdown_mod.update_section_body(
        content,
        "Overview",
        lambda _body: expected_body,
    )

    assert changed is True
    assert expected_body in updated
    assert "## Next\nkeep" in updated
