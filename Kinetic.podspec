
Pod::Spec.new do |s|

  s.name             = "Kinetic"
  s.version          = "1.1.2"
  s.summary          = "A super-flexible tweening library for iOS in Swift inspired by GSAP."

  s.description      = <<-DESC
  						A flexible animation library written in Swift with features and usage very similar to Greensock's GSAP. Perform basic, grouped, sequential and staggered animations to achieve any type of animation, from the most basic to more complex. Supports both individual tweens and full-featured timelines to more easily create and control complex animations for multiple objects.
                       DESC

  s.homepage         = "https://github.com/u10int/Kinetic"
  s.screenshots     = "https://github.com/u10int/Kinetic/raw/master/Example/screenshots/kinetic-timeline-grouped.gif", "https://github.com/u10int/Kinetic/raw/master/Example/screenshots/kinetic-timeline-staggered.gif"
  s.license          = 'MIT'
  s.author           = { "Nicholas Shipes" => "nshipes@urban10.com" }
  s.source           = { :git => "https://github.com/u10int/Kinetic.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/u10int'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.frameworks = 'UIKit'

end
