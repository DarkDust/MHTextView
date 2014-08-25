
Pod::Spec.new do |s|

  s.name         = "MHTextView"
  s.version      = "0.0.3"
  s.summary      = "A custom text view which supports multi-column layouts and exclusion paths."

  s.description  = <<-DESC
    A versatile text view that features:
    
    * Custom layouts.
    * Custom justify that doesn't "stretch" words unless necessary.
    * Ellipsis on last line.
    * Top-to-bottom text destribution for multi column layouts.
    DESC

  s.homepage     = "http://github.com/DarkDust/MHTextView"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = { :type => "BSD", :file => "LICENSE" }
  s.author       = { "Marc Haisenko" => "marc@darkdust.net" }
  s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/DarkDust/MHTextView.git", :tag => "0.0.3" }

  s.source_files  = "MHTextView"
  s.private_header_files = "MHTextView/*+*.h"
  # s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"

  s.requires_arc = true

end
