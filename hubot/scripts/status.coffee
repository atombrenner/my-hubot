# Description:
#   Get the status of hetras systems relevant for public api.
#
# Commands:
#   hubot status [all|other] - get API Gateway statistics from the last three log files
#

fs = require("fs")

module.exports = (robot) ->

  asCode = (f) -> '```\n' + fs.readFileSync(f).toString() + '```'
  asText = (f) -> fs.readFileSync(f).toString()

  robot.respond /status ?(\w*)?/i, (r) ->
    option = r.match[1]
    option = "" unless option?
    r.send asText("/tmp/perflog/summary.txt")
    r.send asCode("/tmp/perflog/status.txt")  if /^(all)?$/      .test option
    r.send asCode("/tmp/perflog/latency.txt") if /^(all)?$/      .test option
    r.send asCode("/tmp/perflog/others.txt")  if /^(all|oth.*)$/ .test option

