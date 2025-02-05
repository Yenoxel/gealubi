# gealubi
## Name:
gealubi stands for: geany luacheck bindings
## Short Description:
Geanylua event script for auto popup annotations with described errors on each line where problem ocurrs.
## Long Description:
Event script (when you save document) for geanylua plugin, for Geany IDE source code editor. Script for lua language developers. Useful for printing luacheck's warnings text directly into the code window by creating annotation box under problematic lines.
## Screenshoots:
Default geany colorscheme:
![preview](https://github.com/Yenoxel/gealubi/blob/main/geany-default-colorscheme-luacheck-warnings.png)
Monokai geany colorscheme:
![preview2](https://github.com/Yenoxel/gealubi/blob/main/geany-monokai-colorscheme-luacheck-warnings.png)
## Dependencies:
### VoidLinux OS:
````markdown
$ sudo xbps-install -Su geany
$ sudo xbps-install -Su geany-plugins-extra
````
### MS-Windows:
- Official site: [geany.org](https://www.geany.org/download/releases/)
- [geany-2.0_setup.exe](https://download.geany.org/geany-2.0_setup.exe)
- [geany-plugins-2.0_setup.exe](https://plugins.geany.org/geany-plugins/geany-plugins-2.0_setup.exe)

- Do not forget enable the geanylua plugin.
````markdown
Tools > Plugin Manager > Lua Script 
````
## How to install:
### UNIX users:
- Voidlinux OS:
1. Lua
````bash
sudo xbps-install -Su lua53
````
2. Luarocks and Luacheck(with dependencies)
````bash
sudo xbps-install -Su luarocks-lua53
luarocks --local install luacheck
````
- luacheck binary must be in:
````markdown
/home/username/.luarocks/bin/luacheck
````
3. Copy script 'saved.lua' into:
````markdown
/home/username/.config/geany/plugins/geanylua/events/
````
4. Copy script 'gealubi.lua' into:
````markdown
/home/username/.config/geany/plugins/geanylua/support/
````
- If folders (events and support) not exist. Just create them.
5. (Optional step) Create '.luacheckrc' file and put it on:
````markdown
/home/username/.config/luacheck/
````
[how-to create config file](https://luacheck.readthedocs.io/en/stable/config.html)
### MS-Windows users:
1. Luacheck app:
For Windows there is single-file 64-bit binary distribution, bundling Lua 5.3.4, Luacheck, LuaFileSystem, and LuaLanes using: [LuaStatic](https://github.com/ers35/luastatic): [download binary](https://github.com/lunarmodules/luacheck/releases/download/v1.2.0/luacheck.exe)
2. Copy script 'saved.lua' into:
````markdown
C:\users\username\AppData\Roaming\geany\plugins\geanylua\events\
````
3. Copy script 'gealubi.lua' into:
````markdown
C:\users\username\AppData\Roaming\geany\plugins\geanylua\support\
````
- Edit the 'gealubi.lua' script by finding line:
````lua
gealubi.windows_luacheck_path = [["C:\Program Files\Lua\luacheck.exe"]]
````
- And paste absolute path to your luacheck.exe between square brackets (with preserved quotes).
4. (Optional step) Create '.luacheckrc' file and put it on:
````markdown
C:\users\username\AppData\Local\Luacheck\
````
- [how-to create config file](https://luacheck.readthedocs.io/en/stable/config.html)
## How to use:
Just write your lua script as usual and then press Ctrl+S (save). After saving the lua file, script run luacheck on your file, extracts warnings (and errors) and draws it's in boxes under problematic lines.
## Bugs:
If you found something, let me know in Issues, ok?
