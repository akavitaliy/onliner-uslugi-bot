require 'ferrum'
require 'active_record'
require_relative 'bot.rb'

# Устанавливаем соединение с базой данных sqlite3
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'projects.db'
)

# Определяем модель Product, которая соответствует таблице products
class Product < ActiveRecord::Base
end

# Создаем таблицу products, если она еще не существует
unless Product.table_exists?
  ActiveRecord::Schema.define do
    create_table :products do |t|
      t.string :name
      t.decimal :price
    end
  end
end

browser = Ferrum::Browser.new(
  browser_path: "/usr/bin/google-chrome", 
  headless: false, 
  browser_options: { "disable-blink-features": "AutomationControlled", 'no-sandbox':nil, 'incognito':nil }, 
  process_timeout: 120,
  #xvfb: true     
)

browser.go_to("https://s.onliner.by/tasks?sections%5B%5D=developer&sections%5B%5D=searchhelp&sections%5B%5D=internetother")

sleep 5

items = browser.at_css('div.service-offers').css('span.service-offers__subtitle')

loop do
  sleep 10
  
  items = browser.at_css('div.service-offers').css('span.service-offers__subtitle')

  items.each do |product|  
    # Get the product name
    name = product.at_css('span.service-offers__name').text
    
    # Check if the product already exists in the database
    p product_exists = Product.where(name: name).any?

    if !product_exists
      Product.create(name: name)
      message = "Новый заказ -   #{name}"
      bot_send(message)
    end   
  end
  sleep 10
  browser.refresh
end

browser.close
