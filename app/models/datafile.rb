class Datafile < ActiveRecord::Base

def self.savezip(upload)
    name =  upload['zip_file'].original_filename
    directory = "public/zipfiles"
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(upload['zip_file'].read) }
	return name
end

def self.saveimage(upload, directory)
  name =  upload.original_filename
  # create the file path
  path = File.join(directory, name)
  # write the file
  File.open(path, "wb") { |f| f.write(upload.read) }
return name
end

end
