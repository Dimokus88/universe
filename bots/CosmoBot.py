import telebot
from telebot import types
import os
import subprocess
bot = telebot.TeleBot("5531416249:AAHgz_ag3bXMutra6z8Us_adB5TwlMK_1wQ")
binary = os.getenv('bunary')
@bot.message_handler(commands=['start'])
def start_message(message):
        bot.send_message(message.chat.id,"Welcome to Akash Nodes Alert Bot!")
        markup=types.ReplyKeyboardMarkup(resize_keyboard=True)
        item1=types.KeyboardButton("Status")
        markup.add(item1)
        bot.send_message(message.chat.id,"Select functions please!",reply_markup=markup)

@bot.message_handler(content_types=['text'])
def handle_text(message):
        if message.text == "Status":
                subprocess.check_call("/root/bot/status.sh '%s'" % binary, shell=True)
                text = open ('/root/bot/text.txt')
                bot.send_message(message.chat.id,text.read())
bot.infinity_polling()
