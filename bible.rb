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



class Bible
	include Menuable

	attr_accessor :bible, :books, :version, :top_menu, :separator
	
	def initialize(version, scripture_hash)
		@bible = scripture_hash
		@books = @bible.keys
		@version = version
		@top_menu = ["Choose Book and Chapter", "Passage Lookup", "Past Searches", "Quit"]
		@separator = "-" * 70
	end


	def clear_screen
		system "clear" or system "cls"
	end

	def wrap(s, width=80)
	  s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n  ")
	end


	def run(flash_message = "")
		clear_screen
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
		display_passage("#{chosen_book} #{chosen_chapter.to_s}")
	end


	def passage_lookup
		puts "Enter a passage (e.g. Romans 3:5-10 or 1 John 2): "
		passage_string = gets.chomp.strip.downcase
		display_passage(passage_string)
	end


	def past_searches

	end


	def display_passage(input)

		abbreviations = ['1st', '2nd', '3rd', 'gen', 'ex', 'lev', 'num', 'deut', 'josh', 'jdg', 'jdgs', '1sam', '2sam', 'sam', '1kings', '2kings', '1chron', '2chron', 'chron', 'neh', 'ps', 'prov', 'eccl', 'song', 'songs', 'is', 'jer', 'lam', 'ezek', 'dan', 'hos', 'ob', 'hab', 'zeph', 'hag', 'zech', 'mal', 'mt', 'matt', 'mk', 'lk', 'jn', 'rom', '1cor', '2cor', 'cor', 'gal', 'eph', 'phil', 'philip', 'col', 'coloss', '1thess', '2thess', 'thess', '1tim', '2tim', 'tim', 'tit', 'ti', 'philem', 'heb', 'jas', '1john', '2john', '3john', 'rev']
		replacements = ['1', '2', '3', 'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Judges', '1 Samuel', '2 Samuel', 'Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Chronicles', 'Nehemiah', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon', 'Song of Solomon', 'Isaiah', 'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Obadiah', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi', 'Matthew', 'Matthew', 'Mark', 'Luke', 'John', 'Romans', '1 Corinthians', '2 Corinthians', 'Corinthians', 'Galatians', 'Ephesians', 'Philippians', 'Philippians', 'Colossians', 'Colossians', '1 Thessalonians', '2 Thessalonians', 'Thessalonians', '1 Timothy', '2 Timothy', 'Timothy', 'Titus', 'Titus', 'Philemon', 'Hebrews', 'James', '1 John', '2 John', '3 John', 'Revelation']

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
			if query[0].downcase.include?('song')
				book = "Song of Solomon"
				chapverse = query[3]
			else
				run("Invalid Search")
			end
		end
		
		verses = []
		
		if chapverse.include?(':') # we want specific verses
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

		clear_screen
		
		puts separator + "\n#{input.upcase}\n" + separator
		
		verses.sort_by(&:to_i).each do |verse|
			verse_text = wrap(bible[book][chapter][verse])
			puts "#{verse}. " + verse_text
		end
		
		puts "\n -#{version} \n\n\n"
	end
end

include Menuable
Bible.new("generic", {}).clear_screen
puts "Choose a Bible Version:"
version_to_load = user_choice($bible_collection.keys)
bible_to_run = Bible.new("#{version_to_load.upcase}", $bible_collection[version_to_load])

bible_to_run.run("Welcome")