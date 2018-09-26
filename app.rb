module App
  class Application < Sinatra::Base
    get "/" do
      @title = "Home"
      erb :index
    end

    get "/lists" do
      @title = "List: #{params[:name]}"
      erb :list
    end
  end
end
