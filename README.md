# atom-terminus

Open terminal on current file's directory with `ctrl-shift-t`.

Open a terminal in the project's root directory with `alt-shift-t`.

Keybindings: `ctrl-shift-t`, `alt-shift-t`

Install: `apm install atom-terminus`

Config:
```coffeescript
"atom-terminus":
    # only necessary if standard config doesn't find terminal app
    app: "/path/to/your/favorite/terminal"
    args: "--useThisOptionWhenLaunchingTerminal"
```

## What's New?

The following are improvements that you will find in this package which are not in atom-terminal:

- Support for multiple project roots
- Better Linux support

![atom-terminus](https://raw.github.com/drelyn86/atom-terminus/master/terminus.gif)
