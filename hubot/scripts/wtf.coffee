# Description:
#   Automate environment creation and deployments
#
# Commands:
#   hubot wtf - relax, don't do  it
#

module.exports = (robot) ->
  robot.respond /wtf$/i, (r) ->
    r.send ":japanese_ogre:"
