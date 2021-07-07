local M = {}
local popup = require("neogit.lib.popup")
local status = require 'neogit.status'
local notif = require("neogit.lib.notification")
local git = require("neogit.lib.git")
local input = require('neogit.lib.input')
local a = require 'plenary.async_lib'
local await, scheduler = a.await, a.scheduler

local push_upstream = function (popup)
  local _, code = await(git.cli.push.args(unpack(popup.get_arguments())).call())
  if code == 0 then
    await(scheduler())
    notif.create "Pushed to pushremote"
    await(status.refresh(true))
  end
end

local push_and_set_upstream = function(popup)
    local remote = input.get_user_input("remote> ")
    local branch = status.repo.head.branch
    local _, code = await(git.cli.push.args("-u", remote, branch).call())
    if code == 0 then
        await(scheduler())
        notif.create("Pushed to " .. remote .. " " .. branch)
        await(status.refresh(true))
    end
end

function M.create()
  return popup.new()
    .name("NeogitPushPopup")
    .switch("f", "force-with-lease", "Force with lease")
    .switch("F", "force", "Force")
    .switch("h", "no-verify", "Disable hooks")
    .switch("d", "dry-run", "Dry run")
    .action("p", "Push to pushremote", push_upstream)
    .action("u", "Push to upstream", push_upstream)
    .action("n", "Push and set upstream", push_and_set_upstream)
    .action("e", "Push to branch")
    .build()
end

return M
