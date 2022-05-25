require 'nokogiri'
require 'httparty'
require 'active_record'

db_config = YAML::load(File.open('./database.yml'))
ActiveRecord::Base.establish_connection(db_config)

class Pokemon < ActiveRecord::Base
end

@url = "https://www.pokemon.com/el/pokedex/"

#Limpieza de caracteres innecesarios en el nombre
def name_cleaner(string)
  cleaned = string.sub "\n", ""
  cleaned = cleaned.sub "N.º", ""
  cleaned = cleaned.sub "      ", ""
  cleaned = cleaned[0..-16]
end

#Extraccion del codigo html del perfil de cada pokemon segun corresponda
def searcher(pure_path)
    unparsed_page = HTTParty.get(@url+pure_path.to_s)
    parsed_page = Nokogiri::HTML(unparsed_page.body)
    parsed_page
end

#Recaudacion del primer selector que se encuentre dentro de la pagina indicada
def first_selector(selector, page_info, number_selector)
  counter = 0
  correct_selector = ''
  page_info.css(selector).each do |element| 
    counter += 1
    if counter == number_selector
      correct_selector = element
    end   
  end
  correct_selector
end

#Verificador de genero segun corresponda
def gender_chooser(selector, page_info)
  gender = ''
  if page_info.css(selector).to_s.include? "_female_"
    gender += 'female,'
  end
  if page_info.css(selector).to_s.include? "_male_"
    gender += 'male'
  end
  gender == '' ? 'Unknown' : gender
end

#Recaudacion multiple de un selector en especifico
def multiple_chooser(selector, page_info)
  content = ''
  page_info.css(selector).each do |element| 
     content += "#{element.text},"
  end
  content
end

#Buscador del nombre de cada gigamaximizacion dependiendo el numero dentro de cada perfil del pokemon
def searcher_gigamaximization_name(no_gigamaximization, page_info)
  element = first_selector("select#formes option", page_info, no_gigamaximization)
  if element.methods.include? :text
    element.text 
  else
    ''
  end 
end

#Recaudacion de los puntos base para las diferentes gigamaximizaciones de los pokemones
def multiple_base_points(selector, page_info)
  counter = 0
  position_points = 1
  num_evolution = 1
  evolution = "\n----#{name_cleaner(page_info.css('.pokedex-pokemon-pagination-title div').text)}----"
  page_info.css(selector).map {|element| element["data-value"]}.each do |puntos|

    case position_points
      when 1
        evolution += "\nPs: #{puntos},"
        position_points += 1
      when 2
        evolution += "\nAttack: #{puntos},"
        position_points += 1

      when 3
        evolution += "\nDefense: #{puntos},"
        position_points += 1
      
      when 4
        evolution += "\nEspecial_attack: #{puntos},"
        position_points += 1
      
      when 5
        evolution += "\nEspecial_defense: #{puntos},"
        position_points += 1

      when 6
        evolution += "\nVelocity: #{puntos},"
        num_evolution += 1
        counter = 0
        position_points = 1
        evolution += "\n\n----#{searcher_gigamaximization_name(num_evolution, page_info)}----"
    end
    
    counter += 1
  end
  evolution[0..-9]
end

#Recaudacion de las caracteristicas principales para las diferente gigamaximizaciones de los pokemones
def multiple_info_stats(selector, page_info, which_statistic)
  counter = 1
  first_name = name_cleaner(page_info.css('.pokedex-pokemon-pagination-title div').text)

  if first_selector("select#formes option", page_info, 1) != ''
    first_name_of_select = first_selector("select#formes option", page_info, 1).text
    if first_name != first_name_of_select
      data = "#{first_name}(#{first_name_of_select}): "
    else
      data = "#{first_name}: "
    end
  else
    data = "#{first_name}: "
  end

  page_info.css(selector).each do |info|
    case which_statistic
      when 1
        if info.text.end_with?(" m") 
          if counter > 1
            data += "\n#{first_selector("select#formes option", page_info, counter).text}: "
          end
          data += "#{info.text} "
          counter += 1
        end

      when 2
        if info.text.end_with?(" kg") 
          if counter > 1
            data += "\n#{first_selector("select#formes option", page_info, counter).text}: "
          end
          data += "#{info.text} "
          counter += 1
        end
      
      when 5
        if counter > 1
          data += "\n#{first_selector("select#formes option", page_info, counter).text}: "
        end
        parent_element = first_selector('.pokemon-ability-info', page_info, counter)
        element_container = first_selector('ul.attribute-list', parent_element, 1)
        if element_container != ''
          data +=  multiple_chooser('li span',element_container)
        else
          data += 'Without hability'
        end
        counter += 1

      when 6
        if counter > 1
          data += "\n#{first_selector("select#formes option", page_info, counter).text}: "
        end
        element_container = first_selector('.dtm-type ul', page_info, counter)
        data +=  multiple_chooser('li a', element_container)
        counter += 1
      when 7
        if counter > 1
          data += "\n#{first_selector("select#formes option", page_info, counter).text}: "
        end
        element_container = first_selector('.dtm-weaknesses ul', page_info, counter)
        data +=  multiple_chooser('span', element_container)[0..-24]
        counter += 1

      when 8
        if counter > 1
          data += "\n#{first_selector("select#formes option", page_info, counter).text}: "
        end
        version_description = first_selector(".version-descriptions", page_info, counter)
        array_descriptions = multiple_chooser('p',version_description)[..-2].strip
        array_descriptions = array_descriptions.split(" ,")
        array_descriptions[0] = array_descriptions[0].strip
        array_descriptions[1] = array_descriptions[1].strip
        data += "VERSION AZUL: #{array_descriptions[1]}^VERSION ROJA:#{array_descriptions[0]}~"
        counter += 1
    end
    
  end
  data
end

#Recaudacion de todos y cada uno de los datos de un solo pokemon
def info(number)
  page_info = searcher(number)
  info = {id: number,
              name: name_cleaner(page_info.css('.pokedex-pokemon-pagination-title div').text),#name
              description: multiple_info_stats('.version-descriptions', page_info, 8),#description,
              height: multiple_info_stats('.pokemon-ability-info .column-7 ul li .attribute-value', page_info, 1),#height
              weight: multiple_info_stats('.pokemon-ability-info .column-7 ul li .attribute-value', page_info, 2),#weight
              gender: gender_chooser('.pokemon-ability-info .column-7 ul li .attribute-value i', page_info),#gender
              category: page_info.css('.color-lightblue.match.active > div.column-7.push-7 > ul > li:nth-child(1) > span.attribute-value').text,#category
              hability: multiple_info_stats('.pokemon-ability-info', page_info, 5),#hability
              kind: multiple_info_stats('.dtm-type', page_info, 6),#kind
              weakness: multiple_info_stats('.dtm-weaknesses', page_info, 7),#weakness
              base_points: multiple_base_points('.pokemon-stats-info ul li.meter', page_info),#ps
              evolutions: multiple_chooser('h3.match', page_info)}#kind     
end

#Impresion del menu para salir/continuar
def menu
  puts "\n\n==================MENU===================="
  puts "1......................Buscar otro pokemon"
  puts "[cualquier tecla que no sea 1].......salir"  
  puts "=========================================="
  puts "==Ingresa una opcion y presiona [ENTER]:=="
  option = gets.to_i
  option == 1 ? true : false
end

#Impresion de los datos en pantalla
def printer_of_stats(pokemon)
  separator = "************************"
  puts "\nNo. de Pokemon: #{pokemon.id}"
  puts "Nombre: #{pokemon.name}"
  puts "/////////////////////Descripciones://////////////////////////"
  descriptions = pokemon.description.split("~")
  
  descriptions.each do |desc_gig|
    this_descriptions = desc_gig.split("^")
    this_descriptions[0].split(":")
    puts this_descriptions[0].split(":")[0]+":"
    puts "\n#{this_descriptions[0].split(":")[1]+":"+this_descriptions[0].split(":")[2]}"
    puts "#{this_descriptions[1].split(":")[0]+":"+this_descriptions[1].split(":")[1]}"
  end
  puts "//////////////////////////////////////////////////////////////"
  puts "\n#{separator}Altura:#{separator}\n #{pokemon.height}"
  puts "\n\n#{separator}PESO#{separator}\n #{pokemon.weight}"
  puts "\n\n#{separator}GENERO#{separator}\n #{pokemon.gender}"
  puts "\n\n#{separator}CATEGORIA#{separator}\n #{pokemon.category}"
  puts "\n\n#{separator}HABILIDAD#{separator}\n #{pokemon.hability}"
  puts "\n\n#{separator}TIPO#{separator}\n #{pokemon.kind}"
  
  puts"\n\n#{separator}DEBILIDAD#{separator}\n "
  array_weak = pokemon.weakness.split(",")
  array_all_weaknesses = ''
  array_weak.each do |weakness|
    array_all_weaknesses += "#{weakness.strip}, "
  end
  puts array_all_weaknesses

  puts "\n\n#{separator}PUNTOS BASE#{separator}\n"
  puts pokemon.base_points

  puts "#{separator}EVOLUCIÓN#{separator}\n"
  array_evo = pokemon.evolutions.split(",")
  evo_complete = ''

  array_evo.each do |evo|
    evo_complete += " > #{evo.strip[0..-8].strip}"
  end
  puts evo_complete
  puts ''
end

#Busqueda por nombre dentro de la db
def searcher_name_pokemon(name)
 pokemon_record = Pokemon.find_by(name: name)
 if pokemon_record == nil
  Gem.win_platform? ? (system "cls") : (system "clear")
  puts "\n||||||No se encontro ese pokemon..intentalo de nuevo|||||||\n\n"
  scraper(false, false)
 end
 Gem.win_platform? ? (system "cls") : (system "clear")
 puts "\n|||||||||||||||||||RESULTADOS DE #{name}||||||||||||||||||\n\n"
 puts printer_of_stats(pokemon_record)
 puts "\n||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n\n"
 if menu() == true
  scraper(false, true)
 else
  puts "Hasta luego :) [FIN DEL SCRIPT]"
  abort()
 end
end

#Guardado de los datos de todos y cada uno de los pokemones
def save_data(pokemon)
    new_record = Pokemon.new
    new_record.id = pokemon[0][:id].to_i
    new_record.name = pokemon[0][:name].to_s
    new_record.description = pokemon[0][:description].to_s
    new_record.height = pokemon[0][:height].to_s
    new_record.weight = pokemon[0][:weight].to_s
    new_record.gender = pokemon[0][:gender].to_s
    new_record.category = pokemon[0][:category].to_s
    new_record.hability = pokemon[0][:hability].to_s
    new_record.kind = pokemon[0][:kind].to_s
    new_record.weakness = pokemon[0][:weakness].to_s
    new_record.base_points = pokemon[0][:base_points].to_s
    new_record.evolutions = pokemon[0][:evolutions].to_s
    
    if new_record.save
      true
    else
      false
    end
end

#Carga total de todos y cada uno de los pokemones
def load_all_data
  principal_page = searcher('')
  quantity = principal_page.css('#maxRangeBox').map {|element| element["value"]}[0].to_i+1
  pokemons = Array.new
  counter_clean_window = 0
  counter_total_pokemons = 0
  increment_number = false
  if Pokemon.all.count > 0
    quantity = quantity - Pokemon.last.id.to_i
    increment_number = true
  end
  quantity.times do |number|
    if number > 0 
      counter_clean_window += 1
      if counter_clean_window == 10
        Gem.win_platform? ? (system "cls") : (system "clear") 
        counter_clean_window = 0
      end

      counter_total_pokemons += 1
      if counter_total_pokemons > 99
        system "ruby scraper.rb"
        abort()
      end
      if increment_number == true 
         number = Pokemon.last.id += 1 
      end
      
      puts "Obteniendo los datos...Pokemon#[#{number}]"
      pokemons.push(info(number))
     
      status_save_data = false
      try_save = 0
      while  status_save_data == false && try_save < 2 do
        if save_data(pokemons) == true
          status_save_data = true
          try_save = 2
        else
          try_save += 1
        end
      end
      pokemons = Array.new
    end
  end
  scraper(false, true)
end

#Verifica la carga total de los datos y pide un nombre para buscarlo en la db 
def scraper(option, found)
  if option == true
    load_all_data()
  else
    if found == true
       Gem.win_platform? ? (system "cls") : (system "clear") 
    end
    puts 'Ingresa el nombre en [minusculas] del pokemon a buscar:'
    name = gets
    name = name[0..-2].strip
    name = name.first.upcase + name[1..]
    name.length.times do |pos| 
      if name[pos] == " "
        upcase_bef_space_pos = name[pos+1].to_s
        after_string = name[..pos]
        name =  after_string + upcase_bef_space_pos.upcase + name[(pos+2)..]
      end 
    end
    searcher_name_pokemon(name)
  end
end

scraper(true, true)
