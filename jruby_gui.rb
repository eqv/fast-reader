#!/usr/local/bin/jruby

# ZetCode JRuby Swing tutorial
# 
# In this example we draw lyrics of a 
# song on the window panel.
# 
# author: Jan Bodnar
# website: www.zetcode.com
# last modified: December 2010


include Java

import java.awt.Color
import java.awt.Font
import java.awt.RenderingHints
import java.awt.geom.Ellipse2D
import javax.swing.JFrame
import javax.swing.JPanel

Thread.abort_on_exception = true

class Canvas < JPanel

    def initialize(*args)
        super(*args)
        @wordcounter = 0
        @words = File.read("das_urteil.txt").lines.map{|x| x.split(/\s+/)}.flatten
        @word = "Get Ready"

        Thread.new do
          sleep_time = 60.0/600
          sentence_length = 0
          sleep 5
          loop do
            @word = @words[@wordcounter % @words.length]
            self.repaint
            @wordcounter += 1
            sleep sleep_time*time_factor(@word, sentence_length)
            if @word =~ /\./
              sentence_length = 0
            else
              sentence_length += 1
            end
          end
        end
    end

    def paintComponent g
        super
        self.drawLyrics g
    end

    def hl_index(word)
      return case word.length
        when 1      then    0
        when 2..5   then    1
        when 6..9   then    2
        when 10..13 then    3
        else 4
      end
    end
    
    def time_factor(word, sentence_length)
      mult = 1
      mult *= 1.6 if word.length > 13
      mult *= 1.3 if word.length > 7 && word.length <=13
      mult *= 1.3 if word.length < 4
      mult *= 1.3 unless word =~ /^[a-z]+$/i
      mult *= 1.1 if word =~ /^[A-Z]/
      if word =~/[,;:."?]/
        mult *= 3.3 if sentence_length > 22
        mult *= 2.2 if sentence_length > 11 && sentence_length <= 22
      end

      return mult
    end

    def drawLyrics g
        rh = RenderingHints.new RenderingHints::KEY_ANTIALIASING, RenderingHints::VALUE_ANTIALIAS_ON
        rh.put RenderingHints::KEY_RENDERING, RenderingHints::VALUE_RENDER_QUALITY
        g.setRenderingHints rh

        g.setFont Font.new "Sanserif", Font::BOLD, 20
        metrics = g.getFontMetrics
        string  = @word
        i = hl_index(string)
        prefix  = string[0...i]
        hl      = string[i..i]
        postfix = string[i+1..-1]
        w = metrics.stringWidth(prefix)
        offset = 90
        g.drawString prefix, offset-w, 30
        g.setColor(Color::RED);
        g.drawString hl, offset, 30
        g.setColor(Color::BLACK);
        g.drawString postfix, offset+metrics.stringWidth(hl), 30
    end
end

class Example < JFrame
  
    def initialize
        super "FastReader"
        initUI
    end
      
    def initUI
        canvas = Canvas.new
        self.getContentPane.add canvas
        
        self.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
        self.setSize 400, 250
        self.setLocationRelativeTo nil
        self.setVisible true
    end
end

Example.new
