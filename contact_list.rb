#!/usr/bin/env ruby 

require 'pg'
require 'active_record'
require 'colorize'
require_relative 'config/db'
require_relative 'lib/contact'
require_relative 'lib/phone_number'

class ContactList

  PER_PAGE = 5

  def initialize
    return show_menu if ARGV.empty?
    @command = ARGV[0]
    @arg = ARGV[1] unless ARGV[1] == nil
    puts "\n============================================================".colorize(:yellow)
    puts "============================================================".colorize(:yellow)
    puts "=======================".colorize(:yellow) + " CONTACT LIST ".colorize(:green) + "=======================".colorize(:yellow)
    puts "============================================================".colorize(:yellow)
    puts "============================================================".colorize(:yellow)
    check_command
  end

private

  # Print a list of available commands
  def show_menu
    menu = "\n Available Commands:
      new\t- Create a new contact
      list\t- List all contacts
      show\t- Show a contact
      update\t- Update a contact
      search\t- Search contacts
      delete\t- Delete contact\n\n"
    puts menu
  end

  # Check the instant variable @command for possible inputs; routes to the proper method
  def check_command
    case @command
    when 'list' then show_contacts
    when 'new' then add_contact
    when 'find' then get_contact
    when 'update' then update_contact
    when 'search' then search_contacts()
    when 'delete' then delete_contact
    else 
      puts "\n> Command not recognized"
      show_menu
    end
  end

  # Prints all contacts to the console
  def show_contacts
    page = 0
    contacts = Contact.all.limit(PER_PAGE).offset(PER_PAGE * page)
    display_contacts(contacts)
    wait_for_enter

    while contacts.count > 0
      page += 1
      contacts = Contact.all.limit(PER_PAGE).offset(PER_PAGE * page)
      if contacts.count == 0
        puts " BYE!\n".colorize(:green)
        return
      end
      display_contacts(contacts)
      wait_for_enter
    end
  end

  # Waits for user input and creates a new contact record
  def add_contact
    puts "\n> Enter contact name:".colorize(:yellow)
    name = STDIN.gets.chomp
    puts "\n> Enter contact email:".colorize(:yellow)
    email = STDIN.gets.chomp
    # if Contact.uniq_email?(email)
      contact = Contact.create(name: name, email: email)
      add_phone_number(contact.id)
      puts "\n> #{name} successfully added to contact list\n".colorize(:green)
    # else
      # puts "\n> #{email} already exists! Contact not added\n\n".colorize(:red)
    # end
  end

  # Takes ID and display contact if it exists
  def get_contact
    contact = [Contact.find(@arg)]
    puts contact.nil? ? "> Contact not found" : display_contacts(contact)
  end

  def update_contact
    contact = Contact.find(@arg)
    display_contacts([contact])

    puts "> Update Name:".colorize(:yellow)
    new_name = STDIN.gets.chomp
    contact.name = new_name unless new_name.empty?

    puts "\n> Update Email:".colorize(:yellow)
    new_email = STDIN.gets.chomp
    contact.email = new_email unless new_email.empty?
    contact.save
  end

  def delete_contact
    contact = Contact.find(@arg)
    Contact.destroy(@arg)
    puts "\n> You've removed #{contact.name} from the database!\n\n".colorize(:red)
  end

  # Takes user input and searches contact list. Outputs all unique entries
  def search_contacts
    # contacts = Contact.search(@arg.downcase).uniq
    contacts = Contact.all
    matched_contacts = contacts.select do |contact|
      term = @arg.downcase
      contact.name.downcase.include?(term) || contact.email.downcase.include?(term)
    end
    display_contacts(matched_contacts)
  end

  # Takes an array of contacts and a Boolean if paginated and formats the output
  def display_contacts(contacts)
    begin
      puts "\n ID \t NAME \t\t EMAIL".colorize(:yellow)
      contacts.each do |contact|
        puts "------------------------------------------------------------"
        puts " #{contact.id}\t #{contact.name}\t (#{contact.email})".colorize(:green)
        if contact.phone_numbers[0] != nil
          contact.phone_numbers.each { |el| puts " #{el.label}: #{el.phone_number}"}
        end
      end
      puts "============================================================"
      puts " #{contacts.size} records shown\n\n".colorize(:yellow )
    rescue NoMethodError
      "> ID does not exists!\n\n".colorize(:red)
    end
  end

  # Takes a contact_id and adds a new PhoneNumber object
  def add_phone_number(contact_id)
    puts "> Would you like to add a phone number? (y/n)".colorize(:yellow)
    input = STDIN.gets.chomp.downcase
    while input == 'y'
      puts "\n> Phone Type (Home/Work/Mobile)".colorize(:yellow)
      label = STDIN.gets.chomp
      puts "\n> Phone Number".colorize(:yellow)
      number = STDIN.gets.chomp
      PhoneNumber.create({label: label, phone_number: number, contact_id: contact_id})

      puts "\nAdd another? (y/n)".colorize(:yellow)
      input = STDIN.gets.chomp.downcase
    end
  end

  # Waits for input from from the user before continuing; returns the input
  def wait_for_enter
    puts "> Press Enter key to continue".colorize(:red)
    STDIN.gets.chomp
  end
end

ContactList.new