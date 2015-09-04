require 'launchy'
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
	attr_accessor :separator

	
	def separator
		@separator = "-" * 80 + "\n"
	end
	
	
	def clear_screen
		system "clear" or system "cls"
	end


	def wrap(s, width=70)
	  s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n  ")
	end


	def display(content, destination = 'terminal', path_to_temp_file = './temp_contents.html')	
		case destination
		when 'terminal'
			puts content
			run("", false)
		when 'browser'	
			File.write(path_to_temp_file, "<html><body><pre>#{content}</pre></body></html>")
			Launchy.open(path_to_temp_file)
			puts "Displaying results in browser."
			run("", false)
		end
	end
end



class Bible
	include Menuable
	include Displayable

	attr_accessor :bible, :books, :version, :top_menu, :where_to_display
	
	def initialize(version, scripture_hash, where_to_display)
		@bible = scripture_hash
		@books = @bible.keys
		@version = version
		@top_menu = ["Choose Book and Chapter", "Passage Lookup", "Past Searches", "Proverb of the Day", "Psalms of the Day", "Proverb and Psalms of the Day", "Quit"]
		@where_to_display = where_to_display.downcase
	end



	def run(flash_message = "", clear_first = true)
		clear_screen if clear_first == true
		puts flash_message
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
		display(make_passage("#{chosen_book} #{chosen_chapter.to_s}"), where_to_display)
	end


	def passage_lookup
		puts "Enter a passage (e.g. Romans 3:5-10 or 1 John 2): "
		passage_string = gets.chomp.strip.downcase
		display(make_passage(passage_string), where_to_display)
	end


	def past_searches

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

		abbreviations = ['1st ', '2nd ', '3rd ', 'gen ', 'ex ', 'lev ', 'num ', 'deut ', 'josh ', 'jdg ', 'jdgs ', '1sam ', '2sam ', 'sam ', '1kings ', '2kings ', '1chron ', '2chron ', 'chron ', 'neh ', 'ps ', 'prov ', 'eccl ', 'song ', 'songs ', 'is ', 'jer ', 'lam ', 'ezek ', 'dan ', 'hos ', 'ob ', 'hab ', 'zeph ', 'hag ', 'zech ', 'mal ', 'mt ', 'matt ', 'mk ', 'lk ', 'jn ', 'rom ', '1cor ', '2cor ', 'cor ', 'gal ', 'eph ', 'phil ', 'philip ', 'col ', 'coloss ', '1thess ', '2thess ', 'thess ', '1tim ', '2tim ', 'tim ', 'tit ', 'ti ', 'philem ', 'heb ', 'jas ', '1john ', '2john ', '3john ', 'rev ', 'esIsaiah']
		
		replacements = ['1 ', '2 ', '3 ', 'Genesis ', 'Exodus ', 'Leviticus ', 'Numbers ', 'Deuteronomy ', 'Joshua ', 'Judges ', 'Judges ', '1 Samuel ', '2 Samuel ', 'Samuel ', '1 Kings ', '2 Kings ', '1 Chronicles ', '2 Chronicles ', 'Chronicles ', 'Nehemiah ', 'Psalms ', 'Proverbs ', 'Ecclesiastes ', 'Song of Solomon ', 'Song of Solomon ', 'Isaiah ', 'Jeremiah ', 'Lamentations ', 'Ezekiel ', 'Daniel ', 'Hosea ', 'Obadiah ', 'Habakkuk ', 'Zephaniah ', 'Haggai ', 'Zechariah ', 'Malachi ', 'Matthew ', 'Matthew ', 'Mark ', 'Luke ', 'John ', 'Romans ', '1 Corinthians ', '2 Corinthians ', 'Corinthians ', 'Galatians ', 'Ephesians ', 'Philippians ', 'Philippians ', 'Colossians ', 'Colossians ', '1 Thessalonians ', '2 Thessalonians ', 'Thessalonians ', '1 Timothy ', '2 Timothy ', 'Timothy ', 'Titus ', 'Titus ', 'Philemon ', 'Hebrews ', 'James ', '1 John ', '2 John ', '3 John ', 'Revelation ', 'esis']

		
		abbreviations.each_with_index do |str, index|
			input.gsub!(str, replacements[index])
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

		content = separator + "#{input.upcase}\n" + separator
		
		verses.sort_by(&:to_i).each do |verse|
			verse_text = wrap(bible[book][chapter][verse])
			content += "\n#{verse}. " + verse_text
		end
		
		return content += "\n-#{version}\n#{separator}\n\n" 
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