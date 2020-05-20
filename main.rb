require 'rubygems'
require 'gosu'

WIDTH = 1000
HEIGHT = 600


class Player
    attr_accessor :name, :choice, :score, :is_turn
    def initialize(name, choice , score, is_turn)                                        
        @name = name
        @choice = choice
        @score = score
        @is_turn = is_turn
    end    
end 


module ZOrder
    BACKGROUND, MIDDLE, UI = *0..2
end

class RPSMain < Gosu::Window

    def initialize
        super WIDTH, HEIGHT
        self.caption = 'Rock Paper Scissors'
        @background = Gosu::Color.new(0xFF62ACB5)
        @general_font = Gosu::Font.new(self, Gosu::default_font_name, 40)
        @info_font = Gosu::Font.new(20)
        @score_font = Gosu::Font.new(30)
        file = File.new('file.txt', 'r')
        num_of_players = file.gets.chomp()
        puts num_of_players
        player1_name = file.gets.chomp()
        if num_of_players.to_i == 2
           player2_name = file.gets.chomp()
        else
            player2_name = 'Computer'
        end    
        @player = Player.new(player1_name,'None', 0, true)
        @computer = Player.new(player2_name, 'None', 0, false)
        @curr_turn = 'player'
    end   

    def draw_images
        rock = Gosu::Image.new('images/rock.png')
        paper = Gosu::Image.new('images/paper.png')
        scissors = Gosu::Image.new('images/scissors.png')
        rock.draw(50, 110 , ZOrder::UI)
        paper.draw(360 , 120, ZOrder::UI)
        scissors.draw(650,120, ZOrder::UI)
    end   

    def draw_rps_labels
        @general_font.draw('Rock',180 , 415, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
        @general_font.draw('Paper',450 , 415, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
        @general_font.draw('Scissors',730 , 415, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    end    

    def draw_score_labels
        @score_font.draw( @player.name + '\'s Score : ' + @player.score.to_s, 70 , 45, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
        @score_font.draw( @computer.name + '\'s Score : ' + @computer.score.to_s , 650 , 45, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    end 
    
    def draw_choice
        @score_font.draw('You Choose : ', 70 , 500, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
        @score_font.draw('Computer Choose :  ' , 490 , 500, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)

    end   

    def draw_background
        Gosu.draw_rect(0, 0, WIDTH, HEIGHT, @background , ZOrder::BACKGROUND, mode = :default)
    end

    def detect_choice(x1, x2, y1, y2)

        if((x1 > 63 and x2 < 340) and (y1 > 120 and y2 < 395))
            if @player.is_turn
                @player.choice = 'Rock'
                @player.is_turn = false
                @computer.is_turn = true
            else
                if @computer.name != 'Computer'
                    @computer.choice = 'Rock'
                    @computer.is_turn = false
                    @player.is_turn = true
                    start_check()    
                end
            end    
        end

        if((x1 > 366 and x2 < 640) and (y1 > 125 and y2 < 398))
            if @player.is_turn
                @player.choice = 'Paper'
                @player.is_turn = false
                @computer.is_turn = true
            else
                if @computer.name != 'Computer'
                    @computer.choice = 'Paper'
                    @computer.is_turn = false
                    @player.is_turn = true
                    start_check()
                end
            end 
        end   

        if((x1 > 666 and x2 < 939) and (y1 > 131 and y2 < 407))
            if @player.is_turn
                @player.choice = 'Scissors'
                @player.is_turn = false
                @computer.is_turn = true
            else
                if @computer.name != 'Computer'
                    @computer.choice = 'Scissors'
                    @computer.is_turn = false
                    @player.is_turn = true
                    start_check()
                end
            end 
        end
        if @computer.name == 'Computer' and @computer.is_turn
            @computer.choice = computer_choice()
            @computer.is_turn = false
            @player.is_turn = true
            start_check()                                                                         
        end   
    end 

    def computer_choice
        choice_arr = ['Rock','Paper', 'Scissors']
        rand_num = rand(3)
        return choice_arr[rand_num]
    end   
    def display_img_choice
        rock = Gosu::Image.new('images/rock_sm.png')
        paper = Gosu::Image.new('images/paper_sm.png')
        scissors = Gosu::Image.new('images/scissors_sm.png')
        if @player.choice != 'None'  
            player_choice = @player.choice.downcase 
            eval(player_choice).draw(245, 500 , ZOrder::UI)
        end
        if @computer.choice != 'None'    
            comp_choice = @computer.choice.downcase 
            eval(comp_choice).draw(740, 500 , ZOrder::UI)
        end
    end    

    def start_check()
            if(@player.choice != 'None' && @computer.choice != 'None')
                check_winner()
            else
                puts('Waiting for calculation')    
            end         
    end

    def rule_engine()
        {
            'Rock'  => ['Scissors'],
            'Paper'=> ['Rock'],
            'Scissors'=>['Paper']
        } 
    end    
    def check_winner()
        if rule_engine[@player.choice].include? @computer.choice
            @player.score += 1
            puts(@computer.choice)
        elsif rule_engine[@computer.choice].include? @player.choice
            @computer.score += 1
            puts(@computer.choice)
        else
            puts ('Tie')
        end    
  
    end  
    def draw_turn
        x1 = 35
        x2 = 55
        y1 = 50
        y2 = 70
        turn_img = Gosu::Image.new('images/turn.png')

        if(@computer.is_turn)
            x1 +=590
            x2 += 590
        else
            x1 = 35
            x2 = 55  
        end    
        turn_img.draw_as_quad(x1, y1, Gosu::Color::WHITE, x2, y1, Gosu::Color::WHITE, x1, y2, Gosu::Color::WHITE, x2, y2, Gosu::Color::WHITE,ZOrder::UI)
    end    
    def needs_cursor?
        true
    end

    def button_down(id)
        case id
        when Gosu::MsLeft
            detect_choice(mouse_x, mouse_x, mouse_y, mouse_y)
        end
    end
    def update
        
    end
  
    def draw()
        draw_background()
        draw_images()
        draw_rps_labels()
        draw_score_labels()
        draw_choice()
        draw_turn()
        display_img_choice()
        @info_font.draw("mouse_x: #{mouse_x}", 200, 550, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
        @info_font.draw("mouse_y: #{mouse_y}", 350, 550, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    end    
end    
if __FILE__ == $0
    RPSMain.new.show 
end
