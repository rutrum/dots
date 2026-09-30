---
name: new-agent
description: |
    Launch a pi "worker" agent in a new zellij tab with an initial brief, so
    distinct or independent chunks of work run in their own context instead of
    bloating this session. Use when the user asks to hand off or split off work
    to a new agent, to start a separate thread of work, or when a self-contained
    task can run in isolation and optionally report its result back.
---

# New Agent

Launches a pi coding agent (a "worker") in a new zellij tab.

## Usage

```
kick-off [options] <message|@file|-> [tab-name]
```

- `message` — initial prompt/context for pi (required). Use `@path` to read it
  from a file, or `-` to read stdin (handy for long briefs).
- `tab-name` — name for the new zellij tab and the pi session (defaults to `pi`).

## Options

- `-c, --cwd <dir>` — working directory for the worker (default: the caller's
  `$PWD`). Without this, the tab inherits the zellij session cwd.
- `--report` — ask the worker to send its final report back to this session via
  pi-post (`send_message`) when its gate passes. Off by default.
- `--report-to <target>` — report to a specific session address instead of this
  one (implies `--report`).
- `-h, --help`

## The report loop

With `--report`, the caller's pi-post address is read from
`PI_SESSION_ADDRESS` (set by the `pi-post` package extension, not core pi;
falls back to the documented `PI_SESSION_ID`). The worker gets an appended
system-prompt instruction to `send_message` its final report to that address.
The orchestrator is woken when the message arrives, and can reply to the
worker's address, which pi-post adds to delivered messages.

`--report` defaults off because not every worker needs to come back: many are
one-shot. Opt in for workstreams whose results you want pushed to you.

## Notes

- Prefer a fresh worker for each distinct task: split agents exist to keep
  context small, so resume an existing session only when the follow-up truly
  depends on context that worker already built up.
- Fails clearly if not inside a zellij session or if `--cwd` does not exist.
- The caller's environment (including `--report` discovery) is read at launch,
  so the report target is baked into the worker's system prompt.
