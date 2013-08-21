#!/usr/bin/env ruby
require 'viddl-rb'
require 'youtube_it'
require 'id3_tags'

DL_PATH = File.join(File.dirname(__FILE__),'download/')

client = YouTubeIt::Client.new

urls = ['http://www.youtube.com/watch?v=bHiV7sLVuSw', 'http://www.youtube.com/watch?v=i78U3VEAwK8' ]

urls.each do |url|

  #Video Title
  title = client.video_by(url).title
  title_without_spaces = title.split(' ').join('')

  #Cover Art
  thumbs = client.video_by(url).thumbnails
  thumbs.each {|thumb| @thumbhd = thumb.url if thumb.name == 'hqdefault'}
  cover_art_name = "#{title_without_spaces}.jpg"
  system("curl #{@thumbhd} > #{cover_art_name}")

  #Retrieving video and audio
  system("viddl-rb #{url} --extract-audio")
  file_name_and_ext = ViddlRb.get_names(url).first.to_s
  file_name_without_ext = file_name_and_ext.split('.').first
  file_name_and_m4a_ext = "#{file_name_without_ext}.m4a"
  system("ls #{file_name_and_m4a_ext}")
  
  #Adding title tags and cover_art
  tags = Id3Tags.read_tags_from(file_name_and_m4a_ext)
  tags[:title] = title
  tags[:cover_art][:mime_type] = "image/jpeg"
  tags[:cover_art][:data] = File.read(cover_art_name)
  
  Id3Tags.write_tags_to(file_name_and_m4a_ext, tags)
  
  #Deleting unecessary files
  system("rm -rf #{file_name_and_ext}")
  system("rm -rf #{cover_art_name}")

  #Moving audio files to /download
  system("mv #{file_name_and_m4a_ext} #{DL_PATH}")

end
