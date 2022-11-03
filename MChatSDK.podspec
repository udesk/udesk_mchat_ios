#
#  Be sure to run `pod spec lint UdeskUniMPSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "MChatSDK"
  spec.version      = "2.0.4"
  spec.summary      = "This is Pod for MChatSDK."
  spec.description  = <<-DESC
  Uesk 多商户即时通信SDK，方便用户集成，欢迎访问www.udesk.com了解详情.
                   DESC

  spec.homepage     = "https://github.com/udesk/udesk_mchat_ios.git"
  spec.license      = "MIT"
  spec.author       = {'zhangshuangyi ' => 'zhangshuangyi@udesk.cn'}
  spec.platform = :ios, "9.0"
  spec.source       = { :git => "https://github.com/udesk/udesk_mchat_ios.git", :tag => "#{spec.version}" }

  #spec.frameworks = 'AVFoundation', 'CoreTelephony', 'SystemConfiguration', 'MobileCoreServices', 'WebKit', 'MapKit','AssetsLibrary','ImageIO','Accelerate','MediaPlayer','Photos','CoreText', 'AVKit'
	#spec.libraries    = 'z', 'xml2', 'resolv', 'sqlite3'
	#spec.vendored_framework = 'UdeskMChat/MChatSDK/UdeskMChatSDK.framework'

  spec.pod_target_xcconfig =  { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }
  #spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.subspec 'SDK' do |ss|
    ss.frameworks = 'AVFoundation', 'CoreTelephony', 'SystemConfiguration', 'MobileCoreServices', 'WebKit', 'MapKit','AssetsLibrary','ImageIO','Accelerate','MediaPlayer','Photos','CoreText', 'AVKit'
    ss.vendored_framework = 'UdeskMChat/MChatSDK/UdeskMChatSDK.framework'
    ss.libraries    = 'z', 'xml2', 'resolv', 'sqlite3'
    ss.xcconfig     = {'OTHER_LDFLAGS' => '-ObjC',
                       'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2'}
  end
  
  spec.subspec 'UIKit' do |ss|
    ss.source_files = 'UdeskMChat/MChatSDK/UdeskMChatUIKit/**/*.{h,m}'
		ss.resource     = 'UdeskMChat/MChatSDK/UdeskMChatUIKit/Assets/UdeskMChatBundle.bundle'
    ss.dependency 'MChatSDK/SDK'
  end
  		
	spec.xcconfig     = {'OTHER_LDFLAGS' => '-ObjC',
                      	 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2'}
end
