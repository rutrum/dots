---
name: context-files
description: |
    Write and edit agent context files: skills (SKILL.md) and AGENTS.md.
    Use when creating or modifying a skill, or when editing an AGENTS.md.
---

# Context files

Persistent instructions an agent reads on its own. Write for the agent that reads it later, not for a human reviewing the change.

## Skills

- Live at `~/.agents/skills/<name>/SKILL.md`; the source of truth in this setup is `~/dots/pi/skills/<name>/SKILL.md`.
- Frontmatter has `name` and `description`; `name` matches the directory name (lowercase letters, numbers, hyphens).
- `description` states what the skill does and when to use it. It is the only text the agent sees before loading the skill, so make it route correctly.
- Put scripts, templates, and references next to `SKILL.md` and reference them by paths relative to the skill directory.
- Reach for a skill when a workflow needs real instructions plus supporting files; a single rule belongs in `AGENTS.md`.
- Run `/reload` to pick up an edit during a live session.

## AGENTS.md

- Applies to its directory and everything below it. Loaded from the working directory and its parents, plus `~/.pi/agent/AGENTS.md`.
- Put repo-specific facts in the repo's `AGENTS.md`; cross-repo preferences in `~/.pi/agent/AGENTS.md`.
- Record durable rules and conventions that apply to every task in scope. One-off task instructions belong in the prompt, not here.
- Give exact commands, paths, and patterns instead of describing them.
- Delete stale instructions rather than appending corrections.

## Style

- don't insert hard wraps into paragraphs
- prefer bullet points for most statements
- don't explain WHY something, just to DO something
- prefer concrete commands, paths, and examples over prose
