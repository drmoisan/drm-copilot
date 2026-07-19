"""Data-only pattern tables for the VSTO/Office analyzer.

Purpose:
    Hold the compiled regular expressions, the customUI namespace-URI table, and
    the static detection descriptions used by ``vsto_office``. Extracting these
    data tables keeps ``vsto_office.py`` under the repository 500-line file-size
    limit while keeping the detection logic in one place.

Neutrality note:
    Every literal here is generic .NET/VSTO/Office stack subject matter (the
    ``Microsoft.Office.*`` namespaces, the customUI schema URIs, COM attribute
    names, project element names). No consumer identifier and no per-Office-
    application special-casing appears; the interop application name is captured
    as data by ``INTEROP_USING_RE`` and never branched on.

Side Effects:
    None. Module-level compiled patterns and constant tables only.
"""

from __future__ import annotations

import re

# customUI namespace URIs by schema generation. The matched URI is recorded in
# ``metadata.customui_schema``; both generations are detected identically.
CUSTOMUI_URIS: tuple[tuple[str, str], ...] = (
    ("2006", "http://schemas.microsoft.com/office/2006/01/customui"),
    ("2009", "http://schemas.microsoft.com/office/2009/07/customui"),
)

# Opening ``<customUI`` root element (the corroborating ribbon-XML signal). The
# ``\b`` after the tag name avoids matching the closing ``</customUI>`` tag.
CUSTOMUI_ELEMENT_RE = re.compile(r"<customUI\b")

# Ribbon-extensibility signals in C# source (run over stripped text).
IRIBBON_RE = re.compile(r"\bIRibbonExtensibility\b")
GETCUSTOMUI_RE = re.compile(r"\bGetCustomUI\s*\(")
DESIGNER_RIBBON_LITERAL = "Microsoft.Office.Tools.Ribbon"

# COM interop attribute presence patterns (run over stripped text so a commented
# or stringized attribute cannot match). Each entry is ``(attribute_name, regex)``.
COM_ATTRIBUTE_RES: tuple[tuple[str, re.Pattern[str]], ...] = (
    ("ComImport", re.compile(r"\[\s*ComImport\b")),
    ("ComVisible", re.compile(r"\[\s*ComVisible\b")),
    ("Guid", re.compile(r"\[\s*Guid\b")),
    ("InterfaceType", re.compile(r"\[\s*InterfaceType\b")),
    ("DispId", re.compile(r"\[\s*DispId\b")),
)

# GUID value capture, applied to the ORIGINAL (unstripped) line only after the
# stripped line has confirmed a real ``[Guid(...)]`` attribute, because the GUID
# lives inside a string literal that the stripper blanks.
GUID_CAPTURE_RE = re.compile(r'\[\s*Guid\s*\(\s*"([^"]+)"')

# ``Marshal.<member>(`` call with the member captured; no fixed member list.
MARSHAL_RE = re.compile(r"\bMarshal\.(?P<member>\w+)\s*\(")

# ``Type.GetTypeFromProgID(`` activation.
PROGID_RE = re.compile(r"\bType\.GetTypeFromProgID\s*\(")

# Office interop using with optional ``static`` and optional alias. The Office
# application name is captured into ``app`` as data and never branched on.
INTEROP_USING_RE = re.compile(
    r"^\s*using\s+(?:static\s+)?(?:[A-Za-z_]\w*\s*=\s*)?"
    r"(?P<full>Microsoft\.Office\.Interop\.(?P<app>[A-Za-z_]\w*)[\w.]*)\s*;"
)

# Project-file COM references (run over unstripped ``*proj`` XML).
COMREFERENCE_RE = re.compile(r'<COMReference\s+Include="(?P<include>[^"]*)"')
EMBEDINTEROP_RE = re.compile(r"<EmbedInteropTypes\b")
INTEROP_ASSEMBLY_RE = re.compile(
    r'<Reference\s+Include="(?P<include>Microsoft\.Office\.Interop\.[^"]*)"'
)

# Static, generic, symbol-free descriptions keyed by detection kind. No consumer
# identifier and no detected symbol appears here; the symbol lives in metadata.
DESCRIPTIONS: dict[str, str] = {
    "ribbon_xml": "Heuristic textual detection of a VSTO ribbon customUI pattern.",
    "ribbon_extensibility": (
        "Heuristic textual detection of a VSTO ribbon-extensibility pattern."
    ),
    "com_attribute": "Heuristic textual detection of a COM interop attribute.",
    "marshal_call": "Heuristic textual detection of a COM Marshal member call.",
    "progid_activation": "Heuristic textual detection of a COM ProgID activation.",
    "interop_using": "Heuristic textual detection of an Office interop using.",
    "com_reference": "Heuristic textual detection of a project-file COM reference.",
}
