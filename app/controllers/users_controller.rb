class UsersController < ApplicationController
    def index    
        
    end

    def create
        
        #declare dom of posts
        @post_dom=[]

        @comment_count=[]
        #Get Instagram Url
        @insta_url=params[:insta_url]
        #run chrome
        @@bot = Selenium::WebDriver.for :chrome 
        @@bot.navigate.to "https://www.instagram.com/accounts/login/?force_classic_login"
        sleep 1
        #using username and password to login
        @@bot.find_element(:id, 'id_username').send_keys 'cuong_manh248'
        @@bot.find_element(:id, 'id_password').send_keys '24081991'
        @@bot.find_element(:class, 'button-green').click
        sleep 1
        @@bot.navigate.to "#{@insta_url}"  
        sleep 1    
        #scroll down the account page and save dom
        for i in 0..24
            @@bot.action.send_keys(:page_down).perform
            sleep 1
            #save dom after 8 times press page down button
            if i%8==0
                # elements contain the content of a post
                dom=@@bot.find_elements(:class, '_mck9w')
                for i in dom
                    dom=i.find_element(:tag_name,'a')['href']
                    @post_dom.push(dom)   
                end      
            end 
        end
         #avoid duplicate when save dom
         @post_dom=@post_dom.uniq
         #Get exactly 100 post
         @post_dom=@post_dom[0..99]
         Comment.all.delete_all
        for i in 0..@post_dom.length-1
                @@bot.navigate.to "#{@post_dom[i]}"
                while @@bot.find_elements(:class, '_m3m1c').size > 0 do
                   @@bot.find_element(:class, '_m3m1c').click  
                   sleep 0.5
                end
                # find hashtag
                #dom=@@bot.find_element(:class, '_b0tqa')
                #dom=dom.find_elements(:tag_name, 'a')
                #for i in dom
                    #if i.text.include? "#"
                    #@hashtags.push(i.text)
                    #end
                #end
                #find comments
                dom_comment=@@bot.find_elements(:class, '_ezgzd')
                dom_comment.shift
                @comment_count.push(dom_comment.length)     
                for d in dom_comment
                    comments=Comment.new(
                        id: i ,
                        username:d.find_element(:tag_name, 'a')['title'],
                        body:d.find_element(:tag_name, 'span').text
                    )
                    comments.save
                end
                
    
        end
            render 'index'
    end
    def show
        @id=params[:id]
        @comments=Comment.where('id = ?', @id)
    end    
end
