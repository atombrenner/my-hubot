# Description:
#   Get the status of hetras systems relevant for public api.
#
# Commands:
#   hubot stats - show statistics from the last four log files
#   hubot stats <status> - show only statistics for the given status code
#   hubot stats others - show requests that do not match any group
#

fs = require("fs")

module.exports = (robot) ->

  asCode = (f) -> '```\n' + fs.readFileSync(f).toString() + '```'
  asText = (f) -> fs.readFileSync(f).toString()

  robot.respond /stats$/i, (r) ->
    r.send asText("/tmp/perflog/summary.txt")
    r.send asCode("/tmp/perflog/status.txt")
    r.send asCode("/tmp/perflog/latency.txt")

  robot.respond /stats (\d\w\w)$/i, (r) ->
    status = r.match[1]
    r.send asText("/tmp/perflog/summary.txt")
    r.send "Latencies for status code #{status}:"
    r.send asCode("/tmp/perflog/latency#{status}.txt")

  robot.respond /stats o(thers)?$/i, (r) ->
    r.send asText("/tmp/perflog/summary.txt")
    r.send asCode("/tmp/perflog/others.txt")
