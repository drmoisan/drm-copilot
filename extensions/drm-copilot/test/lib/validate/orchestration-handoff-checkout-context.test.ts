import { describe, expect, it, jest } from "@jest/globals";

import type {
  CommandResult,
  CommandRunOptions,
  CommandRunner,
} from "../../../src/lib/subprocess-runner";
import {
  createGitCheckoutContext,
  normalizeRepositoryId,
} from "../../../src/lib/validate/orchestration-handoff-checkout-context";

const workspaceRoot = "C:/canonical-workspace";
const canonicalWorkspaceRoot = "C:/canonical-workspace";
const expectedSourceHeadSha = "a".repeat(40);
const observedHeadSha = "b".repeat(40);

type RunnerScript = Readonly<Record<string, CommandResult>>;

function ok(stdout: string): CommandResult {
  return { stdout, stderr: "", code: 0 };
}

function fail(stderr: string): CommandResult {
  return { stdout: "", stderr, code: 128 };
}

/**
 * Build a deterministic {@link CommandRunner} keyed by the exact argument
 * vector. An unscripted invocation is a test defect, so it is surfaced as a
 * failing result rather than silently succeeding.
 */
function createScriptedRunner(script: RunnerScript): {
  readonly runner: CommandRunner;
  readonly run: jest.Mock<
    (args: readonly string[], options?: CommandRunOptions) => CommandResult
  >;
} {
  const run = jest.fn<
    (args: readonly string[], options?: CommandRunOptions) => CommandResult
  >((args: readonly string[]): CommandResult => {
    const key = args.join(" ");
    const scripted = script[key];
    if (scripted === undefined) {
      return fail(`unscripted invocation: ${key}`);
    }
    return scripted;
  });
  return { runner: { run }, run };
}

const defaultScript: RunnerScript = {
  [`git -C ${workspaceRoot} rev-parse --show-toplevel`]: ok(
    canonicalWorkspaceRoot,
  ),
  [`git -C ${workspaceRoot} remote get-url origin`]: ok(
    "https://github.com/drmoisan/drm-copilot.git",
  ),
  [`git -C ${workspaceRoot} branch --show-current`]: ok(
    "feature/portable-handoff-614",
  ),
  [`git -C ${workspaceRoot} rev-parse HEAD`]: ok(observedHeadSha),
};

function scriptWith(overrides: RunnerScript): RunnerScript {
  return { ...defaultScript, ...overrides };
}

describe("normalizeRepositoryId", () => {
  it.each([
    ["https://github.com/drmoisan/drm-copilot.git"],
    ["https://github.com/drmoisan/drm-copilot"],
    ["git@github.com:drmoisan/drm-copilot.git"],
    ["ssh://git@github.com/drmoisan/drm-copilot.git"],
    ["https://user@github.com/drmoisan/drm-copilot.git/"],
  ])("normalizes remote %s to the canonical repository id", (remoteUrl) => {
    // Arrange / Act
    const repositoryId = normalizeRepositoryId(remoteUrl);

    // Assert
    expect(repositoryId).toBe("github.com/drmoisan/drm-copilot");
  });

  it.each([[""], ["   "], ["not a url"], ["https://github.com/"]])(
    "returns null for the unusable remote %p",
    (remoteUrl) => {
      // Arrange / Act
      const repositoryId = normalizeRepositoryId(remoteUrl);

      // Assert
      expect(repositoryId).toBeNull();
    },
  );
});

describe("git checkout observation boundary", () => {
  it("observes canonical workspace, repository, branch, and HEAD", () => {
    // Arrange
    const { runner, run } = createScriptedRunner(defaultScript);
    const context = createGitCheckoutContext(runner);

    // Act
    const observation = context.observe(workspaceRoot);

    // Assert
    expect(observation).toEqual({
      status: "observed",
      repositoryId: "github.com/drmoisan/drm-copilot",
      workspaceRoot: canonicalWorkspaceRoot,
      branch: "feature/portable-handoff-614",
      headSha: observedHeadSha,
    });
    expect(run).toHaveBeenCalledTimes(4);
  });

  it("canonicalizes a Windows toplevel to trailing-slash-free POSIX form", () => {
    // Arrange
    const { runner } = createScriptedRunner(
      scriptWith({
        [`git -C ${workspaceRoot} rev-parse --show-toplevel`]: ok(
          "C:\\canonical-workspace\\",
        ),
      }),
    );
    const context = createGitCheckoutContext(runner);

    // Act
    const observation = context.observe(workspaceRoot);

    // Assert
    expect(observation).toMatchObject({
      status: "observed",
      workspaceRoot: canonicalWorkspaceRoot,
    });
  });

  it("uses no shell and issues no network-capable git subcommand", () => {
    // Arrange
    const { runner, run } = createScriptedRunner(defaultScript);
    const context = createGitCheckoutContext(runner);

    // Act
    context.observe(workspaceRoot);

    // Assert
    const invocations = run.mock.calls.map(([args]) => args.join(" "));
    for (const invocation of invocations) {
      expect(invocation.startsWith("git ")).toBe(true);
      expect(invocation).not.toMatch(/\b(fetch|ls-remote|pull|push|clone)\b/);
    }
    for (const [, options] of run.mock.calls) {
      expect(options).toMatchObject({ allowError: true });
    }
  });

  it.each([
    ["rev-parse --show-toplevel", "workspace"],
    ["remote get-url origin", "repository"],
    ["branch --show-current", "branch"],
    ["rev-parse HEAD", "head"],
  ])(
    "returns an explicit unavailable result when git %s fails",
    (subcommand, reasonFragment) => {
      // Arrange
      const { runner } = createScriptedRunner(
        scriptWith({
          [`git -C ${workspaceRoot} ${subcommand}`]: fail("git error"),
        }),
      );
      const context = createGitCheckoutContext(runner);

      // Act
      const observation = context.observe(workspaceRoot);

      // Assert
      expect(observation.status).toBe("unavailable");
      expect(observation).toMatchObject({ reason: expect.any(String) });
      expect(JSON.stringify(observation)).toContain(reasonFragment);
    },
  );

  it.each([
    ["rev-parse --show-toplevel", ""],
    ["remote get-url origin", "not-a-remote"],
    ["branch --show-current", ""],
    ["rev-parse HEAD", "not-a-sha"],
  ])(
    "returns unavailable for the ambiguous git %s output %p",
    (subcommand, output) => {
      // Arrange
      const { runner } = createScriptedRunner(
        scriptWith({
          [`git -C ${workspaceRoot} ${subcommand}`]: ok(output),
        }),
      );
      const context = createGitCheckoutContext(runner);

      // Act
      const observation = context.observe(workspaceRoot);

      // Assert
      expect(observation.status).toBe("unavailable");
    },
  );

  it("stops observing at the first unavailable git fact", () => {
    // Arrange
    const { runner, run } = createScriptedRunner(
      scriptWith({
        [`git -C ${workspaceRoot} rev-parse --show-toplevel`]:
          fail("not a repo"),
      }),
    );
    const context = createGitCheckoutContext(runner);

    // Act
    const observation = context.observe(workspaceRoot);

    // Assert
    expect(observation.status).toBe("unavailable");
    expect(run).toHaveBeenCalledTimes(1);
  });
});

describe("head relationship validation", () => {
  it("accepts equal only when the observed HEAD matches exactly", () => {
    // Arrange
    const { runner, run } = createScriptedRunner(defaultScript);
    const context = createGitCheckoutContext(runner);

    // Act
    const matching = context.isHeadRelationshipSatisfied({
      workspaceRoot,
      expectedSourceHeadSha,
      observedHeadSha: expectedSourceHeadSha,
      allowedHeadRelationship: "equal",
    });
    const mismatched = context.isHeadRelationshipSatisfied({
      workspaceRoot,
      expectedSourceHeadSha,
      observedHeadSha,
      allowedHeadRelationship: "equal",
    });

    // Assert
    expect(matching).toBe(true);
    expect(mismatched).toBe(false);
    expect(run).not.toHaveBeenCalled();
  });

  it("accepts equal_or_descendant only when git reports ancestry", () => {
    // Arrange
    const ancestorInvocation = `git -C ${workspaceRoot} merge-base --is-ancestor ${expectedSourceHeadSha} HEAD`;
    const { runner: ancestorRunner, run: ancestorRun } = createScriptedRunner(
      scriptWith({ [ancestorInvocation]: ok("") }),
    );
    const { runner: unrelatedRunner } = createScriptedRunner(
      scriptWith({ [ancestorInvocation]: { stdout: "", stderr: "", code: 1 } }),
    );

    // Act
    const descendant = createGitCheckoutContext(
      ancestorRunner,
    ).isHeadRelationshipSatisfied({
      workspaceRoot,
      expectedSourceHeadSha,
      observedHeadSha,
      allowedHeadRelationship: "equal_or_descendant",
    });
    const unrelated = createGitCheckoutContext(
      unrelatedRunner,
    ).isHeadRelationshipSatisfied({
      workspaceRoot,
      expectedSourceHeadSha,
      observedHeadSha,
      allowedHeadRelationship: "equal_or_descendant",
    });

    // Assert
    expect(descendant).toBe(true);
    expect(unrelated).toBe(false);
    expect(ancestorRun).toHaveBeenCalledWith(
      [
        "git",
        "-C",
        workspaceRoot,
        "merge-base",
        "--is-ancestor",
        expectedSourceHeadSha,
        "HEAD",
      ],
      { allowError: true },
    );
  });

  it("treats a git ancestry error as an unsatisfied relationship", () => {
    // Arrange
    const { runner } = createScriptedRunner(
      scriptWith({
        [`git -C ${workspaceRoot} merge-base --is-ancestor ${expectedSourceHeadSha} HEAD`]:
          fail("bad object"),
      }),
    );
    const context = createGitCheckoutContext(runner);

    // Act
    const satisfied = context.isHeadRelationshipSatisfied({
      workspaceRoot,
      expectedSourceHeadSha,
      observedHeadSha,
      allowedHeadRelationship: "equal_or_descendant",
    });

    // Assert
    expect(satisfied).toBe(false);
  });
});
