require 'net/smtp'

class Smtp
# create mail
  def email(mail, name)
    filecontent = File.binread(mail[:file])
    size = File.size(mail[:file])
    encodedcontent = [filecontent].pack("m") # base64
    marker = "PART_SEPARATOR"
    # Define the main headers.
    part1 = <<EOF
From: #{name}
To: <#{mail[:send_to]}>
Subject: #{mail[:subject]}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=#{marker}
--#{marker}
EOF

    # Define the message action
    part2 = <<EOF
Content-Type: text/plain
Content-Transfer-Encoding:8bit

#{mail[:content]}
--#{marker}
EOF

    # Define the attachment section
    part3 = <<EOF
Content-Type: application/octet-stream; name="#{mail[:file]}"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename="#{mail[:file]}"; size=#{size}

#{encodedcontent}
--#{marker}--
EOF
    # return email
    message = part1 + part2 + part3
  end

  def send_mail(smtp_server, port, helo, username, password, msg, send_from, send_to)
    smtp = Net::SMTP.new smtp_server, port
    smtp.enable_starttls
    smtp.start(helo, username, password, :login) do
      smtp.send_message(msg, send_from, send_to)
    end
  end
end