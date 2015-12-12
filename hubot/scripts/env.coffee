# Description:
#   Automate environment creation and deployments
#
# Commands:
#   hubot env - list existing environments on Certification
#   hubot env artifacts - list existing artifacts that could be deployed to environments
#   hubot env update <env> <branch> - update an environment with the latest artifacts from branch
#

request = require('request')
printf = require('printf')
dateformat = require('dateformat')

module.exports = (robot) ->

  COSTS_PER_MONTH = 700 * 0.11   # Volumes
  COSTS_PER_HOUR = 0.274 + 0.028 + COSTS_PER_MONTH / 30 / 24 # Instance + ELB + Volumes

  robot.respond /env$/i, (r) ->
    request 'http://localhost:5000/instances', (error, response, body) ->
      instances = JSON.parse(body)
      now = new Date()
      for i in instances
        started = new Date(i.Started)
        i.Started = dateformat(started, "yyyy-mm-dd HH:MM");
        i.Costs = (now - started) / 1000 / 3600 * COSTS_PER_HOUR
      widthName = Math.max (i.Name.length for i in instances)...
      widthType = Math.max (i.Instance.length for i in instances)...
      title = printf("%-*s %-*s %-16s %4s\n", "Name", widthName, "Type", widthType, "Created", "Costs")
      sep = "-".repeat(widthName + widthType + 16 + 4 + 4) + "\n"
      report = (printf("%-*s %-*s %16s %4d$", i.Name, widthName, i.Instance, widthType, i.Started, i.Costs) for i in instances)
      r.send "```\n" + title + sep + report.join("\n") + "```\n"

  robot.respond /env a(rtifacts)?$/i, (r) ->
    request 'http://localhost:5000/artifacts', (error, response, body) ->
      r.send "```\nArtifacts:\n" + JSON.parse(body).join("\n") + "```\n"

  robot.respond /env u(pdate)? ([^ ]+) ([^ ]+)$/i, (r) ->
    r.send "ansible-playbook update.yaml #{r.match[2]} #{r.match[3]}"
