

$abbreviations = ['1st ', '2nd ', '3rd ', 'gen ', 'ex ', 'lev ', 'num ', 'deut ', 'josh ', 'jdgs ', 'jdg ', '1sam ', '2sam ', 'sam ', '1kings ', '2kings ', '1chron ', '2chron ', 'chron ', 'neh ', 'ps ', 'prov ', 'pr ', 'eccl ', 'song ', 'songs ', 'is ', 'jer ', 'lam ', 'ezek ', 'dan ', 'hos ', 'ob ', 'hab ', 'zeph ', 'hag ', 'zech ', 'mal ', 'mt ', 'matt ', 'mk ', 'lk ', 'jn ', 'rom ', '1cor ', '2cor ', 'cor ', 'gal ', 'eph ', 'phil ', 'philip ', 'col ', 'coloss ', '1thess ', '2thess ', 'thess ', '1tim ', '2tim ', 'tim ', 'tit ', 'ti ', 'philem ', 'heb ', 'jas ', '1john ', '2john ', '3john ', 'rev ', 'esIsaiah']
		
$replacements = ['1 ', '2 ', '3 ', 'Genesis ', 'Exodus ', 'Leviticus ', 'Numbers ', 'Deuteronomy ', 'Joshua ', 'Judges ', 'Judges ', '1 Samuel ', '2 Samuel ', 'Samuel ', '1 Kings ', '2 Kings ', '1 Chronicles ', '2 Chronicles ', 'Chronicles ', 'Nehemiah ', 'Psalms ', 'Proverbs ', 'Proverbs ', 'Ecclesiastes ', 'Song of Solomon ', 'Song of Solomon ', 'Isaiah ', 'Jeremiah ', 'Lamentations ', 'Ezekiel ', 'Daniel ', 'Hosea ', 'Obadiah ', 'Habakkuk ', 'Zephaniah ', 'Haggai ', 'Zechariah ', 'Malachi ', 'Matthew ', 'Matthew ', 'Mark ', 'Luke ', 'John ', 'Romans ', '1 Corinthians ', '2 Corinthians ', 'Corinthians ', 'Galatians ', 'Ephesians ', 'Philippians ', 'Philippians ', 'Colossians ', 'Colossians ', '1 Thessalonians ', '2 Thessalonians ', 'Thessalonians ', '1 Timothy ', '2 Timothy ', 'Timothy ', 'Titus ', 'Titus ', 'Philemon ', 'Hebrews ', 'James ', '1 John ', '2 John ', '3 John ', 'Revelation ', 'esis']


## The following commented code was used once to construct the bible_collection hash (with correct book order) into the bible_collection.marshal file. 

# require 'json'

# bibles = {}
# bibles['NIV'] = JSON.parse(File.read('./bibles/NIV/NIV.json'))
# bibles['ESV'] = JSON.parse(File.read('./bibles/ESV/ESV.json'))
# bibles['MSG'] = JSON.parse(File.read('./bibles/MSG/MSG.json'))
# bibles['NLT'] = JSON.parse(File.read('./bibles/NLT/NLT.json'))

# correct_book_order = ['Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra', 'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zecharaiah', 'Malachi', 'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Revelation']

# $bible_collection = {}

# bibles.each do |key, value|
# 	eval("$#{key}_correct ||= {}")
# 	correct_book_order.each do |book|
# 		eval("$#{key}_correct[\"#{book}\"] = bibles[\"#{key}\"][\"#{book}\"]")
# 	end
# 	$bible_collection["#{key}"] = (eval("$#{key}_correct"))
# end

# File.open("bible_collection.marshal", "w"){|to_file| Marshal.dump($bible_collection, to_file)}
