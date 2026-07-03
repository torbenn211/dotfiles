#!/usr/bin/env python3
import select
import sys
from collections import deque

try:
    import evdev
except Exception:
    print("")
    sys.stdout.flush()
    sys.exit(0)


def keyboard_devices():
    devices = []
    for path in evdev.list_devices():
        try:
            dev = evdev.InputDevice(path)
            keys = dev.capabilities().get(evdev.ecodes.EV_KEY, [])
            if evdev.ecodes.KEY_A in keys and evdev.ecodes.KEY_SPACE in keys:
                devices.append(dev)
        except Exception:
            continue
    return devices


keyboards = keyboard_devices()
if not keyboards:
    print("")
    sys.stdout.flush()
    sys.exit(0)

fds = {dev.fd: dev for dev in keyboards}
buffer = deque(maxlen=4)
mods = {"SHIFT": False, "CTRL": False, "ALT": False, "SUPER": False, "CAPS": False}

letters = {
    evdev.ecodes.KEY_Q: "q",
    evdev.ecodes.KEY_W: "w",
    evdev.ecodes.KEY_E: "e",
    evdev.ecodes.KEY_R: "r",
    evdev.ecodes.KEY_T: "t",
    evdev.ecodes.KEY_Y: "y",
    evdev.ecodes.KEY_U: "u",
    evdev.ecodes.KEY_I: "i",
    evdev.ecodes.KEY_O: "o",
    evdev.ecodes.KEY_P: "p",
    evdev.ecodes.KEY_A: "a",
    evdev.ecodes.KEY_S: "s",
    evdev.ecodes.KEY_D: "d",
    evdev.ecodes.KEY_F: "f",
    evdev.ecodes.KEY_G: "g",
    evdev.ecodes.KEY_H: "h",
    evdev.ecodes.KEY_J: "j",
    evdev.ecodes.KEY_K: "k",
    evdev.ecodes.KEY_L: "l",
    evdev.ecodes.KEY_Z: "z",
    evdev.ecodes.KEY_X: "x",
    evdev.ecodes.KEY_C: "c",
    evdev.ecodes.KEY_V: "v",
    evdev.ecodes.KEY_B: "b",
    evdev.ecodes.KEY_N: "n",
    evdev.ecodes.KEY_M: "m",
}

names = {
    "SPACE": "Space",
    "ENTER": "Enter",
    "TAB": "Tab",
    "ESC": "Esc",
    "BACKSPACE": "Bksp",
    "CAPSLOCK": "Caps",
    "DOT": ".",
    "COMMA": ",",
    "SLASH": "/",
    "MINUS": "-",
    "EQUAL": "=",
    "SEMICOLON": ";",
    "APOSTROPHE": "'",
    "LEFTBRACE": "[",
    "RIGHTBRACE": "]",
    "BACKSLASH": "\\",
}


def key_name(code):
    if code in letters:
        value = letters[code]
        return value.upper() if mods["SHIFT"] ^ mods["CAPS"] else value

    raw = evdev.ecodes.KEY.get(code, f"UNK{code}")
    raw = raw.replace("KEY_", "")
    return names.get(raw, raw.title())


def update_modifier(name, value):
    pressed = value != 0
    if "SHIFT" in name:
        mods["SHIFT"] = pressed
        return True
    if "CTRL" in name:
        mods["CTRL"] = pressed
        return True
    if "ALT" in name:
        mods["ALT"] = pressed
        return True
    if "META" in name:
        mods["SUPER"] = pressed
        return True
    if "CAPSLOCK" in name:
        if value == 1:
            mods["CAPS"] = not mods["CAPS"]
        return True
    return False


print("")
sys.stdout.flush()

while True:
    readable, _, _ = select.select(list(fds.keys()), [], [])
    for fd in readable:
        dev = fds[fd]
        for event in dev.read():
            if event.type != evdev.ecodes.EV_KEY:
                continue

            code = event.code
            raw_name = evdev.ecodes.KEY.get(code, "")
            is_modifier = update_modifier(raw_name, event.value)

            if event.value != 1 or is_modifier:
                continue

            prefix = ""
            if mods["SUPER"]:
                prefix += "Super-"
            if mods["CTRL"]:
                prefix += "Ctrl-"
            if mods["ALT"]:
                prefix += "Alt-"
            if mods["SHIFT"] and code not in letters:
                prefix += "Shift-"

            buffer.append(prefix + key_name(code))
            print(" ".join(buffer))
            sys.stdout.flush()
