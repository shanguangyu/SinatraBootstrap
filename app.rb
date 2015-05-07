
require 'sinatra'
require 'sqlite3'
require 'mysql2'
require 'sequel'
require 'json'

DB = Sequel.connect(:adapter => 'mysql2', :database=>'snp', :user=>'root', :password=>'')

items = DB[:catalog]
puts "Item count: #{items.count}"
configure do
 DB = Sequel.connect(:adapter => 'mysql2', :database=>'snp', :user=>'root', :password=>'')
 class Contact < Sequel::Model(:catalog)
 end
end

get '/' do 
  erb :index
end

before do
  @contacts = Contact.all
end

post '/search' do
  @snp_id_list = params['snp_id'].lines.collect {|line| line.strip()}
  @results = DB[:catalog].where(:snpID => @snp_id_list).all

  erb :search_result

end

get '/details/:id' do

  @result = params[:result]
  @split_str = @result.lines.collect{|line| line.split(':')}[0]


  @motifpwm = @split_str[10].lines.collect{|line| line.split(',')}[0]
  @motifstrand = @split_str[11].lines.collect{|line| line.split(',')}[0]
  @motif_lists = @motifpwm.zip(@motifstrand)


  erb :details_result
end

post '/upload' do
    content_type 'application/json', :charset => 'utf-8' if request.xhr?
    
    file_hash = params[:file]
    save_path = File.join settings.uploads, file_hash[:filename]
    File.open(save_path, 'wb') { |f| f.write file_hash[:tempfile].read }
    
    # should allways return json
    file_hash.to_json
end

# post '/details/:id' do
#   @id = params[:snp_id_list]

#   erb :details_result

# end







