### V2! Cause I finally figured out that repeating the numbers like 10 times might be a bad idea.
### Problem: You have to redo it everytime you add or change a culture... Maybe one day I'll make a V3 where you put it idk in the cultures (I think that's where it's defined?)

### This was done in about 10 minutes so don't judge thank you very much
### How to use:
## 1. Put that in your logs folder, where your error.log is generated
## 2. Delete any already existing name localizing file (elder-kings-ck3\localization\english\names\ek_character_names_l_english.yml)
## 3. Run this script
## 4. Put the resulting .yml file in the folder your previously emptied
## 5. Make sure there isn't anything strange
## 6. Profit?

reader = open('error.log', 'r')

fileResultName = "ek_character_names_l_english"
try:
    # Pog, the file is opened
	print("File opened")
	
	# Let's read it
	fileContent = reader.readlines()
	interestingLines = []
	
	# We take all the "Missing loc for name" lines and put them somewhere
	for line in fileContent:
		if "Missing loc for name" in line:
			interestingLines.append(line)
	
	# print(interestingLines)
	
	# Now we parse them and isolate the name
	nameList = []
	
	for line in interestingLines:
		# Ugly, but basically we isolate what's between 'Missing loc for name' and 'in culture'
		name = line.split("Missing loc for name")[1].split("in culture")[0].replace(" \'", '').replace("\' ", '').replace('\n', '')

		if not name in nameList:
			nameList.append(name)
	
	# We got our names, pogchamp
	# If we have at least one, we create our file. Otherwise it'd be kinda useless dontcha think
	if nameList:
		nameList.sort()
		
		with open(fileResultName + ".yml", "w", encoding='utf-8-sig') as file:
			file.write("l_english:\n")
			for name in nameList:
				file.write(" " + name + ":0 \"" + name + "\"\n")
	
finally:
    reader.close()