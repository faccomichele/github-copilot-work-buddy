#!/usr/bin/env python3
"""PreToolUse hook: Work Buddy may only run scripts/yo-gh in the terminal."""
import json
import os
import re
import shlex
import sys

SCRIPT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "yo-gh")


def decide(permission, reason):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": permission,
        "permissionDecisionReason": reason,
    }}))
    sys.exit(0)


def single_simple_command(cmd):
    # Unquoted operators or newlines would let a second command ride along.
    quote, escaped = None, False
    for ch in cmd:
        if escaped:
            escaped = False
        elif quote:
            if ch == "\\" and quote == '"':
                escaped = True
            elif ch == quote:
                quote = None
        elif ch == "\\":
            escaped = True
        elif ch in "'\"":
            quote = ch
        elif ch in ";&|<>()\n\r":
            return False
    return quote is None


data = json.load(sys.stdin)
if not re.search(r"terminal|bash|shell|execute", str(data.get("tool_name", "")), re.I):
    sys.exit(0)

command = (data.get("tool_input") or {}).get("command")
if not isinstance(command, str):
    decide("deny", "Could not read the terminal command.")
# `$` and backticks would expand environment variables or run substitutions inside quotes.
if "$" in command or "`" in command or not single_simple_command(command):
    decide("deny", "Only a single plain yo-gh command is allowed (no $, backticks, pipes, or chaining).")
try:
    first = shlex.split(command)[0]
except (ValueError, IndexError):
    decide("deny", "Could not parse the terminal command.")
if os.path.realpath(first) != os.path.realpath(SCRIPT):
    decide("deny", "Work Buddy may only run ./scripts/yo-gh from the workspace root.")
decide("allow", "yo-gh")
