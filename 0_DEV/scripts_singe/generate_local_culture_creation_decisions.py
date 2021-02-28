regions = ['glenumbra', 'rivenspire', 'stormhaven', 'greater_wrothgar', 'bangkorai', 'craglorn', 'abecee', 'colovia', 'nibenay', 'heartlands', 'karth', 'west_ghost', 'white_river', 'dark_water', 'solstheim', 'yokuda', 'auridon', 'summerset', 'grahtroowd', 'greenshade', 'malabal_tor', 'reaper_march', 'anequina', 'tenmar', 'pellitine']

decisionFile = open("ek_local_culture_creation_decisions.txt", "w+")

for region in regions:
	str = ""
	
	str += "create_local_culture_" + region + "_decision = {" + '\n'
	str += '\t' + "picture = \"gfx/interface/illustrations/decisions/decision_realm.dds\"" + '\n'
	str += '\n'
	str += '\t' + "desc = create_local_culture_" + region + "_decision_desc" + '\n'
	str += '\t' + "major = yes" + '\n'
	str += '\n'
	str += '\t' + "ai_check_interval = 120" + '\n'
	str += '\n'
	str += '\t' + "is_shown = {" + '\n'
	str += '\t' + '\t' + "is_landed = yes" + '\n'
	str += '\t' + '\t' + "is_independent_ruler = yes" + '\n'
	str += '\t' + '\t' + "exists = capital_province" + '\n'
	str += '\n'
	str += '\t' + '\t' + "create_local_culture_decision_is_shown_scripted_trigger = { REGION = " + region + " }" + '\n'
	str += '\t' + "}" + '\n'
	str += '\n'
	str += '\t' + "is_valid = {" + '\n'
	str += '\t' + '\t' + "create_local_culture_decision_is_valid_scripted_trigger = { REGION = " + region + " }" + '\n'
	str += '\t' + "}" + '\n'
	str += '\n'
	str += '\t' + "is_valid_showing_failures_only = {" + '\n'
	str += '\t' + '\t' + "is_capable_adult = yes" + '\n'
	str += '\t' + '\t' + "is_imprisoned = no" + '\n'
	str += '\t' + '\t' + "is_independent_ruler = yes" + '\n'
	str += '\t' + '\t' + "is_at_war = no" + '\n'
	str += '\t' + "}" + '\n'
	str += '\n'
	str += '\t' + "effect = {" + '\n'
	str += '\t' + '\t' + "create_local_culture_decision_scripted_effects = { REGION = " + region + " }" + '\n'
	str += '\n'
	str += '\t' + '\t' + "### Capital in " + region +", personally convert culture" + '\n'
	str += '\t' + '\t' + "if = {" + '\n'
	str += '\t' + '\t' + '\t' + "limit = { capital_province = { geographical_region = custom_nativity_" + region + " } }" + '\n'
	str += '\t' + '\t' + '\t' + "custom_tooltip = create_local_culture_" + region +"_decision_courtiers_embrace_new_culture" + '\n'
	str += '\t' + '\t' + '\t' + "custom_tooltip = create_local_culture_" + region +"_decision_capital_embrace_new_culture" + '\n'
	str += '\t' '\t' + "}" + '\n'
	str += '\t' '\t' + "custom_tooltip = create_local_culture_" + region + "_decision_provinces_embrace_new_culture" + '\n'
	str += '\t' + "}" + '\n'
	str += '\n'
	str += '\t' + "ai_potential = {" + '\n'
	str += '\t' + '\t' + "always = yes" + '\n'
	str += '\t' + "}" + '\n'
	str += '\n'
	str += '\t' + "ai_will_do = {" + '\n'
	str += '\t' + '\t' + "base = 100" + '\n'
	str += '\t' + "}" + '\n'
	str += "}" + '\n'
	
	decisionFile.write(str)
	decisionFile.write('\n')
	
decisionFile.close()