### This was done in about 10 minutes so don't judge thank you very much
### How to use:
## 1. Put that in your logs folder, where your error.log is generated
## 2. Delete any already existing name localizing file (elder-kings-ck3\localization\english\names\characters_name_XXX_l_english.yml)
## 3. Run this script
## 4. Put the resulting .yml files in the folder your previously emptied
## 5. Make sure there isn't anything strange
## 6. Profit?

reader = open('error.log', 'r')
try:
    # Pog, the file is opened
	print("File opened")
	
	# Let's read it
	fileContent = reader.readlines()
	interestingLines = []
	
	# We take all the "Missing loc for name" lines and put them somewhere
	for line in fileContent:
		if "[culture_names.cpp:98]: Missing loc for name" in line:
			interestingLines.append(line)
	
	# print(interestingLines)
	
	# Now we separate the lines by their culture tag
	dict_name_cultures = {}
	
	for line in interestingLines:
		name = line.split("Missing loc for name ")[1].split(" in culture ")[0].replace('\'', '').replace('\n', '')
		culture = line.split(" in culture ")[1].replace('\'', '').replace('\n', '')
		
		# We create a dictionary where each culture is given an array of names
		if not culture in dict_name_cultures:
			dict_name_cultures[culture] = []
			
		dict_name_cultures[culture].append(name)
	
	# for key in dict_name_cultures:
		# print(key + ":")
		# for item in dict_name_cultures[key]:
			# print(" - " + item)
			
	# Ok so now is the fun part! We create a loc file for each culture, in which we do a 1->1 localization of the name, poggers
	for key in dict_name_cultures:
		print(key)
		with open("characters_name_"+key+"_l_english.yml", "w") as file:
			file.write("l_english:\n")
			for name in dict_name_cultures[key]:
				file.write(" " + name + ":0 \"" + name + "\"\n")
	
finally:
    reader.close()