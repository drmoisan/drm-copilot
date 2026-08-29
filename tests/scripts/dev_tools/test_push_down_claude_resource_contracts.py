"""Contract tests for bundled `.claude` customization resources.

These tests require the bundled `.claude` payload to exist at
`extensions/drm-copilot/resources/claude-customizations/`. The payload is
present in the repository, so these tests are expected to pass. The
byte-identical mirror assertion exempts the `.claude/agent-memory/**` subtree,
which is distributed by scope rather than mirrored byte-for-byte.
"""

from __future__ import annotations

import importlib
import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLED_ROOT = (
    REPO_ROOT / "extensions" / "drm-copilot" / "resources" / "claude-customizations"
)
SCOPED_ROOTS: tuple[Path, ...] = (Path(".claude"),)
REQUIRED_BUNDLED_FILES = (
    Path(".claude/settings.json"),
    Path(".claude/skills/feature-promotion-lifecycle/SKILL.md"),
    Path(".claude/skills/atomic-plan-contract/SKILL.md"),
    Path(".claude/skills/policy-audit-template-usage/SKILL.md"),
    Path(".claude/skills/execute-hard-lock/SKILL.md"),
    Path(".claude/skills/pr-base-branch-merge-base/SKILL.md"),
    Path(".claude/rules/python.md"),
    Path(".claude/rules/typescript.md"),
    Path(".claude/agents/orchestrator.md"),
)
PLANNER_REVIEW_RESOURCE_PATHS = (
    Path(".claude/skills/atomic-plan-contract/SKILL.md"),
    Path(".claude/hooks/validate-planner-output.ps1"),
    Path(".claude/agents/atomic-planner.md"),
)


def list_scoped_files(root: Path) -> list[Path]:
    """Return scoped files in deterministic relative-path order."""

    files: list[Path] = []
    for scoped_root in SCOPED_ROOTS:
        scoped_path = root / scoped_root
        for path in scoped_path.rglob("*"):
            if path.is_file():
                files.append(path.relative_to(root))
    return sorted(files)


def read_text(root: Path, relative_path: Path) -> str:
    """Return UTF-8 text for a bundled or source payload file."""

    return (root / relative_path).read_text(encoding="utf-8")


def test_bundled_claude_payload_contains_required_runtime_files() -> None:
    """Require the bundled payload to include the expected Claude runtime files.

    Expected to fail until Phase 9 copies the .claude tree into the bundled root.
    """

    bundled_files = list_scoped_files(BUNDLED_ROOT)

    assert bundled_files
    # Verify each required anchor file is present in the bundled payload.
    for relative_path in REQUIRED_BUNDLED_FILES:
        assert (
            relative_path in bundled_files
        ), f"Required bundled file missing: {relative_path}"


AGENT_MEMORY_RELATIVE_ROOT = Path(".claude/agent-memory")


def _is_agent_memory_path(relative_path: Path) -> bool:
    """Return whether a scoped relative path lives under `.claude/agent-memory/`.

    Purpose:
        Identify agent-memory files so the byte-identical mirror assertion can
        exempt them: general memories live in the bundle but not at the
        gitignored root `.claude/agent-memory/`, so they cannot be compared
        against a root copy.

    Args:
        relative_path (Path): A `.claude`-scoped path relative to a payload
            root.

    Returns:
        bool: True when the path is under `.claude/agent-memory/`.

    Raises:
        None.

    Side Effects:
        None.
    """

    try:
        relative_path.relative_to(AGENT_MEMORY_RELATIVE_ROOT)
    except ValueError:
        return False
    return True


def test_bundled_claude_payload_contains_all_repo_runtime_contracts() -> None:
    """Require every non-memory repo `.claude` file to exist in the bundle.

    Excludes settings.local.json and the `.claude/agent-memory/**` subtree.
    Agent memories are distributed by scope (general memories live in the
    bundle but not at the gitignored root), so they are not subject to the
    byte-identical mirror assertion.
    """

    bundled_files = list_scoped_files(BUNDLED_ROOT)
    # Enumerate repo .claude files, excluding the local-only settings file and
    # the scope-filtered agent-memory subtree.
    repo_runtime_files = [
        f
        for f in list_scoped_files(REPO_ROOT)
        if f != Path(".claude/settings.local.json") and not _is_agent_memory_path(f)
    ]

    for relative_path in repo_runtime_files:
        assert (
            relative_path in bundled_files
        ), f"Repo file missing from bundle: {relative_path}"
        assert read_text(BUNDLED_ROOT, relative_path) == read_text(
            REPO_ROOT,
            relative_path,
        ), f"Bundle content differs from repo for: {relative_path}"


def test_planner_review_resources_exist_and_are_byte_identical() -> None:
    """Require the three changed planner-review resources in both payloads."""

    for relative_path in PLANNER_REVIEW_RESOURCE_PATHS:
        canonical_path = REPO_ROOT / relative_path
        bundled_path = BUNDLED_ROOT / relative_path
        assert canonical_path.is_file(), f"Canonical resource missing: {relative_path}"
        assert bundled_path.is_file(), f"Bundled resource missing: {relative_path}"
        assert canonical_path.read_bytes() == bundled_path.read_bytes(), (
            f"Planner-review resource differs from bundle: {relative_path}"
        )


def test_pack_manifests_are_outside_the_parity_scope() -> None:
    """Verify pack manifests live outside the `.claude/**` parity scope.

    The root-to-bundle parity assertion compares only `.claude/**` files
    (``SCOPED_ROOTS == (Path(".claude"),)``). The pack manifests live under
    ``pack-manifests/`` (a sibling of `.claude/`), so they must never appear in
    the enumerated `.claude/**` payload and are not pushed to a destination.
    """

    # The manifest directory exists in the bundle as a sibling of `.claude`.
    manifest_dir = BUNDLED_ROOT / "pack-manifests"
    assert manifest_dir.is_dir(), "Bundled pack-manifests directory must exist."

    # No enumerated `.claude/**` payload path may reference pack-manifests.
    bundled_files = list_scoped_files(BUNDLED_ROOT)
    assert not any(
        "pack-manifests" in relative_path.as_posix() for relative_path in bundled_files
    ), "pack-manifests must not be enumerated within the .claude parity scope."


def test_bundled_claude_payload_excludes_settings_local_json() -> None:
    """Verify settings.local.json is absent from the bundled payload.

    Expected to fail until Phase 9 copies the .claude tree into the bundled root.
    """

    assert not (
        BUNDLED_ROOT / ".claude" / "settings.local.json"
    ).exists(), "settings.local.json must not be present in the bundled payload"


VARIANT_SUBTREE_RELATIVE = Path(".claude-variants/csharp-legacy")


def test_bundled_claude_payload_excludes_variant_subtree_from_parity() -> None:
    """Verify the variant subtree is outside the byte-identical parity scope.

    The root-to-bundle parity comparison enumerates only `.claude/**`. The
    legacy variant subtree lives at `.claude-variants/csharp-legacy/` (a sibling
    of `.claude/`), so no enumerated parity path may reference it.
    """

    bundled_files = list_scoped_files(BUNDLED_ROOT)
    # No `.claude/**` payload path may reference the variant subtree directory.
    assert not any(
        ".claude-variants" in relative_path.as_posix()
        for relative_path in bundled_files
    ), ".claude-variants must not be enumerated within the .claude parity scope."


def test_variant_subtree_is_bundle_only_and_non_colliding() -> None:
    """Assert the legacy variant subtree is bundle-only and non-colliding.

    Three invariants are checked:
    - No `.claude-variants/` directory exists at the repository root; the
      variant lives only in the bundle.
    - Every variant file maps to an existing modern file at the root `.claude`
      tree (so the variant is a true alternative, not a stray file).
    - Each variant file's content differs from its root `.claude` counterpart
      (so the legacy variant is a distinct profile, not a duplicate).
    """

    # The variant must not leak to the repository root .claude-variants path.
    assert not (
        REPO_ROOT / ".claude-variants"
    ).exists(), "No .claude-variants directory may exist at the repository root."

    variant_root = BUNDLED_ROOT / VARIANT_SUBTREE_RELATIVE
    assert variant_root.is_dir(), "Bundled legacy variant subtree must exist."

    # Enumerate every variant file and verify it maps to a distinct modern file.
    variant_files = sorted(path for path in variant_root.rglob("*") if path.is_file())
    assert variant_files, "Legacy variant subtree must contain files."

    for variant_path in variant_files:
        # Map the variant file to its canonical `.claude/` destination tail.
        tail = variant_path.relative_to(variant_root)
        root_path = REPO_ROOT / ".claude" / tail
        assert (
            root_path.is_file()
        ), f"Variant file has no modern counterpart at root: {tail}"
        # The variant must be a distinct profile, not a byte copy of the modern.
        assert variant_path.read_text(encoding="utf-8") != root_path.read_text(
            encoding="utf-8"
        ), f"Variant file is byte-identical to its root counterpart: {tail}"


def _frontmatter_declares_scope(content: str) -> bool:
    """Return whether a memory file explicitly declares `metadata.scope`.

    Purpose:
        Distinguish a file that explicitly carries a `metadata.scope` leaf from
        one the parser merely defaulted to `repo`. Used so the parity test can
        require every memory to be explicitly annotated rather than relying on
        the fail-safe default.

    Args:
        content (str): The full text of a bundled memory file.

    Returns:
        bool: True when a `scope:` leaf appears inside the frontmatter metadata
        block.

    Raises:
        None.

    Side Effects:
        None.
    """

    # A memory is explicitly scoped only when a metadata block and a scope leaf
    # are both present in the leading frontmatter.
    return "metadata:" in content and "scope:" in content


def test_bundled_agent_memory_scopes_are_well_formed() -> None:
    """Assert every bundled agent memory carries the required scope marker.

    Every `MEMORY.md` index file must declare `metadata.scope: repo` so an
    index is never distributed and never clobbers a destination's own index.
    Every non-index agent-memory file must declare exactly
    `metadata.scope: general`: repo-specific memories were physically removed
    from the bundle (Option B), so the bundle now holds only general-scoped,
    repository-neutral memories. A non-index file with any scope other than
    `general` (including the fail-safe `repo` default) is rejected so a
    repo-specific memory can never reside in the distributed bundle.
    """

    # Reuse the production scope parser so the test enforces exactly the value
    # the push-down filter reads at runtime.
    module = importlib.import_module(
        "scripts.dev_tools.push_down_claude_customizations"
    )
    agent_memory_root = BUNDLED_ROOT / ".claude" / "agent-memory"

    # Enumerate the entire bundled agent-memory tree so a newly added memory
    # cannot bypass the scope assertion.
    memory_files = sorted(
        path for path in agent_memory_root.rglob("*.md") if path.is_file()
    )
    assert memory_files, "Bundled agent-memory tree must contain memory files."

    # Classify each file by whether it is a MEMORY.md index and assert the
    # required scope for that class. Indexes must be repo-scoped (never
    # distributed); every other memory must be exactly general-scoped.
    for path in memory_files:
        content = path.read_text(encoding="utf-8")
        scope = module._read_memory_scope(content)
        if path.name == "MEMORY.md":
            assert (
                scope == "repo"
            ), f"MEMORY.md index must be scope: repo, got {scope}: {path}"
        else:
            assert _frontmatter_declares_scope(
                content
            ), f"Non-index memory must declare an explicit metadata.scope: {path}"
            assert (
                scope == "general"
            ), f"Non-index bundled memory must be scope: general, got {scope}: {path}"


CLAUDE_LEGACY_VARIANT_FILES: tuple[Path, ...] = (
    Path(".claude-variants/csharp-legacy/rules/csharp.md"),
    Path(".claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md"),
)
LEGACY_REQUIRED_SUBSTRINGS: tuple[str, ...] = (
    "dotnet tool run csharpier format .",
    "dotnet tool run csharpier check .",
    "dotnet tool restore",
    "/t:Rebuild /m",
    '"/p:Platform=Any CPU"',
    "/p:TreatWarningsAsErrors=true",
    "#nullable enable",
)
LEGACY_FORBIDDEN_SUBSTRINGS: tuple[str, ...] = (
    "csharpier .",
    "sln /t:Build",
    '/p:Platform="Any CPU"',
)
NULLABLE_SPAN_SCOPE_LITERALS: tuple[str, str] = ("msbuild", "/p:Nullable=enable")
INLINE_CODE_SPAN_PATTERN = re.compile(r"`([^`\n]+)`")
CLAUDE_MODERN_CSHARP_FILES: tuple[Path, ...] = (
    Path(".claude/rules/csharp.md"),
    Path(".claude/skills/csharp-qa-gate/SKILL.md"),
)
MODERN_REQUIRED_SUBSTRINGS: tuple[str, ...] = (
    "dotnet csharpier check .",
    "dotnet build",
)
MODERN_FORBIDDEN_SUBSTRINGS: tuple[str, ...] = ("msbuild", "/t:Rebuild")


def test_claude_legacy_variant_files_contain_corrected_gate_commands() -> None:
    """Assert both Claude legacy variant files carry the corrected gate commands.

    The corrected `csharp-legacy` gate contract requires the CSharpier
    subcommand forms, the manifest restore step, the `/t:Rebuild /m` local
    build, the whole-argument platform token, the retained warnings-as-errors
    property, and the per-file nullable opt-in marker. Real repository bytes are
    read so the assertion reflects what the push-down engines emit.
    """

    # Arrange: the two canonical Claude variant sources.
    variant_files = CLAUDE_LEGACY_VARIANT_FILES

    # Act / Assert: every required substring must appear in every variant file.
    for relative_path in variant_files:
        content = read_text(BUNDLED_ROOT, relative_path)
        for required in LEGACY_REQUIRED_SUBSTRINGS:
            assert required in content, (
                f"Required legacy gate substring missing from "
                f"{relative_path}: {required}"
            )


def _spans_with_both_literals(content: str) -> list[str]:
    """Return inline code spans containing both nullable-scope literals.

    Purpose:
        Implement the span-scoped nullable predicate: a documented command lives
        inside a backtick-delimited inline code span, so the guard against
        `/p:Nullable=enable` reaching an MSBuild command line is expressed as a
        conjunction over one span rather than over a whole line or file.

    Args:
        content (str): Full UTF-8 text of a variant file.

    Returns:
        list[str]: Every extracted span that contains both the lowercase
        `msbuild` token and the `/p:Nullable=enable` literal. An empty list
        means the file satisfies the predicate.

    Raises:
        None.

    Side Effects:
        None.
    """

    msbuild_token, nullable_property = NULLABLE_SPAN_SCOPE_LITERALS
    # Matching is case-sensitive on purpose: the lowercase `msbuild` token
    # appears only in command spans, while prose names the product `MSBuild`.
    return [
        span
        for span in INLINE_CODE_SPAN_PATTERN.findall(content)
        if msbuild_token in span and nullable_property in span
    ]


def test_claude_legacy_variant_files_exclude_stale_gate_commands() -> None:
    """Assert both Claude legacy variant files carry no stale gate command form.

    Two distinct scopes apply. The three literals in
    ``LEGACY_FORBIDDEN_SUBSTRINGS`` are file-scoped: they must not appear
    anywhere in either variant file. The `/p:Nullable=enable` guard is
    span-scoped: no backtick-delimited inline code span may contain both
    `msbuild` and `/p:Nullable=enable`, which permits prohibition prose that
    names the property while still forbidding it as a command argument. The
    scan targets only these two files; a bundle-wide or repository-wide scan
    would fail on out-of-scope files that legitimately carry stale forms.
    """

    # Arrange: the two canonical Claude variant sources.
    variant_files = CLAUDE_LEGACY_VARIANT_FILES

    # Act / Assert: file-scoped absence, then the span-scoped nullable predicate.
    for relative_path in variant_files:
        content = read_text(BUNDLED_ROOT, relative_path)
        for forbidden in LEGACY_FORBIDDEN_SUBSTRINGS:
            assert (
                forbidden not in content
            ), f"Stale legacy gate substring present in {relative_path}: {forbidden}"
        offending_spans = _spans_with_both_literals(content)
        assert not offending_spans, (
            f"Inline code span in {relative_path} contains both 'msbuild' and "
            f"'/p:Nullable=enable': {offending_spans}"
        )


def test_claude_modern_csharp_profile_retains_modern_gate_commands() -> None:
    """Assert the modern Claude C# profile keeps its SDK-style gate commands.

    This pins the modern/default profile as a baseline so a legacy-variant
    correction cannot silently drift into it. Byte parity between the repo root
    and the bundle is already enforced by
    ``test_bundled_claude_payload_contains_all_repo_runtime_contracts``, so the
    root files alone are read here.
    """

    # Arrange: the two modern-profile files at the repository root.
    modern_files = CLAUDE_MODERN_CSHARP_FILES

    # Act / Assert: the modern SDK-style commands are present and no
    # classic-MSBuild form has leaked into the modern profile.
    for relative_path in modern_files:
        content = read_text(REPO_ROOT, relative_path)
        for required in MODERN_REQUIRED_SUBSTRINGS:
            assert (
                required in content
            ), f"Modern profile substring missing from {relative_path}: {required}"
        for forbidden in MODERN_FORBIDDEN_SUBSTRINGS:
            assert (
                forbidden not in content
            ), f"Modern profile must not contain {forbidden}: {relative_path}"
