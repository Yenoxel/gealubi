# gealubi
## Name:
gealubi stands for: geany luacheck bindings
## Short Description:
Geanylua event script for auto popup anntations with described errors on each line where problem ocurrs.
## Long Description:
Event script (when you save document) for geanylua plugin, for Geany IDE source code editor. Script for lua language developers. Useful for printing luacheck's warnings text directly into the code window by creating annotation box under problematic lines.
## Screenshoot:
![preview](https://github.com/Yenoxel/gealubi/blob/main/Screenshot_2025-01-25_18-26-49.png)
## Dependencies:
- Geany IDE [geany.org](https://www.geany.org/) version 2.0.0
  - geanylua [plugin](https://plugins.geany.org/geanylua/geanylua-index.html)
- Luarocks [link](https://luarocks.org/](https://github.com/luarocks/luarocks/wiki/Download)
  - Luacheck [link](https://github.com/lunarmodules/luacheck)
  - And sub-dependencies which auto installed after luacheck install:
    - LuaFileSystem 1.8.0-1 [link](https://luarocks.org/modules/hisham/luafilesystem)
    - lanes 3.17.0-0 [link](https://luarocks.org/modules/benoitgermain/lanes)
    - argparse 0.7.1-1 [link](https://luarocks.org/modules/argparse/argparse)
- Linux OS
  - But it's possible to adapt only one function named 'luacheck_report()' by changing paths to luacheck program. Rest of the script should works same on any platform. (Where luacheck works)
## How to install:
Voidlinux users:
````markdown
```bash
$ sudo xbps-install -Su luarocks-lua53
$ luarocks --local install luacheck
```
````
