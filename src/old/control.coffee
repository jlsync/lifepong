
if exports?
  $ = require('jquery')
  _und = require('underscore')._
else
  $ = jQuery
  _und = _


$window = if exports? then $('body') else $(window)

# closure globals 
current_state = null
$selected = null
$help = null
clones = []
rows_of_$clones = []
full_cloning = true

# callbacks...
process_key = (key, jq_event) =>
  if $selected and not $selected.is(':visible')
    move_state 'start'
  return if ! current_state.events_by_trigger?[key]?
  return if jq_event.target and !_und.include(current_state.exclusive_triggers,key) and ((/textarea|select/i.test( jq_event.target.nodeName )) or (/text|password|search|tel|url|email|number/i.test( jq_event.target.type ) ))
  # otherwise, let's deal with it...
  jq_event.preventDefault()
  triggerEvent(current_state.events_by_trigger[key].name, key)


# key is what the callback takes, might be not be a key
(exports ? window).triggerEvent = (event_name, key = "") =>
  #$state_box.find('div.event').remove()
  #$("<div class='event'><i>#{event_name}</i></div>").appendTo($state_box).effect('highlight', {color: '#00FF00'}, 1500)
  event = current_state.events_by_name[event_name]
  unless event?
    console.log("#{event_name} is not valid for state #{current_state.name}")
    return
  if event.return_state
    move_state event.return_state.call(this, key)
  else if event.callback
    if event.callback.call(this, key)
      move_state event.transitions[current_state.name]
  else
    move_state event.transitions[current_state.name]



end_navigation = ->
  $selected.removeClass('selected')
  $selected = null
  true # callbacks should normally return true

next_row = ->
  $selected.removeClass('selected')
  $selected = next_row_selection $selected
  $selected.addClass('selected').jscrollTo()

prev_row = ->
  $selected.removeClass('selected')
  $selected = prev_row_selection $selected
  $selected.addClass('selected').jscrollTo()

mark_next_row = ->
  $selected.removeClass('selected')
  $selected = $selected.add(next_row_selection($selected))
  $selected.addClass('selected').jscrollTo() # jscrollTo('bottom')

mark_prev_row = ->
  $selected.removeClass('selected')
  $selected = $selected.add(prev_row_selection($selected))
  $selected.addClass('selected').jscrollTo()

next_row_cloning = ->
  $clones.remove() for $clones in rows_of_$clones
  $selected.removeClass('selected').find('div.bodier').stripe()
  $selected = next_row_selection $selected, true
  start_at = new Date(parseInt($selected.find('div.period').first().data('start_at')))
  $append_row = $selected.first()
  for $clones in rows_of_$clones
    $clones.find('span.start_at_wdn').text(start_at.toString('dddd'))
    $append_row.find('div.bodier').append($clones).stripe()
    start_at.addDays(1)
    $append_row = next_row_selection $append_row
  $selected.addClass('selected').jscrollTo()

prev_row_cloning = ->
  $clones.remove() for $clones in rows_of_$clones
  $selected.removeClass('selected').find('div.bodier').stripe()
  $selected = prev_row_selection $selected, true
  start_at = new Date(parseInt($selected.find('div.period').first().data('start_at')))
  $append_row = $selected.first()
  for $clones in rows_of_$clones
    $clones.find('span.start_at_wdn').text(start_at.toString('dddd'))
    $append_row.find('div.bodier').append($clones).stripe()
    start_at.addDays(1)
    $append_row = next_row_selection $append_row
  $selected.addClass('selected').jscrollTo()

next_vil = ->
  $selected.removeClass('selected')
  $selected = next_vil_selection $selected
  $selected.addClass('selected').jscrollTo()

prev_vil = ->
  $selected.removeClass('selected')
  $selected = prev_vil_selection $selected
  $selected.addClass('selected').jscrollTo()

highlight_first_row = ->
  $selected = first_visible_row()
  $selected.addClass('selected')

highlight_first_vil = ->
  $selected = first_visible_vil()
  $selected.addClass('selected').jscrollTo()

highlight_first_employee = ->
  $first = first_visible_employee $selected
  if $first.length
    $selected.removeClass('selected')
    $selected = $first
    $selected.addClass('selected').focus()
  else
    return false

start_remove_nav = ->
  $first = first_assignment $selected
  if $first.length
    $selected.removeClass('selected')
    $selected = $first
    $selected.addClass('selected').focus()
  else
    return false

remove_nav_down = ->
  $selected.removeClass('selected')
  $selected = next_assignment $selected
  $selected.addClass('selected').jscrollTo()

remove_nav_up = ->
  $selected.removeClass('selected')
  if $new = prev_assignment $selected
    $selected = $new
    $selected.addClass('selected').jscrollTo()
  else
    triggerEvent('esc_remove_nav')
    return false # prevent original transition

escape_remove_nav = ->
  $selected.removeClass('selected')
  $selected = $selected.closest('div.ribbon.shift')
  $selected.addClass('selected').jscrollTo()

remove_assignment = ->
  $selected.removeClass('selected')
  $vil = $selected.closest('div.ribbon.shift')
  $selected.find('div.remove_link a').click()
  $selected = $vil
  $selected.addClass('selected').jscrollTo()

assign_first_employee = ->
  $first = first_visible_employee $selected
  if $first.length
    $selected.removeClass('selected')
    $selected = $first
    $selected.addClass('selected').focus()
    setTimeout () ->
      $selected.click()
    , 100 # allow first transition to finish before click triggers assignment
    return true
  else
    return false

assign_nav_down = ->
  $selected.removeClass('selected')
  $selected = next_visible_employee $selected
  $selected.focus()
  setTimeout () ->
    $selected.addClass('selected')
  , 50 # allow chrome focus to reposition

assign_nav_up = ->
  $selected.removeClass('selected')
  if $new = prev_visible_employee($selected)
    $selected = $new
    $selected.focus()
    setTimeout () ->
      $selected.addClass('selected')
    , 50 # allow chrome focus to reposition
  else
    triggerEvent('back_to_assign_search')
    return false # prevent original transition

confirm_vil = ->
  $vil = $selected.find('div.vil')
  vil = $vil.data('vil_model')
  if !vil.approved()
    $vil.find('#vil_approve_submit').click()
    # line above causes a redraw, could use defferred?
    setTimeout () ->
      $selected = $("#ribbon_#{vil.id()}").first()
      $selected.addClass('selected').jscrollTo()
    , 1000
  else
    $.gritter.add({ title: vil.eventType() + ' Status', text: vil.name_or_start() + " is already confirmed."})

unconfirm_vil = ->
  $vil = $selected.find('div.vil')
  vil = $vil.data('vil_model')
  if vil.approved()
    $vil.find('#vil_approve_submit').click()
    # line above causes a redraw, could use defferred?
    setTimeout () ->
      $selected = $("#ribbon_#{vil.id()}").first()
      $selected.addClass('selected').jscrollTo()
    , 1000
  else
    $.gritter.add({ title: vil.eventType() + ' Status', text: vil.name_or_start() + " is already draft status."})

confirm_vils = ->
  $vils = $selected.find('div.vil')
  $vils.each ->
    $vil = $(this)
    vil = $vil.data('vil_model')
    if !vil.approved()
      $vil.find('#vil_approve_submit').click()

unconfirm_vils = ->
  $vils = $selected.find('div.vil')
  $vils.each ->
    $vil = $(this)
    vil = $vil.data('vil_model')
    if vil.approved()
      $vil.find('#vil_approve_submit').click()


edit_vil = ->
  $vil = $selected.find('div.vil')
  vil = $vil.data('vil_model')
  $n = $('#new_shift_jlt').jlt(vil)
  $('#cal_dialog').jlDialog({title: (if vil.newRecord() then 'New' else 'Edit' ) + ' Shift', body: $n, width: '550px', no_close_link: true, arrow: { top: $selected.offset().top + $selected.outerHeight()  , left: $selected.offset().left + ( $selected.outerWidth() / 2 )  }}).jscrollTo()
  $n.find('input.time').bind 'change', ->
    $this = $(this)
    $this.val( reformat_time($this.val()))
    if $this.val() != ''
      t = (new Date()).at(reformat_time($this.val()))
      if t?
        $this.val( tf(t) )
      else
        $this.val( '' )
  $n.find('input.time:first').focus()
  $n.find('input:visible:first').bind 'keydown', (event)->
    code = event.keyCode || event.which
    if code == 9
      event.preventDefault()
      $n.find('input:visible').eq(1).focus()
  $n.find('input:visible:last').bind 'keydown', (event)->
    code = event.keyCode || event.which
    if code == 9
      event.preventDefault()
      $n.find('input:visible:first').focus()



# this callback takes an Item instance, not a "key"
saved = (vil) ->
  $('#cal_dialog').hide().empty()
  $selected?.removeClass("selected")
  $selected = vil.$ribbons[0]
  $selected.jscrollTo().addClass("selected")

save_vil = (vil) ->
  $('#cal_dialog').find('form').submit()

delete_shift = ->
  $grey = $("<div class='jconfirm'><div class='question'><div class='prompt'>Are you sure you want to delete this shift?</div><button class='no'><b>N</b>o</button><button class='yes'><b>Y</b>es</button></div></div>")
  $('body').append($grey)
  $grey.find('button.yes').click ->
    triggerEvent('confirm_delete_shift')
  $grey.find('button.no').click ->
    triggerEvent('reject_delete_shift')
  $grey.find('button.yes').focus()

confirm_delete_shift = ->
  $('div.jconfirm').remove()
  $selected.removeClass('selected')
  $row = $selected.closest('div.row')
  $vil = $selected.find('div.vil')
  vil = $vil.data('vil_model')
  $selected.find('form.delete_form').submit()
  $selected = $row
  $selected.addClass('selected').jscrollTo()

reject_delete_shift = ->
  $('div.jconfirm').remove()

add_new_vil = ->
  $row = if $selected.hasClass('row') then $selected else $selected.closest('div.row')
  $period = $row.find('div.period:first')
  start_at_msec = parseInt($period.data('start_at'))
  start_at = new Date(start_at_msec)

  vil = new Vil({event_type: 'shift', rota_id: R.rota.id, simple_day: start_at.toDateString()})
  $n = $('#new_shift_jlt').jlt(vil)
  $('#cal_dialog').jlDialog({title: (if vil.newRecord() then 'New' else 'Edit' ) + ' Shift', body: $n, width: '550px', no_close_link: true, arrow: { top: $selected.offset().top + $selected.outerHeight()  , left: $selected.offset().left + ( $selected.outerWidth() / 2 )  }}).jscrollTo()
  $n.find('input.time').bind 'change', ->
    $this = $(this)
    $this.val( reformat_time($this.val()))
    if $this.val() != ''
      t = (new Date()).at(reformat_time($this.val()))
      if t?
        $this.val( tf(t) )
      else
        $this.val( '' )
  $n.find('input.time:first').focus()
  $n.find('input:visible:first').bind 'keydown', (event)->
    code = event.keyCode || event.which
    if code == 9
      event.preventDefault()
      $n.find('input:visible').eq(1).focus()
  $n.find('input:visible:last').bind 'keydown', (event)->
    code = event.keyCode || event.which
    if code == 9
      event.preventDefault()
      $n.find('input:visible:first').focus()

esc_new_vil = ->
  # also call emtpy to regain keyboard focus
  $('#cal_dialog').hide().empty()

esc_edit_vil = ->
  # also call emtpy to regain keyboard focus
  $('#cal_dialog').hide().empty()

full_clone = ->
  full_cloning = true
  $row = if $selected.hasClass('row') then $selected else $selected.closest('div.row')
  $first_period = $row.find('div.period').first()
  $last_period = $row.find('div.period').last()
  start_at_msec = parseInt($first_period.data('start_at'))
  start_at = new Date(start_at_msec)
  end_at_msec = parseInt($last_period.data('end_at')) + 1
  end_at = new Date(end_at_msec)
  clones = Vil.select( ->
    this.start_at() >= start_at and this.start_at() < end_at
  ).all()
  rows_of_$clones = $selected.find('div.bodier').map ->
    $(this).find('div.ribbon.shift').clone(true).addClass('clones')
  $selected.find('div.ribbon.shift').addClass('cloned')

full_clone_of_ribbon = ->
  full_cloning = true
  clones = [ $selected.find('div.vil').data('vil_model') ]
  rows_of_$clones = [ $selected.clone(true).addClass('clones') ]
  $selected.addClass('cloned')

partial_clone = ->
  full_cloning = false
  $row = if $selected.hasClass('row') then $selected else $selected.closest('div.row')
  $first_period = $row.find('div.period').first()
  $last_period = $row.find('div.period').last()
  start_at_msec = parseInt($first_period.data('start_at'))
  start_at = new Date(start_at_msec)
  end_at_msec = parseInt($last_period.data('end_at')) + 1
  end_at = new Date(end_at_msec)
  clones = Vil.select( ->
    this.start_at() >= start_at and this.start_at() < end_at
  ).all()
  rows_of_$clones = $selected.find('div.bodier').map ->
    $(this).find('div.ribbon.shift').clone(true).addClass('clones').find('div.assignment').remove().end()
  $selected.find('div.ribbon.shift').addClass('cloned')

partial_clone_of_ribbon = ->
  full_cloning = false
  clones = [ $selected.find('div.vil').data('vil_model') ]
  rows_of_$clones = [ $selected.clone(true).addClass('clones').find('div.assignment').remove().end() ]
  $selected.addClass('cloned')

esc_cloning = ->
  for clone in clones
    for $ribbon in clone.$ribbons
      $ribbon.removeClass('cloned')
  clones = []
  for $clones in rows_of_$clones
    $bodier = $clones.closest('div.bodier')
    $clones.remove()
    $bodier.stripe()
  rows_of_$clones = []

paste_cloning = ->
  $paste_row = $selected.first()
  for $clones in rows_of_$clones
    $clones.remove()
    start_at = new Date(parseInt($paste_row.find('div.period:first').data('start_at')))
    $paste_row = next_row_selection $paste_row
    $clones.each ->
      orig = Vil.find($(this).find('div.vil').attr('id').replace('vil_',''))
      for $ribbon in orig.$ribbons
        $ribbon.removeClass('cloned')
      do (orig, full_cloning) ->
        v = new Vil({event_type: 'shift', simple_day: start_at.toDateString(), name: orig.name(), description: orig.description(), simple_start: orig.simpleStart(), simple_end: orig.simpleEnd()})
        v.save (success) ->
          if success
            this.render()
            $.gritter.add({ title: this.eventType() + ' Created', text: this.name_or_start() })
            if full_cloning
              for assignment in orig.assignments().all()
                  a = new Assignment({vil_id: this.id(), employee_id: assignment.employeeId() })
                  a.save (asuccess) ->
                    if asuccess
                      this.render()
                      $.gritter.add({ title: 'Employee Assigment', text: this.employee().uname() + ' assigned to ' + this.vil().event_type() + ': ' + this.vil().name_or_start() })
                    else
                      $.gritter.add({ title: 'Rotaville Error!', text: 'Uh Oh! Assignment Problem. Please try reloading this page.' , sticky: true})
          else
            $.gritter.add({ title: 'Rotaville Error!', text: this.attr('event_type') + ' create failed.'})

  $selected.addClass('selected').jscrollTo()

open_assign_menu = ->
  $selected.removeClass('selected')
  $selected =  open_assign_for_vil $selected
  $selected.addClass('selected')
  $selected.find('a.close_assignment_menu').remove()
  $selected.jscrollTo() # running last to allow full render.

close_assign_menu = ->
  $selected.removeClass('selected')
  $selected =  close_menu_and_return_ribbon $selected
  setTimeout ->
    $selected.addClass('selected').jscrollTo()
  , 100 # allow menu to fade and page to resize


assign_menu_search = ->
  $selected.removeClass('selected')
  $selected =  closest_assign_menu($selected)
  $selected.addClass('selected').jscrollTo()

open_assign_for_vil = ($ribbon) ->
  $vil = $ribbon.find('div.vil')
  $vil.find('.controls').show()
  $vil.find('span.assign_employee').click()
  $vil.find('.controls').hide()
  $menu = $vil.data('vil_model').$menu
  $menu.delegate 'a', 'click', (event) ->
    triggerEvent('esc_assign_menu', 'esc') # closes menu after assignment
  setTimeout ->
    $menu.find('input.esearch').focus()
  , 10
  $menu


closest_assign_menu = ($top) ->
  $menu = $top.closest('div.assignment_menu')
  setTimeout ->
    $menu.find('input.esearch').focus()
  , 10
  $menu

close_menu_and_return_ribbon = ($selected) ->
  if $selected.hasClass('assignment_link')
    $menu = $selected.closest('div.assignment_menu')
  else
    $menu = $selected
  $vil = $menu.data('$vil')
  $menu.fadeOut()
  setTimeout ->
    $menu.remove()
  , 100 # ugly. wait for live assignemnt click witch uses $menu.data('vil')
  $vil.closest('div.ribbon.shift')

open_help = () ->
  $help?.remove()
  cs_events = (event for name, event of current_state.events_by_name)
  $help = $('#help_jlt').jlt({ current_state: current_state, events: cs_events})
  $('body').append($help)

close_help_return_previous_state = () ->
  previous_state = $help.data('current_state.name')
  $help.remove()
  return previous_state

# TODO this finding next vil in DOM which not always the 
# next chronalogical vil on the rota (should be using model data and method)
next_vil_selection = ($current) ->
  if $current.hasClass 'row'
    $next = $current.find 'div.ribbon.shift:first'
    if $next.length == 1
      return $next
    $next = $current.nextAll().find('div.ribbon.shift:first').first()
    if $next.length == 1
      return $next
    $.gritter.add title: 'info', text: 'no next shift found'
    return $current
  else if $current.hasClass 'ribbon'
    $next = $current.next 'div.ribbon.shift'
    if $next.length == 1
      return $next
    $next = $current.closest('div.row').nextAll().find('div.ribbon.shift:first').first()
    if $next.length == 1
      return $next
    $.gritter.add title: 'info', text: 'no next shift found'
    return $current

next_row_selection = ($current, multi = false) ->
  $last = $current.last()
  if $last.hasClass 'row'
    $next = $last.next 'div.row'
    if $next.length == 0
      app.runRoute('get', '#/more')
      $next = $last.next 'div.row'
    if multi
      $result = $()
      $current.each ->
        $result = $result.add $next
        $next = $next.prev 'div.row'
      return $result
    else
      return $next
  else if $last.hasClass 'ribbon'
    $next = $last.closest('div.row').next('div.row')
    if $next.length == 1
      return $next
    $.gritter.add title: 'info', text: 'no next day found'
    return $last

prev_row_selection = ($current, multi = false) ->
  $first = $current.first()
  if $first.hasClass 'row'
    $prev = $first.prev 'div.row'
    if $prev.length == 1
      if multi
        $result = $()
        $current.each ->
          $result = $result.add $prev
          $prev = $prev.next 'div.row'
        return $result
      else
        return $prev
    $.gritter.add title: 'info', text: 'no earlier day found'
    return $first
  else if $first.hasClass 'ribbon'
    $prev = $first.closest('div.row')
    if $prev.length == 1
      return $prev
    $.gritter.add title: 'info', text: 'no earlier day found'
    return $first

prev_vil_selection = ($current) ->
  if $current.hasClass 'row'
    $next = $current.prevAll().find('div.ribbon:last').first()
    if $next.length == 1
      return $next
    $.gritter.add title: 'info', text: 'no earlier shift found'
    return $current
  else if $current.hasClass 'ribbon'
    $next = $current.prev 'div.ribbon.shift'
    if $next.length == 1
      return $next
    $next = $current.closest('div.row').prevAll().find('div.ribbon.shift:last').first()
    if $next.length == 1
      return $next
    $.gritter.add title: 'info', text: 'no earlier shift found'
    return $current


first_visible_row = () ->
  for row in $('div.row').toArray()
    $row = $(row)
    if $row.offset().top > $window.scrollTop()
      return $row
  $('div.row:first')

first_visible_vil = () ->
  for ribbon in $('div.ribbon.shift').toArray()
    $ribbon = $(ribbon)
    if $ribbon.offset().top > $window.scrollTop()
      return $ribbon
  $('div.ribbon.shift:first')

first_visible_employee = ($menu) ->
  $menu.find('a.employee:visible').first()

next_visible_employee = ($cur) ->
  $next = $cur.nextAll(':visible:first')
  if $next[0]?
    $next
  else
    $cur

prev_visible_employee = ($cur) ->
  $prev = $cur.prevAll(':visible:first')
  if $prev[0]?
    $prev
  else
    null

first_assignment = ($vil) ->
  $vil.find('div.assignment:first')

next_assignment = ($cur) ->
  $next = $cur.next()
  if $next[0]?
    $next
  else
    $cur

prev_assignment = ($cur) ->
  $prev = $cur.prev()
  if $prev[0]?
    $prev
  else
    null

# the states...
states =
  start:
    full_name: 'Starting Keyboard Navigation'
    quick_help: '''
                &nbsp;<kbd>k</kbd><kbd>&uarr;</kbd><kbd> &darr;</kbd><kbd>j</kbd> days
                &nbsp;<kbd>h</kbd><kbd>&larr;</kbd><kbd>&rarr;</kbd><kbd>l</kbd> shifts
                &nbsp;<kbd>?</kbd> help
                &nbsp;<kbd>esc</kbd> exit
                '''
    long_help:  '''
                <p>
                Rotaville supports keyboard commands and navigation.
                For a busy manager using the keyboard commands will
                make updating and maintaining the rota much faster.
                </p>
                <p>
                While in keyboard mode the mouse is
                disabled. Keyboard mode is actually
                made up of many different sub-modes such as 'Edit
                Shift Mode' and 'Assignment Mode'. All modes have
                their own unique keystroke commands.
                </p>
                <p>
                Mini-Help for the current mode is always showing at the
                top of the screen.  Press <kbd>?</kbd>
                at any time get full help for the current mode.
                Press <kbd>esc</kbd> to exit from the current mode.
                </p>

                '''
  row_nav:
    full_name: 'Row Navigation'
    quick_help: '''
                &nbsp;<kbd>k</kbd> <kbd>&uarr;</kbd> <kbd>&darr;</kbd> <kbd>j</kbd> days
                &nbsp;<kbd>h</kbd> <kbd>&larr;</kbd> <kbd>&rarr;</kbd> <kbd>l</kbd> shifts
                &nbsp;<kbd>n</kbd> new shift
                &nbsp;<kbd>?</kbd> help
                &nbsp;<kbd>esc</kbd> exit
                '''
    long_help:  '''
                <p>
                You can clone multiple days (rows) of shifts (e.g. 
                whole weeks) by first marking out the days you want 
                to clone using <kbd>J</kbd> or <kbd>shift+down</kbd> 
                to mark out days in down direction ( <kbd>shift+up</kbd> 
                or <kbd>K</kbd> 
                to mark days upwards) and then using <kbd>c</kbd> to 
                clone the shifts (or <kbd>s</kbd> to clone shifts 
                without assignments). 
                </p>
                <p>
                Navigate the cloned shifts to 
                the new dates you want (using <kbd>j</kbd> <kbd>down</kbd> 
                or <kbd>up</kbd> <kbd>k</kbd>) and then paste the 
                shifts onto the rota using <kbd>v</kbd> or <kbd>p</kbd>. 
                </p>
                <p>
                Use <kbd>esc</kbd> to exit cloning mode without pasting.
                </p>
                '''
  vil_nav:
    full_name: 'Shift Navigation'
    quick_help: '''
                &nbsp;<kbd>h</kbd> <kbd>&larr;</kbd> <kbd>&rarr;</kbd> <kbd>l</kbd> shifts
                &nbsp;<kbd>a</kbd> assign
                &nbsp;<kbd>r</kbd> remove
                &nbsp;<kbd>e</kbd> edit
                &nbsp;<kbd>d</kbd> delete
                &nbsp;<kbd>?</kbd> help
                &nbsp;<kbd>esc</kbd> exit
                '''
  vil_edit:
    full_name: 'Shift Editing'
    quick_help: '''
                &nbsp;<kbd>?</kbd> help
                &nbsp;<kbd>enter</kbd> save changes
                &nbsp;<kbd>esc</kbd> cancel and exit
                '''
  vil_new:
    full_name: 'New Shift'
    quick_help: '''
                &nbsp;<kbd>?</kbd> help
                &nbsp;<kbd>enter</kbd> save shift
                &nbsp;<kbd>esc</kbd> cancel and exit
                '''
  assignment:
    full_name: 'Assignment Menu Search'
    quick_help: '''
                &nbsp; Type to search and
                &nbsp;<kbd>enter</kbd> assign first match, or
                &nbsp;<kbd>&darr;</kbd> down
                &nbsp;<kbd>esc</kbd> exit
                '''
  assignment_nav:
    full_name: 'Assignment Menu Navigation'
    quick_help: '''
                &nbsp;<kbd>&uarr;</kbd> up
                &nbsp;<kbd>&darr;</kbd> down
                &nbsp;<kbd>enter</kbd> assign
                &nbsp;<kbd>?</kbd> help
                &nbsp;<kbd>esc</kbd> exit
                '''
  remove_nav:
    full_name: 'Remove Employee Navigation'
    quick_help: '''
                &nbsp;<kbd>k</kbd> <kbd>&uarr;</kbd> up
                &nbsp;<kbd>&darr;</kbd> <kbd>j</kbd> down
                &nbsp;<kbd>return</kbd> <kbd>r</kbd> remove
                &nbsp;<kbd>?</kbd> help
                &nbsp;<kbd>esc</kbd> exit
                '''
  cloning:
    full_name: 'Shift Cloning'
    quick_help: '''
                &nbsp;<kbd>k</kbd> <kbd>&uarr;</kbd> <kbd>&darr;</kbd> <kbd>j</kbd> days
                &nbsp;<kbd>v</kbd> or <kbd>p</kbd> paste shifts
                &nbsp;<kbd>?</kbd> help
                &nbsp;<kbd>esc</kbd> cancel
                '''
  confirm:
    full_name: 'Confirm Dialog'
    quick_help: '''
                &nbsp;<kbd>y</kbd> <kbd>d</kbd> yes delete
                &nbsp;<kbd>n</kbd> <kbd>esc</kbd> no cancel
                '''
  help:
    full_name: 'Help'
    quick_help: '&nbsp<kbd>esc</kbd> to close help'

events =
  esc_to_start:
    transitions:
      row_nav: 'start'
      vil_nav: 'start'
    triggers: [ 'esc' ]
    help: 'End keyboard naviation'
    callback: end_navigation
  start_remove_nav:
    transitions:
      vil_nav: 'remove_nav'
    triggers: [ 'r' ]
    help: '<b>r</b>emove employee shift assignment'
    callback: start_remove_nav
  to_next_remove:
    transitions:
      remove_nav: 'remove_nav'
    triggers: [ 'j', 'down' ]
    help: 'Select next assignment down'
    callback: remove_nav_down
  to_prev_remove:
    transitions:
      remove_nav: 'remove_nav'
    triggers: [ 'up', 'k' ]
    help: 'Select next assignment up'
    callback: remove_nav_up
  esc_remove_nav:
    transitions:
      remove_nav: 'vil_nav'
    triggers: [ 'esc' ]
    help: 'Escape remove assignment mode'
    callback: escape_remove_nav
  remove_assignment:
    transitions:
      remove_nav: 'vil_nav'
    triggers: [ 'r', 'return' ]
    help: '<b>r</b>emove the currently selected assignemnt from the shift'
    callback: remove_assignment
  start_row_nav:
    transitions:
      start: 'row_nav'
    triggers: [ 'j', 'down', 'up', 'k' ]
    help: 'Select First row'
    callback: highlight_first_row
  start_vil_nav:
    transitions:
      start: 'vil_nav'
    triggers: [ 'h', 'left', 'right', 'l' ]
    help: 'Select First shift'
    callback: highlight_first_vil
  to_next_row:
    transitions:
      row_nav: 'row_nav'
      vil_nav: 'row_nav'
    triggers: [ 'j', 'down' ]
    help: 'Next Row'
    callback: next_row
  to_prev_row:
    transitions:
      row_nav: 'row_nav'
      vil_nav: 'row_nav'
    triggers: [ 'up', 'k' ]
    help: 'Previous Row'
    callback: prev_row
  to_next_vil:
    transitions:
      row_nav: 'vil_nav'
      vil_nav: 'vil_nav'
    triggers: [ 'right', 'l' ]
    help: 'Next Shift'
    callback: next_vil
  to_prev_vil:
    transitions:
      row_nav: 'vil_nav'
      vil_nav: 'vil_nav'
    triggers: [ 'h', 'left' ]
    help: 'Prev Shift'
    callback: prev_vil
  mark_next_row:
    transitions:
      row_nav: 'row_nav'
    triggers: [ 'J', 'shift+down' ]
    help: 'Mark next row (for bulk cloning)'
    callback: mark_next_row
  mark_prev_row:
    transitions:
      row_nav: 'row_nav'
    triggers: [ 'shift+up', 'K' ]
    help: 'Mark previous row (for bulk cloning)'
    callback: mark_prev_row
  confirm_vil:
    transitions:
      vil_nav: 'vil_nav'
    triggers: [ 'C' ]
    help: '<b>C</b>onfirm shift'
    callback: confirm_vil
  unconfirm_vil:
    transitions:
      vil_nav: 'vil_nav'
    triggers: [ 'U' ]
    help: '<b>U</b>n-confirm shift'
    callback: unconfirm_vil
  confirm_vils:
    transitions:
      row_nav: 'row_nav'
    triggers: [ 'C' ]
    help: '<b>C</b>onfirm shifts still with draft status'
    callback: confirm_vils
  unconfirm_vils:
    transitions:
      row_nav: 'row_nav'
    triggers: [ 'U' ]
    help: '<b>U</b>n-confirm shifts back to draft status'
    callback: unconfirm_vils
  to_next_row_cloning:
    transitions:
      cloning: 'cloning'
    triggers: [ 'j', 'down' ]
    help: 'Next Row'
    callback: next_row_cloning
  to_prev_row_cloning:
    transitions:
      cloning: 'cloning'
    triggers: [ 'up', 'k' ]
    help: 'Previous Row'
    callback: prev_row_cloning
  full_clone:
    transitions:
      row_nav: 'cloning'
    triggers: [ 'c' ]
    help: '<b>c</b>lone Shift and Assignments'
    callback: full_clone
  partial_clone:
    transitions:
      row_nav: 'cloning'
    triggers: [ 's' ]
    help: 'clone <b>s</b>hifts Only (without assignments)'
    callback: partial_clone
  full_clone_ribbon:
    transitions:
      vil_nav: 'cloning'
    triggers: [ 'c' ]
    help: '<b>c</b>lone Shift and Assignments'
    callback: full_clone_of_ribbon
  partial_clone_ribbon:
    transitions:
      vil_nav: 'cloning'
    triggers: [ 's' ]
    help: 'Clone <b>s</b>hift Only (without assignments)'
    callback: partial_clone_of_ribbon
  esc_cloning:
    transitions:
      cloning: 'row_nav'
    triggers: [ 'esc' ]
    help: 'Escape/Cancel Cloning'
    callback: esc_cloning
  paste_cloning:
    transitions:
      cloning: 'row_nav'
    triggers: [ 'v', 'p' ]
    help: '<b>p</b>aste Cloned Shifts'
    callback: paste_cloning
  new_vil:
    transitions:
      row_nav: 'vil_new'
      vil_nav: 'vil_new'
    triggers: [ 'n' ]
    help: '<b>n</b>ew Shift'
    callback: add_new_vil
  esc_new_vil:
    transitions:
      vil_new: 'row_nav'
    triggers: [ 'esc' ]
    exclusive_triggers: [ 'esc' ]
    help: 'Cancel'
    callback: esc_new_vil
  esc_vil_edit:
    transitions:
      vil_edit: 'vil_nav'
    triggers: [ 'esc' ]
    exclusive_triggers: [ 'esc' ]
    help: 'Cancel'
    callback: esc_edit_vil
  start_edit:
    transitions:
      vil_nav: 'vil_edit'
    triggers: [ 'e' ]
    help: '<b>e</b>dit Shift'
    callback: edit_vil
  save_vil:
    transitions:
      vil_edit: 'vil_edit'
      vil_new: 'vil_new'
    triggers: [ 'return' ]
    exclusive_triggers: [ 'return' ]
    help: 'Save Shift'
    callback: save_vil
  saved:
    transitions:
      vil_edit: 'vil_nav'
      vil_new: 'vil_nav'
    callback: saved
  delete_shift:
    transitions:
      vil_nav: 'confirm'
    triggers: [ 'd' ]
    help: '<b>d</b>elete Shift'
    callback: delete_shift
  confirm_delete_shift:
    transitions:
      confirm: 'row_nav'
    triggers: [ 'y', 'd' ]
    help: '<b>y</b>es, <b>d</b>elete Shift'
    callback: confirm_delete_shift
  reject_delete_shift:
    transitions:
      confirm: 'vil_nav'
    triggers: [ 'n', 'esc' ]
    help: '<b>n</b>o, do not delete Shift'
    callback: reject_delete_shift
  open_assign_menu:
    transitions:
      vil_nav: 'assignment'
    triggers: [ 'a' ]
    help: '<b>a</b>ssign staff'
    callback: open_assign_menu
  esc_assign_menu:
    transitions:
      assignment: 'vil_nav'
      assignment_nav: 'vil_nav'
    triggers: [ 'esc' ]
    exclusive_triggers: [ 'esc' ]
    help: 'close staff assignment menu'
    callback: close_assign_menu
  assign_first_match:
    transitions:
      assignment: 'assignment_nav'
    triggers: [ 'return' ]
    exclusive_triggers: [ 'return' ]
    help: 'assign first listed (matching current search) employee'
    callback: assign_first_employee
  assign_nav_begin:
    transitions:
      assignment: 'assignment_nav'
    triggers: [ 'down', 'tab' ]
    exclusive_triggers: [ 'down', 'tab' ]
    help: 'navigate assignment menu'
    callback: highlight_first_employee
  assign_nav_down:
    transitions:
      assignment_nav: 'assignment_nav'
    triggers: [ 'down', 'tab' ]
    help: 'navigate assignment menu down'
    callback: assign_nav_down
  assign_nav_up:
    transitions:
      assignment_nav: 'assignment_nav'
    triggers: [ 'up', 'shift+tab' ]
    help: 'navigate assignment menu up'
    callback: assign_nav_up
  back_to_assign_search:
    transitions:
      assignment_nav: 'assignment'
    callback: assign_menu_search
  ask_help:
    transitions:
      start: 'help'
      row_nav: 'help'
      vil_nav: 'help'
      vil_edit: 'help'
      vil_new: 'help'
      assignment: 'help'
      assignment_nav: 'help'
      remove_nav: 'help'
      confirm: 'help'
      cloning: 'help'
    triggers: [ '?' ]
    help: 'get keyboard help'
    callback: open_help
  esc_from_help:
    transitions:
      help: 'help'
    triggers: [ 'esc' ]
    help: 'close help'
    return_state: close_help_return_previous_state

control = {}
control.getStates = ->
  states
control.getEvents = ->
  events

(exports ? window).control = control
#(exports ? this).control = control

all_keys = []

for name, values of states
  states[name].name = name

for e_name, e_data of events
  e_data.name = e_name
  all_keys = all_keys.concat e_data.triggers if e_data.triggers?
  for from, to of e_data.transitions
    states[from].events_by_trigger or= {}
    states[from].events_by_name or= {}
    states[from].events_by_name[e_name] = e_data
    if e_data.triggers?
      for trigger in e_data.triggers
        states[from].events_by_trigger[trigger] = e_data
    if e_data.exclusive_triggers?
      states[from].exclusive_triggers ?= []
      for trigger in e_data.exclusive_triggers
        states[from].exclusive_triggers.push(trigger)

all_keys = _und(all_keys).uniq()
all_keys_string = all_keys.join(", ")

$state_box = $('<div class="screen"><div class="state_box"><span class="state"></span> Mode:&nbsp;<span class="quick_help light-keys"></span></div></div>')
$state_box.click ->
  triggerEvent('ask_help')

move_state = (state_name) ->
  if !current_state? or current_state.name != state_name
    current_state = states[state_name] or console.log("state_name #{state_name} not found!")
    if state_name == "start"
      $state_box.hide()
    else
      $state_box.show()
      _gaq.push(['_trackEvent', 'keyboard', state_name])
    $state_box.find('span.state').text(current_state.full_name)
    $state_box.find('span.quick_help').html(current_state.quick_help)
  true

# initial state
$selected = null
$ ->
  if R.workplace?
    $state_box.appendTo('body')
    move_state 'start'
    $(document).bkeys all_keys, process_key
    $('a.keyboard').click ->
      triggerEvent 'ask_help', '?'


