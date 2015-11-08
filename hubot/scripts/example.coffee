# Description:
#   Automate environment creation and deployments
#
# Commands:
#   hubot env create <name> - Creates a new mappable environment on Certification
#   hubot env deploy <name> [branch] - Deploy the lastest code to environment name
#   hubot env prod-db <name> - restore the latest production DB, can take some minutes

module.exports = (robot) ->

  robot.respond /env create ?(\w*)/i, (r) ->
    name = r.match[1]
    r.send "Start creation of environment" + name
    setTimeout () ->
      r.send "ec2 instances for " + name + " created"
    , 1500
    setTimeout () ->
      r.send "databases for " + name + " created"
    , 4000
    setTimeout () ->
      r.send "*Environment " + name + " not created!*"
    , 4500

  robot.respond /env create (\w*)( (\w*))?/i, (r) ->
    name = r.match[1]
    branch = r.match[3]
    branch = "master" unless branch?
    r.send "No artifacts found for branch " + branch

  robot.respond /env db|prod-db/i, (r) ->
    setTimeout () ->
      r.send "database backup not found"
    , 1500
