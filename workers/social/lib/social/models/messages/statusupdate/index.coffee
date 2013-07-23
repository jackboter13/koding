JPost = require '../post'

module.exports = class JStatusUpdate extends JPost
  {secure} = require 'bongo'
  {Relationship} = require 'jraphical'
  {permit} = require '../../group/permissionset'
  {once, extend} = require 'underscore'

  @trait __dirname, '../../../traits/grouprelated'

  @share()

  schema = extend {}, JPost.schema, {
    link :
      link_url   : String
      link_embed : Object
  }

  @set
    slugifyFrom       : 'body'
    sharedEvents      :
      instance        : [
        { name: 'TagsChanged' }
        { name: 'ReplyIsAdded' }
        { name: 'LikeIsAdded' }
        { name: 'updateInstance' }
        { name: 'RemovedFromCollection' }
      ]
      static          : [
        { name: 'updateInstance' }
        { name: 'RemovedFromCollection' }
      ]
    sharedMethods     :
      static          : ['create','one','fetchDataFromEmbedly','updateAllSlugs']
      instance        : [
        'reply','restComments','commentsByRange'
        'like','fetchLikedByes','mark','unmark','fetchTags'
        'delete','modify','fetchRelativeComments','checkIfLikedBefore'
      ]
    schema            : schema
    relationships     : JPost.relationships

  @getActivityType =-> require './statusactivity'

  @fetchDataFromEmbedly = (url, options, callback)->
    {Api}      = require "embedly"

    embedly = new Api
      user_agent : 'Mozilla/5.0 (compatible; koding/1.0; arvid@koding.com)'
      key        : "e8d8b766e2864a129f9e53460d520115"

    embedOptions = extend {}, options, {url:url}

    embedly.preview(embedOptions).on "complete", (data)->
      callback JSON.stringify data
    .on "error", (data)->
      callback JSON.stringify data
    .start()

  @create = secure (client, data, callback)->
    statusUpdate  =
      meta        : data.meta
      title       : data.title
      body        : data.body
      group       : data.group

    if data.link_url and data.link_embed
      statusUpdate.link =
        link_url   : data.link_url
        link_embed : data.link_embed

    JPost.create.call this, client, statusUpdate, callback

  modify: secure (client, data, callback)->
    statusUpdate =
      meta        : data.meta
      title       : data.title
      body        : data.body

    if data.link_url and data.link_embed
      statusUpdate.link =
        link_url   : data.link_url
        link_embed : data.link_embed

    JPost::modify.call this, client, statusUpdate, callback

  reply: permit 'reply to posts',
    success:(client, comment, callback)->
      JComment = require '../comment'
      JPost::reply.call this, client, JComment, comment, callback
