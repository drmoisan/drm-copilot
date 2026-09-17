import { describe, expect, it } from "@jest/globals";

import { TreeFileSystem } from "./tree-file-system";
import {
  type CommandResult,
  type CommandRunner,
  type CommandRunOptions,
} from "../../../src/lib/subprocess-runner";
import { collectPrContextServiceCall } from "../../../src/lib/pr-context/pr-context-service-call";

/**
 * Table-driven cross-product suite for `target_ref` (spec.md #675,
 * "Explicit target reaches git" / "Fallback is observable, not silent" /
 * "Empty diff fails loudly"). A sibling of `pr-context-service-call.test.ts`,
 * exercising `{ target: explicit | absent } x { diff: populated |
 * empty-with-refs-resolved | empty-with-refs-unresolved }`.
 */

const ROOT = "/workspace";
const SESSION_BRANCH = "feature/session-branch";
const EXPLICIT_TARGET = "feature/explicit-target";
const REQUESTED_BASE = "main";
const RESOLVED_BASE = "origin/main";
const MERGE_BASE_SHA = "merge-sha";

const ok = (stdout: string): CommandResult => ({ stdout, stderr: "", code: 0 });
const fail = (stderr: string): CommandResult => ({
  stdout: "",
  stderr,
  code: 1,
});

/** Deterministic per-ref SHA so an argv assertion can name the source ref. */
function shaFor(ref: string): string {
  return `sha-for-${ref}`;
}

interface RunnerConfig {
  /** Whether the diff carries at least one changed file. */
  readonly diffPopulated: boolean;
  /** A ref that fails `rev-parse --verify`, simulating an unresolved head. */
  readonly unresolvedRef?: string;
}

/** Recording runner: captures every argv call and dispatches deterministically. */
class RecordingRunner implements CommandRunner {
  readonly calls: string[][] = [];

  constructor(private readonly config: RunnerConfig) {}

  run(args: readonly string[], options?: CommandRunOptions): CommandResult {
    this.calls.push([...args]);
    const result = this.dispatch(args);
    if (!(options?.allowError ?? false) && result.code !== 0) {
      const joined = (result.stdout + "\n" + result.stderr).trim();
      throw new Error(`${args.join(" ")} failed (${result.code}): ${joined}`);
    }
    return result;
  }

  private dispatch(args: readonly string[]): CommandResult {
    const isGh = args[0] === "gh" || String(args[0]).endsWith("gh");
    if (isGh) {
      return fail("offline");
    }
    const sub = args.slice(1).join(" ");
    if (sub.startsWith("rev-parse --abbrev-ref HEAD")) {
      return ok(SESSION_BRANCH);
    }
    if (sub.includes("@{u}")) {
      return ok("");
    }
    if (sub.startsWith("rev-parse --verify --quiet")) {
      // Remote-base probe for origin/<base>; always confirms.
      return ok("confirmed");
    }
    if (sub.startsWith("rev-parse --verify")) {
      const requestedRef = args[args.length - 1] ?? "";
      if (
        this.config.unresolvedRef !== undefined &&
        requestedRef === this.config.unresolvedRef
      ) {
        return fail(
          `unknown revision or path not in the working tree: '${requestedRef}'`,
        );
      }
      return ok(shaFor(requestedRef));
    }
    if (sub.startsWith("merge-base")) {
      return ok(MERGE_BASE_SHA);
    }
    if (sub.startsWith("diff --name-status")) {
      return ok(this.config.diffPopulated ? "M\tsrc/example.ts" : "");
    }
    if (sub.startsWith("diff --numstat")) {
      return ok(this.config.diffPopulated ? "1\t0\tsrc/example.ts" : "");
    }
    return ok("");
  }
}

/** Seed a minimal repo with a `.git` marker so resolveRoot returns ROOT. */
function seedWorkspace(): TreeFileSystem {
  const fs = new TreeFileSystem();
  fs.addFile(`${ROOT}/.git`, "");
  fs.addDir(`${ROOT}/docs/features/active`);
  fs.addDir(`${ROOT}/docs/features/potential/promoted`);
  return fs;
}

describe("collectPrContextServiceCall — target_ref cross-product", () => {
  it("passes the explicit target ref to git rather than the session HEAD", () => {
    const runner = new RecordingRunner({ diffPopulated: true });

    collectPrContextServiceCall({
      runner,
      fileSystem: seedWorkspace(),
      workspaceRoot: ROOT,
      base: REQUESTED_BASE,
      targetRef: EXPLICIT_TARGET,
    });

    const revParseCalls = runner.calls.filter(
      (call) => call[1] === "rev-parse" && call[2] === "--verify",
    );
    expect(
      revParseCalls.some((call) => call[call.length - 1] === EXPLICIT_TARGET),
    ).toBe(true);

    const mergeBaseCall = runner.calls.find((call) => call[1] === "merge-base");
    expect(mergeBaseCall).toBeDefined();
    expect(
      (mergeBaseCall ?? []).some((part) => part.includes(EXPLICIT_TARGET)),
    ).toBe(true);

    const flattened = runner.calls.flat();
    expect(flattened.some((part) => part === SESSION_BRANCH)).toBe(false);
  });

  it("reports target_resolution explicit and the resolved head ref and sha when a target ref is supplied", () => {
    const runner = new RecordingRunner({ diffPopulated: true });

    const result = collectPrContextServiceCall({
      runner,
      fileSystem: seedWorkspace(),
      workspaceRoot: ROOT,
      base: REQUESTED_BASE,
      targetRef: EXPLICIT_TARGET,
    });

    expect(result.targetResolution).toBe("explicit");
    expect(result.resolvedHeadRef).toBe(EXPLICIT_TARGET);
    expect(result.resolvedHeadSha).toBe(shaFor(EXPLICIT_TARGET));
  });

  it("reports target_resolution session-fallback when no target ref is supplied", () => {
    const runner = new RecordingRunner({ diffPopulated: true });

    const result = collectPrContextServiceCall({
      runner,
      fileSystem: seedWorkspace(),
      workspaceRoot: ROOT,
      base: REQUESTED_BASE,
    });

    expect(result.targetResolution).toBe("session-fallback");
    expect(result.resolvedHeadRef).toBe(SESSION_BRANCH);
    expect(result.resolvedHeadSha).toBe(shaFor(SESSION_BRANCH));
  });

  it("raises naming the resolved head ref, head sha, merge base and base when the refs resolve and no file changed", () => {
    const runner = new RecordingRunner({ diffPopulated: false });

    expect(() =>
      collectPrContextServiceCall({
        runner,
        fileSystem: seedWorkspace(),
        workspaceRoot: ROOT,
        base: REQUESTED_BASE,
        targetRef: EXPLICIT_TARGET,
      }),
    ).toThrow(
      new RegExp(
        `${EXPLICIT_TARGET}.*${shaFor(EXPLICIT_TARGET)}.*${MERGE_BASE_SHA}.*${RESOLVED_BASE}`,
      ),
    );
  });

  it("raises naming the requested base when the base or head could not be resolved", () => {
    const noChangeRunner = new RecordingRunner({ diffPopulated: false });
    let noChangeMessage = "";
    try {
      collectPrContextServiceCall({
        runner: noChangeRunner,
        fileSystem: seedWorkspace(),
        workspaceRoot: ROOT,
        base: REQUESTED_BASE,
        targetRef: EXPLICIT_TARGET,
      });
    } catch (error) {
      noChangeMessage = error instanceof Error ? error.message : String(error);
    }

    const unresolvedRunner = new RecordingRunner({
      diffPopulated: true,
      unresolvedRef: EXPLICIT_TARGET,
    });
    let unresolvedMessage = "";
    expect(() => {
      try {
        collectPrContextServiceCall({
          runner: unresolvedRunner,
          fileSystem: seedWorkspace(),
          workspaceRoot: ROOT,
          base: REQUESTED_BASE,
          targetRef: EXPLICIT_TARGET,
        });
      } catch (error) {
        unresolvedMessage =
          error instanceof Error ? error.message : String(error);
        throw error;
      }
    }).toThrow(new RegExp(REQUESTED_BASE));

    expect(unresolvedMessage).not.toEqual(noChangeMessage);
  });

  it("writes both artifacts and then raises when the diff is empty", () => {
    const runner = new RecordingRunner({ diffPopulated: false });
    const fs = seedWorkspace();

    expect(() =>
      collectPrContextServiceCall({
        runner,
        fileSystem: fs,
        workspaceRoot: ROOT,
        base: REQUESTED_BASE,
        targetRef: EXPLICIT_TARGET,
      }),
    ).toThrow();

    expect([...fs.writtenPaths].sort()).toEqual([
      `${ROOT}/artifacts/pr_context.appendix.txt`,
      `${ROOT}/artifacts/pr_context.summary.txt`,
    ]);
  });
});
