require 'rubygems'
require 'gosu'


module ZOrder
    BACKGROUND, MIDDLE, UI = *0..2
end

require_relative './main.rb'

class TextField < Gosu::TextInput
    # Some constants that define our appearance.
    INACTIVE_COLOR  = 0xcc666666
    ACTIVE_COLOR    = 0xccff6666
    SELECTION_COLOR = 0xcc0000ff
    CARET_COLOR     = 0xffffffff
    PADDING = 5
    
    attr_reader :x, :y
    
    def initialize(window, font, x, y)
      # TextInput's constructor doesn't expect any arguments.
      super()
      
      @window, @font, @x, @y = window, font, x, y
      
      # Start with a self-explanatory text in each field.
      self.text = "Enter Name"
    end
    
    # Example filter method. You can truncate the text to employ a length limit (watch out
    # with Ruby 1.8 and UTF-8!), limit the text to certain characters etc.
    
    
    def draw
      # Depending on whether this is the currently selected input or not, change the
      # background's color.
      if @window.text_input == self then
        background_color = ACTIVE_COLOR
      else
        background_color = INACTIVE_COLOR
      end


      @window.draw_quad(x - PADDING,         y - PADDING,          background_color,
                        x + width + PADDING, y - PADDING,          background_color,
                        x - PADDING,         y + height + PADDING, background_color,
                        x + width + PADDING, y + height + PADDING, background_color, 0)
      
      # Calculate the position of the caret and the selection start.
      pos_x = x + @font.text_width(self.text[0...self.caret_pos])
      sel_x = x + @font.text_width(self.text[0...self.selection_start])
      
      # Draw the selection background, if any; if not, sel_x and pos_x will be
      # the same value, making this quad empty.
      @window.draw_quad(sel_x, y,          SELECTION_COLOR,
                        pos_x, y,          SELECTION_COLOR,
                        sel_x, y + height, SELECTION_COLOR,
                        pos_x, y + height, SELECTION_COLOR, 0)
  
      # Draw the caret; again, only if this is the currently selected field.
      if @window.text_input == self then
        @window.draw_line(pos_x, y,          CARET_COLOR,
                          pos_x, y + height, CARET_COLOR, 0)
      end
      
  
      # Finally, draw the text itself!
      @font.draw(self.text, x, y, 0)
    end
  
    # This text field grows with the text that's being entered.
    # (Usually one would use clip_to and scroll around on the text field.)
    def width
      @font.text_width(self.text)
    end
    
    def height
      @font.height
    end
  
    # Hit-test for selecting a text field with the mouse.
    def under_point?(mouse_x, mouse_y)
      mouse_x > x - PADDING and mouse_x < x + width + PADDING and
        mouse_y > y - PADDING and mouse_y < y + height + PADDING
    end
    
    # Tries to move the caret to the position specifies by mouse_x
    def move_caret(mouse_x)
      # Test character by character
      1.upto(self.text.length) do |i|
        if mouse_x < x + @font.text_width(text[0...i]) then
          self.caret_pos = self.selection_start = i - 1;
          return
        end
      end
      # Default case: user must have clicked the right edge
      self.caret_pos = self.selection_start = self.text.length
    end
  end




class WelcomeScreen < Gosu::Window
    WIDTH = 1000
    HEIGHT = 600
    def initialize
        super WIDTH, HEIGHT
        @font = Gosu::Font.new(32, name: "Nimbus Mono L")  
        @info_font = Gosu::Font.new(20)
        @background = Gosu::Color.new(0xFF62ACB5)
        @player_num_choice = 0

        font = Gosu::Font.new(self, Gosu::default_font_name, 20)
        @text_fields = Array.new(2) { |index| TextField.new(self, font, 400, 300 + index * 50) }
	end

    def draw
        draw_images()
        draw_background()
        draw_btn()
        if @player_num_choice >= 1
            @text_fields[0].draw
        end
        if @player_num_choice == 2
            @text_fields[1].draw
        end
        @info_font.draw("mouse_x: #{mouse_x}", 200, 550, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
        @info_font.draw("mouse_y: #{mouse_y}", 350, 550, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    end    
    
    def needs_cursor?
        true
    end
    def detect_choice(x1, x2, y1, y2)
        if((x1 > 413 and x2 < 528) and (y1 > 444 and y2 < 494))
            @player1_name =  @text_fields[0].text
            @player2_name =  @text_fields[1].text
            returns_player()
            RPSMain.new.show     
        end 
    end

    def detect_num_player_choice(x1,x2,y1,y2)
        if((x1 > 280 and x2 < 410) and (y1 > 132 and y2 < 252))
            @player_num_choice = 1
        end 
        if((x1 > 555 and x2 < 724) and (y1 > 132 and y2 < 252))
            @player_num_choice = 2
        end 
    end 

    def draw_images()
        player_1_img = Gosu::Image.new('images/player1.png')
        player_2_img = Gosu::Image.new('images/player2.png')
        player_1_img.draw(250, 110 , ZOrder::UI)
        player_2_img.draw(550, 110 , ZOrder::UI)
    end    

    def draw_btn()
        button_img = Gosu::Image.new('images/button.png')
        button_img.draw(410,440,ZOrder::UI)
    end    

    def returns_player()
      myarr = Array.new()
      if @player1_name == 'Enter Name'
        @player1_name = 'Unknown'
      end  
      if @player2_name == 'Enter Name'
        @player2_name = 'Unknown'
      end
      my_file = File.new('file.txt', 'w')
      my_file.write(@player_num_choice.to_s+ "\n")
      my_file.write(@player1_name +"\n")
      my_file.write(@player2_name +"\n")
      my_file.close
    end   

    def draw_background
        Gosu.draw_rect(0, 0, WIDTH, HEIGHT, @background , ZOrder::BACKGROUND, mode = :default)
    end       
    def button_down(id)
        if id == Gosu::MsLeft
            self.text_input = @text_fields.find { |tf| tf.under_point?(mouse_x, mouse_y) }
        end    
      # Advanced: Move caret to clicked position
        detect_choice(mouse_x, mouse_x, mouse_y, mouse_y)
        detect_num_player_choice(mouse_x, mouse_x, mouse_y, mouse_y)
    end
end    
if __FILE__ == $0
    WelcomeScreen.new.show 
end
        