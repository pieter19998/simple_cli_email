require 'net/imap'
require 'json'


class Imap
  def login(host, port, ssl, username, password)
    begin
      @imap = Net::IMAP.new(host, port, ssl)
      #login credentials
      @imap.login(username, password)
    rescue
      abort 'Authentication failed'
    end
  end

  def get_mail
    #get all mails and display the first 10 mails sender and subject
    titles = []
    @imap.examine('INBOX')

    @imap.search(["ALL"]).each_with_index do |message_id, i|
      envelope = @imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
      titles.push "#{envelope.from[0].name}: \t#{envelope.subject}"
      break if i >= 9
    end
    #return titles
    titles
  end

  def read_mail(title)
    # get mail by subject
    message_id = @imap.search(["SUBJECT", title])
    puts @imap.fetch(message_id, 'BODY.PEEK[1]')[0].attr["BODY[1]"]
    # return message id
    message_id
  end

  def check_for_attachements(message_id)
    body = @imap.fetch(message_id, 'BODY').first.attr['BODY']

    puts "#{body.parts[1].media_type}"
    puts "#{body.parts[1].param['NAME']}"
    puts "#{body.parts[1].subtype}"
    puts "#{(body.parts[1].size) / 1024} kb"

    unless (body.parts[1].size) / 1024 == 0
      return true
    end

    false
  end

  def read_attachement(message_id)
    size = @imap.fetch(message_id, 'RFC822.SIZE').first.attr['RFC822.SIZE']
    if size < 81920
      puts "msg '#{message_id}' appears to meet size criteria, downloading"
    end
    body = @imap.fetch(message_id, 'BODY').first.attr['BODY']
    i = 1

    until body.parts[i].nil?
      name = body.parts[i].param['NAME']
      i += 1

      attachment = @imap.fetch(message_id, "BODY[#{i}]").first.attr["BODY[#{i}]"]

      unless File.exists? name
        File.new(name, 'w').write attachment.unpack('m').first
        puts "Wrote #{name}"
      else
        puts "#{name} appears to exist already, skipping..."
      end
    end
  end

  def disconnect
    @imap.disconnect
  end
end