# gealubi
Choose your language/Выбери свой язык:
- English/[Русский](https://github.com/Yenoxel/gealubi/blob/main/%D0%9F%D0%A0%D0%9E%D0%A7%D0%A2%D0%98-%D0%9C%D0%95%D0%9D%D0%AF.md)
## Contents:
* [Name](#name)
* [Short Description](#short-description)
* [Long Description](#long-description)
* [Screenshoots](#screenshoots)
* [Dependencies](#dependencies)
    - [VoidLinux](#voidlinux-os)
    - [MS-Windows](#ms-windows)
    - [MAC-OS](#mac-os)
    - [Note](#note-for-all-operating-systems)
* [How-to install](#how-to-install)
    - [Unix users](#unix-users)
    - [MS-Windows users](#ms-windows-users)
    - [MAC-OS users](#mac-os-users)
* [How-to use](#how-to-use)
* [Bugs](#bugs)
* [Contributing](#contributing)
* [Alternate repository](#alternate-repository)
## Name:
gealubi stands for: geany luacheck bindings
## Short Description:
Geanylua event script for auto popup annotations with described errors on each line where problem ocurrs.
## Long Description:
Event script (when you save document) for geanylua plugin, for Geany IDE source code editor. Script for lua language developers. Useful for printing luacheck's warnings text directly into the code window by creating annotation box under problematic lines.
## Screenshoots:
- Default geany colorscheme:
![preview](https://github.com/Yenoxel/gealubi/blob/main/geany-default-colorscheme-luacheck-warnings.png)
- Monokai geany colorscheme:
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
### MAC-OS:
- Official site: [geany.org](https://www.geany.org/download/releases/)
- [geany-2.0_osx.dmg](https://download.geany.org/geany-2.0_osx.dmg)
    - Plugins included.
- [geany-2.0_osx_arm64.dmg](https://download.geany.org/geany-2.0_osx_arm64.dmg)
    - Not sure about plugins. Let me know in Issues, ok?
### Note for all operating systems:
- Do not forget enable the geanylua plugin.
````markdown
Tools > Plugin Manager > Lua Script 
````
## How to install:
### UNIX users:
- Voidlinux OS:
1. Lua
````markdown
$ sudo xbps-install -Su lua53
````

2. Luarocks and Luacheck(with dependencies)
````markdown
$ sudo xbps-install -Su luarocks-lua53
$ luarocks --local install luacheck
````
- luacheck binary must be in:
````markdown
/home/username/.luarocks/bin/luacheck
````
or specify absolute path to your luacheck linter app by editing file 'saved.lua' and changing path in variable:
````lua
gealubi.unix_luacheck_path = [[/home/yeleaf/.luarocks/bin/luacheck2]]
````
This variable have higher priority. If gealubi script not find app from variable above it will check for default path.

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
All steps IMPORTANT if 'Optional step' not specified.
1. Luacheck app:
For Windows there is single-file 64-bit binary distribution, bundling Lua 5.3.4, Luacheck, LuaFileSystem, and LuaLanes using: [LuaStatic](https://github.com/ers35/luastatic): 
- [download binary](https://github.com/lunarmodules/luacheck/releases/download/v1.2.0/luacheck.exe)
- Edit the 'saved.lua' script by finding line:
````lua
gealubi.windows_luacheck_path = [["C:\Program Files\Lua\luacheck.exe"]]
````
And paste absolute path to your luacheck.exe between square brackets (with preserved quotes if spaces in path exist).

2. Copy script 'saved.lua' into:
````markdown
C:\users\username\AppData\Roaming\geany\plugins\geanylua\events\
````

3. Copy script 'gealubi.lua' into:
````markdown
C:\users\username\AppData\Roaming\geany\plugins\geanylua\support\
````

4. (Optional step) Create '.luacheckrc' file and put it on:
````markdown
C:\users\username\AppData\Local\Luacheck\
````
- [how-to create config file](https://luacheck.readthedocs.io/en/stable/config.html)
### MAC-OS Users:
Need your help here. Tell me in Issues or Pull Request.
1. Try to find luacheck linter app here: [link](https://github.com/lunarmodules/luacheck/releases)
2. For file 'saved.lua'. Find geanylua script directory and submit that path in Issues or Pull Request.
3. For file 'gealubi.lua'. Find geanylua script directory and submit that path in Issues or Pull Request.
4. If you found correct path for gealubi plugin scripts. You can edit script 'saved.lua' by finding line:
````lua
gealubi.unix_luacheck_path = [[/home/yeleaf/.luarocks/bin/luacheck2]]
```` 
and pasting absolute path to your luacheck linter application.

5. (Optional step) Create '.luacheckrc' configurational file. [how-to create link](https://luacheck.readthedocs.io/en/stable/config.html) and paste it at:
````markdown
~/Library/Application Support/Luacheck/.luacheckrc
````
Default mac-os /OS X path.

- Or paste absolute path to your custom luacheck config file in file 'saved.lua' in line containing: 
````lua
gealubi.custom_luacheckrc_config_path = [[C:\.luacheckrc2]]
````

- Note by author: MacOS users can work with this plugin if you figure out where to paste gealubi scripts and find luacheck app for your OS.
Fell free to contribute in Issues or Pull Request. Together we finding a way.

## How to use:
Just write your lua script as usual and then press Ctrl+S (save). After saving the lua file, script run luacheck on your file, extracts warnings (and errors) and draws it's in boxes under problematic lines.
## Bugs:
If you found something, let me know in Issues, ok?
## Contributing:
Feel free to contribute bugs, suggestion, ideas or more optimized lua code in 'Issues' or Pull Request.
## Alternate repository:
Using [codeberg.org](https://codeberg.org/Yeleaf/gealubi) ?
* [GO UP ^](#gealubi)
