ApplicationController = Caboose.get 'ApplicationController'

_ = require 'underscore'
cheerio = require 'cheerio'

_projects = null

read_projects = ->
  # return _projects if _projects?
  
  _projects = Caboose.path.views.join('docs').readdir_sync().filter (file) ->
    file.extension is 'html'
  .map (file) ->
    content = file.read_file_sync('utf8')
    $ = cheerio.load(content)
    
    {
      name: $('header .name').html()
      description: $('header .description').html()
      github: $('header .github').attr('href')
      sections: $('section[id]').map ->
        {
          id: $(@).attr('id')
          name: $(@).find('h3').text()
        }
    }

class DocsController extends ApplicationController
  before_action (next) ->
    @projects = read_projects()
    next()
  
  show: ->
    @active_project = _(@projects).find((p) => p.name is @params.project)
    
    content = Caboose.path.views.join('docs', "#{@params.project}.html").read_file_sync('utf8')
    $ = cheerio.load(content)
    $('header').remove()
    @content = $.html()
    @render()
