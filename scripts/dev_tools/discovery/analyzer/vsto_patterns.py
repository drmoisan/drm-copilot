"""Forward historical inert pattern data only when explicitly requested.

Ordinary imports do not load the optional runtime. Classifiers own consent checks;
these compatibility exports neither inspect source nor authorize analysis.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.optional.vsto_patterns import (
        COM_ATTRIBUTE_RES,
        COMREFERENCE_RE,
        CUSTOMUI_ELEMENT_RE,
        CUSTOMUI_URIS,
        DESCRIPTIONS,
        DESIGNER_RIBBON_LITERAL,
        EMBEDINTEROP_RE,
        GETCUSTOMUI_RE,
        GUID_CAPTURE_RE,
        INTEROP_ASSEMBLY_RE,
        INTEROP_USING_RE,
        IRIBBON_RE,
        MARSHAL_RE,
        PROGID_RE,
    )

__all__ = (
    "CUSTOMUI_URIS",
    "CUSTOMUI_ELEMENT_RE",
    "IRIBBON_RE",
    "GETCUSTOMUI_RE",
    "DESIGNER_RIBBON_LITERAL",
    "COM_ATTRIBUTE_RES",
    "GUID_CAPTURE_RE",
    "MARSHAL_RE",
    "PROGID_RE",
    "INTEROP_USING_RE",
    "COMREFERENCE_RE",
    "EMBEDINTEROP_RE",
    "INTEROP_ASSEMBLY_RE",
    "DESCRIPTIONS",
)


def __getattr__(name: str) -> object:
    """Return one fixed inert export from the canonical optional pattern module.

    name (str) must be a historical name in __all__. Returns the identical data
    object, without copying or executing detection. Raises AttributeError for an
    unknown name before imports. The fixed optional import is the only effect.
    """
    if name not in __all__:
        raise AttributeError("Unknown legacy optional pattern export")
    from drm_copilot_discovery.analyzer.optional import vsto_patterns

    return getattr(vsto_patterns, name)
