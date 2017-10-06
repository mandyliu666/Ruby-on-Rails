# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.destroy_all
Profile.destroy_all
TodoList.destroy_all
TodoItem.destroy_all

User.create! [
	{ username: "Fiorina", password_digest: "carlyfiorina" },
	{ username: "Trump", password_digest: "donaldtrump" },
	{ username: "Carson", password_digest: "bencarson" },
	{ username: "Clinton", password_digest: "hillaryclinton" }
]

User.find_by!(username: "Fiorina").create_profile(gender: "female", birth_year: 1954, first_name: "Carly", last_name: "Fiorina")
User.find_by!(username: "Trump").create_profile(gender: "male", birth_year: 1946, first_name: "Donald", last_name: "Trump")
User.find_by!(username: "Carson").create_profile(gender: "male", birth_year: 1951, first_name: "Ben", last_name: "Carson")
User.find_by!(username: "Clinton").create_profile(gender: "female", birth_year: 1947, first_name: "Hillary", last_name: "Clinton")

User.first.todo_lists.create(list_name: "cflist", list_due_date: Date.today + 1.year)
User.second.todo_lists.create(list_name: "dtlist", list_due_date: Date.today + 1.year)
User.third.todo_lists.create(list_name: "bclist", list_due_date: Date.today + 1.year)
User.fourth.todo_lists.create(list_name: "hclist", list_due_date: Date.today + 1.year)

TodoList.first.todo_items.create! [
	{ due_date: Date.today + 1.year, title: "item11", description: "des11"},
	{ due_date: Date.today + 1.year, title: "item12", description: "des12"},
	{ due_date: Date.today + 1.year, title: "item13", description: "des13"},
	{ due_date: Date.today + 1.year, title: "item14", description: "des14"},
	{ due_date: Date.today + 1.year, title: "item15", description: "des15"}
]

TodoList.second.todo_items.create! [
	{ due_date: Date.today + 1.year, title: "item21", description: "des21"},
	{ due_date: Date.today + 1.year, title: "item22", description: "des22"},
	{ due_date: Date.today + 1.year, title: "item23", description: "des23"},
	{ due_date: Date.today + 1.year, title: "item24", description: "des24"},
	{ due_date: Date.today + 1.year, title: "item25", description: "des25"}
]

TodoList.third.todo_items.create! [	
	{ due_date: Date.today + 1.year, title: "item31", description: "des31"},
	{ due_date: Date.today + 1.year, title: "item32", description: "des32"},
	{ due_date: Date.today + 1.year, title: "item33", description: "des33"},
	{ due_date: Date.today + 1.year, title: "item34", description: "des34"},
	{ due_date: Date.today + 1.year, title: "item35", description: "des35"}
]

TodoList.fourth.todo_items.create! [
	{ due_date: Date.today + 1.year, title: "item41", description: "des41"},
	{ due_date: Date.today + 1.year, title: "item42", description: "des42"},
	{ due_date: Date.today + 1.year, title: "item43", description: "des43"},
	{ due_date: Date.today + 1.year, title: "item44", description: "des44"},
	{ due_date: Date.today + 1.year, title: "item45", description: "des45"}
]