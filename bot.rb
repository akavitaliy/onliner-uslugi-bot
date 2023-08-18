require 'telegram/bot'

@token = '6391426583:AAFPMkZjAwDoa3YxiXmXSTd1tbHiybDHdIc'

def bot_send(message)    
    Telegram::Bot::Client.run(@token) do |bot|
        bot.api.send_message(chat_id: '-1001880618687', text: "#{message}")   
    end    

    return "OK"
end