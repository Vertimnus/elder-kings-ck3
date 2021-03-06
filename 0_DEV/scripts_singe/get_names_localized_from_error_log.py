### V3: Can now use both "Missing loc for name XXX in culture YYY" AND "Missing loc for name XXX for character ZZZ"
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

reader = open('error.log', 'r', encoding="utf8")

fileResultName = "ek_character_names_l_english"
try:
	# Pog, the file is opened
	print("File opened")
	
	# Let's read it
	fileContent = reader.readlines()
	interestingLines1 = []	
	interestingLines2 = []	
	nameList = []
	
	### We take all the "Missing loc for name" lines and put them somewhere
	for line in fileContent:
		if "culture_names.cpp" in line and "Missing loc for name" in line:
			interestingLines1.append(line)
		
		if "characterhistory.cpp" in line and "Missing loc for name" in line:
			interestingLines2.append(line)

	### [19:05:20][culture_names.cpp:103]: Missing loc for name 'Longinus' in culture 'pontic'
	for line in interestingLines1:
		# Ugly, but basically we isolate what's between 'Missing loc for name' and 'in culture'
		name = line.split("Missing loc for name")[1].split("in culture")[0].replace(" \'", '').replace("\' ", '').replace('\n', '')

		if not name in nameList:
			nameList.append(name)
	
	### [19:50:40][characterhistory.cpp:698]: Missing loc for name 'Belana' for character 'caro_001'
	for line in interestingLines2:
		# Ugly, but basically we isolate what's between 'Missing loc for name' and 'in culture'
		name = line.split("Missing loc for name")[1].split("for character")[0].replace(" \'", '').replace("\' ", '').replace('\n', '')

		if not name in nameList:
			nameList.append(name)
	
	### We got our names, pogchamp
	# If we have at least one, we create our file. Otherwise it'd be kinda useless dontcha think
	if nameList:
		nameList.sort()
		
		with open(fileResultName + ".yml", "w", encoding='utf-8-sig') as file:
			file.write("l_english:\n")
			for name in nameList:
				file.write(" " + name + ":0 \"" + name + "\"\n")
	
finally:
	reader.close()