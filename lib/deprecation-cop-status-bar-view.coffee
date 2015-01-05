{CompositeDisposable} = require 'atom'
{$, $$, View} = require 'atom-space-pen-views'
_ = require 'underscore-plus'
Grim = require 'grim'

module.exports =
class DeprecationCopStatusBarView extends View
  @content: ->
    @div class: 'deprecation-cop-status inline-block text-warning', tabindex: -1, =>
      @span class: 'icon icon-alert'
      @span class: 'deprecation-number', outlet: 'deprecationNumber', '0'

  lastLength: null
  toolTipDisposable: null

  initialize: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add Grim.on 'updated', @update

  destroy: ->
    @subscriptions.dispose()
    @detach()

  attached: ->
    @update()
    @click ->
      workspaceElement = atom.views.getView(atom.workspace)
      atom.commands.dispatch workspaceElement, 'deprecation-cop:view'

  update: =>
    console.log 'update'
    length = Grim.getDeprecationsLength()
    return if @lastLength == length

    @lastLength = length
    @deprecationNumber.text(length)
    @toolTipDisposable?.dispose()
    @toolTipDisposable = atom.tooltips.add @element, title: "#{_.pluralize(length, 'call')} to deprecated methods"

    if length == 0
      @hide()
    else
      @show()