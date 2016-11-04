--The first file loaded (optional)

function love.conf(t)
  t.console = true --useful for debugging (background console)

  t.window.title = "Children of the Citadel"
  t.window.width = 800
  t.window.height = 600
  t.window.fullscreen = false

  t.modules.touch = false --turning touch module off, since this won't be used
end
