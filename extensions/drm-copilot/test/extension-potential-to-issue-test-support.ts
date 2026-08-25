import { type jest } from "@jest/globals";

/**
 * Seam helpers for the extension-level `potentialToIssue` cases.
 *
 * Purpose:
 *     Hold the in-process seam arrangement used by
 *     `extension.potential-to-issue.test.ts` so that suite stays under the
 *     500-line repository file-size limit. The helpers are seam arrangement
 *     only: no expected value asserted by any case in that suite lives here.
 *
 * Design choice:
 *     The `node:fs` and `node:child_process` mock handles are passed in rather
 *     than imported, because the `jest.mock` registrations that produce them are
 *     hoisted into the test module and must stay there. The factory therefore
 *     accepts the handles and returns the seam-installing function, leaving the
 *     call sites in the test file unchanged.
 */

/** `node:fs` mock handle required by the in-process seam arrangement. */
export interface PotentialToIssueFsMock {
  readonly existsSync: jest.MockedFunction<(filePath: string) => boolean>;
  readonly readFileSync: jest.MockedFunction<(filePath: string) => string>;
  readonly writeFileSync: jest.MockedFunction<
    (filePath: string, content: string) => void
  >;
  readonly mkdirSync: jest.MockedFunction<(dirPath: string) => void>;
  readonly renameSync: jest.MockedFunction<(src: string, dest: string) => void>;
}

/** `node:child_process` mock handle required by the seam arrangement. */
export interface PotentialToIssueChildProcessMock {
  readonly spawn: jest.Mock;
  readonly spawnSync: jest.Mock;
  readonly execSync: jest.Mock;
}

/** Minimal feature potential content used by the in-process scenarios. */
export const FEATURE_CONTENT = [
  "# Feature Title",
  "## Problem / Why",
  "why",
  "## Proposed Behavior",
  "behave",
].join("\n");

/** Fake `gh` path the seeded `execSync` lookup resolves to. */
const SEEDED_GH_PATH = "/usr/bin/gh";

/** Slug returned by the seeded repository-view resolution. */
const SEEDED_REPO_SLUG = "drmoisan/drm-copilot";

/**
 * Build the seam-installing function bound to a pair of module mock handles.
 *
 * The returned function configures the in-process seams so the promotion
 * workflow runs hermetically: the target repository resolves through the
 * repository-view operation, `gh` resolves on PATH (execSync), `gh` calls
 * return a seeded create result (spawnSync), and the potential file exists with
 * feature content.
 *
 * @param fsMock The hoisted `node:fs` mock handle.
 * @param childProcessMock The hoisted `node:child_process` mock handle.
 * @returns A function taking the exit code returned by the seeded
 *   `gh issue create` (default 0) and returning the recorded `gh` argument
 *   vectors.
 */
export function createInProcessSeamInstaller(
  fsMock: PotentialToIssueFsMock,
  childProcessMock: PotentialToIssueChildProcessMock,
): (createExitCode?: number) => { readonly spawnSyncArgs: string[][] } {
  return function installInProcessSeams(createExitCode = 0): {
    readonly spawnSyncArgs: string[][];
  } {
    const spawnSyncArgs: string[][] = [];

    // `gh` path lookup uses execSync; resolve it to a fake path.
    childProcessMock.execSync.mockReturnValue(`${SEEDED_GH_PATH}\n`);

    // `gh` invocations route through spawnSync. Seed auth-success and a create
    // result; the workflow inspects exit codes itself.
    childProcessMock.spawnSync.mockImplementation((...rawArgs: unknown[]) => {
      const exe = rawArgs[0] as string;
      const args = (rawArgs[1] as string[] | undefined) ?? [];

      // Target-repository resolution runs before the client is constructed and
      // invokes the bare program name, so this branch is matched on the
      // argument vector alone rather than on the executable token. Its stdout
      // must be a Buffer: SubprocessRunner decodes stdout only when it is one,
      // and a plain string would be discarded as empty output.
      if (args[0] === "repo" && args[1] === "view") {
        return {
          status: 0,
          stdout: Buffer.from(`{"nameWithOwner":"${SEEDED_REPO_SLUG}"}`),
          stderr: Buffer.from(""),
        };
      }

      if (exe === SEEDED_GH_PATH) {
        spawnSyncArgs.push([...args]);
        if (args[0] === "auth") {
          return { status: 0, stdout: "ok", stderr: "" };
        }
        if (args[0] === "issue" && args[1] === "create") {
          return {
            status: createExitCode,
            stdout:
              createExitCode === 0
                ? "Created: https://example.com/issues/123"
                : "gh: create failed",
            stderr: "",
          };
        }
        if (args[0] === "issue" && args[1] === "view") {
          return {
            status: 0,
            stdout: '{"number":123,"updatedAt":"2024-01-02T00:00:00Z"}',
            stderr: "",
          };
        }
      }
      return { status: 0, stdout: "", stderr: "" };
    });

    // The potential file exists and holds feature content; metadata writes and
    // the move are recorded by the fs mock (no real disk access).
    fsMock.existsSync.mockReturnValue(true);
    fsMock.readFileSync.mockReturnValue(FEATURE_CONTENT);
    fsMock.writeFileSync.mockReturnValue(undefined);
    fsMock.mkdirSync.mockReturnValue(undefined);
    fsMock.renameSync.mockReturnValue(undefined);

    return { spawnSyncArgs };
  };
}
