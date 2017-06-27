ui = require "tek.ui"
app = ui.Application:new()
win = ui.Window:new { Title = "Hello", HideOnEscape = true }
text = ui.Button:new { Text = "_Hello, World!", Width = "auto" }
text:addNotify("Pressed", false, {
  ui.NOTIFY_SELF,
  ui.NOTIFY_FUNCTION,
  function(self)
    print "Hello, World!"
  end
})
win:addMember(text)
app:addMember(win)
app:run()