require 'json'

bibles = {}
bibles['NIV'] = JSON.parse(File.read('./bibles/NIV/NIV.json'))
bibles['ESV'] = JSON.parse(File.read('./bibles/ESV/ESV.json'))
bibles['MSG'] = JSON.parse(File.read('./bibles/MSG/MSG.json'))
bibles['NLT'] = JSON.parse(File.read('./bibles/NLT/NLT.json'))

correct_book_order = ['Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra', 'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zecharaiah', 'Malachi', 'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Revelation']

$bible_collection = {}

bibles.each do |key, value|
	eval("$#{key}_correct ||= {}")
	correct_book_order.each do |book|
		eval("$#{key}_correct[\"#{book}\"] = bibles[\"#{key}\"][\"#{book}\"]")
	end
	$bible_collection["#{key}"] = (eval("$#{key}_correct"))
end