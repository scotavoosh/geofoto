require 'mini_exiftool'
require 'gpx'

class Pictures

  attr_accessor :pictures

  def initialize(directory)
    @directory = directory
    @pictures = Array.new
    Dir.entries(directory).each do |entry|
      if entry =~ /.jpg$/i
        @pictures << entry
      end
    end
    puts "Found #{@pictures.length} pictures in #{directory}"
    @i = 0
  end

  def next
    i += 1
    @pictures[i - 1]
  end
end

gpx_filename = nil
Dir.entries(Dir.pwd).each do |entry|
  if entry =~ /.gpx$/
    gpx_filename = entry
    puts "Found GPX track file: #{entry}"
    break
  end
end
gpx = GPX::GPXFile.new(:gpx_file => gpx_filename)

time_offset = 20

pics = Pictures.new(Dir.pwd)

pics.pictures.each do |pic_file|
  diff = 999999;
  pic = MiniExiftool.new(pic_file)
  p = nil
  gpx.tracks.each do |track|
    track.segments.each do |segment|
      segment.points.each do |point|
        this_diff = (point.time - pic.dateTimeOriginal + time_offset).abs
        if this_diff < diff
          diff = this_diff
          p = point
        end
      end
    end
  end
  
  pic.gpslatitude = p.lat
  pic.gpslatituderef = (p.lat > 0) ? "N" : "S"
  pic.gpslongitude = p.lon
  pic.gpslongituderef = (p.lon > 0) ? "E" : "W"
  pic.gpsaltitude = p.elevation
  pic.gpsaltituderef = (p.elevation > 0) ? 0 : 1
  t = p.time.getgm
  pic.gpsdatestamp = t.strftime("%Y:%d:%m")
  pic.gpstimestamp = t.strftime("%H:%M:%S")
  pic.save
  puts "#{pic.filename} was taken at (#{p.lat}, #{p.lon}) written with lat: #{pic.gpslatitude pic.gpslatituderef} long:#{pic.gpslongitude pic.gpslongituderef} elev:#{pic.gpsaltitude} m (#{pic.gpsaltituderef}) date:#{pic.gpsdatestamp} time:#{pic.gpstimestamp}"
end