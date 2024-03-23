local M = {}
function M.get_attach_choices()
    local get_process_id_cmd = "Get-PSHostProcessInfo | ConvertTo-Json"
    local result = vim.api.nvim_exec("!pwsh -NoProfile -Command '" .. get_process_id_cmd .. "'", true)
    local choices = vim.fn.json_decode(vim.split(result, "\r\n")[2])
    for index, choice in ipairs(choices) do
        choices[index] = choice["ProcessName"] .. ": " .. choice["ProcessId"]
    end
    return choices
end

function M.get_dotnet_process_id()
    local get_process_id_cmd = '$(Get-PSHostProcessInfo | ? {$_.ProcessName -eq "dotnet"}).ProcessId'
    local result = vim.api.nvim_exec("!pwsh -NoProfile -Command '" .. get_process_id_cmd .. "'", true)
    return vim.fn.trim(vim.split(result, "\r\n")[2])
end
return M
