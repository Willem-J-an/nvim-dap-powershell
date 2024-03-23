---@mod dap-powershell Powershell extension for nvim-dap

local M = {}
local Path = require("plenary.path")
local dappwsh_configs = require("dap-powershell.configs")
local dappwsh_process = require("dap-powershell.process")

local specify_script_args_indicator = "${command:SpecifyScriptArgs}"
local pick_host_process_indicator = "${command:PickPSHostProcess}"

local function load_dap()
    local ok, dap = pcall(require, "dap")
    assert(ok, "nvim-dap is required to use dap-powershell")
    return dap
end

---@param pses_bundle_path string | nil Path to the powershell-editor-services bundle.
---@return Path pses_bundle_path Validated pses_bundle_path
local function get_pses_bundle_path(pses_bundle_path)
    if pses_bundle_path == nil then
        local mason_home = Path:new(vim.fn.stdpath("data"), "mason")
        pses_bundle_path = mason_home:joinpath("packages", "powershell-editor-services")
    end
    local bundle_path = Path:new(pses_bundle_path)

    assert(
        bundle_path:exists(),
        "Powershell Editor Services was not found; be sure to install it and pass a valid path; tried["
            .. pses_bundle_path
            .. "]"
    )
    return bundle_path
end

---@param opts DapPwshSetupOpts
---@return Adapter
local function get_dap_adapter(opts)
    local pses_bundle_path = get_pses_bundle_path(opts.pses_bundle_path)
    local tmpdir = Path:new(os.tmpname() .. "d")
    tmpdir:mkdir()

    return {
        type = "pipe",
        pipe = "${pipe}",
        executable = {
            command = "pwsh",
            args = dappwsh_configs.get_adapter_args(pses_bundle_path, tmpdir),
        },
    }
end

---Fix correct application of ANSI color codes for the dap repl pane.
---Run this after dapui has initialized.
function M.correct_repl_colors()
    local visible_wins = vim.api.nvim_tabpage_list_wins(0)
    for _, win in ipairs(visible_wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "dap-repl" then
            local baleia = require("baleia").setup()
            baleia.automatically(buf)
        end
    end
end

---Register the powershell debug adapter
---@param opts DapPwshSetupOpts|nil
function M.setup(opts)
    opts = vim.tbl_extend("keep", opts or {}, dappwsh_configs.default_setup_opts)
    local dap_adapter = get_dap_adapter(opts)
    local dap = load_dap()

    dap.adapters.PowerShell = function(cb, config)
        if config.processId == pick_host_process_indicator then
            local prompt = { prompt = "Choose process id" }
            local result
            vim.ui.select(dappwsh_process.get_attach_choices(), prompt, function(choice)
                result = vim.split(choice, ":")[2]
                config.processId = result
                cb(dap_adapter)
            end)
            return
        end

        if config.request == "attach" then
            config.processId = dappwsh_process.get_dotnet_process_id()
        end

        if config.args and vim.tbl_contains(config.args, specify_script_args_indicator) then
            local args = vim.fn.input("Specify Script Args: ")
            for index, arg in ipairs(config.args) do
                if arg == specify_script_args_indicator then
                    config.args[index] = args
                end
            end
        end
        cb(dap_adapter)
    end

    if opts.include_configs then
        local configs = dap.configurations.PowerShell or {}
        dap.configurations.PowerShell = configs
        for _, config in pairs(dappwsh_configs.get_default_configs(specify_script_args_indicator)) do
            table.insert(configs, config)
        end
    end
end

return M
