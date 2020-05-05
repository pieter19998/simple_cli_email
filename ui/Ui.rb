require 'json'
require 'tty-spinner'
require_relative '../helpers/Imap'
require_relative '../helpers//Smtp'
require_relative '../helpers//Settings'

class Menu

  def initialize(prompt)
    @prompt = prompt
    @file = Settings.new
    @imap = Imap.new
    @smtp = Smtp.new
  end

  def clear
    #clear terminal
    puts "\e[H\e[2J"
  end

  def menu
    menu = [
        {"Inbox" => -> do
          inbox
        end},
        {"Send Mail" => -> do
          send
        end},
        {"Setup" => -> do
          settings
        end},
        {"Quit" => -> do
          exit
        end}
    ]
    clear
    @prompt.select("Menu:", menu)
  end

  def inbox
    clear
    spinner = TTY::Spinner.new("[:spinner] Loading ...", format: :pulse_2)
    spinner.auto_spin
    settings = @file.get_settings
    @imap.login(settings[:host],settings[:port],settings[:ssl],settings[:username],settings[:password])
    mail = @imap.get_mail
    spinner.stop(" ✔ ")
    mail.push({"Back" => -> do
      menu
    end})
    subject = @prompt.select("Mails:", mail)
    subject = subject.split("\t")
    # @imap.read_mail(subject[1])
    puts @imap.read_attachement(@imap.read_mail(subject[1]))
    gets
    inbox
  end

  def send
    clear
    result = @prompt.collect do
      key(:subject).ask('Subject')
      key(:content).multiline("content")
      while @prompt.yes?("attache file?")
        key(:file).ask("enter file location")
        break
      end
      key(:send_to).ask("SendTo")
    end

    settings = @file.get_settings

    email = @smtp.email(result,settings[:username])
    @smtp.send_mail(settings[:host], 587, settings[:host],
                    settings[:username], settings[:password],
                    "#{email}",
                    settings[:username], result[:send_to]
    )
    menu
  end

  def settings
    settings = @prompt.collect do
      key(:host).ask('host?')
      key(:port).ask('port?', convert: :int)
      key(:ssl).yes?('ssl?')
      key(:username).ask('username?')
      key(:password).ask('password?')
    end
    @file.set_settings(settings[:host],settings[:port],settings[:ssl],settings[:username],settings[:password])
    menu
  end
end