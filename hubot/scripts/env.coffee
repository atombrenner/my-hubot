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
async = require('async')
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
      w = (maxWidth(artifacts, i) for i in [0..2])
      w = (Math.max(w[i], title.length) for title, i in ["Artifact", "Version", "Time"])
      title = printf("%-*s %-*s %-*s\n", "Artifact", w[0], "Version", w[1], "Time", w[2])
      sep = "-".repeat(w[0] + w[1] + w[2] + w.length) + "\n"
      artifacts = (printf("%-*s %-*s %-*s", a[0], w[0], a[1], w[1], a[2], w[2]) for a in artifacts).join("\n")
      r.send "```\n" + title + sep + artifacts + "```\n"

  robot.respond /env u(pdate)? ([^ ]+) ([^ ]+)$/i, (r) ->

    download = (path) -> (callback) -> request "http://localhost:5000/#{path}", (err, res, body) ->
      callback(null, JSON.parse(body))

    validate = (valid, val, name) ->
      matching = valid.filter (x) -> x.toUpperCase().startsWith(val.toUpperCase())
      if (matching.length == 1)
        return matching[0]
      else if (matching.length < 1)
        r.reply "Please specify a valid #{name} from :\n" + valid.join("\n")
      else if (matching_artifacts.length > 1)
        r.reply "Which #{name} do you mean?\n" + matching.join("\n")
      return null

    update = (env, art) ->
      cmd = "ansible-playbook UpdateEnvironment.yaml -e \"env_name=#{env} version=#{art}\""
      r.send cmd
      exec cmd, {cwd: "/repos/tools/Ansible/Playbooks"}, (error, stdout, stderr) ->
        r.reply error if error?
        r.reply stdout
        r.reply stderr

    async.parallel [download("environments"), download("artifacts")], (error, result) ->
      [environments, artifacts] = result
      env = validate(environments, r.match[2], "environment")
      art = validate(artifacts, r.match[3], "artifact") if env
      update(env, art) if env && art
