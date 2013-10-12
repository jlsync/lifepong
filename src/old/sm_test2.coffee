

states =
  start:
    full_name: 'Starting Keyboard Navigation'
    quick_help: '''
                &nbsp;<kbd>k</kbd><kbd>&uarr;</kbd><kbd> &darr;</kbd><kbd>j</kbd> days
                '''
    long_help:  "blah blah"
  row_nav:
    full_name: 'Row Navigation'
  vil_nav:
    full_name: 'Shift Navigation'
  vil_edit:
    full_name: 'Shift Editing'
  vil_new:
    full_name: 'New Shift'
  assignment:
    full_name: 'Assignment Menu Search'
  assignment_nav:
    full_name: 'Assignment Menu Navigation'
  remove_nav:
    full_name: 'Remove Employee Navigation'
  cloning:
    full_name: 'Shift Cloning'
  confirm:
    full_name: 'Confirm Dialog'
  help:
    full_name: 'Help'

events =
  esc_to_start:
    transitions:
      row_nav: 'start'
      vil_nav: 'start'
    triggers: [ 'esc' ]
    help: 'End keyboard naviation'
    callback: -> console.log 'end_navigation'
  start_remove_nav:
    transitions:
      vil_nav: 'remove_nav'
    triggers: [ 'r' ]
    help: '<b>r</b>emove employee shift assignment'
    callback: -> console.log 'start_remove_nav'
  to_next_remove:
    transitions:
      remove_nav: 'remove_nav'
    triggers: [ 'j', 'down' ]
    help: 'Select next assignment down'
    callback: -> console.log 'remove_nav_down'
  to_prev_remove:
    transitions:
      remove_nav: 'remove_nav'
    triggers: [ 'up', 'k' ]
    help: 'Select next assignment up'
    callback: -> console.log 'remove_nav_up'
  esc_remove_nav:
    transitions:
      remove_nav: 'vil_nav'
    triggers: [ 'esc' ]
    help: 'Escape remove assignment mode'
    callback: -> console.log 'escape_remove_nav'
  remove_assignment:
    transitions:
      remove_nav: 'vil_nav'
    triggers: [ 'r', 'return' ]
    help: '<b>r</b>emove the currently selected assignemnt from the shift'
    callback: -> console.log 'remove_assignment'
  start_row_nav:
    transitions:
      start: 'row_nav'
    triggers: [ 'j', 'down', 'up', 'k' ]
    help: 'Select First row'
    callback: -> console.log 'highlight_first_row'


StateMachine = require('./sm').StateMachine

class JasonStateMachine extends StateMachine
  @states = states
  @events = events
  constructor: () ->
    super()

  jason: -> console.log('Jason!')

m = new JasonStateMachine()
n = new JasonStateMachine()

console.log '### m.current_state.name'
console.log m.current_state.name
console.log '### n.current_state.name'
console.log n.current_state.name


console.log "### m.trigger('start_row_nav')"
m.trigger('start_row_nav')

console.log '### m.current_state.name'
console.log m.current_state.name
console.log '### n.current_state.name'
console.log n.current_state.name

m.jason()
m.trigger('random_event')

