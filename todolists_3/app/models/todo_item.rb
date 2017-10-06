class TodoItem < ActiveRecord::Base

	def self.count_completed_todo_items
		TodoItem.where(completed: true).count
	end
end
