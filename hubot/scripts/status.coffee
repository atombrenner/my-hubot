# Description:
#   Get the status of hetras systems relevant for public api.
#
# Commands:
#   hubot status api [all|http|groups|other] - get statistics for the API Gateway from the last three log files
#
fs = require("fs")

module.exports = (robot) ->

  robot.respond /status api/i, (r) ->
    r.send fs.readFileSync("/tmp/perflog/info.txt")
    r.send '```' +
        fs.readFileSync("/tmp/perflog/status.txt") +
        fs.readFileSync("/tmp/perflog/durations.txt") +
        '```'

