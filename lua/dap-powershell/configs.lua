local M = {}
---@type DapPwshSetupOpts
M.default_setup_opts = {
    include_configs = true,
    pwsh_executable = "pwsh",
}
--- Get the list of default dap configs
---@param specify_script_args_indicator string indicator for script_args_specification
function M.get_default_configs(specify_script_args_indicator)
    return {
        {
            type = "PowerShell",
            request = "launch",
            name = "PowerShell Launch Current File",
            program = "${file}",
            cwd = "${file}",
        },
        {
            type = "PowerShell",
            request = "launch",
            name = "PowerShell Launch File With Arguments",
            program = "${file}",
            args = { specify_script_args_indicator },
            cwd = "${file}",
        },
        {
            type = "PowerShell",
            request = "attach",
            name = "PowerShell Attach Azure Function",
            runspaceId = 1,
        },
        {
            type = "PowerShell",
            request = "attach",
            name = "PowerShell Attach to Chosen Host Process",
            processId = "${command:PickPSHostProcess}",
            runspaceId = 1,
        },
    }
end

--- return adapter args
---@param pses_bundle_path Path Path to the powershell-editor-services bundle.
---@param tmpdir Path Path to tmpdir for logs and session information
---@return string[]
function M.get_adapter_args(pses_bundle_path, tmpdir)
    return {
        "-NoLogo",
        "-NoProfile",
        "-NonInteractive",
        "-OutputFormat",
        "Text",
        "-File",
        pses_bundle_path:joinpath("PowerShellEditorServices", "Start-EditorServices.ps1").filename,
        "-BundledModulesPath",
        pses_bundle_path.filename,
        "-LogPath",
        tmpdir:joinpath("logs.log").filename,
        "-SessionDetailsPath",
        tmpdir:joinpath("session.json").filename,
        "-HostName",
        "Neovim",
        "-HostProfileId",
        "Neovim.DAP",
        "-HostVersion",
        "1.0.0",
        "-LogLevel",
        "Normal",
        "-DebugServiceOnly",
        "-DebugServicePipeName",
        "${pipe}",
    }
end
return M
