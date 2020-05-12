require 'tty-cursor'
require "tty-prompt"
require 'pathname'
require_relative 'ui/Ui'

class Main

  def initialize
    @prompt = TTY::Prompt.new(active_color: :blue)
    pn = Pathname.new("config")
    menu = Menu.new(@prompt)

    unless pn.exist?
      menu.settings
    end

    menu.menu
  end
end

Main.new

