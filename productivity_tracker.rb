require 'date'
require 'json'

class ProductivityTracker
  DATA_FILE = 'tasks.json'

  def initialize
    @tasks = load_tasks
  end

  def load_tasks
    if File.exist?(DATA_FILE)
      JSON.parse(File.read(DATA_FILE), symbolize_names: true)
    else
      []
    end
  end

  def save_tasks
    File.write(DATA_FILE, JSON.pretty_generate(@tasks))
  end

  def add_task(description, deadline)
    @tasks << { description: description, deadline: deadline, completed: false, created_at: Date.today.to_s }
    save_tasks
  end

  def mark_task_completed(index)
    @tasks[index][:completed] = true
    save_tasks
  end

  def view_tasks(status = nil)
    filtered_tasks = @tasks
    filtered_tasks = @tasks.select { |task| task[:completed] == (status == :completed) } if status

    puts "Tasks:"
    filtered_tasks.each_with_index do |task, index|
      puts "#{index + 1}. #{task[:description]} - Deadline: #{task[:deadline]} - Completed: #{task[:completed]}"
    end
  end

  def generate_report
    completed_tasks = @tasks.select { |task| task[:completed] }
    pending_tasks = @tasks.reject { |task| task[:completed] }

    puts "Daily Productivity Report (#{Date.today}):"
    puts "Completed Tasks: #{completed_tasks.size}"
    puts "Pending Tasks: #{pending_tasks.size}"
  end
end

tracker = ProductivityTracker.new

loop do
  puts "\nPersonal Productivity Tracker"
  puts "1. Add Task"
  puts "2. Mark Task as Completed"
  puts "3. View Pending Tasks"
  puts "4. View Completed Tasks"
  puts "5. Generate Daily Report"
  puts "6. Exit"

  choice = gets.chomp.to_i

  case choice
  when 1
    puts "Enter task description:"
    description = gets.chomp
    puts "Enter task deadline (YYYY-MM-DD):"
    deadline = gets.chomp
    tracker.add_task(description, deadline)
    puts "Task added."
  when 2
    tracker.view_tasks(:pending)
    puts "Enter task number to mark as completed:"
    index = gets.chomp.to_i - 1
    tracker.mark_task_completed(index)
    puts "Task marked as completed."
  when 3
    tracker.view_tasks(:pending)
  when 4
    tracker.view_tasks(:completed)
  when 5
    tracker.generate_report
  when 6
    break
  else
    puts "Invalid choice. Please try again."
  end
end
