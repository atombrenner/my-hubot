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
exec = require('child_process').exec;
maxWidth = (items, index) -> Math.max (item[index].length for item in items)...

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
      widthName = maxWidth(instances, "Name")
      widthType = maxWidth(instances, "Instance")
      title = printf("%-*s %-*s %-16s %4s\n", "Name", widthName, "Type", widthType, "Created", "Costs")
      sep = "-".repeat(widthName + widthType + 16 + 4 + 4) + "\n"
      report = (printf("%-*s %-*s %16s %4d$", i.Name, widthName, i.Instance, widthType, i.Started, i.Costs) for i in instances)
      r.send "```\n" + title + sep + report.join("\n") + "```\n"

  robot.respond /env a(rtifacts)?$/i, (r) ->
    request 'http://localhost:5000/artifacts', (error, response, body) ->
      artifacts = (a.split('_') for a in JSON.parse(body))
      col0 = maxWidth(artifacts, 0)
      col1 = maxWidth(artifacts, 1)
      title = printf("%-*s %-*s\n", "Artifact", col0, "Version", col1)
      sep = "-".repeat(col0 + col1 + 1) + "\n"
      artifacts = (printf("%-*s %-*s", a[0], col0, a[1], col1) for a in artifacts).join("\n")
      r.send "```\nArtifacts:\n" + title + sep + artifacts + "```\n"

  robot.respond /env u(pdate)? ([^ ]+) ([^ ]+)$/i, (r) ->
    env = r.match[2]
    branch = r.match[3]
    cmd = "ansible-playbook UpdateEnvironment.yaml --extra-vars \"env_name=#{env} branch=#{branch}\""
    r.send cmd
    exec cmd, {cwd: "/repos/tools/Ansible/Playbooks"}, (error, stdout, stderr) ->
      r.reply error if error?
      r.reply stdout
      r.reply stderr
