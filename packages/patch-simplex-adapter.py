import sys

if len(sys.argv) > 1:
    path = sys.argv[1]
    with open(path) as f:
        src = f.read()
else:
    src = sys.stdin.read()

old_send = '''            if chat_id.startswith("group:"):
                # Structured form: addresses by numeric ID, and json.dumps
                # escapes newlines + special chars correctly.
                composed = json.dumps(
                    [{"msgContent": {"type": "text", "text": content}}]
                )
                cmd_str = f"/_send #{chat_id[6:]} json {composed}"
            else:
                cmd_str = f"@{chat_id} {content}"'''

new_send = '''            composed = json.dumps(
                [{"msgContent": {"type": "text", "text": content}}]
            )
            if chat_id.startswith("group:"):
                cmd_str = f"/_send #{chat_id[6:]} json {composed}"
            else:
                cmd_str = f"/_send @{chat_id} json {composed}"'''

assert old_send in src, "Could not find DM send() code to patch"
src = src.replace(old_send, new_send)

old_standalone = '''            # Direct contacts are addressed by display name without brackets.
            cmd_str = f"@{chat_id} {message}"'''

new_standalone = '''            composed = json.dumps(
                [{"msgContent": {"type": "text", "text": message}}]
            )
            cmd_str = f"/_send @{chat_id} json {composed}"'''

assert old_standalone in src, "Could not find _standalone_send() code to patch"
src = src.replace(old_standalone, new_standalone)

if len(sys.argv) > 1:
    with open(path, "w") as f:
        f.write(src)
    print("Patched simplex adapter successfully")
else:
    sys.stdout.write(src)
