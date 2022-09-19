import telebot
from telebot import types
import os
import subprocess
bot = telebot.TeleBot("$TOKEN")
binary = os.getenv("binary")
@bot.message_handler(commands=['start'])
def start_message(message):
  bot.send_message(message.chat.id,"Welcome to Akash Nodes Alert Bot!")
  markup=types.ReplyKeyboardMarkup(resize_keyboard=True)
  item1=types.KeyboardButton("Info")
  item2=types.KeyboardButton("Proposal")
  item3=types.KeyboardButton("About Akash Network")
  markup.add(item1,item2,item3)
  bot.send_message(message.chat.id,"Choose a section!",reply_markup=markup)

@bot.message_handler(content_types=['text'])
def handle_text(message):
  if message.text == "Info":
     markup=types.ReplyKeyboardMarkup(resize_keyboard=True)
     item1=types.KeyboardButton("Status node hardware")
     item2=types.KeyboardButton("Blockchain Parameters")
     item3=types.KeyboardButton("Request balance")
     item4=types.KeyboardButton("Request transaction status")
     item5=types.KeyboardButton("Request block")
     item6=types.KeyboardButton("Main menu")
     markup.add(item1,item2,item3)
     markup.add(item4,item5)
     markup.add(item6)
     bot.send_message(message.chat.id,"Info section:",reply_markup=markup)
  
  if message.text == "About Akash Network":
     text = open ('/root/bot/about.txt')
     bot.send_message(message.chat.id,text.read())

  if message.text == "Request balance":
     text = "Enter address:"
     a = telebot.types.ReplyKeyboardRemove()
     text = bot.send_message(message.chat.id,text,reply_markup=a)
     bot.register_next_step_handler(text,address)
  if message.text == "Transaction":
     text = "Enter transaction hash:"
     text = bot.send_message(message.chat.id,text)
     bot.register_next_step_handler(text,hash)
  elif (message.text == "Main menu"):
     markup=types.ReplyKeyboardMarkup(resize_keyboard=True)
     item1=types.KeyboardButton("Info")
     item2=types.KeyboardButton("Proposal")
     item3=types.KeyboardButton("About Akash Network")
     markup.add(item1,item2,item3)
     bot.send_message(message.chat.id,"Choose a section!",reply_markup=markup)
  if message.text == "Status node hardware":
     subprocess.check_call("/root/bot/status.sh '%s'" % binary, shell=True)
     text = open ('/root/bot/text.txt')
     bot.send_message(message.chat.id,text.read())
  if message.text == "Request transaction status":
     text = "Enter TX_HASH:"
     a = telebot.types.ReplyKeyboardRemove()
     text = bot.send_message(message.chat.id,text,reply_markup=a)
     bot.register_next_step_handler(text,hash)

  if message.text == "Blockchain Parameters":
     text = open ('/root/bot/tmp/parameters.txt')
     bot.send_message(message.chat.id,text.read())

def hash(message):
    markup=types.ReplyKeyboardMarkup(resize_keyboard=True)
    item1=types.KeyboardButton("Info")
    text = message.text
    file = open('/root/bot/tmp/transaction.txt', 'w')
    file.write("{hash}".format(hash=message.text))
    file.close()
    subprocess.check_call("/root/bot/txs.sh '%s'" , shell=True)
    text = open ('/root/bot/tmp/txs.txt')
    markup.add(item1)
    bot.send_message(message.chat.id,text.read(),reply_markup=markup)


def address(message):
    markup=types.ReplyKeyboardMarkup(resize_keyboard=True)
    item1=types.KeyboardButton("Info")
    text = message.text
    file = open('/root/bot/tmp/address.txt', 'w')
    file.write("{address}".format(address=message.text))
    file.close()
    subprocess.check_call("/root/bot/balance.sh '%s'" , shell=True)
    text = open ('/root/bot/tmp/balance.txt')
    markup.add(item1)
    bot.send_message(message.chat.id,text.read(),reply_markup=markup)

bot.infinity_polling()
