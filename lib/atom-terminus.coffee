exec = require('child_process').exec
fs = require('fs')
path = require('path')
platform = require('os').platform
{CompositeDisposable} = require 'atom'

###
  Opens a terminal in the given directory, as specefied by the config
###
open_terminal = (dirpath, full_filepath) ->
  # Figure out the app and the arguments
  prefix = atom.config.get('atom-terminus.commandPrefix')
  app = atom.config.get('atom-terminus.app')
  args = atom.config.get('atom-terminus.args')

  # A single space in prefix or args should override defaults to empty
  if prefix == ' '
    prefix = ''
  if args == ' '
    args = ''

  # get options
  setWorkingDirectory = atom.config.get('atom-terminus.setWorkingDirectory')
  runDirectly = atom.config.get('atom-terminus.runDirectly')

  # set relative_filepath
  relative_filepath = full_filepath.replace(dirpath + path.sep, '')

  # Start assembling the command line
  cmdline = ""
  if prefix
    cmdline = "#{prefix} "
  cmdline = "#{cmdline}\"#{app}\""
  if args
    cmdline = "#{cmdline} #{args}"
  cmdline = cmdline.replace(/%d/g, dirpath)
  cmdline = cmdline.replace(/%p/g, full_filepath)
  cmdline = cmdline.replace(/%f/g, relative_filepath)

  # For mac, we prepend open -a unless we run it directly
  if platform() == "darwin" && !runDirectly
    cmdline = "open -a " + cmdline
  # for windows, we prepend start unless we run it directly.
  if platform() == "win32" && !runDirectly
    cmdline = "start \"\" " + cmdline
  # for linux, we prepend sh unless we run it directly.
  if platform() == "linux" && !runDirectly
    cmdline = "sh -c \"" + cmdline.replace(/"/g, '\\"') + "\""

  # log the command so we have context if it fails
  console.log("atom-terminus executing: ", cmdline)

  # Set the working directory if configured
  if setWorkingDirectory
    exec cmdline, cwd: dirpath if dirpath?
  else
    exec cmdline if dirpath?


module.exports =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add "atom-workspace", "atom-terminus:open", => @open()
    @subscriptions.add atom.commands.add "atom-workspace", "atom-terminus:open-project-root", => @openroot()
  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null
  open: ->
    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer?.file
    filepath = file?.path
    if filepath
      open_terminal path.dirname(filepath), filepath
  openroot: ->
    root_paths = atom.project.getPaths()
    if root_paths.length > 1
      editor = atom.workspace.getActivePaneItem()
      file = editor?.buffer?.file
      filepath = file?.path
      if filepath
        this_path = path.dirname(filepath)
        for root_path in root_paths
          path_matches = root_path is this_path
          path_in_root = this_path.indexOf(root_path + path.sep) is 0
          if path_matches or path_in_root
            open_terminal root_path, filepath
            break
    else
      open_terminal pathname for pathname in root_paths

# Set per-platform defaults
if platform() == 'darwin'
  # Defaults for Mac, use Terminal.app
  module.exports.config =
    app:
      type: 'string'
      default: 'Terminal.app'
    args:
      type: 'string'
      default: ''
    commandPrefix:
      type: 'string'
      default: ''
    setWorkingDirectory:
      type: 'boolean'
      default: true
    runDirectly:
      type: 'boolean'
      default: false
else if platform() == 'win32'
  # Defaults for windows, use cmd.exe as default
  module.exports.config =
    app:
      type: 'string'
      default: 'C:\\Windows\\System32\\cmd.exe'
    args:
      type: 'string'
      default: ''
    commandPrefix:
      type: 'string'
      default: ''
    setWorkingDirectory:
      type: 'boolean'
      default: true
    runDirectly:
      type: 'boolean'
      default: false
else
  # Defaults for Linux
  # Check for existance of common terminals and set appropriate default args
  linux_terms = [
    {path: '/usr/bin/gnome-terminal', args: '--working-directory "%d"'},
    {path: '/usr/bin/konsole', args: '--workdir "%d"'},
    {path: '/usr/bin/xfce4-terminal', args: '--working-directory "%d"'},
    {path: '/usr/bin/lxterminal', args: '--working-directory "%d"'},
    {path: '/usr/bin/urxvt', args: '-cd "%d"'},
  ]
  default_term = {path: '/usr/bin/x-terminal-emulator', args: ''}
  for term in linux_terms
    try
      if fs.statSync(term.path).isFile()
        default_term = term
        break

  module.exports.config =
    app:
      type: 'string'
      default: default_term.path
    args:
      type: 'string'
      default: default_term.args
    commandPrefix:
      type: 'string'
      default: ''
    setWorkingDirectory:
      type: 'boolean'
      default: true
    runDirectly:
      type: 'boolean'
      default: true
