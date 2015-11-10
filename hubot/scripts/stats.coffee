# Description:
#   Get the status of hetras systems relevant for public api.
#
# Commands:
#   hubot stats     show statistics from the last four log files
#   hubot latencies <status> show only latencies for with specific status code
#   hubot others    show requests that do not match any group
#

fs = require("fs")

module.exports = (robot) ->

  asCode = (f) -> '```\n' + fs.readFileSync(f).toString() + '```'
  asText = (f) -> fs.readFileSync(f).toString()

  robot.respond /stats$/i, (r) ->
    r.send asText("/tmp/perflog/summary.txt")
    r.send asCode("/tmp/perflog/status.txt")
    r.send asCode("/tmp/perflog/latency.txt")

  robot.respond /latenc(y|ies) (\d\d\d)$/i, (r) ->
    status = r.match[2]
    r.send asText("/tmp/perflog/summary.txt")
    r.send "Latencies for status code #{status}:"
    r.send asCode("/tmp/perflog/latency#{status}.txt")

  robot.respond /others?$/i, (r) ->
    r.send asText("/tmp/perflog/summary.txt")
    r.send asCode("/tmp/perflog/others.txt")
