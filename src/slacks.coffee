{Robot, Adapter} = require 'hubot'
SlackBot = require './slack'

Util = require 'util'

class SlackBots extends Adapter

  constructor: (robot) ->
    @robot = robot
    @tokens = [] # TODO load tokens from redis
    @bots = {}
    @tokens.push process.env.HUBOT_SLACK_TOKEN # TODO remove! just for testing


  run: ->
    @robot.logger.info "starting #{@tokens.length} slackbot(s)"
    @robot.brain.on 'loaded', @.brainLoaded
    @robot.name = "Sam.AI"
    @.startBot token for token in @tokens


  close: ->
    @robot.logger.info "closing all slackbots"
    bot.close for token, bot of @bots


  startBot: (token) ->
    return null unless @bots[token] is undefined
    @robot.logger.debug "starting bot for #{token}"
    bot = new SlackBot @robot
    bot.run token
    bot.on 'closed', @.botStopped
    if @brainLoaded is true
      bot.brainLoaded

    @bots[token] = bot


  botStopped: (token) =>
    @robot.logger.debug "botStopped #{token}"
    return null unless @bots[token] isnt undefined
    bot = @bots[token]
    @bots[token] = null # TODO remove token from redis? or store in offline bots list?
    bot.removeListener 'closed', @.botStopped


  brainLoaded: =>
    @robot.logger.debug "brainLoaded (#{@tokens.length} bots)"
    return null unless @brainLoaded isnt true
    # tell all bots that the brain is loaded
    for token, bot of @bots
      bot.brainLoaded
    @brainLoaded = true


  send: (envelope, messages...) ->
    @robot.logger.debug "sending"

    # find correct bot for envelope
    targetBot = null
    for token,bot in bots
      if bot.hasChannel envelope.room
        targetBot = bot
        break

    if channel isnt null
      @robot.logger.debug "found bot and channel for #{envelope.room} in #{targetBot.options.token}"
      targetBot.send envelope messages...
    else
      @robot.logger.warn "no bot found for #{envelope.room}; msg #{envelope}"


  reply: (envelope, messages...) ->
    @robot.logger.debug "Sending reply"

    for msg in messages
      # TODO: Don't prefix username if replying in DM
      @.send envelope, "#{envelope.user.name}: #{msg}"


  topic: (envelope, strings...) ->
    #channel = @bot.getChannelGroupOrDMByName envelope.room
    #channel.setTopic strings.join "\n"

# Export class for unit tests
module.exports = SlackBots
