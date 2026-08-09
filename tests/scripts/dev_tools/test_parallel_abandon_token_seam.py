"""Cross-artifact seam test binding the parallel abandon token pair.

Why this test exists:
    The abandon token pair is PRODUCED by the abandon CLI module
    ``scripts/dev_tools/parallel_mutation_abandon_cli.py`` and by the documented
    invocation line in ``.claude/skills/parallel-remove/SKILL.md``, and CONSUMED by
    ``.claude/hooks/enforce-parallel-abandon-gate.ps1``. Per-side
    coverage is blind to divergence between them: every side can reach 100% coverage
    while tested against its own copy of the token, so a rename on one side alone would
    ship a silently dead gate that never matches the command it is meant to guard.

How it binds them:
    Three independent extractions PARSE the counterpart artifacts at run time instead of
    restating their content. The CLI's own constants are the single producer-side source
    of truth; the hook's values are read out of its two named ``$script:`` assignments;
    the SKILL's values are read out of its one documented invocation line. No token
    value is hardcoded here as an expected value, so a rename in one artifact
    without the identical rename in the other two fails this test rather than
    passing vacuously.

    Each extraction is asserted non-empty before it is compared, so a parse that
    silently matched nothing fails loudly instead of satisfying a subset assertion.

Determinism:
    Reads only committed repository files, by repo-relative path resolved from this
    module's location. Creates no temporary file, starts no subprocess, invokes no live
    ``gh`` or ``git``, and neither executes the CLI nor runs the hook.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

from scripts.dev_tools import parallel_mutation_abandon_cli as cli

# Repo root, resolved from this module: tests/scripts/dev_tools/<file> is three
# levels below it.
REPO_ROOT = Path(__file__).resolve().parents[3]

# The two counterpart artifacts parsed as text. Path anchors are permitted literals.
HOOK_PATH = REPO_ROOT / ".claude" / "hooks" / "enforce-parallel-abandon-gate.ps1"
SKILL_PATH = REPO_ROOT / ".claude" / "skills" / "parallel-remove" / "SKILL.md"

# The anchor that locates the SKILL's documented invocation line. This is a file-name
# anchor, not a token value.
INVOCATION_ANCHOR = "parallel_mutation_abandon_cli.py"

# The two named script-scope assignments the hook declares its tokens in. Only the
# CONSTANT NAMES appear here; the values are whatever the hook currently holds.
HOOK_DISPOSITION_ASSIGNMENT = re.compile(
    r"\$script:AbandonDispositionToken\s*=\s*'(?P<value>[^']+)'"
)
HOOK_CONFIRM_ASSIGNMENT = re.compile(
    r"\$script:AbandonConfirmToken\s*=\s*'(?P<value>[^']+)'"
)

# The option prefix every extracted flag carries. This is argparse syntax, not a token.
OPTION_PREFIX = "--"


def read_text(path: Path) -> str:
    """Return a committed artifact's UTF-8 text.

    Args:
        path (Path): Absolute path to the artifact.

    Returns:
        str: The file's contents.

    Raises:
        OSError: If the artifact cannot be read, which is itself a seam failure: a
            counterpart artifact that is absent cannot be bound to.
    """

    return path.read_text(encoding="utf-8")


def cli_token_pair() -> tuple[str, str]:
    """Return the producer-side abandon token pair from the CLI module.

    Returns:
        tuple[str, str]: The disposition token and the confirmation token, read from the
        CLI's module-level constants. The CLI is the single producer-side source of
        truth for both values; nothing here composes or guesses them.

    Raises:
        None.
    """

    return (cli.ABANDON_DISPOSITION_TOKEN, cli.CONFIRM_ABANDON_TOKEN)


def parser_option_strings() -> set[str]:
    """Return every option string registered on the live argparse surface.

    Returns:
        set[str]: The union of every action's ``option_strings`` from the parser
        ``build_parser()`` actually returns, so a constant the parser does not honor is
        detectable.

    Raises:
        None.
    """

    parser = cli.build_parser()
    # Union every action's option strings: the confirmation flag must be wired into one
    # of them, and which action carries it is not this test's concern.
    return {
        option_string
        for action in parser._actions  # pyright: ignore[reportPrivateUsage]
        for option_string in action.option_strings
    }


def disposition_action_composition() -> str:
    """Compose the disposition token from the live parser's own surface.

    Locates the action registered under the CLI's ``DISPOSITION_OPTION`` and composes
    its option string with the abandon member of its ``choices``. Composing from the
    parser rather than reading the constant is what proves the constant is HONORED
    by the parser, not merely declared beside it.

    Returns:
        str: The option string and the abandon choice joined by one space.

    Raises:
        AssertionError: If no action carries the disposition option string, or if the
            abandon member is absent from that action's choices.
    """

    parser = cli.build_parser()
    # Find the one action registered under the disposition option name; the parser is
    # small, so a scan is clearer than an index into a private lookup table.
    for action in parser._actions:  # pyright: ignore[reportPrivateUsage]
        if cli.DISPOSITION_OPTION not in action.option_strings:
            continue
        choices = list(action.choices or [])
        assert choices, "the disposition action must register a non-empty choices set"
        assert (
            cli.ABANDON_DISPOSITION in choices
        ), f"the disposition action's choices must include abandon: {choices}"
        return f"{cli.DISPOSITION_OPTION} {cli.ABANDON_DISPOSITION}"
    raise AssertionError(
        f"no argparse action registers the option string {cli.DISPOSITION_OPTION!r}"
    )


def hook_token_pair() -> tuple[str, str]:
    """Extract the consumer-side token pair from the hook's named assignments.

    Returns:
        tuple[str, str]: The disposition token and the confirmation token, taken from
        the right-hand side of the hook's two named ``$script:`` assignments.

    Raises:
        AssertionError: If either named assignment is absent, which means the hook no
            longer declares its tokens where this seam can read them.
    """

    text = read_text(HOOK_PATH)
    disposition = HOOK_DISPOSITION_ASSIGNMENT.search(text)
    confirm = HOOK_CONFIRM_ASSIGNMENT.search(text)
    assert (
        disposition is not None
    ), "the hook must declare $script:AbandonDispositionToken with a quoted value"
    assert (
        confirm is not None
    ), "the hook must declare $script:AbandonConfirmToken with a quoted value"
    return (disposition.group("value"), confirm.group("value"))


def skill_invocation_line() -> str:
    """Return the SKILL's single documented abandon invocation line.

    Returns:
        str: The one line carrying the CLI file-name anchor together with at least one
        option token. A line naming the CLI in prose carries no option token and is
        therefore not selected.

    Raises:
        AssertionError: If the SKILL carries no such line, or more than one, since
            either case makes the invocation impossible to parse deterministically.
    """

    # Select by anchor AND option token: the SKILL mentions the module path in prose
    # too, and only the executable invocation carries option tokens.
    candidates = [
        line
        for line in read_text(SKILL_PATH).splitlines()
        if INVOCATION_ANCHOR in line and OPTION_PREFIX in line
    ]
    assert len(candidates) == 1, (
        f"{SKILL_PATH.name} must carry exactly one documented invocation line matching "
        f"the anchor {INVOCATION_ANCHOR!r} with option tokens; found "
        f"{len(candidates)}: "
        f"{candidates}"
    )
    return candidates[0]


def skill_option_tokens() -> set[str]:
    """Extract the option tokens documented on the SKILL's invocation line.

    Every whitespace-separated token beginning with the option prefix contributes
    itself, and additionally contributes the ``<option> <value>`` pair when the next
    token is a value rather than another option. Emitting both shapes is what lets a
    bare flag and a valued option be compared against the CLI's pair without this
    test knowing which shape either token takes.

    Returns:
        set[str]: The bare options and the option-plus-value pairs on that line.

    Raises:
        AssertionError: If the line yields no option token at all.
    """

    tokens = skill_invocation_line().split()
    extracted: set[str] = set()
    # Walk the token list once, emitting the bare flag and, where a value follows, the
    # composed pair. Index-based iteration is needed to look ahead one token.
    for index, token in enumerate(tokens):
        if not token.startswith(OPTION_PREFIX):
            continue
        extracted.add(token)
        following = tokens[index + 1] if index + 1 < len(tokens) else None
        if following is not None and not following.startswith(OPTION_PREFIX):
            extracted.add(f"{token} {following}")
    assert (
        extracted
    ), "the documented invocation line must carry at least one option token"
    return extracted


def test_cli_declares_a_non_empty_token_pair() -> None:
    """The producer-side constants must both carry a value."""

    disposition, confirm = cli_token_pair()

    assert disposition.strip(), "ABANDON_DISPOSITION_TOKEN must not be empty"
    assert confirm.strip(), "CONFIRM_ABANDON_TOKEN must not be empty"


def test_parser_registers_the_confirmation_token() -> None:
    """The confirmation constant must be wired into the live argparse surface."""

    option_strings = parser_option_strings()

    assert option_strings, "build_parser() must register at least one option string"
    assert cli_token_pair()[1] in option_strings, (
        "CONFIRM_ABANDON_TOKEN must appear in some action's option_strings; the parser "
        f"registers {sorted(option_strings)}"
    )


def test_parser_composes_the_disposition_token() -> None:
    """The disposition constant must equal what the parser's own surface composes."""

    assert cli_token_pair()[0] == disposition_action_composition(), (
        "ABANDON_DISPOSITION_TOKEN must be composed exactly from the disposition "
        "action's option string plus the abandon member of its choices"
    )


def test_hook_declares_a_non_empty_token_pair() -> None:
    """The consumer-side assignments must both yield a value."""

    disposition, confirm = hook_token_pair()

    assert disposition.strip(), "the hook's disposition token must not be empty"
    assert confirm.strip(), "the hook's confirmation token must not be empty"


def test_hook_token_pair_equals_the_cli_pair() -> None:
    """The gate must match on exactly the tokens the CLI produces."""

    assert hook_token_pair() == cli_token_pair(), (
        "the hook's declared token pair must equal the CLI's; a divergence here means "
        "the gate cannot match the invocation it is meant to guard"
    )


@pytest.mark.parametrize("token_index", [0, 1])
def test_hook_states_each_token_exactly_once(token_index: int) -> None:
    """Each token literal must appear only in its own named assignment."""

    token = hook_token_pair()[token_index]

    assert read_text(HOOK_PATH).count(token) == 1, (
        f"the hook must state {token!r} exactly once, in its named assignment, so the "
        "extracted value is the only token the hook can match on"
    )


def test_skill_documents_the_cli_token_pair() -> None:
    """The documented invocation must carry both tokens the CLI produces."""

    documented = skill_option_tokens()
    disposition, confirm = cli_token_pair()

    assert disposition in documented, (
        f"the documented invocation must carry {disposition!r}; it carries "
        f"{sorted(documented)}"
    )
    assert confirm in documented, (
        f"the documented invocation must carry {confirm!r}; it carries "
        f"{sorted(documented)}"
    )


def test_skill_invocation_line_names_the_cli_module() -> None:
    """The parsed line must be the invocation, not an arbitrary option-bearing line."""

    line = skill_invocation_line()

    assert INVOCATION_ANCHOR in line
    assert line.strip(), "the documented invocation line must not be blank"


def test_all_three_extractions_agree() -> None:
    """The single binding assertion: CLI, hook, and SKILL carry one token pair."""

    cli_pair = cli_token_pair()
    hook_pair = hook_token_pair()
    documented = skill_option_tokens()

    assert cli_pair == hook_pair
    assert set(cli_pair) <= documented
