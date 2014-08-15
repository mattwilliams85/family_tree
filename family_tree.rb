require 'bundler/setup'
require 'pry'
Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

database_configurations = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configurations['development']
ActiveRecord::Base.establish_connection(development_configuration)

def menu
  system 'clear'
  puts 'Welcome to the family tree!'
  puts 'What would you like to do?'

  loop do
    puts ""
    main_menu

    choice = gets.chomp.downcase

    case choice
    when '1'
      add_person
    when '2'
      add_marriage
    when '3'
      add_parents
    when '4'
      list
    when '5'
     show_relations
    when 'x'
      exit
    end
  end
end

def main_menu
  puts "Press 1 to add"
  puts "Press 2 to list"
  puts "Press 3 to delete"
  puts "Press 4 to divorce"
  puts "Press x to exit"
  case gets.chomp.downcase
  when '1' then add_menu
  when '2' then list_menu
  when '3' then delete
  when '4'
    list
    break_vows
  when 'x' then exit
  end
end

def show_relations
  list
  puts "Enter the number of the relative and I'll find you all their relations."
  person = Person.find(gets.chomp)

  puts "Married to:"
  puts "-#{person.find_marriage}"

  result = person.find_parents
  puts "Father:"
  puts "-#{result[0]}"
  puts "Mother:"
  puts "-#{result[1]}"

  puts "Grandparents:"
  person.find_grandparents.each { |grandparent| puts "-#{grandparent}"}

  puts "Siblings:"
  person.find_siblings.each { |sibling| puts "-#{sibling}"}

  puts "Children:"
  person.find_children.each { |child| puts "-#{child}"}

  puts "Cousins:"
  person.find_cousins

  puts "Aunts & Uncles:"
  person.find_auncles
end

def add_menu
  puts 'Press 1 > to add a family member.'
  puts 'Press 2 > to marry two people.'
  puts 'Press 3 > to add parents to child'
end

def list_menu
  puts 'Press 4 > to list out the family members.'
  puts "Press 5 > to see family member's relations"
end

def add_person
  puts 'What is the name of the family member?'
  name = gets.chomp
  Person.create(:name => name.downcase.capitalize)
  puts name + " was added to the family tree.\n\n"
end

def add_marriage
  list
  puts 'What is the number of the first spouse?'
  spouse1 = Person.find(gets.chomp)
  puts 'What is the number of the second spouse?'
  spouse2 = Person.find(gets.chomp)
  spouse1.update(:spouse_id => spouse2.id)
  puts spouse1.name + " is now married to " + spouse2.name + "."
end

def add_parents
  list
  puts "What is the number of the child?"
  child = Person.find(gets.chomp)
  puts 'What is the number of the mother?'
  mommy = Person.find(gets.chomp)
  puts "What is the number of the father?"
  daddy = Person.find(gets.chomp)
  child.update(:mother_id => mommy.id)
  child.update(:father_id => daddy.id)
  puts child.name + " is now the child of " + mommy.name + " and " + daddy.name + "."
end

def delete
  list
  puts "Enter the number of the relative you wish to delete"
  person = Person.find(gets.chomp)
  puts "#{person.name} has been removed!"
  person.destroy
end

def list
  puts 'Here are all your relatives:'
  people = Person.all
  people.each do |person|
    puts person.id.to_s + ". " + person.name
  end
  puts "\n"
end


def break_vows
  puts "Enter the number of the person and we'll divorce them from their spouse."
  person = Person.find(gets.chomp)
  spouse = Person.find_by(id: person.spouse_id)
  person.update_columns(spouse_id: 0)
  spouse.update_columns(spouse_id: 0)

  puts "Congratulations to #{person.name} and #{spouse.name} for breaking their vows!"
end



menu
