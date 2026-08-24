/**
 * Git Gate Extension
 *
 * Intercepts `git push` and `git commit` commands by properly parsing the
 * bash command into an AST (using `unbash`), then prompts the user with a
 * 30-second countdown. If the user confirms within 30s, the command runs
 * normally. If they cancel or time out, it's blocked.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";
import { parse } from "unbash";

/** Check a parsed command to see if it's `git push` or `git commit`. */
function isBlockedGitCommand(command: string): boolean {
	try {
		const ast = parse(command);
		for (const stmt of ast.commands) {
			const cmd = stmt.command;
			if (cmd.type !== "Command") continue;
			const name = cmd.name?.text ?? "";
			if (name !== "git") continue;
			const subcommand = cmd.suffix?.[0]?.text ?? "";
			if (subcommand === "push" || subcommand === "commit") return true;
		}
		return false;
	} catch {
		// If parsing fails, fall back to regex rather than blocking everything
		return /\bgit\s+(push|commit)\b/.test(command);
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (!isToolCallEventType("bash", event)) return;

		const command = event.input.command ?? "";
		if (!isBlockedGitCommand(command)) return;

		const controller = new AbortController();
		const timeoutId = setTimeout(() => controller.abort(), 30_000);

		try {
			const summary = command.length > 120
				? command.slice(0, 120) + "..."
				: command;

			const confirmed = await ctx.ui.confirm(
				"Git Gate",
				`Allow this git command?\n\n${summary}`,
				{ signal: controller.signal },
			);

			if (confirmed) {
				// Let it through
				return;
			}

			if (controller.signal.aborted) {
				return {
					block: true,
					reason: `⏱️ Timed out waiting for approval (30s). The git command was blocked. Tell the user and continue with the task — they can run the git command manually if needed.`,
				};
			}

			return {
				block: true,
				reason: `🚫 Git command blocked by user.`,
			};
		} finally {
			clearTimeout(timeoutId);
		}
	});
}