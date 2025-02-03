# gealubi
## Name:
gealubi stands for: geany luacheck bindings
## Short Description:
Geanylua event script for auto popup anntations with described errors on each line where problem ocurrs.
## Long Description:
Event script (when you save document) for geanylua plugin, for Geany IDE source code editor. Script for lua language developers. Useful for printing luacheck's warnings text directly into the code window by creating annotation box under problematic lines.
## Screenshoot:
Default geany colorscheme:
![preview](https://github.com/Yenoxel/gealubi/blob/main/geany-default-colorscheme-luacheck-warnings.png)
Monokai geany colorscheme:
![preview2](https://github.com/Yenoxel/gealubi/blob/main/geany-monokai-colorscheme-luacheck-warnings.png)
## Dependencies:
- Geany IDE [geany.org](https://www.geany.org/) version 2.0.0
  - geanylua [plugin](https://plugins.geany.org/geanylua/geanylua-index.html)
- Luarocks [link](https://github.com/luarocks/luarocks/wiki/Download)
  - Luacheck [link](https://github.com/lunarmodules/luacheck)
  - And sub-dependencies which auto installed after luacheck install:
    - LuaFileSystem 1.8.0-1 [link](https://luarocks.org/modules/hisham/luafilesystem)
    - lanes 3.17.0-0 [link](https://luarocks.org/modules/benoitgermain/lanes)
    - argparse 0.7.1-1 [link](https://luarocks.org/modules/argparse/argparse)
- Linux OS
  - But it's possible to adapt only one function named 'luacheck_report()' by changing paths to luacheck program. Rest of the script should works same on any platform. (Where luacheck works)
## How to install:
1. Luarocks and Luacheck(with dependencies)
- Voidlinux users:
````markdown
$ sudo xbps-install -Su luarocks-lua53
$ luarocks --local install luacheck
````
2. Copy script 'saved.lua' into:
````markdown
/home/username/.config/geany/plugins/geanylua/events/
````
3. Copy script 'gealubi.lua' into:
````markdown
/home/username/.config/geany/plugins/geanylua/support/
````
  3.1 If folders (events and support) not exist. Just create them.
4. Create '.luacheckrc' file and put it on:
````markdown
/home/username/.config/luacheck/
````
[how-to create config file](https://luacheck.readthedocs.io/en/stable/config.html)
## How to use:
Just write your lua script as usual and then press Ctrl+S (save). After saving the lua file, script run luacheck on your file, extracts warnings (and errors) and draws it's in boxes under problematic lines.
## Bugs:
If you found something, let me know in Issues, ok?
