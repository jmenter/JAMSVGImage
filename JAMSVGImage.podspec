Pod::Spec.new do |s|
  s.name         = "JAMSVGImage"
  s.version      = "1.6.0"
  s.summary      = "An easy way to display resolution-independent SVG image graphics in iOS."

  s.description  = <<-DESC
                   JAMSVGImage is used to parse and display SVG image graphics in iOS. SVG images are resolution independent so they look good at any size and don't require @2x or @3x versions. The JAMSVGImageView is IBDesignable and IBInspectable so you can see your SVGs right in Interface Builder.
                   DESC
  s.homepage     = "https://github.com/jmenter/JAMSVGImage"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Jeff Menter" => "jmenter@gmail.com" }
  s.social_media_url = "http://twitter.com/jmenter"
  s.platform     = :ios, '6.0'
  s.tvos.deployment_target = '9.0'
  s.source       = { :git => "https://github.com/jmenter/JAMSVGImage.git", :tag => s.version.to_s }
  s.source_files  = 'Classes', 'Classes/**/*.{h,m}'
  s.requires_arc = true
  s.libraries    = 'z'

end
