# nvim-dap-powershell

An extension for [nvim-dap][1] providing default configurations for powershell. Supports launch and attach configurations.


## Installation

- Requires Neovim >= 0.5
- Requires [nvim-dap][1]
- Requires [Powershell Editor Services][3]
- Installation:
``` lua
{
    "Willem-J-an/nvim-dap-powershell",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "mfussenegger/nvim-dap",
        "rcarriga/nvim-dap-ui",
        {
            "m00qek/baleia.nvim",
            lazy = true,
            tag = "v1.4.0",
        },
    },
    config = function()
        require("dap-powershell").setup()
    end,
}
```

## Configuration

### Default config
``` lua
{
    include_configs = true,
    pwsh_executable = "pwsh",
    pses_bundle_path -- Default path for PowerShell Editor Services bundle if installed through mason.
}
```

### Powershell launch.json

Launch.json refers to powershell as type = PowerShell, but nvim-dap refers to the filetype, default = ps1.
To make the standard launch.json work it is recommended to set powershell filetype as PowerShell.

This is done by:
- Create file in your nvim directory: ftdetect/PowerShell.vim
- Set content to:
``` vim
au BufRead,BufNewFile *.ps1 set filetype=PowerShell
au BufRead,BufNewFile *.psm1 set filetype=PowerShell
```

### Repl content color correction

Powershell Editor Services send back ANSI color coded error messages. These are not correctly parsed out of the box.
To fix this it is recommended to configure the following after the dapui is initialized:

``` lua
local dapui = require("dapui")
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open({})
    require('dap-powershell').correct_repl_colors()
end
```

## Custom dap configurations

If you call the `require('dap-powershell').setup` method it will create a few `nvim-dap` configuration entries.
These configurations are general purpose configurations suitable for many use cases, but you may need to customize the configurations.

To add your own entries, you can extend the `dap.configurations.PowerShell` list after calling the `setup` function:

```vimL
lua << EOF
require('dap-powershell').setup()
table.insert(require('dap').configurations.PowerShell, {
  type = 'PowerShell',
  request = 'launch',
  name = 'My custom launch configuration',
  script = '${file}',
})
EOF
```

An alternative is to use project specific `.vscode/launch.json` files, see `:help dap-launch.json`.


[1]: https://github.com/mfussenegger/nvim-dap
[3]: https://github.com/PowerShell/PowerShellEditorServices
