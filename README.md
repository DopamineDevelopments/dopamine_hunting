# dopamine_hunting
ESX Hunting Script


Insert this on ox_inventory/data/items.lua

['carcass'] = {
		label = 'Carcass',
		stack = true,
		weight = 5000,
},


and If you don't have a job named hunting yet just insert this in your database

INSERT INTO `jobs` (name, label) VALUES
	('hunting','Hunting')
;
INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('hunting',0,'hunter','Hunter',0,'{}')
;



