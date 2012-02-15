class ChameleonsController < ApplicationController
require 'css_parser'
include CssParser
protect_from_forgery :except => :imagechange
def index
end

def uploadfiles
  #upload zip file
	post = Datafile.savezip(params[:upload])
	if post != nil
		zip_file_ext = post.split(".") # get the file extension
	  #check if the file uploaded is a zip file
		if zip_file_ext[1] == "zip"
		  #create a directory for each user
			o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  
			@randstring  =  (0..5).map{ o[rand(o.length)]  }.join;
			@directory_name = Dir::pwd + "/" + "public" + "/" + "archives" + "/" + "#{@randstring}"
			unless FileTest::directory?(@directory_name)
				Dir::mkdir(@directory_name)
			end
				
			#put the uploaded zip file to zipfiles directory
			Zip::ZipFile.open("#{Rails.root}/public/zipfiles/#{post}") do |zip_file|
				zip_file.each do |f|
				  #extracts zip file
					f_path = File.join("#{@directory_name}/", f.name)
					FileUtils.mkdir_p(File.dirname(f_path))
					zip_file.extract(f, f_path) unless File.exist?(f_path) 
				end
			end

			@filenames = []
			@folderfilenames = []
			@folder2filenames = []
			@folders = []
			@folders2 = []
			@htmlfiles = []
			@cssfiles = []
			i = 0
			folderctr = 0
			htmlctr = 0
			cssctr = 0
			folderctr2 = 0

			#read all files in archives folder
			files_dir = Dir.glob("#{@directory_name}/*")
			for files in files_dir
			  if i < files_dir.size.to_i
				  #put all filenames in the filenames array
					@filenames[i] = files.gsub("#{@directory_name}/","")
				  #get all file extensions of the files and save html,css and folders in an array	
					file_ext = @filenames[i].split(".")
					if file_ext[1] == nil
						@folders[folderctr] =  files
						folderctr += 1
					elsif	file_ext[1] == "html"
						@htmlfiles[htmlctr] =  @filenames[i]
						htmlctr += 1
						session[:htmlpath] = "#{@directory_name}/"
					elsif	file_ext[1] == "css"
						@cssfiles[cssctr] =  @filenames[i]
						cssctr += 1
						session[:csspath] = "#{@directory_name}/"
					end
					i += 1
				end
      end

			#session the html and css files
			session[:htmlfiles] = @htmlfiles
			session[:cssfiles] = @cssfiles	

			#check if all files where extracted on the archives folder
			if @htmlfiles.blank? != true && @cssfiles.blank? != true
			  flash[:notice] = "ZipFile Successfully Uploaded."
				redirect_to(:action => 'choosefiletocustomize')
			else
		    if @folders.blank? != true
				  #check for the folders inside the zipfile
					x = 0
					i = 0
					while x < @folders.size
					  #read all files in archives folder
						files_dir = Dir.glob("#{@folders[x]}/*")
						for files in files_dir
						  #put all filenames in the filenames array
							@folderfilenames[i] = files.gsub("#{@folders[x]}/","")
							#get all file extensions of the files and save html,css and folders in an array	
							file_ext = @folderfilenames[i].split(".")
							if file_ext[1] == nil
								@folders2[folderctr2] =  files
								folderctr2 += 1
							elsif	file_ext[1] == "html"
								@htmlfiles[htmlctr] =  @folderfilenames[i]
								htmlctr += 1
								session[:htmlpath] = "#{@folders[x]}/"
							elsif	file_ext[1] == "css"
								@cssfiles[cssctr] =  @folderfilenames[i]
								cssctr += 1
								session[:csspath] = "#{@folders[x]}/"
							end
							i += 1
						end
					 x += 1
					end
					
			    #session the html and css files
			    session[:htmlfiles] = @htmlfiles
			    session[:cssfiles] = @cssfiles
			
          #check if all files inside the archives folder
			    if @htmlfiles.blank? != true && @cssfiles.blank? != true
			      flash[:notice] = "ZipFile Successfully Uploaded."
				    redirect_to(:action => 'choosefiletocustomize')
			    else								
			      if @folders2.blank? != true
			        #check for the folders inside the zipfile
				      x = 0
				      i = 0
				      while x < @folders2.size
				        #read all files in archives folder
					      files_dir = Dir.glob("#{@folders2[x]}/*")
					      for files in files_dir
						      #put all filenames in the filenames array
							    @folder2filenames[i] = files.gsub("#{@folders2[x]}/","")
							    #get all file extensions of the files and save html,css and folders in an array	
							    file_ext = @folder2filenames[i].split(".")
							    if	file_ext[1] == "html"
							      @htmlfiles[htmlctr] =  @folder2filenames[i]
								    htmlctr += 1
								    session[:csspath] = "#{@folders2[x]}/"
						      elsif	file_ext[1] == "css"
								    @cssfiles[cssctr] =  @folder2filenames[i]
								    cssctr += 1
							      session[:csspath] = "#{@folders2[x]}/"
							    end			
							    i += 1
					      end
				        x += 1
				    end
				
				#session the html and css files
				session[:htmlfiles] = @htmlfiles
				session[:cssfiles] = @cssfiles	

				flash[:notice] = "ZipFile Successfully Uploaded."
				redirect_to(:action => 'choosefiletocustomize')

			else												
			  flash[:notice] = "There is no HTML or CSS File in the ZipFile."
				render("index")
			end
			    end

				else
				  flash[:notice] = "There is no HTML or CSS File in the ZipFile."
					render("index")
				end
		  end		
			else
				flash[:notice] = "Uploaded file is not a ZipFile."
				render("index")
			end
	else	
		flash[:notice] = "Error Uploading ZipFile."
		render("index")
  end
end

def choosefiletocustomize

#get the filename of html and css from session
	@htmlfiles = session[:htmlfiles]

end

def customize

#get the filename to be edited
	@filetoedit = params[:htmlform][:filehtm]
	@cssfiles = session[:cssfiles]
	@htmlpath = session[:htmlpath] 
	@csspath = session[:csspath]

#check if the HTML file is empty	
	if !File.zero?(@htmlpath.to_s + "#{@filetoedit}")

	#copy jquery files to the htmlfile to edit folder
		FileUtils.cp "#{Rails.root}/public/jquery/jquery.js", @htmlpath.to_s
		FileUtils.cp "#{Rails.root}/public/jquery/jquery.dimensions.js", @htmlpath.to_s
		FileUtils.cp "#{Rails.root}/public/jquery/jquery-1.6.4.js", @htmlpath.to_s

	#open the html file		
		doc = Nokogiri::HTML(open(@htmlpath.to_s + "#{@filetoedit}"))

	#get all the class and id from the html file
		@htmlid = []
		@htmlclass = []
		doc.search('@id').each { |x| @htmlid << x.value }
		doc.search('@class').each { |x| @htmlclass << x.value }

	#get all the stylesheets used in the html file
		 @csslist = []
		 doc.search('@href').each { |x| @csslist << x.value }

		@cssused = []
		cssusedctr = 0
		i = 0

		while i < @csslist.size
			if @csslist[i].include? ".css"
				@trimcssfolder = @csslist[i].split("/")
				@cssused[cssusedctr] = @trimcssfolder[@trimcssfolder.size - 1]
				cssusedctr += 1
			else
			end
			i += 1
		end

	#read all the stylesheets used
			i = 0
			@tempfilelist = []

			while i < @cssused.size
				parser = CssParser::Parser.new
				parser.load_file!(@csspath.to_s + "#{@cssused[i]}")

	#create a temporary file
				@tempfile = "temp" + i.to_s + ".css"
				@tempfilelist[i] = @tempfile
				f = File.new(@csspath.to_s + "#{@tempfile}","w")
				f.puts parser.zydgetallhexvalues
				f.close
				i += 1
			end

	#read all the tempfile and get the selector, property and value 
			i = 0
			@cssselector = []
			@cssproperty = []
			@cssvalue = []
			@tempcssvalue = []
			cssctr = 0

			while i < @tempfilelist.size
				if !File.zero?(@csspath.to_s + "#{@tempfilelist[i]}")
					myfile = File.read(@csspath.to_s + "#{@tempfilelist[i]}")
						@tempread = myfile.to_s
						@csslbl = @tempread.split("\n")
						x = 0
						while x < @csslbl.size
							#split the string by pipe
							@pipesplitter = @csslbl[x].split("|")
							#save the selector
							@cssselector[cssctr] = @pipesplitter[0]
							#strore the value of the other
							@colonsplitter = @pipesplitter[1].split(":")
							#save the property
							@cssproperty[cssctr] = @colonsplitter[0]
							#save the value
							@tempcssvalue[cssctr] = @colonsplitter[1].strip
							cssctr += 1
							x += 1
						end
						y = 0
						while y < @tempcssvalue.size
							@spacesplitter = @tempcssvalue[y].split(" ")
							z = 0
							while z < @spacesplitter.size
								if @spacesplitter[z].include? "#"
									@cssvalue[y] = @spacesplitter[z]
								end
								z += 1
							end
							y += 1
						end
					i += 1
				else
				end			
			end

			session[:cssselector] = @cssselector
			session[:cssproperty] = @cssproperty
			session[:cssvalue] = @cssvalue
	
			#combine all selector property
			combinedElements = []
			ccount = 0
			maxCount = @cssselector.count
			while ccount < maxCount
			  combinedElements << [@cssselector[ccount], @cssproperty[ccount], @cssvalue[ccount]]
			  ccount += 1
			end
			
			menu = '<ul>'
			indicator = 0
			combinedElements.each do |element|
			  menu += "<li>"
			  menu += element[0] + " " + element[1]
			  menu += "<input type='text' name='element#{indicator}' id='element#{indicator}' value='#{element[2].gsub('#', '')}' />"
		    menu +="</li>"
		    indicator += 1
			end
		  menu += '</ul>'
		  
		  #generate jquery code
		  jqueryCode = ''
		  combinedElements.each do |element|
		    jqueryCode += "$('#{element[0]}').css('#{element[1].gsub(' ', '')}', '#{element[2]}');\n"
		  end
		  
=begin
 jqueryBlur += "$('#element#{indicator}').blur(function(){ \n
    $('#{element[0]}').css('#{element[1].gsub(' ', '')}', $(this).val()); \n
  }); \n"
  
   \n
  .bind('keyup', function(){ \n
    alert(this.value); \n
    $('#{element[0]}').css('#{element[1].gsub(' ', '')}', this.value); \n
  	$(this).ColorPickerSetColor(this.value); \n
  })
=end		  
		  
		  #generate jquery code for colorpicker
		  indicator = 0
		  jqueryBlur = ""
		  combinedElements.each do |element|
		    jqueryBlur += "$('#element#{indicator}').ColorPicker({ \n
        	onSubmit: function(hsb, hex, rgb, el) { \n
        		$(el).val(hex); \n
        		$('#{element[0]}').css('#{element[1].gsub(' ', '')}', '#' + hex); \n
        		$('#{element[0]}').css('border', 'none');
        		$(el).ColorPickerHide(); \n
        	}, \n
        	onBeforeShow: function () { \n
        	  $('#{element[0]}').css('border', 'dotted 2px red');
        		$(this).ColorPickerSetColor(this.value); \n
        	}, \n
        	onChange : function (hsb, hex, rgb, el) { \n
        	  $('#{element[0]}').css('#{element[1].gsub(' ', '')}', '#' + hex); \n
        	  $('#element#{indicator}').val(hex);
        	},
        	onHide : function() { \n
        	  $('#{element[0]}').css('border', 'none');
        	}
        });"
		    indicator += 1
		  end
		  
			#create a copy of the html file to be edited
				@results = []
				@openhtml = File.open(@htmlpath.to_s + "#{@filetoedit}","r").each { |line| @results << line }

			#append some codes
				@forthebody = "
				<script src='https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js'></script>
				<script src='https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js'></script>
				<script src='/jquery/colorpicker/js/colorpicker.js'></script>
        <script>
						$(function() {
            		$( '#floatMenu').draggable({containment : 'parent'});
            		#{jqueryCode}
            		#{jqueryBlur}
            		var currentElement;
            		$('img').click(function(){ \n
            		  currentElement = $(this); \n
            		  $('#browse').trigger('click'); \n
            		}); \n
            		
            		$('#browse').change(function (){  \n
                   $('#upload').trigger('click'); \n   
                }); \n
                
                $('#uploadForm').submit(function() { \n
                  $.post('chameloens/imagechange' + '?' + $(this).serialize(), \n
                            function(data){ \n
                              if(data.status = 'ok') { \n
                                currentElement.attr('src', data.path); \n
                              } \n
                            } \n
                        ); \n
                    return false; \n
                }); \n
            });
				</script>
				<div id='floatMenu' style='border-color:black;'>
								#{menu}
				</div>\n
				<iframe name='submit-iframe' style='display: none;'></iframe>\n
				<div style='visibility:hidden'>\n
				  <form id='uploadForm' name='uploadForm' action='/chameleons/imagechange' enctype='multipart/form-data' method='post' target='submit-iframe'>
				    <input type='hidden' value='' />
				    <input id='browse' name='upload' type='file' />
				    <input id='upload' type='submit' value='upload' />
				  </form>
				</div>
				"

				@forthehead = "
				<link rel='stylesheet' media='screen' type='text/css' href='/jquery/colorpicker/css/colorpicker.css' />
				<style type = 'text/css'>
						#floatMenu { 
							top:50px;  
							position: absolute;  
							width:400px;  
						} 
						/*
						#floatMenu ul {  
							margin-bottom:20px;  
						}  
						#floatMenu ul li a {  
							display:block;  
							border:1px solid #999;  
							border-left:6px solid #999;  
							text-decoration:none;  
							color:#ccc;  
							padding:5px 5px 5px 25px;  
						}
						*/
						</style>"

				j = 0
				while j < @results.size
					if @results[j].strip == "<head>"
						@results[j] =  @results[j] + @forthehead 
					elsif @results[j].strip == "</body>"
						@results[j] =  @forthebody + @results[j]
					else
					end
					j += 1
				end

			#===================	
				@temphtmlfile = "temp" + @filetoedit
				f = File.new(@htmlpath.to_s + "#{@temphtmlfile}","w")
				f.puts @results
				f.close
	else
		flash[:notice] = "#{@filetoedit} is empty."
		render('choosefiletocustomize')
	end
	@previewpath = "http://localhost:3000" + @htmlpath.gsub("#{Rails.root}/public", "").to_s + @temphtmlfile
	redirect_to(@previewpath)
end


  def imagechange
    # fetch the html direcoty
    directory = session[:htmlpath]
    tempFolder = "temp"
    tempPath = directory + tempFolder
    unless File.directory? tempPath
      Dir::mkdir(tempPath)
    end
    jsonResponse = {:status => "error"}
    post = Datafile.saveimage(params[:upload], tempPath)
	  if post != nil
	    jsonResponse = {:status => "ok", :path => tempPath + '/' + post}
	  end
	  render :json => jsonResponse
  end
  
  def iframeajax
  end
end