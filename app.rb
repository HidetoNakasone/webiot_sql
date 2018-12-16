
require "sinatra"
require "sinatra/reloader"
require "mysql2"
require "mysql2-cs-bind"

before do
  headers 'Access-Control-Allow-Origin' => '*'
  headers 'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept'
end

enable :sessions

# ======================

client = Mysql2::Client.new(
  :host => "localhost",
  :username => "root",
  :password => "root",
  :database => "webiot2018"
)

# ======================

def time_con(time_info)
  if time_info > Time.now - 60
    # 1分 以内
    "#{(Time.now - time_info).floor}秒前"
  elsif time_info > Time.now - (60*60)
    # 1時間 以内
    "#{((Time.now - time_info)/(60)).floor}分前"
  elsif time_info > Time.now - (24*60*60)
    # 24時間 以内
    "#{((Time.now - time_info)/(60*60)).floor}時間前"
  elsif time_info > Time.now - (30*24*60*60)
    # 1月 以内
    "#{((Time.now - time_info)/(24*60*60)).floor}日前"
  elsif time_info > Time.now - (365*24*60*60)
    # 1年 以内
    "#{((Time.now - time_info)/(30*24*60*60)).floor}ヶ月前"
  else
    # 1年 以上
    "#{((Time.now - time_info)/(365*24*60*60)).floor}年前"
  end
end

# ======================

get '/set_msg/:msg' do
  client.xquery("insert into posts values (NULL, ?, ?);", params["msg"], DateTime.now)

  # デフォルト
  json = {msg: params[:msg]}

  # 音声によって、処理を変えてる
  get = params["msg"]

  if get == "こんにちは" || get == "こんにちわ"
    json["msg"] = "ようこそ。私は ちょいすま と言います。よろしくね。"
  end

  # if get == "管理ログインルート"
  #   json["msg"] = "適正ユーザーです。管理者モードです。"
  # end


  # == 注文する ==

  if get.include?("をお願い")
    menu_name = get
    menu_name.slice!("をお願い")

    res_kane = client.xquery("select * from menus where name = ?;", menu_name).first['kane']
    res = client.xquery("insert into ate values (null, ?, ?);", menu_name, res_kane)
    json["msg"] = "分かりました。" + menu_name + "を注文しました。"
  end

  if get.include?("お願い")
    menu_name = get
    menu_name.slice!("お願い")

    res_kane = client.xquery("select * from menus where name = ?;", menu_name).first['kane']
    res = client.xquery("insert into ate values (null, ?, ?);", menu_name, res_kane)
    json["msg"] = "分かりました。" + menu_name + "を注文しました。"
  end

  # == 注文する ==



  # == 値段に関して ==
  if get.include?("の値段を教えて")
    menu_name = get
    menu_name.slice!("の値段を教えて")

    res = client.xquery("select * from menus where name = ?;", menu_name).first['kane']
    json["msg"] = "値段は" + res.to_s + "円だよ。"

  end

  if get.include?("の値段教えて")
    menu_name = get
    menu_name.slice!("の値段教えて")

    res = client.xquery("select * from menus where name = ?;", menu_name).first['kane']
    json["msg"] = "値段は" + res.to_s + "円だよ。"

  end

  if get.include?("いくら")
    menu_name = get
    menu_name.slice!("いくら")

    res = client.xquery("select * from menus where name = ?;", menu_name).first['kane']
    json["msg"] = "値段は" + res.to_s + "円だよ。"

  end

  if get.include?("の値段いくら")
    menu_name = get
    menu_name.slice!("の値段いくら")

    res = client.xquery("select * from menus where name = ?;", menu_name).first['kane']
    json["msg"] = "値段は" + res.to_s + "円だよ。"

  end
  # == 値段に関して ==

  # == 合計に関して ==
  if get == "合計金額を教えて"
    sum = client.xquery("select sum(kane) from ate;").first['sum(kane)']
    json["msg"] = "合計は" + sum.to_s + "円になります。"
  end
  # == 合計に関して ==

  json.to_json
end

# ======================

get '/get_msg' do
  content_type :json
  data = {}
  client.xquery("SELECT * FROM posts;").each do |row|
    data[row['id']] = {id: "number", msg: row["msg"], dateinfo: time_con(row['uptime'])}
  end
  data.to_json
end















get '/dev' do
  "dev"
end
