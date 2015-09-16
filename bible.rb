require 'launchy'
require 'yaml'
require 'time'
require './correct_bibles.rb' #gives us global variable $bible_collection

module Menuable
	def make_numbered_list(array)
		while (num ||= 1) <= array.count
			puts "[#{num}] " + array[num-1].to_s
			num += 1
		end
	end
	
	
	def user_choice(list, prompt = "Make your selection")		
		chosen_numeral, first_try = nil, true
		until (1..list.count).to_a.include?(chosen_numeral)
			puts "** Invalid Selection ** \n\n" if first_try == false
			make_numbered_list(list)
			print "#{prompt} (1"
		   print " - #{list.count}" if list.count > 1
			print "): "
			chosen_numeral = gets.chomp.strip.to_i
			first_try = false
			system "clear" or system "cls"
		end
		return list[chosen_numeral - 1] # the item chosen
	end
end


module Displayable
	def separator
		@separator = "-" * 80 + "\n"
	end
	
	
	def clear_screen
		system "clear" or system "cls"
	end


	def wrap(s, width = 70, leading_numeral)
		if leading_numeral.to_i < 10 and leading_numeral.to_i != 0
			indent = "   "
		elsif leading_numeral.to_i >= 10
			indent = "    "
		else
			indent = ""
		end
		s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n#{indent}")
	end


	def strip_html(html_string)
		html_string.gsub(%r{</?[^>]+?>}, '')
	end

	
	def display(content, destination = 'terminal', path_to_temp_file = './temp_contents.html')	
		case destination
		when 'Terminal'
			puts strip_html(content)
			run("", false)
		when 'Browser'	
			content = content.gsub(separator, "\n")
			File.write(path_to_temp_file, "<html><head><link rel='stylesheet' type='text/css' href='browser_display.css'></head><body>#{content}</body></html>")
			Launchy.open(path_to_temp_file)
			puts "Displaying results in browser."
			run("", false)
		end
	end
end


module Historyable
	def read_history
		@history ||= []
		if !File.exist?("history.yml")
			File.open("history.yml", 'w') {|f| f.write("") }
		end
		@history = YAML.load_file("history.yml")
	end

	def save_to_history(passage)
		@history.push({"#{Time.now}" => passage})
		File.open('history.yml', 'w') do |file|
			file.write(@history.to_yaml)
		end
	end

	def clear_history
		@history = []
		File.open('history.yml', 'w') do |file|
			file.write(@history.to_yaml)
		end
		run("History cleared")
	end
end



class Bible
	include Menuable
	include Displayable
	include Historyable

	attr_accessor :bible, :books, :version, :top_menu, :where_to_display, :history

	
	def initialize(version, scripture_hash, where_to_display)
		read_history
		@bible = scripture_hash
		@books = @bible.keys
		@version = version
		@top_menu = ["Choose Book and Chapter", "Passage Lookup", "Proverb of the Day", "Psalms of the Day", "Proverb and Psalms of the Day", "History", "Quit"]
		@where_to_display = where_to_display
	end



	def run(flash_message = "", clear_first = true)
		clear_screen if clear_first == true
		puts flash_message + "\n"
		puts "Bible Version: #{version}"
		puts "Make your selection below:"
		puts separator
		selection = user_choice(top_menu)
		clear_screen
		eval(selection.downcase.gsub(" ", "_"))
	end


	def quit
		puts "Goodbye! \n\n"
		exit		
	end


	def choose_book_and_chapter
		chosen_book = user_choice(books, "Select a book")
		clear_screen
		puts chosen_book.upcase + "\n"
		available_chapters = bible[chosen_book].keys.map(&:to_i).sort
		chosen_chapter = user_choice(available_chapters, "Select a chapter")
		passage = "#{chosen_book} #{chosen_chapter.to_s}"
		save_to_history(passage)
		puts separator
		display(make_passage(passage), where_to_display)
	end


	def passage_lookup
		puts "Enter a passage (e.g. Romans 3:5-10 or 1 John 2): "
		passage_string = gets.chomp.strip.downcase
		save_to_history(passage_string)
		display(make_passage(passage_string), where_to_display)
	end


	def history
		puts "Choose a passage to look up again: "
		if @history.any?
			items = []
			@history.each_with_index do |entry, index|
				entry.each do |key, value|
					t = Time.parse(key)
					items.push("#{t.strftime("%e %b %Y %l:%M%p")}: #{value}")
				end
			end
			items.push("Clear History", "Go Back")
			choice = user_choice(items) 
			if choice == "Clear History"
				clear_history
			elsif choice == "Go Back"
				run()
			else
				passage = choice.split(': ')[1]
				display(make_passage(passage), where_to_display)
			end
		else
			run("***History is empty***")
		end
	end


	def proverb_of_the_day(display_it = true)
		date_day = Time.now.day.to_s
		passage = make_passage("Proverbs #{date_day}")
		display(passage, where_to_display) if display_it == true
		return passage
	end


	def psalms_of_the_day(display_it = true)
		date_day = Time.now.day
		assembled_psalms = ""
		until (chapter_number ||= date_day) > 150
			assembled_psalms += make_passage("Psalms #{chapter_number}")
			chapter_number += 30
		end
		display(assembled_psalms, where_to_display) if display_it == true
		return assembled_psalms
	end


	def proverb_and_psalms_of_the_day
		assembled_passages = proverb_of_the_day(false) + psalms_of_the_day(false)
		display(assembled_passages, where_to_display)
	end


	def make_passage(input)
		
		$abbreviations.each_with_index do |str, index| # arrays defined in correct_bibles.rb
			input.gsub!(str, $replacements[index])
		end

		query = input.downcase.chomp.strip.split # splits at spaces
		
		case query.count
		when 3
			book = "#{query[0]} #{query[1].capitalize}"  # book name with ordinal, e.g. "1 Chronicles"
			chapverse = query[2]
		when 2
			book = query[0].capitalize # book name without ordinal e.g. "Romans"
			chapverse = query[1]
		else
			if query[0].downcase.include?('song') # Song of Solomon special case
				book = "Song of Solomon"
				chapverse = query[3]
			else
				run("Invalid Search")
			end
		end
		
		verses = []
		
		if chapverse.include?(':') # we want specific verse(s)
			chapter = chapverse.split(':').first  
			verse_statement = chapverse.split(':').last
			if verse_statement.include?('-')  # it's a range of verses
				verse_range = (verse_statement.split('-').first.to_i..verse_statement.split('-').last.to_i)
				verse_range.to_a.each {|verse_number| verses << verse_number.to_s}		
			else  # single verse
				verses << verse_statement
			end
		else # There are no verses given; only a chapter is provided, e.g. "John 3"
			chapter = chapverse
			bible[book][chapter].keys.each {|verse_number| verses << verse_number } # store every verse in the chapter in verses
		end

		content = "\n<div class='passage'>\n" + separator + "<h2>#{input.upcase}\n</h2>" + separator
		
		verses.sort_by(&:to_i).each do |verse|
			verse_text = wrap(bible[book][chapter][verse], 70, verse)
			content += "<p class='verse'>\n<span class='verse_number'>#{verse}.</span> " + verse_text + "</p>"
		end
		
		return content += "\n<div class='citation'>- #{version}</div>\n#{separator}\n</div><!--.passage-->\n" 
	end
end
	


include Menuable
include Displayable

clear_screen
puts "Choose a Bible Version:"
version_to_load = user_choice($bible_collection.keys)
display_options = ["Terminal", "Browser"]
puts "Choose where to display the Bible text:"
where_to_display = user_choice(display_options)

bible_to_run = Bible.new("#{version_to_load.upcase}", $bible_collection[version_to_load], where_to_display)
bible_to_run.run("Welcome")