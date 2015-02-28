SlackBots = require './src/slacks'
{SlackTextMessage, SlackRawMessage, SlackBotMessage} = require './src/message'
{SlackRawListener, SlackBotListener} = require './src/listener'

module.exports = exports = {
  SlackBots
  SlackTextMessage
  SlackRawMessage
  SlackBotMessage
  SlackRawListener
  SlackBotListener
}

exports.use = (robot) ->
  new SlackBots robot
