module CheckValidity

	def is_word_valid?(word)
		if word.length != 4
			puts "Code is too long! Try a 4-char code"
			return false
		end
		word.split("").each do |letter|
			if not "ROYGBV".include? letter
				puts "Repeat input!"
				return false
			end
		end
	end

end


class CluesBoard
	attr_accessor :board
	def initialize
		@board = []
		12.times {@board << "0000"}
	end

	def to_board(word, position)
		@board[position] = word
	end
end


class GuessBoard
	attr_accessor :board
	def initialize
		@board =[]
		12.times {@board << "0000"}
	end

	def to_board(word, position)
		@board[position] = word
	end
end

class GameBoard
	
	def initialize(guessboard, cluesboard)
		@guessboard = guessboard
		@cluesboard =cluesboard
		@board = []
	end

	def display_board
		join_boards
		@board.each do |row|
			puts "#{row}"
		end
	end

	private
		def join_boards
			13.times do |n|
				@board[n] = "#{@guessboard.board[n].to_s}   #{@cluesboard.board[n].to_s}"
			end
		end
end

class CodeMaker
	include CheckValidity
	attr_accessor :control
	def initialize
		@guess = ""
	end

	public
		def make_code
			if not @control
				word = computer_code_writer
			else
				word = player_input
				player_code_writer(word) 
			end
			puts word
			return word
		end

	public
		def guess_check(word)
			return check_code(word)
		end

	private
		def computer_code_writer
			4.times do
				color_picker = Random.new_seed%6
				case color_picker
					when 1
						color = 'B'
					when 2
						color = 'G'
					when 3
						color = 'O'
					when 4
						color = 'V'
					when 5
						color = 'R'
					else
						color = 'Y'
				end
				@guess += color
			end
			puts "Computer has created a code!"
			@code = @guess
		end

	private
		def player_input
			word_validity_check = false
			puts "Input your code, Maker! R - Red,\n O - Orange,\n Y - Yellow,\n G - Green,\n B - Blue,\n V - Violet"
			while not word_validity_check
				word = gets.chomp.upcase
				word_validity_check = is_word_valid?(word)
			end
			puts "CODE: #{word}"
			return word
		end

	private
		def player_code_writer(word)
			@code = word
		end

	private
		def check_code(guess)
			word = ''
			@guess_array = guess.split("")
			@code_array = @code.split("")
			@guess_array.each do |char_guess|
				if @code_array.include? char_guess
					if @code_array.index(char_guess) == @guess_array.index(char_guess)
						word += 'B'
					else
						word += 'W'
					end
					@code_array[@code_array.index(char_guess)] = 'x'
					@guess_array[@guess_array.index(char_guess)] = 'x'
				else
					word += '0'
				end
			end
			return word
		end
end


class CodeBreaker
	attr_accessor :control
	include CheckValidity
	
	public
		def guess
			puts "Break the code!"
			if @control
				player_guess
			else
				computer_guess
			end
		end

	private
		def player_guess
			word_validity_check = false
			while not word_validity_check
				word = gets.chomp.upcase
				word_validity_check = is_word_valid?(word)
			end
			puts "\n\nCODE: #{word}"
			return word
		end

	private
		def computer_guess
		end

end


class Mastermind
	def initialize(player_choice, guessboard, cluesboard, gameboard, maker, breaker)
		@player_choice = player_choice
		@guessboard = guessboard
		@cluesboard = cluesboard
		@maker = maker
		@breaker = breaker
		@gameboard = gameboard
		@number_of_guess = 0
	end

	def start_message
		if @player_choice == 'B'
			return "Welcome Breaker! Can you break me?"
		else
			return "Welcome Maker! Do you have an unbreakable code?"
		end
	end

	def game_init
		if @player_choice == 'M'
			@maker.control = true
			@breaker.control = false
		else
			@maker.control = false
			@breaker.control = true
		end
		@maker.make_code
	end

	
	def guess
		@word = @breaker.guess
		@result = @maker.guess_check(@word)
		@guessboard.to_board(@word, @number_of_guess)
		@cluesboard.to_board(@result, @number_of_guess)
		@gameboard.display_board
	end

	def results
		case is_game_finished
			when 1
				puts "Exceeded allowed guesses! You lost!"
			when 2
				puts "You guessed the code! You're strong!"
		end
	end

	public
		def is_game_finished
			if @result == 'BBBB'
				return 2			
			elsif @number_of_guess > 10
				return 1
			else
				@number_of_guess += 1
				return 0
			end
		end
end


def is_choice_valid?(player_choice)
	unless player_choice == 'B' or player_choice == 'M'
		puts "No such option. You can only choose either CodeBreaker (B) or CodeMaker (M)"
		return false
	else
		return true
	end
end


puts "Welcome to the Mastermind!"
puts "Who do you want to play? CodeBreaker (B) or CodeMaker (M)?"

choice_check = false
while not choice_check
	player_choice = gets.chomp.upcase
	choice_check = is_choice_valid?(player_choice)
end

guessboard = GuessBoard.new
cluesboard = CluesBoard.new
gameboard = GameBoard.new(guessboard, cluesboard)
maker = CodeMaker.new
breaker = CodeBreaker.new
game = Mastermind.new(player_choice, guessboard, cluesboard, gameboard, maker, breaker)

puts game.start_message

game.game_init

game_stat = 0
while game_stat == 0
	game.guess
	game_stat = game.is_game_finished
end

game.results

