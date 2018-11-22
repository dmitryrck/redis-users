module App
  UNIT_TIME = 60*30
  TEN_MIN   = 60*10

  class Application < Sinatra::Base
    helpers do
      def present?(value = nil)
        value != nil && value != ""
      end

      def redis
        @redis ||= Redis.new(url: ENV["REDIS_URL"])
      end

      def blank?(value = nil)
        !present?(value)
      end

      def list_name(params)
        "list-" + params.fetch(:list_name, params["list_name"])
      end

      def list_url(params)
        "/lists/#{params.fetch(:list_name, params['list_name'])}"
      end

      def list_title(params)
        "List: #{params[:list_name]}"
      end

      def users_by_list(name)
        redis
          .get(name)
          .split(",")
          .reject { |uuid| blank?(uuid) }
          .map { |uuid| JSON.parse(redis.get("user-" + uuid)) }
      end
    end

    get "/" do
      @title = "Home"
      erb :index
    end

    get "/about" do
      @title = "About this app"
      erb :about
    end

    get "/lists" do
      redirect list_url(params)
    end

    get "/lists/:list_name" do
      @title = list_title(params)

      @users = if redis.exists(list_name(params))
                 users_by_list(list_name(params))
               else
                 redis.set(list_name(params), "", ex: App::UNIT_TIME)
                 []
               end

      erb :list
    end

    get "/lists/:list_name/new" do
      @title = list_title(params)

      erb :new
    end

    get "/lists/:list_name/login" do
      erb :login
    end

    post "/lists/:list_name/login" do
      @user = users_by_list(list_name(params))
        .select { |user| user["email"] == params[:email] }[0]

      if @user["password"] == params[:password]
        @title = "Welcome, #{@user['name']}."
        erb :success
      else
        @error = true
        erb :login
      end
    end

    post "/lists/:list_name/?" do
      if present?(params[:email]) && present?(params[:password])
        if redis.exists(list_name(params))
          user_uuid = SecureRandom.uuid

          redis
            .set(
              "user-" + user_uuid,
              JSON.dump(params.merge("uuid" => user_uuid)),
              ex: App::UNIT_TIME + App::TEN_MIN
            )

          redis.append(list_name(params), ",#{user_uuid}")
        else
          redis.set(list_name(params), "", ex: App::UNIT_TIME)
        end

        redirect list_url(params)
      else
        @title = list_title(params)
        @error = true

        erb :new
      end
    end

    get "/users/:user_uuid/edit" do
      if redis.exists("user-" + params[:user_uuid])
        user = JSON.parse(redis.get("user-" + params[:user_uuid]))

        params[:name] = user["name"]
        params[:email] = user["email"]
        params[:list_name] = user["list_name"]

        erb :new
      else
        not_found
      end
    end

    post "/lists/:list_name/:user_uuid" do
      if redis.exists("user-" + params[:user_uuid])
        user = JSON.parse(redis.get("user-" + params[:user_uuid]))

        if present?(params[:email]) && present?(params[:password])
          redis.set("user-" + params[:user_uuid], JSON.dump(user.merge(params)))
          redirect list_url(params)
        else
          @error = true
          erb :new
        end
      else
        not_found
      end
    end

    get "/users/:user_uuid/delete" do
      if redis.exists("user-" + params[:user_uuid])
        user = JSON.parse(redis.get("user-" + params[:user_uuid]))
        list_content = redis.get(list_name(user))
        redis.set(list_name(user), list_content.gsub(user["uuid"], ""))
        redis.del("user-" + user["uuid"])

        redirect list_url(user)
      else
        not_found
      end
    end
  end
end
